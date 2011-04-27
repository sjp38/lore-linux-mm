Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 87F1890010B
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:51:03 -0400 (EDT)
Date: Wed, 27 Apr 2011 15:50:40 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110427135040.GA12437@cmpxchg.org>
References: <20110415101248.GB22688@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415101248.GB22688@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Fri, Apr 15, 2011 at 11:12:48AM +0100, Mel Gorman wrote:
> With transparent hugepage support, handle_mm_fault() has to be careful
> that a normal PMD has been established before handling a PTE fault. To
> achieve this, it used __pte_alloc() directly instead of pte_alloc_map
> as pte_alloc_map is unsafe to run against a huge PMD. pte_offset_map()
> is called once it is known the PMD is safe.
> 
> pte_alloc_map() is smart enough to check if a PTE is already present
> before calling __pte_alloc but this check was lost. As a consequence,
> PTEs may be allocated unnecessarily and the page table lock taken.
> Thi useless PTE does get cleaned up but it's a performance hit which
> is visible in page_test from aim9.
> 
> This patch simply re-adds the check normally done by pte_alloc_map to
> check if the PTE needs to be allocated before taking the page table
> lock. The effect is noticable in page_test from aim9.
> 
> AIM9
>                 2.6.38-vanilla 2.6.38-checkptenone
> creat-clo      446.10 ( 0.00%)   424.47 (-5.10%)
> page_test       38.10 ( 0.00%)    42.04 ( 9.37%)
> brk_test        52.45 ( 0.00%)    51.57 (-1.71%)
> exec_test      382.00 ( 0.00%)   456.90 (16.39%)
> fork_test       60.11 ( 0.00%)    67.79 (11.34%)
> MMTests Statistics: duration
> Total Elapsed Time (seconds)                611.90    612.22
> 
> (While this affects 2.6.38, it is a performance rather than a
> functional bug and normally outside the rules -stable. While the big
> performance differences are to a microbench, the difference in fork
> and exec performance may be significant enough that -stable wants to
> consider the patch)
> 
> Reported-by: Raz Ben Yehuda <raziebe@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
