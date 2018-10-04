Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED9936B0007
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 16:16:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v7-v6so9185623plo.23
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 13:16:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18-v6sor4925504pgk.58.2018.10.04.13.16.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 13:16:35 -0700 (PDT)
Date: Thu, 4 Oct 2018 13:16:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20180925120326.24392-2-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 25 Sep 2018, Michal Hocko wrote:

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da858f794eb6..149b6f4cf023 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2046,8 +2046,36 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		nmask = policy_nodemask(gfp, pol);
>  		if (!nmask || node_isset(hpage_node, *nmask)) {
>  			mpol_cond_put(pol);
> -			page = __alloc_pages_node(hpage_node,
> -						gfp | __GFP_THISNODE, order);
> +			/*
> +			 * We cannot invoke reclaim if __GFP_THISNODE
> +			 * is set. Invoking reclaim with
> +			 * __GFP_THISNODE set, would cause THP
> +			 * allocations to trigger heavy swapping
> +			 * despite there may be tons of free memory
> +			 * (including potentially plenty of THP
> +			 * already available in the buddy) on all the
> +			 * other NUMA nodes.
> +			 *
> +			 * At most we could invoke compaction when
> +			 * __GFP_THISNODE is set (but we would need to
> +			 * refrain from invoking reclaim even if
> +			 * compaction returned COMPACT_SKIPPED because
> +			 * there wasn't not enough memory to succeed
> +			 * compaction). For now just avoid
> +			 * __GFP_THISNODE instead of limiting the
> +			 * allocation path to a strict and single
> +			 * compaction invocation.
> +			 *
> +			 * Supposedly if direct reclaim was enabled by
> +			 * the caller, the app prefers THP regardless
> +			 * of the node it comes from so this would be
> +			 * more desiderable behavior than only
> +			 * providing THP originated from the local
> +			 * node in such case.
> +			 */
> +			if (!(gfp & __GFP_DIRECT_RECLAIM))
> +				gfp |= __GFP_THISNODE;
> +			page = __alloc_pages_node(hpage_node, gfp, order);
>  			goto out;
>  		}
>  	}

This causes, on average, a 13.9% access latency regression on Haswell, and 
the regression would likely be more severe on Naples and Rome.

There exist libraries that allow the .text segment of processes to be 
remapped to memory backed by transparent hugepages and use MADV_HUGEPAGE 
to stress local compaction to defragment node local memory for hugepages 
at startup.  The cost, including the statistics Mel gathered, is 
acceptable for these processes: they are not concerned with startup cost, 
they are concerned only with optimal access latency while they are 
running.

So while it may take longer to start the process because memory compaction 
is attempting to allocate hugepages with __GFP_DIRECT_RECLAIM, in the 
cases where compaction is successful, this is a very significant long-term 
win.  In cases where compaction fails, falling back to local pages of the 
native page size instead of remote thp is a win for the remaining time 
this process wins: as stated, 13.9% faster for all memory accesses to the 
process's text while it runs on Haswell.

So these processes, and there are 100's of users of these libraries, 
explicitly want to incur the cost of startup to attempt to get local thp 
and fallback only when necessary to local pages of the native page size.  
They want the behavior this patch is changing and regress if the patch is 
merged.

This patch does not provide an alternative beyond MPOL_BIND to preserve 
the existing behavior.  In that case, if local memory is actually oom, we 
unnecessarily oom kill processes which would be completely unacceptable to 
these users since they are fine to accept 10-20% of their memory being 
faulted remotely if necessary to prevent processes being oom killed.

These libraries were implemented with the existing behavior of 
MADV_HUGEPAGE in mind and I cannot ask for 100s of binaries to be rebuilt 
to enforce new constraints specifically for hugepages with no alternative 
that does not allow unnecessary oom killing.

There are ways to address this without introducing regressions for 
existing users of MADV_HUGEPAGE: introduce an madvise() mode to accept 
remote thp allocations, which users of this library would never set, or 
fix memory compaction so that it does not incur substantial allocation 
latency when it will likely fail.

We don't introduce 13.9% regressions for binaries that are correctly using 
MADV_HUGEPAGE as it is implemented.

Nacked-by: David Rientjes <rientjes@google.com>
