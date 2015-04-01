Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4C06B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 12:36:33 -0400 (EDT)
Received: by widdi4 with SMTP id di4so51377246wid.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 09:36:33 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id c17si4902965wib.12.2015.04.01.09.36.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 09:36:32 -0700 (PDT)
Received: by wgbdm7 with SMTP id dm7so59560550wgb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 09:36:31 -0700 (PDT)
Date: Wed, 1 Apr 2015 18:36:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 3/3] mm: hugetlb: cleanup using PageHugeActive flag
Message-ID: <20150401163624.GC12808@dhcp22.suse.cz>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 31-03-15 08:50:46, Naoya Horiguchi wrote:
> Now we have an easy access to hugepages' activeness, so existing helpers to
> get the information can be cleaned up.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/hugetlb.h |  8 ++++++--
>  mm/hugetlb.c            | 42 +++++-------------------------------------
>  mm/memory_hotplug.c     |  2 +-
>  3 files changed, 12 insertions(+), 40 deletions(-)
> 
> diff --git v4.0-rc6.orig/include/linux/hugetlb.h v4.0-rc6/include/linux/hugetlb.h
> index 7b5785032049..8494abed02a5 100644
> --- v4.0-rc6.orig/include/linux/hugetlb.h
> +++ v4.0-rc6/include/linux/hugetlb.h
> @@ -42,6 +42,7 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
>  void hugepage_put_subpool(struct hugepage_subpool *spool);
>  
>  int PageHuge(struct page *page);
> +int PageHugeActive(struct page *page);
>  
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
>  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> @@ -79,7 +80,6 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  int dequeue_hwpoisoned_huge_page(struct page *page);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
> -bool is_hugepage_active(struct page *page);
>  void free_huge_page(struct page *page);
>  
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> @@ -114,6 +114,11 @@ static inline int PageHuge(struct page *page)
>  	return 0;
>  }
>  
> +static inline int PageHugeActive(struct page *page)
> +{
> +	return 0;
> +}
> +
>  static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  {
>  }
> @@ -152,7 +157,6 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
>  	return false;
>  }
>  #define putback_active_hugepage(p)	do {} while (0)
> -#define is_hugepage_active(x)	false
>  
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot)
> diff --git v4.0-rc6.orig/mm/hugetlb.c v4.0-rc6/mm/hugetlb.c
> index 05e0233d30d7..8e1c46affc59 100644
> --- v4.0-rc6.orig/mm/hugetlb.c
> +++ v4.0-rc6/mm/hugetlb.c
> @@ -3795,20 +3795,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
>  
>  #ifdef CONFIG_MEMORY_FAILURE
>  
> -/* Should be called in hugetlb_lock */
> -static int is_hugepage_on_freelist(struct page *hpage)
> -{
> -	struct page *page;
> -	struct page *tmp;
> -	struct hstate *h = page_hstate(hpage);
> -	int nid = page_to_nid(hpage);
> -
> -	list_for_each_entry_safe(page, tmp, &h->hugepage_freelists[nid], lru)
> -		if (page == hpage)
> -			return 1;
> -	return 0;
> -}
> -
>  /*
>   * This function is called from memory failure code.
>   * Assume the caller holds page lock of the head page.
> @@ -3820,7 +3806,11 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
>  	int ret = -EBUSY;
>  
>  	spin_lock(&hugetlb_lock);
> -	if (is_hugepage_on_freelist(hpage)) {
> +	/*
> +	 * Just checking !PageHugeActive is not enough, because that could be
> +	 * an isolated/hwpoisoned hugepage (which have >0 refcount).
> +	 */
> +	if (!PageHugeActive(hpage) && !page_count(hpage)) {
>  		/*
>  		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
>  		 * but dangling hpage->lru can trigger list-debug warnings
> @@ -3864,25 +3854,3 @@ void putback_active_hugepage(struct page *page)
>  	spin_unlock(&hugetlb_lock);
>  	put_page(page);
>  }
> -
> -bool is_hugepage_active(struct page *page)
> -{
> -	VM_BUG_ON_PAGE(!PageHuge(page), page);
> -	/*
> -	 * This function can be called for a tail page because the caller,
> -	 * scan_movable_pages, scans through a given pfn-range which typically
> -	 * covers one memory block. In systems using gigantic hugepage (1GB
> -	 * for x86_64,) a hugepage is larger than a memory block, and we don't
> -	 * support migrating such large hugepages for now, so return false
> -	 * when called for tail pages.
> -	 */
> -	if (PageTail(page))
> -		return false;
> -	/*
> -	 * Refcount of a hwpoisoned hugepages is 1, but they are not active,
> -	 * so we should return false for them.
> -	 */
> -	if (unlikely(PageHWPoison(page)))
> -		return false;
> -	return page_count(page) > 0;
> -}
> diff --git v4.0-rc6.orig/mm/memory_hotplug.c v4.0-rc6/mm/memory_hotplug.c
> index 65842d688b7c..2d53388c0715 100644
> --- v4.0-rc6.orig/mm/memory_hotplug.c
> +++ v4.0-rc6/mm/memory_hotplug.c
> @@ -1376,7 +1376,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  			if (PageLRU(page))
>  				return pfn;
>  			if (PageHuge(page)) {
> -				if (is_hugepage_active(page))
> +				if (PageHugeActive(page))
>  					return pfn;
>  				else
>  					pfn = round_up(pfn + 1,
> -- 
> 1.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
