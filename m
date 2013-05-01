Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 07E3C6B018B
	for <linux-mm@kvack.org>; Wed,  1 May 2013 11:26:39 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id e11so2026086iej.16
        for <linux-mm@kvack.org>; Wed, 01 May 2013 08:26:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130430215355.GN6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
	<1367018367-11278-18-git-send-email-glommer@openvz.org>
	<20130430215355.GN6415@suse.de>
Date: Wed, 1 May 2013 17:26:38 +0200
Message-ID: <CAKMK7uEkZ8nYZgB4pGiqJx+PAt6xL10FN3R5nFRgCAHVvPW8iQ@mail.gmail.com>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan API
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Kent Overstreet <koverstreet@google.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Tue, Apr 30, 2013 at 11:53 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
>> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
>> index 6be940e..2e44733 100644
>> --- a/drivers/gpu/drm/i915/i915_gem.c
>> +++ b/drivers/gpu/drm/i915/i915_gem.c
>> @@ -1729,15 +1731,20 @@ i915_gem_purge(struct drm_i915_private *dev_priv, long target)
>>       return __i915_gem_shrink(dev_priv, target, true);
>>  }
>>
>> -static void
>> +static long
>>  i915_gem_shrink_all(struct drm_i915_private *dev_priv)
>>  {
>>       struct drm_i915_gem_object *obj, *next;
>> +     long freed = 0;
>>
>> -     i915_gem_evict_everything(dev_priv->dev);
>> +     freed += i915_gem_evict_everything(dev_priv->dev);
>>
>> -     list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list)
>> +     list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list) {
>> +             if (obj->pages_pin_count == 0)
>> +                     freed += obj->base.size >> PAGE_SHIFT;
>>               i915_gem_object_put_pages(obj);
>> +     }
>> +     return freed;
>>  }
>>
>
> i915_gem_shrink_all is a sledge hammer! That i915_gem_evict_everything
> looks like it switches to every GPU context, waits for everything to
> complete and then retire it all. I don't know the details of what it's
> doing but it's sounds very heavy handed and is called from shrinker
> context if it fails to shrink 128 objects. Those shrinker callsback can
> be very frequently called even from kswapd.

i915_gem_shrink_all is our escape hatch, we only use it as a
last-ditch effort when all else fails. Imo there's no point in passing
the number of freed objects around from it since it really never
should get called (as long as we don't get called with more objects to
shrink than our counter counted beforehand at least). Also, the above
hunk is broken since i915_gem_evict_everything only unbinds object
from the gpu address space and puts them onto the unbound list, i.e.
those objects will be double-counted.

>>  static int
>> @@ -4205,7 +4212,8 @@ i915_gem_load(struct drm_device *dev)
>>
>>       dev_priv->mm.interruptible = true;
>>
>> -     dev_priv->mm.inactive_shrinker.shrink = i915_gem_inactive_shrink;
>> +     dev_priv->mm.inactive_shrinker.scan_objects = i915_gem_inactive_scan;
>> +     dev_priv->mm.inactive_shrinker.count_objects = i915_gem_inactive_count;
>>       dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
>>       register_shrinker(&dev_priv->mm.inactive_shrinker);
>>  }
>> @@ -4428,8 +4436,8 @@ static bool mutex_is_locked_by(struct mutex *mutex, struct task_struct *task)
>>  #endif
>>  }
>>
>> -static int
>> -i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>> +static long
>> +i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
>>  {
>>       struct drm_i915_private *dev_priv =
>>               container_of(shrinker,
>> @@ -4437,9 +4445,8 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>>                            mm.inactive_shrinker);
>>       struct drm_device *dev = dev_priv->dev;
>>       struct drm_i915_gem_object *obj;
>> -     int nr_to_scan = sc->nr_to_scan;
>>       bool unlock = true;
>> -     int cnt;
>> +     long cnt;
>>
>>       if (!mutex_trylock(&dev->struct_mutex)) {
>>               if (!mutex_is_locked_by(&dev->struct_mutex, current))
>> @@ -4451,15 +4458,6 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>>               unlock = false;
>>       }
>>
>> -     if (nr_to_scan) {
>> -             nr_to_scan -= i915_gem_purge(dev_priv, nr_to_scan);
>> -             if (nr_to_scan > 0)
>> -                     nr_to_scan -= __i915_gem_shrink(dev_priv, nr_to_scan,
>> -                                                     false);
>> -             if (nr_to_scan > 0)
>> -                     i915_gem_shrink_all(dev_priv);
>> -     }
>> -
>>       cnt = 0;
>>       list_for_each_entry(obj, &dev_priv->mm.unbound_list, gtt_list)
>>               if (obj->pages_pin_count == 0)
>> @@ -4472,3 +4470,36 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>>               mutex_unlock(&dev->struct_mutex);
>>       return cnt;
>>  }
>> +static long
>> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
>> +{
>> +     struct drm_i915_private *dev_priv =
>> +             container_of(shrinker,
>> +                          struct drm_i915_private,
>> +                          mm.inactive_shrinker);
>> +     struct drm_device *dev = dev_priv->dev;
>> +     int nr_to_scan = sc->nr_to_scan;
>> +     long freed;
>> +     bool unlock = true;
>> +
>> +     if (!mutex_trylock(&dev->struct_mutex)) {
>> +             if (!mutex_is_locked_by(&dev->struct_mutex, current))
>> +                     return 0;
>> +
>
> return -1 if it's about preventing potential deadlocks?
>
>> +             if (dev_priv->mm.shrinker_no_lock_stealing)
>> +                     return 0;
>> +
>
> same?

No idea. Aside, the aggressive shrinking with shrink_all and the lock
stealing madness here are to paper our current "one lock for
everything" approach we have for i915 gem stuff. We've papered over
the worst offenders through lock-dropping tricks while waiting, the
lock stealing above plus aggressively calling shrink_all.

Still it's pretty trivial to (spuriously) OOM if you compete a gpu
workload with something else. Real fix is per-object locking plus some
watermark limits on how many pages are locked down this way, but
that's long term (and currently stalling for the wait/wound mutexes
from Maarten Lankhorst to get in).

>
>> +             unlock = false;
>> +     }
>> +
>> +     freed = i915_gem_purge(dev_priv, nr_to_scan);
>> +     if (freed < nr_to_scan)
>> +             freed += __i915_gem_shrink(dev_priv, nr_to_scan,
>> +                                                     false);
>> +     if (freed < nr_to_scan)
>> +             freed += i915_gem_shrink_all(dev_priv);
>> +
>
> Do we *really* want to call i915_gem_shrink_all from the slab shrinker?
> Are there any bug reports where i915 rendering jitters in low memory
> situations while shrinkers might be active? Maybe it's really fast.

It's terrible for interactivity in X, but we need it :( See above for
how we plan to eventually fix this mess.

Cheers, Daniel
--
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
