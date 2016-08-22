Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 33B8F6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 05:37:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so57112210wmu.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 02:37:10 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id hu9si17694754wjb.5.2016.08.22.02.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 02:37:09 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so12567293wmg.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 02:37:08 -0700 (PDT)
Date: Mon, 22 Aug 2016 11:37:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822093707.GG13596@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822093249.GA14916@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

[ups, fixing up Greg's email]

On Mon 22-08-16 11:32:49, Michal Hocko wrote:
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
> From 899b738538de41295839dca2090a774bdd17acd2 Mon Sep 17 00:00:00 2001
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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
