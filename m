Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C10E36B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:56:22 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so6796987pbc.40
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 03:56:22 -0700 (PDT)
Received: by mail-la0-f41.google.com with SMTP id ec20so5459048lab.14
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 03:56:17 -0700 (PDT)
Date: Wed, 18 Sep 2013 12:56:31 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
Message-ID: <20130918105631.GS32145@phenom.ffwll.local>
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
 <5239829F.4080601@t-online.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5239829F.4080601@t-online.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Sep 18, 2013 at 12:38:23PM +0200, Knut Petersen wrote:
> On 18.09.2013 11:10, Daniel Vetter wrote:
> 
> Just now I prepared a patch changing the same function in vmscan.c
> >Also, this needs to be rebased to the new shrinker api in 3.12, I
> >simply haven't rolled my trees forward yet.
> 
> Well, you should. Since commit 81e49f  shrinker->count_objects might be
> set to SHRINK_STOP, causing shrink_slab_node() to complain loud and often:
> 
> [ 1908.234595] shrink_slab: i915_gem_inactive_scan+0x0/0x9c negative objects to delete nr=-xxxxxxxxx
> 
> The kernel emitted a few thousand log lines like the one quoted above during the
> last few days on my system.
> 
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index 2cff0d4..d81f6e0 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -254,6 +254,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >  			total_scan = max_pass;
> >  		}
> >+		/* Always try to shrink a bit to make forward progress. */
> >+		if (shrinker->evicts_to_page_lru)
> >+			total_scan = max_t(long, total_scan, batch_size);
> >+
> At that place the error message is already emitted.
> >  		/*
> >  		 * We need to avoid excessive windup on filesystem shrinkers
> >  		 * due to large numbers of GFP_NOFS allocations causing the
> 
> Have a look at the attached patch. It fixes my problem with the erroneous/misleading
> error messages, and I think it's right to just bail out early if SHRINK_STOP is found.
> 
> Do you agree ?

Looking at the patch which introduced these error message for you, which
changed the ->count_objects return value from 0 to SHRINK_STOP your patch
below to treat 0 and SHRINK_STOP equally simply reverts the functional
change.

I don't think that's the intention behind SHRINK_STOP. But if it's the
right think to do we better revert the offending commit directly. And
since I lack clue I think that's a call for core mm guys to make.
-Daniel
> 
> cu,
>  Knut
> 

> From 75ae570ce7b0bb6b40c76beb18fc075e9af3127a Mon Sep 17 00:00:00 2001
> From: Knut Petersen <Knut_Petersen@t-online.de>
> Date: Wed, 18 Sep 2013 12:06:33 +0200
> Subject: [PATCH] mm: respect SHRINK_STOP in shrink_slab_node()
> 
> Since commit 81e49f811404f428a9d9a63295a0c267e802fa12
> i915_gem_inactive_count() might return SHRINK_STOP.
> 
> Unfortunately SHRINK_STOP is not handled propperly in
> shrink_slab_node(), causing a system log cluttered with
> kernel error messages complaining about "negative objects
> to delete".
> 
> I think the proper way of handling SHRINK_STOP is obvious,
> we should obey ;-)
> 
> Signed-off-by: Knut Petersen <Knut_Petersen@t-online.de>
> ---
>  mm/vmscan.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8ed1b77..b1e6f0d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -244,6 +244,8 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
>  	max_pass = shrinker->count_objects(shrinker, shrinkctl);
>  	if (max_pass == 0)
>  		return 0;
> +	if (max_pass == SHRINK_STOP)
> +		return 0;
>  
>  	/*
>  	 * copy the current shrinker scan count into a local variable
> -- 
> 1.8.1.4
> 


-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
