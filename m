Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E3658828F3
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 20:06:13 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id zm5so20554081pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 17:06:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z23si332273pfi.42.2016.04.05.17.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 17:06:13 -0700 (PDT)
Date: Tue, 5 Apr 2016 17:06:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/11] mm, oom: protect !costly allocations some more
Message-Id: <20160405170612.d17d3a04f2609f62b3572d0e@linux-foundation.org>
In-Reply-To: <1459855533-4600-11-git-send-email-mhocko@kernel.org>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
	<1459855533-4600-11-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue,  5 Apr 2016 13:25:32 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
> 
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and there is no guarantee
> further reclaim/compaction attempts would help but at least make sure
> that the compaction was active before we go OOM and keep retrying even
> if should_reclaim_retry tells us to oom if
> 	- the last compaction round backed off or
> 	- we haven't completed at least MAX_COMPACT_RETRIES active
> 	  compaction rounds.
> 
> The first rule ensures that the very last attempt for compaction
> was not ignored while the second guarantees that the compaction has done
> some work. Multiple retries might be needed to prevent occasional
> pigggy packing of other contexts to steal the compacted pages before
> the current context manages to retry to allocate them.
> 
> compaction_failed() is taken as a final word from the compaction that
> the retry doesn't make much sense. We have to be careful though because
> the first compaction round is MIGRATE_ASYNC which is rather weak as it
> ignores pages under writeback and gives up too easily in other
> situations. We therefore have to make sure that MIGRATE_SYNC_LIGHT mode
> has been used before we give up. With this logic in place we do not have
> to increase the migration mode unconditionally and rather do it only if
> the compaction failed for the weaker mode. A nice side effect is that
> the stronger migration mode is used only when really needed so this has
> a potential of smaller latencies in some cases.
> 
> Please note that the compaction doesn't tell us much about how
> successful it was when returning compaction_made_progress so we just
> have to blindly trust that another retry is worthwhile and cap the
> number to something reasonable to guarantee a convergence.
> 
> If the given number of successful retries is not sufficient for a
> reasonable workloads we should focus on the collected compaction
> tracepoints data and try to address the issue in the compaction code.
> If this is not feasible we can increase the retries limit.
> 
> @@ -3369,14 +3425,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
>  		goto nopage;
>  
> -	/*
> -	 * It can become very expensive to allocate transparent hugepages at
> -	 * fault, so use asynchronous memory compaction for THP unless it is
> -	 * khugepaged trying to collapse.
> -	 */
> -	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
> -		migration_mode = MIGRATE_SYNC_LIGHT;
> -
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
>  							&did_some_progress);

Hugh's patches moved this elsewhere.  I'll drop this hunk altogether -
please carefully review the result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
