Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F98A6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 19:52:36 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf1so8890674pab.24
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 16:52:35 -0700 (PDT)
Date: Thu, 19 Sep 2013 09:52:28 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
Message-ID: <20130918235228.GG9901@dastard>
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
 <5239829F.4080601@t-online.de>
 <20130918203822.GA4330@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130918203822.GA4330@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

[my keyboard my be on the fritz - it's not typing what I'm thinking...]

On Thu, Sep 19, 2013 at 06:38:22AM +1000, Dave Chinner wrote:
> On Wed, Sep 18, 2013 at 12:38:23PM +0200, Knut Petersen wrote:
> > On 18.09.2013 11:10, Daniel Vetter wrote:
> > 
> > Just now I prepared a patch changing the same function in vmscan.c
> > >Also, this needs to be rebased to the new shrinker api in 3.12, I
> > >simply haven't rolled my trees forward yet.
> > 
> > Well, you should. Since commit 81e49f  shrinker->count_objects might be
> > set to SHRINK_STOP, causing shrink_slab_node() to complain loud and often:
> > 
> > [ 1908.234595] shrink_slab: i915_gem_inactive_scan+0x0/0x9c negative objects to delete nr=-xxxxxxxxx
> > 
> > The kernel emitted a few thousand log lines like the one quoted above during the
> > last few days on my system.
> > 
> > >diff --git a/mm/vmscan.c b/mm/vmscan.c
> > >index 2cff0d4..d81f6e0 100644
> > >--- a/mm/vmscan.c
> > >+++ b/mm/vmscan.c
> > >@@ -254,6 +254,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> > >  			total_scan = max_pass;
> > >  		}
> > >+		/* Always try to shrink a bit to make forward progress. */
> > >+		if (shrinker->evicts_to_page_lru)
> > >+			total_scan = max_t(long, total_scan, batch_size);
> > >+
> > At that place the error message is already emitted.
> > >  		/*
> > >  		 * We need to avoid excessive windup on filesystem shrinkers
> > >  		 * due to large numbers of GFP_NOFS allocations causing the
> > 
> > Have a look at the attached patch. It fixes my problem with the erroneous/misleading
> > error messages, and I think it's right to just bail out early if SHRINK_STOP is found.
> > 
> > Do you agree ?
> 
> No, that's wrong. ->count_objects should never ass SHRINK_STOP.

						*pass

> Indeed, it should always return a count of objects in the cache,
> regardless of the context. 
> 
> SHRINK_STOP is for ->scan_objects to tell the shrinker it can make

							*can't

> any progress due to the context it is called in. This allows the
> shirnker to defer the work to another call in a different context.
> However, if ->count-objects doesn't return a count, the work that
> was supposed to be done cannot be deferred, and that is what

							 *why

> ->count_objects should always return the number of objects in the
> cache.

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
