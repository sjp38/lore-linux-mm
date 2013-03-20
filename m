Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 46A606B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 15:52:14 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id b57so1334097eek.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2013 12:52:12 -0700 (PDT)
Date: Wed, 20 Mar 2013 20:52:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] mm, hugetlb: include hugepages in meminfo
Message-ID: <20130320195209.GA3600@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1303191714440.13526@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1303201207110.28997@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303201207110.28997@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 20-03-13 12:07:29, David Rientjes wrote:
> mm, hugetlb: include hugepages in meminfo
> 
> Particularly in oom conditions, it's troublesome that hugetlb memory is 
> not displayed.  All other meminfo that is emitted will not add up to what 
> is expected, and there is no artifact left in the kernel log to show that 
> a potentially significant amount of memory is actually allocated as 
> hugepages which are not available to be reclaimed.
> 
> Booting with hugepages=8192 on the command line, this memory is now shown 
> in oom conditions.  For example, with echo m > /proc/sysrq-trigger:
> 
> Node 0 hugepages_total=2048 hugepages_free=2048 hugepages_surp=0 hugepages_size=2048kB
> Node 1 hugepages_total=2048 hugepages_free=2048 hugepages_surp=0 hugepages_size=2048kB
> Node 2 hugepages_total=2048 hugepages_free=2048 hugepages_surp=0 hugepages_size=2048kB
> Node 3 hugepages_total=2048 hugepages_free=2048 hugepages_surp=0 hugepages_size=2048kB
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thank you!

> ---
>  include/linux/hugetlb.h |  4 ++++
>  mm/hugetlb.c            | 15 +++++++++++++++
>  mm/page_alloc.c         |  3 +++
>  3 files changed, 22 insertions(+)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -58,6 +58,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
>  void hugetlb_report_meminfo(struct seq_file *);
>  int hugetlb_report_node_meminfo(int, char *);
> +void hugetlb_show_meminfo(void);
>  unsigned long hugetlb_total_pages(void);
>  int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, unsigned int flags);
> @@ -114,6 +115,9 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
>  {
>  }
>  #define hugetlb_report_node_meminfo(n, buf)	0
> +static inline void hugetlb_show_meminfo(void)
> +{
> +}
>  #define follow_huge_pmd(mm, addr, pmd, write)	NULL
>  #define follow_huge_pud(mm, addr, pud, write)	NULL
>  #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2121,6 +2121,21 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
>  		nid, h->surplus_huge_pages_node[nid]);
>  }
>  
> +void hugetlb_show_meminfo(void)
> +{
> +	struct hstate *h;
> +	int nid;
> +
> +	for_each_node_state(nid, N_MEMORY)
> +		for_each_hstate(h)
> +			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
> +		        	nid,
> +				h->nr_huge_pages_node[nid],
> +				h->free_huge_pages_node[nid],
> +				h->surplus_huge_pages_node[nid],
> +				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> +}
> +
>  /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
>  unsigned long hugetlb_total_pages(void)
>  {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -58,6 +58,7 @@
>  #include <linux/prefetch.h>
>  #include <linux/migrate.h>
>  #include <linux/page-debug-flags.h>
> +#include <linux/hugetlb.h>
>  #include <linux/sched/rt.h>
>  
>  #include <asm/tlbflush.h>
> @@ -3105,6 +3106,8 @@ void show_free_areas(unsigned int filter)
>  		printk("= %lukB\n", K(total));
>  	}
>  
> +	hugetlb_show_meminfo();
> +
>  	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
>  
>  	show_swap_cache_info();
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
