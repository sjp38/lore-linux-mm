Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E88A6B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:46:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so6708022ith.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 21:46:31 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v3si20084194ita.98.2016.08.22.21.46.29
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 21:46:30 -0700 (PDT)
Date: Tue, 23 Aug 2016 13:52:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160823045245.GC17039@js1304-P5Q-DELUXE>
References: <20160822093249.GA14916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822093249.GA14916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 22, 2016 at 11:32:49AM +0200, Michal Hocko wrote:
> Hi, 
> there have been multiple reports [1][2][3][4][5] about pre-mature OOM
> killer invocations since 4.7 which contains oom detection rework. All of
> them were for order-2 (kernel stack) alloaction requests failing because
> of a high fragmentation and compaction failing to make any forward
> progress. While investigating this we have found out that the compaction
> just gives up too early. Vlastimil has been working on compaction
> improvement for quite some time and his series [6] is already sitting
> in mmotm tree. This already helps a lot because it drops some heuristics
> which are more aimed at lower latencies for high orders rather than
> reliability. Joonsoo has then identified further problem with too many
> blocks being marked as unmovable [7] and Vlastimil has prepared a patch
> on top of his series [8] which is also in the mmotm tree now.
> 
> That being said, the regression is real and should be fixed for 4.7
> stable users. [6][8] was reported to help and ooms are no longer
> reproducible. I know we are quite late (rc3) in 4.8 but I would vote
> for mergeing those patches and have them in 4.8. For 4.7 I would go
> with a partial revert of the detection rework for high order requests
> (see patch below). This patch is really trivial. If those compaction
> improvements are just too large for 4.8 then we can use the same patch
> as for 4.7 stable for now and revert it in 4.9 after compaction changes
> are merged.
> 
> Thoughts?
> 
> [1] http://lkml.kernel.org/r/20160731051121.GB307@x4
> [2] http://lkml.kernel.org/r/201608120901.41463.a.miskiewicz@gmail.com
> [3] http://lkml.kernel.org/r/20160801192620.GD31957@dhcp22.suse.cz
> [4] https://lists.opensuse.org/opensuse-kernel/2016-08/msg00021.html
> [5] https://bugzilla.opensuse.org/show_bug.cgi?id=994066
> [6] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
> [7] http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
> [8] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz
> 
> ---
> >From 899b738538de41295839dca2090a774bdd17acd2 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 22 Aug 2016 10:52:06 +0200
> Subject: [PATCH] mm, oom: prevent pre-mature OOM killer invocation for high
>  order request
> 
> There have been several reports about pre-mature OOM killer invocation
> in 4.7 kernel when order-2 allocation request (for the kernel stack)
> invoked OOM killer even during basic workloads (light IO or even kernel
> compile on some filesystems). In all reported cases the memory is
> fragmented and there are no order-2+ pages available. There is usually
> a large amount of slab memory (usually dentries/inodes) and further
> debugging has shown that there are way too many unmovable blocks which
> are skipped during the compaction. Multiple reporters have confirmed that
> the current linux-next which includes [1] and [2] helped and OOMs are
> not reproducible anymore. A simpler fix for the stable is to simply
> ignore the compaction feedback and retry as long as there is a reclaim
> progress for high order requests which we used to do before. We already
> do that for CONFING_COMPACTION=n so let's reuse the same code when
> compaction is enabled as well.

Hello, Michal.

I agree with partial revert but revert should be a different form.
Below change try to reuse should_compact_retry() version for
!CONFIG_COMPACTION but it turned out that it also causes regression in
Markus report [1].

Theoretical reason for this regression is that it would stop retry
even if there are enough lru pages. It only checks if freepage
excesses min watermark or not for retry decision. To prevent
pre-mature OOM killer, we need to keep allocation loop when there are
enough lru pages. So, logic should be something like that.

should_compact_retry()
{
        for_each_zone_zonelist_nodemask {
                available = zone_reclaimable_pages(zone);
                available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
                if (__zone_watermark_ok(zone, *0*, min_wmark_pages(zone),
                        ac_classzone_idx(ac), alloc_flags, available))
                        return true;

        }
}

