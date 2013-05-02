Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8A11E6B0251
	for <linux-mm@kvack.org>; Thu,  2 May 2013 05:31:58 -0400 (EDT)
Date: Thu, 2 May 2013 10:31:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130502093150.GI11497@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-18-git-send-email-glommer@openvz.org>
 <20130430215355.GN6415@suse.de>
 <CAKMK7uEkZ8nYZgB4pGiqJx+PAt6xL10FN3R5nFRgCAHVvPW8iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAKMK7uEkZ8nYZgB4pGiqJx+PAt6xL10FN3R5nFRgCAHVvPW8iQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Kent Overstreet <koverstreet@google.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Wed, May 01, 2013 at 05:26:38PM +0200, Daniel Vetter wrote:
> On Tue, Apr 30, 2013 at 11:53 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
> >> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> >> index 6be940e..2e44733 100644
> >> --- a/drivers/gpu/drm/i915/i915_gem.c
> >> +++ b/drivers/gpu/drm/i915/i915_gem.c
> >> @@ -1729,15 +1731,20 @@ i915_gem_purge(struct drm_i915_private *dev_priv, long target)
> >>       return __i915_gem_shrink(dev_priv, target, true);
> >>  }
> >>
> >> -static void
> >> +static long
> >>  i915_gem_shrink_all(struct drm_i915_private *dev_priv)
> >>  {
> >>       struct drm_i915_gem_object *obj, *next;
> >> +     long freed = 0;
> >>
> >> -     i915_gem_evict_everything(dev_priv->dev);
> >> +     freed += i915_gem_evict_everything(dev_priv->dev);
> >>
> >> -     list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list)
> >> +     list_for_each_entry_safe(obj, next, &dev_priv->mm.unbound_list, gtt_list) {
> >> +             if (obj->pages_pin_count == 0)
> >> +                     freed += obj->base.size >> PAGE_SHIFT;
> >>               i915_gem_object_put_pages(obj);
> >> +     }
> >> +     return freed;
> >>  }
> >>
> >
> > i915_gem_shrink_all is a sledge hammer! That i915_gem_evict_everything
> > looks like it switches to every GPU context, waits for everything to
> > complete and then retire it all. I don't know the details of what it's
> > doing but it's sounds very heavy handed and is called from shrinker
> > context if it fails to shrink 128 objects. Those shrinker callsback can
> > be very frequently called even from kswapd.
> 
> i915_gem_shrink_all is our escape hatch, we only use it as a
> last-ditch effort when all else fails. Imo there's no point in passing
> the number of freed objects around from it since it really never
> should get called (as long as we don't get called with more objects to
> shrink than our counter counted beforehand at least).

The shrinkers can be called quite frequently so I'm concerned that you do
get called with "more objects to shrink than our counter counted beforehand"
if it's called from direct reclaim and kswapd at the same time. kswapd
can be a very frequent caller via

kswapd
  balance_pgdat
    shrink_slab
      i915_gem_inactive_shrink
        i915_gem_shrink_all

That can be active just because there is a streaming reader of a video
file that is larger than physical memory. If there is enough additional
pressure then direct reclaimers and kswapd can both call the shrinker.
The mutex on its own is not enough for them both to read "500 objects"
and then both trying to free 500 objects each with the second stalling
in i915_gem_shrink_all.

Unfortunately the laptop I'm using does not have an i915 card to check
how easy this is to trigger but I suspect filling memory with dd,
starting a video of some sort and writing to a USB stick may be enough
to trigger it.

> >> @@ -4472,3 +4470,36 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
> >>               mutex_unlock(&dev->struct_mutex);
> >>       return cnt;
> >>  }
> >> +static long
> >> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
> >> +{
> >> +     struct drm_i915_private *dev_priv =
> >> +             container_of(shrinker,
> >> +                          struct drm_i915_private,
> >> +                          mm.inactive_shrinker);
> >> +     struct drm_device *dev = dev_priv->dev;
> >> +     int nr_to_scan = sc->nr_to_scan;
> >> +     long freed;
> >> +     bool unlock = true;
> >> +
> >> +     if (!mutex_trylock(&dev->struct_mutex)) {
> >> +             if (!mutex_is_locked_by(&dev->struct_mutex, current))
> >> +                     return 0;
> >> +
> >
> > return -1 if it's about preventing potential deadlocks?
> >

In Glauber's series, shrinkers are split into count and scan callbacks.
If a scan returns -1, it indicates to vmscan.c that the slab could not
be shrunk at this time be it due to a deadlock risk or because the necessary
locks could not be acquired at this time.

> >> +             if (dev_priv->mm.shrinker_no_lock_stealing)
> >> +                     return 0;
> >> +
> >
> > same?
> 
> No idea. Aside, the aggressive shrinking with shrink_all and the lock
> stealing madness here are to paper our current "one lock for
> everything" approach we have for i915 gem stuff. We've papered over
> the worst offenders through lock-dropping tricks while waiting, the
> lock stealing above plus aggressively calling shrink_all.
> 
> Still it's pretty trivial to (spuriously) OOM if you compete a gpu
> workload with something else. Real fix is per-object locking plus some
> watermark limits on how many pages are locked down this way, but
> that's long term (and currently stalling for the wait/wound mutexes
> from Maarten Lankhorst to get in).
> 

Hmm, that's unfortunate. Later in Glauber's series, he also hooks up
the vm_pressure for in-kernel notification which is a better indication
of pressure than a slab shrinker. Conceivably that could be used to call
shrink_all if the system is about to go OOM. This would only be necessary
if it can be shown that the shrinker currently calls i915_gem_shrink_all
and stalls the world too easily.

> >
> >> +             unlock = false;
> >> +     }
> >> +
> >> +     freed = i915_gem_purge(dev_priv, nr_to_scan);
> >> +     if (freed < nr_to_scan)
> >> +             freed += __i915_gem_shrink(dev_priv, nr_to_scan,
> >> +                                                     false);
> >> +     if (freed < nr_to_scan)
> >> +             freed += i915_gem_shrink_all(dev_priv);
> >> +
> >
> > Do we *really* want to call i915_gem_shrink_all from the slab shrinker?
> > Are there any bug reports where i915 rendering jitters in low memory
> > situations while shrinkers might be active? Maybe it's really fast.
> 
> It's terrible for interactivity in X, but we need it :( See above for
> how we plan to eventually fix this mess.
> 

Ok, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
