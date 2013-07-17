Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 519616B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 07:01:05 -0400 (EDT)
Date: Wed, 17 Jul 2013 13:00:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 04/18] mm: numa: Do not migrate or account for hinting
 faults on the zero page
Message-ID: <20130717110053.GD17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:06PM +0100, Mel Gorman wrote:
> The zero page is not replicated between nodes and is often shared
> between processes. The data is read-only and likely to be cached in
> local CPUs if heavily accessed meaning that the remote memory access
> cost is less of a concern. This patch stops accounting for numa hinting
> faults on the zero page in both terms of counting faults and scheduling
> tasks on nodes.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/huge_memory.c | 9 +++++++++
>  mm/memory.c      | 7 ++++++-
>  2 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e4a79fa..ec938ed 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1302,6 +1302,15 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	page = pmd_page(pmd);
>  	get_page(page);
> +
> +	/*
> +	 * Do not account for faults against the huge zero page. The read-only
> +	 * data is likely to be read-cached on the local CPUs and it is less
> +	 * useful to know about local versus remote hits on the zero page.
> +	 */
> +	if (is_huge_zero_pfn(page_to_pfn(page)))
> +		goto clear_pmdnuma;
> +
>  	src_nid = numa_node_id();
>  	count_vm_numa_event(NUMA_HINT_FAULTS);
>  	if (src_nid == page_to_nid(page))

And because of:

  5918d10 thp: fix huge zero page logic for page with pfn == 0

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1308,7 +1308,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 	 * data is likely to be read-cached on the local CPUs and it is less
 	 * useful to know about local versus remote hits on the zero page.
 	 */
-	if (is_huge_zero_pfn(page_to_pfn(page)))
+	if (is_huge_zero_page(page))
 		goto clear_pmdnuma;
 
 	src_nid = numa_node_id();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
