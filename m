Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RGieB2015903
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:44:40 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RGiS0J099048
	for <linux-mm@kvack.org>; Tue, 27 May 2008 10:44:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RGiRcP011688
	for <linux-mm@kvack.org>; Tue, 27 May 2008 10:44:28 -0600
Date: Tue, 27 May 2008 09:44:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 03/23] hugetlb: modular state
Message-ID: <20080527164426.GC20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.408189000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.408189000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:20 +1000], npiggin@suse.de wrote:
> Large, but rather mechanical patch that converts most of the hugetlb.c
> globals into structure members and passes them around.
> 
> Right now there is only a single global hstate structure, but 
> most of the infrastructure to extend it is there.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  arch/ia64/mm/hugetlbpage.c    |    6 
>  arch/powerpc/mm/hugetlbpage.c |    2 
>  arch/sh/mm/hugetlbpage.c      |    2 
>  arch/sparc64/mm/hugetlbpage.c |    4 
>  arch/x86/mm/hugetlbpage.c     |    4 
>  fs/hugetlbfs/inode.c          |   49 +++---
>  include/asm-ia64/hugetlb.h    |    2 
>  include/asm-powerpc/hugetlb.h |    2 
>  include/asm-s390/hugetlb.h    |    2 
>  include/asm-sh/hugetlb.h      |    2 
>  include/asm-sparc64/hugetlb.h |    2 
>  include/asm-x86/hugetlb.h     |    7 
>  include/linux/hugetlb.h       |   81 +++++++++-
>  ipc/shm.c                     |    3 
>  mm/hugetlb.c                  |  321 ++++++++++++++++++++++--------------------
>  mm/memory.c                   |    2 
>  mm/mempolicy.c                |    9 -
>  mm/mmap.c                     |    3 
>  18 files changed, 308 insertions(+), 195 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -22,30 +22,24 @@
>  #include "internal.h"
> 
>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> -static unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
> -static unsigned long surplus_huge_pages;
> -static unsigned long nr_overcommit_huge_pages;
>  unsigned long max_huge_pages;
>  unsigned long sysctl_overcommit_huge_pages;
> -static struct list_head hugepage_freelists[MAX_NUMNODES];
> -static unsigned int nr_huge_pages_node[MAX_NUMNODES];
> -static unsigned int free_huge_pages_node[MAX_NUMNODES];
> -static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
> -static int hugetlb_next_nid;
> +
> +struct hstate global_hstate;
> 
>  /*
>   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
>   */
>  static DEFINE_SPINLOCK(hugetlb_lock);
> 
> -static void clear_huge_page(struct page *page, unsigned long addr)
> +static void clear_huge_page(struct page *page, unsigned long addr, unsigned long sz)
>  {
>  	int i;
> 
>  	might_sleep();
> -	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); i++) {
> +	for (i = 0; i < sz/PAGE_SIZE; i++) {
>  		cond_resched();
>  		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>  	}
> @@ -55,42 +49,43 @@ static void copy_huge_page(struct page *
>  			   unsigned long addr, struct vm_area_struct *vma)
>  {
>  	int i;
> +	struct hstate *h = hstate_vma(vma);
> 
>  	might_sleep();
> -	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
> +	for (i = 0; i < 1 << huge_page_order(h); i++) {

So it seems like most (not quite all) users of huge_page_order(h) don't
actually care about the order, per se, but want some sense of the
underlying pagesize. Either pages_per_huge_page() or huge_page_size().

So perhaps it would be sensible to have the helpers defined as such?

huge_page_size(h) -> size in bytes of huge page (corresponds to what was
HPAGE_SIZE), which is what I think you currently have

and

pages_per_huge_page(h) -> number of base pages per huge page
(corresponds to HPAGE_SIZE / PAGE_SIZE)

?

Also, I noticed that this caller has no parentheses, but the other one
does, for (1 << huge_page_order(h))

Neither are huge issues and the first can be a clean-up patch from me,
so

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
