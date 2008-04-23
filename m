Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NFHaiN026995
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 11:17:36 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NFK1WD152768
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 09:20:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NFJxEH012006
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 09:20:01 -0600
Subject: Re: [patch 18/18] hugetlb: my fixes 2
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
In-Reply-To: <20080423015431.569358000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
	 <20080423015431.569358000@nick.local0.net>
Content-Type: text/plain
Date: Wed, 23 Apr 2008 10:20:53 -0500
Message-Id: <1208964053.16652.11.camel@skynet>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-04-23 at 11:53 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-fixes2.patch)
> Here is my next set of fixes and changes:
> - Allow configurations without the default HPAGE_SIZE size (mainly useful
>   for testing but maybe it is the right way to go).
> - Fixed another case where mappings would be set up on incorrect boundaries
>   because prepare_hugepage_range was not hpage-ified.
> - Changed the sysctl table behaviour so it only displays as many values in
>   the vector as there are hstates configured.
> - Fixed oops in overcommit sysctl handler
> 
> This fixes several oopses seen on the libhugetlbfs test suite. Now it seems to
> pass most of them and fails reasonably on others (eg. most 32-bit tests fail
> due to being unable to map enough virtual memory, others due to not enough
> hugepages given that I only have 2).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> ---
>  arch/x86/mm/hugetlbpage.c |    4 ++--
>  fs/hugetlbfs/inode.c      |    4 +++-
>  include/linux/hugetlb.h   |   19 ++-----------------
>  kernel/sysctl.c           |    2 ++
>  mm/hugetlb.c              |   35 ++++++++++++++++++++++++++++++-----
>  5 files changed, 39 insertions(+), 25 deletions(-)
> 
> Index: linux-2.6/arch/x86/mm/hugetlbpage.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
> +++ linux-2.6/arch/x86/mm/hugetlbpage.c
> @@ -124,7 +124,7 @@ int huge_pmd_unshare(struct mm_struct *m
>  	return 1;
>  }
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -402,7 +402,7 @@ hugetlb_get_unmapped_area(struct file *f
>  		return -ENOMEM;
> 
>  	if (flags & MAP_FIXED) {
> -		if (prepare_hugepage_range(addr, len))
> +		if (prepare_hugepage_range(file, addr, len))
>  			return -EINVAL;
>  		return addr;
>  	}
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -640,7 +640,7 @@ static int __init hugetlb_init(void)
>  {
>  	BUILD_BUG_ON(HPAGE_SHIFT == 0);
> 
> -	if (!size_to_hstate(HPAGE_SIZE)) {
> +	if (!max_hstate) {
>  		huge_add_hstate(HUGETLB_PAGE_ORDER);
>  		parsed_hstate->max_huge_pages = default_hstate_resv;
>  	}
> @@ -821,9 +821,10 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  			   struct file *file, void __user *buffer,
>  			   size_t *length, loff_t *ppos)
>  {
> -	int err = 0;
> +	int err;
>  	struct hstate *h;
> 
> +	table->maxlen = max_hstate * sizeof(unsigned long);
>  	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
>  	if (err)
>  		return err;
> @@ -846,6 +847,7 @@ int hugetlb_treat_movable_handler(struct
>  			struct file *file, void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> +	table->maxlen = max_hstate * sizeof(int);
>  	proc_dointvec(table, write, file, buffer, length, ppos);
>  	if (hugepages_treat_as_movable)
>  		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
> @@ -858,15 +860,22 @@ int hugetlb_overcommit_handler(struct ct
>  			struct file *file, void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> +	int err;
>  	struct hstate *h;
> -	int i = 0;
> -	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> +
> +	table->maxlen = max_hstate * sizeof(unsigned long);
> +	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> +	if (err)
> +		return err;
> +
>  	spin_lock(&hugetlb_lock);
>  	for_each_hstate (h) {
> -		h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages[i];
> +		h->nr_overcommit_huge_pages =
> +				sysctl_overcommit_huge_pages[h - hstates];
>  		i++;

The increment of i can be removed since it is no longer used or defined.

<snip>

Jon
Tollefson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
