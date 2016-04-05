Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 11D3D828F3
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 19:58:29 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id td3so20344868pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 16:58:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ku9si273916pab.99.2016.04.05.16.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 16:58:28 -0700 (PDT)
Date: Tue, 5 Apr 2016 16:58:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-Id: <20160405165826.012236e79db7f396fda546a8@linux-foundation.org>
In-Reply-To: <1459855533-4600-10-git-send-email-mhocko@kernel.org>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
	<1459855533-4600-10-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>

On Tue,  5 Apr 2016 13:25:31 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Compaction can provide a wild variation of feedback to the caller. Many
> of them are implementation specific and the caller of the compaction
> (especially the page allocator) shouldn't be bound to specifics of the
> current implementation.
> 
> This patch abstracts the feedback into three basic types:
> 	- compaction_made_progress - compaction was active and made some
> 	  progress.
> 	- compaction_failed - compaction failed and further attempts to
> 	  invoke it would most probably fail and therefore it is not
> 	  worth retrying
> 	- compaction_withdrawn - compaction wasn't invoked for an
>           implementation specific reasons. In the current implementation
>           it means that the compaction was deferred, contended or the
>           page scanners met too early without any progress. Retrying is
>           still worthwhile.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3362,25 +3362,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto got_pg;
>  
> -	/* Checks for THP-specific high-order allocations */
> -	if (is_thp_gfp_mask(gfp_mask)) {
> -		/*
> -		 * If compaction is deferred for high-order allocations, it is
> -		 * because sync compaction recently failed. If this is the case
> -		 * and the caller requested a THP allocation, we do not want
> -		 * to heavily disrupt the system, so we fail the allocation
> -		 * instead of entering direct reclaim.
> -		 */
> -		if (compact_result == COMPACT_DEFERRED)
> -			goto nopage;
> -
> -		/*
> -		 * Compaction is contended so rather back off than cause
> -		 * excessive stalls.
> -		 */
> -		if(compact_result == COMPACT_CONTENDED)
> -			goto nopage;
> -	}
> +	/*
> +	 * Checks for THP-specific high-order allocations and back off
> +	 * if the the compaction backed off
> +	 */
> +	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> +		goto nopage;

This change smashed into Hugh's "huge tmpfs: shmem_huge_gfpmask and
shmem_recovery_gfpmask".

I ended up doing this:

	/* Checks for THP-specific high-order allocations */
	if (!is_thp_allocation(gfp_mask, order))
		migration_mode = MIGRATE_SYNC_LIGHT;

	/*
	 * Checks for THP-specific high-order allocations and back off
	 * if the the compaction backed off
	 */
	if (is_thp_allocation(gfp_mask) && compaction_withdrawn(compact_result))
		goto nopage;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
