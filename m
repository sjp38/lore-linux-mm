Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 17C2F6B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 04:59:10 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so5891667wgg.32
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:59:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si12244358wia.79.2014.01.30.01.59.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 01:59:09 -0800 (PST)
Date: Thu, 30 Jan 2014 10:59:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, hugetlb: gimme back my page
Message-ID: <20140130095907.GA13574@dhcp22.suse.cz>
References: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391063823.2931.3.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jonathan Gonzalez <jgonzalez@linets.cl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 29-01-14 22:37:03, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> While testing some changes, I noticed an issue triggered by the libhugetlbfs
> test-suite. This is caused by commit 309381fe (mm: dump page when hitting a
> VM_BUG_ON using VM_BUG_ON_PAGE), where an application can unexpectedly OOM due
> to another program that using, or reserving, pool_size-1 pages later triggers
> a VM_BUG_ON_PAGE and thus greedly leaves no memory to the rest of the hugetlb
> aware tasks. For example, in libhugetlbfs 2.14:
> 
> mmap-gettest 10 32783 (2M: 64): <---- hit VM_BUG_ON_PAGE
> mmap-cow 32782 32783 (2M: 32):  FAIL    Failed to create shared mapping: Cannot allocate memory
> mmap-cow 32782 32783 (2M: 64):  FAIL    Failed to create shared mapping: Cannot allocate memory
> 
> While I have not looked into why 'mmap-gettest' keeps failing, it is of no
> importance to this particular issue. This problem is similar to why we have
> the hugetlb_instantiation_mutex, hugepages are quite finite.
> 
> Revert the use of VM_BUG_ON_PAGE back to just VM_BUG_ON.

I do not understand what VM_BUG_ON_PAGE has to do with the above
failure. Could you be more specific.

Hmm, now that I am looking into dump_page_badflags it shouldn't call
mem_cgroup_print_bad_page for hugetlb pages because it doesn't make any
sense. I will post a patch for that but that still doesn't explain the
above changelog.

> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
>  include/linux/hugetlb.h        |  3 +--
>  include/linux/hugetlb_cgroup.h |  5 ++---
>  mm/hugetlb.c                   | 10 +++++-----
>  mm/hugetlb_cgroup.c            |  2 +-
>  4 files changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 8c43cc4..d01cc97 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -2,7 +2,6 @@
>  #define _LINUX_HUGETLB_H
>  
>  #include <linux/mm_types.h>
> -#include <linux/mmdebug.h>
>  #include <linux/fs.h>
>  #include <linux/hugetlb_inline.h>
>  #include <linux/cgroup.h>
> @@ -355,7 +354,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  
>  static inline struct hstate *page_hstate(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageHuge(page), page);
> +	VM_BUG_ON(!PageHuge(page));
>  	return size_to_hstate(PAGE_SIZE << compound_order(page));
>  }
>  
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> index 787bba3..ce8217f 100644
> --- a/include/linux/hugetlb_cgroup.h
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -15,7 +15,6 @@
>  #ifndef _LINUX_HUGETLB_CGROUP_H
>  #define _LINUX_HUGETLB_CGROUP_H
>  
> -#include <linux/mmdebug.h>
>  #include <linux/res_counter.h>
>  
>  struct hugetlb_cgroup;
> @@ -29,7 +28,7 @@ struct hugetlb_cgroup;
>  
>  static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageHuge(page), page);
> +	VM_BUG_ON(!PageHuge(page));
>  
>  	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
>  		return NULL;
> @@ -39,7 +38,7 @@ static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
>  static inline
>  int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
>  {
> -	VM_BUG_ON_PAGE(!PageHuge(page), page);
> +	VM_BUG_ON(!PageHuge(page));
>  
>  	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
>  		return -1;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c01cb9f..04306b9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -584,7 +584,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>  				1 << PG_active | 1 << PG_reserved |
>  				1 << PG_private | 1 << PG_writeback);
>  	}
> -	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
> +	VM_BUG_ON(hugetlb_cgroup_from_page(page));
>  	set_compound_page_dtor(page, NULL);
>  	set_page_refcounted(page);
>  	arch_release_hugepage(page);
> @@ -1089,7 +1089,7 @@ retry:
>  		 * no users -- drop the buddy allocator's reference.
>  		 */
>  		put_page_testzero(page);
> -		VM_BUG_ON_PAGE(page_count(page), page);
> +		VM_BUG_ON(page_count(page));
>  		enqueue_huge_page(h, page);
>  	}
>  free:
> @@ -3503,7 +3503,7 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
>  
>  bool isolate_huge_page(struct page *page, struct list_head *list)
>  {
> -	VM_BUG_ON_PAGE(!PageHead(page), page);
> +	VM_BUG_ON(!PageHead(page));
>  	if (!get_page_unless_zero(page))
>  		return false;
>  	spin_lock(&hugetlb_lock);
> @@ -3514,7 +3514,7 @@ bool isolate_huge_page(struct page *page, struct list_head *list)
>  
>  void putback_active_hugepage(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageHead(page), page);
> +	VM_BUG_ON(!PageHead(page));
>  	spin_lock(&hugetlb_lock);
>  	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
>  	spin_unlock(&hugetlb_lock);
> @@ -3523,7 +3523,7 @@ void putback_active_hugepage(struct page *page)
>  
>  bool is_hugepage_active(struct page *page)
>  {
> -	VM_BUG_ON_PAGE(!PageHuge(page), page);
> +	VM_BUG_ON(!PageHuge(page));
>  	/*
>  	 * This function can be called for a tail page because the caller,
>  	 * scan_movable_pages, scans through a given pfn-range which typically
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index cb00829..d747a84 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -390,7 +390,7 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
>  	if (hugetlb_cgroup_disabled())
>  		return;
>  
> -	VM_BUG_ON_PAGE(!PageHuge(oldhpage), oldhpage);
> +	VM_BUG_ON(!PageHuge(oldhpage));
>  	spin_lock(&hugetlb_lock);
>  	h_cg = hugetlb_cgroup_from_page(oldhpage);
>  	set_hugetlb_cgroup(oldhpage, NULL);
> -- 
> 1.8.1.4
> 
> 
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