I suggested it before and current situation looks like it is indeed
needed.

And, I still think that your OOM detection rework has some flaws.

1) It doesn't consider freeable objects that can be freed by shrink_slab().
There are many subsystems that cache many objects and they will be
freed by shrink_slab() interface. But, you don't account them when
making the OOM decision.

Think about following situation that we are trying to find order-2
freepage and some subsystem has order-2 freepage. It can be freed by
shrink_slab(). Your logic doesn't guarantee that shrink_slab() is
invoked to free this order-2 freepage in that subsystem. OOM would be
triggered when compaction fails even if there is a order-2 freeable
page. I think that if decision is made before whole lru list is
scanned and then shrink_slab() is invoked for whole freeable objects,
it would cause pre-mature OOM.

It seems that you already knows this issue [2].

2) 'OOM detection rework' depends on compaction too much. Compaction
algorithm is racy and has some limitation. It's failure doesn't mean we
are in OOM situation. Even if Vlastimil's patchset and mine is
applied, it is still possible that compaction scanner cannot find enough
freepage due to race condition and return pre-mature failure. To
reduce this race effect, I hope to give more chances to retry even if
full compaction is failed. We can remove this heuristic when we make
sure that compaction is stable enough.

As you know, I said these things several times but isn't accepted.
Please consider them more deeply at this time.

Thanks.

[1] http://lkml.kernel.org/r/20160731051121.GB307@x4
[2] https://bugzilla.opensuse.org/show_bug.cgi?id=994066


> 
> [1] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
> [2] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz
> 
> Fixes: 0a0337e0d1d1 ("mm, oom: rework oom detection")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 50 ++------------------------------------------------
>  1 file changed, 2 insertions(+), 48 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8b3e1341b754..6e354199151b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3254,53 +3254,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	return NULL;
>  }
>  
> -static inline bool
> -should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> -		     enum compact_result compact_result, enum migrate_mode *migrate_mode,
> -		     int compaction_retries)
> -{
> -	int max_retries = MAX_COMPACT_RETRIES;
> -
> -	if (!order)
> -		return false;
> -
> -	/*
> -	 * compaction considers all the zone as desperately out of memory
> -	 * so it doesn't really make much sense to retry except when the
> -	 * failure could be caused by weak migration mode.
> -	 */
> -	if (compaction_failed(compact_result)) {
> -		if (*migrate_mode == MIGRATE_ASYNC) {
> -			*migrate_mode = MIGRATE_SYNC_LIGHT;
> -			return true;
> -		}
> -		return false;
> -	}
> -
> -	/*
> -	 * make sure the compaction wasn't deferred or didn't bail out early
> -	 * due to locks contention before we declare that we should give up.
> -	 * But do not retry if the given zonelist is not suitable for
> -	 * compaction.
> -	 */
> -	if (compaction_withdrawn(compact_result))
> -		return compaction_zonelist_suitable(ac, order, alloc_flags);
> -
> -	/*
> -	 * !costly requests are much more important than __GFP_REPEAT
> -	 * costly ones because they are de facto nofail and invoke OOM
> -	 * killer to move on while costly can fail and users are ready
> -	 * to cope with that. 1/4 retries is rather arbitrary but we
> -	 * would need much more detailed feedback from compaction to
> -	 * make a better decision.
> -	 */
> -	if (order > PAGE_ALLOC_COSTLY_ORDER)
> -		max_retries /= 4;
> -	if (compaction_retries <= max_retries)
> -		return true;
> -
> -	return false;
> -}
>  #else
>  static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> @@ -3311,6 +3264,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	return NULL;
>  }
>  
> +#endif /* CONFIG_COMPACTION */
> +
>  static inline bool
>  should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
>  		     enum compact_result compact_result,
> @@ -3337,7 +3292,6 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
>  	}
>  	return false;
>  }
> -#endif /* CONFIG_COMPACTION */
>  
>  /* Perform direct synchronous page reclaim */
>  static int
> -- 
> 2.8.1
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
