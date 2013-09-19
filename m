Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2B01D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 03:32:36 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so9285270pad.2
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 00:32:35 -0700 (PDT)
Date: Thu, 19 Sep 2013 17:32:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
Message-ID: <20130919073225.GI9901@dastard>
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
 <5239829F.4080601@t-online.de>
 <20130918203822.GA4330@dastard>
 <CAKMK7uGR7HtMLgu2-tvfTm+W=_gndVJ7QPcf0okFcKX6Htd61Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGR7HtMLgu2-tvfTm+W=_gndVJ7QPcf0okFcKX6Htd61Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Knut Petersen <Knut_Petersen@t-online.de>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Sep 19, 2013 at 08:57:04AM +0200, Daniel Vetter wrote:
> On Wed, Sep 18, 2013 at 10:38 PM, Dave Chinner <david@fromorbit.com> wrote:
> > No, that's wrong. ->count_objects should never ass SHRINK_STOP.
> > Indeed, it should always return a count of objects in the cache,
> > regardless of the context.
> >
> > SHRINK_STOP is for ->scan_objects to tell the shrinker it can make
> > any progress due to the context it is called in. This allows the
> > shirnker to defer the work to another call in a different context.
> > However, if ->count-objects doesn't return a count, the work that
> > was supposed to be done cannot be deferred, and that is what
> > ->count_objects should always return the number of objects in the
> > cache.
> 
> So we should rework the locking in the drm/i915 shrinker to be able to
> always count objects? Thus far no one screamed yet that we're not
> really able to do that in all call contexts ...

It's not the end of the world if you count no objects. in an ideal
world, you keep a count of the object sizes on the LRU when you
add/remove the objects on the list, that way .count_objects doesn't
need to walk or lock anything, which is what things like the inode
and dentry caches do...

> 
> So should I revert 81e49f or will the early return 0; completely upset
> the core shrinker logic?

It looks to me like 81e49f changed the wrong function to return
SHRINK_STOP. It should have changed i915_gem_inactive_scan() to
return SHRINK_STOP when the locks could not be taken, not
i915_gem_inactive_count().

What should happen is this:

	max_pass = count_objects()
	if (max_pass == 0)
		/* skip to next shrinker */

	/* calculate total_scan from max_pass and previous leftovers */

	while (total_scan) {
		freed = scan_objects(batch_size)
		if (freed == SHRINK_STOP)
			break; /* can't make progress */
		total_scan -= batch_size;
	}

	/* save remaining total_scan for next pass */


i.e. SHRINK_STOP will abort the scan loop when nothing can be done.
Right now, if nothing can be done because the locks can't be taken,
the scan loop will continue running until total_scan reaches zero.
i.e. it does a whole lotta nothing.

So right now, I'd revert 81e49f and then convert
i915_gem_inactive_scan() to return SHRINK_STOP if it can't get
locks, and everything shoul dwork just fine...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
