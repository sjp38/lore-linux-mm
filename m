Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5E0C66B009C
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:31:06 -0400 (EDT)
Date: Tue, 11 Sep 2012 14:33:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/3 v2] mm: Reorg code to allow i_mmap_mutex acquisition
 to be done by caller of page_referenced & try_to_unmap
Message-ID: <20120911053302.GB14494@bbox>
References: <1347293969.9977.72.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347293969.9977.72.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Sep 10, 2012 at 09:19:29AM -0700, Tim Chen wrote:
> We reorganize the page_referenced and try_to_unmap code to determine
> explicitly if mapping->i_mmap_mutex needs to be acquired.  This allows
> us to acquire the mutex for multiple pages in batch. We can call 
> __page_referenced or __try_to_unmap with the mutex already acquired so
> the mutex doesn't have to be acquired multiple times.

It would be better to write down.
"This patch is intend for preparing next patch  which reduces
 lock contention."

> 
> Tim
> 
> ---
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index fd07c45..f1320b1 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -156,8 +156,11 @@ static inline void page_dup_rmap(struct page *page)
>  /*
>   * Called from mm/vmscan.c to handle paging out
>   */
> -int page_referenced(struct page *, int is_locked,
> -			struct mem_cgroup *memcg, unsigned long *vm_flags);
> +int needs_page_mmap_mutex(struct page *page);
> +int page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
> +				unsigned long *vm_flags);
> +int __page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
> +				unsigned long *vm_flags);
>  int page_referenced_one(struct page *, struct vm_area_struct *,
>  	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
>  
> @@ -176,6 +179,7 @@ enum ttu_flags {
>  bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  
>  int try_to_unmap(struct page *, enum ttu_flags flags);
> +int __try_to_unmap(struct page *, enum ttu_flags flags);
>  int try_to_unmap_one(struct page *, struct vm_area_struct *,
>  			unsigned long address, enum ttu_flags flags);

Why do you declare double underscore functions in header?
As I look the patch, that function is used by only rmap.c so that
you don't need to declare it in header file and you can make that
functions static.

If next patch use that functions on other files, let's make that
function external in next patch, NOT this patch.

>  
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5b5ad58..8be1799 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -843,8 +843,7 @@ static int page_referenced_file(struct page *page,
>  	 * so we can safely take mapping->i_mmap_mutex.
>  	 */
>  	BUG_ON(!PageLocked(page));
> -
> -	mutex_lock(&mapping->i_mmap_mutex);
> +	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
>  
>  	/*
>  	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
> @@ -869,21 +868,15 @@ static int page_referenced_file(struct page *page,
>  			break;
>  	}
>  
> -	mutex_unlock(&mapping->i_mmap_mutex);
>  	return referenced;
>  }
>  
> -/**
> - * page_referenced - test if the page was referenced
> - * @page: the page to test
> - * @is_locked: caller holds lock on the page
> - * @memcg: target memory cgroup
> - * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
> - *
> - * Quick test_and_clear_referenced for all mappings to a page,
> - * returns the number of ptes which referenced the page.
> - */
> -int page_referenced(struct page *page,

Please add a description about this function and
add lokcing rule.
Page should be locked for such test.

And how about this naming?

/*
 * This function return true if we have to hold page->mapping->i_mmap_mutex.
 * Otherwise, return false.
 * Caller should lock the page
 */
bool need_page_mapping_mutex(struct page *page)
{
        BUG_ON(!PageLocked(page));
	return page->mapping && !PageKsm(page) && !PageAnon(page);
}

MM guys are used to page_mapping.

> +int needs_page_mmap_mutex(struct page *page)
> +{
> +	return page->mapping && !PageKsm(page) && !PageAnon(page);
> +}
> +
> +int __page_referenced(struct page *page,

static

>  		    int is_locked,
>  		    struct mem_cgroup *memcg,
>  		    unsigned long *vm_flags)
> @@ -919,6 +912,32 @@ out:
>  	return referenced;
>  }
>  
> +/**
> + * page_referenced - test if the page was referenced
> + * @page: the page to test
> + * @is_locked: caller holds lock on the page
> + * @memcg: target memory cgroup
> + * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
> + *
> + * Quick test_and_clear_referenced for all mappings to a page,
> + * returns the number of ptes which referenced the page.
> + */
> +int page_referenced(struct page *page,
> +		    int is_locked,
> +		    struct mem_cgroup *memcg,
> +		    unsigned long *vm_flags)
> +{
> +	int result, needs_lock;
> +
> +	needs_lock = needs_page_mmap_mutex(page);
> +	if (needs_lock)
> +		mutex_lock(&page->mapping->i_mmap_mutex);
> +	result = __page_referenced(page, is_locked, memcg, vm_flags);
> +	if (needs_lock)
> +		mutex_unlock(&page->mapping->i_mmap_mutex);
> +	return result;
> +}
> +
>  static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  			    unsigned long address)
>  {
> @@ -1560,7 +1579,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>  	unsigned long max_nl_size = 0;
>  	unsigned int mapcount;
>  
> -	mutex_lock(&mapping->i_mmap_mutex);
> +	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
>  	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address = vma_address(page, vma);
>  		if (address == -EFAULT)
> @@ -1640,7 +1659,24 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
>  	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
>  		vma->vm_private_data = NULL;
>  out:
> -	mutex_unlock(&mapping->i_mmap_mutex);
> +	return ret;
> +}
> +
> +int __try_to_unmap(struct page *page, enum ttu_flags flags)

static

> +{
> +	int ret;
> +
> +	BUG_ON(!PageLocked(page));
> +	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
> +
> +	if (unlikely(PageKsm(page)))
> +		ret = try_to_unmap_ksm(page, flags);
> +	else if (PageAnon(page))
> +		ret = try_to_unmap_anon(page, flags);
> +	else
> +		ret = try_to_unmap_file(page, flags);
> +	if (ret != SWAP_MLOCK && !page_mapped(page))
> +		ret = SWAP_SUCCESS;
>  	return ret;
>  }
>  
> @@ -1660,20 +1696,27 @@ out:
>   */
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
> -	int ret;
> +	int result, needs_lock;
> +
> +	needs_lock = needs_page_mmap_mutex(page);
> +	if (needs_lock)
> +		mutex_lock(&page->mapping->i_mmap_mutex);
> +	result = __try_to_unmap(page, flags);
> +	if (needs_lock)
> +		mutex_unlock(&page->mapping->i_mmap_mutex);
> +	return result;
> +}
>  
> -	BUG_ON(!PageLocked(page));
> -	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
> +static int __try_to_munlock(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
>  
>  	if (unlikely(PageKsm(page)))
> -		ret = try_to_unmap_ksm(page, flags);
> +		return try_to_unmap_ksm(page, TTU_MUNLOCK);
>  	else if (PageAnon(page))
> -		ret = try_to_unmap_anon(page, flags);
> +		return try_to_unmap_anon(page, TTU_MUNLOCK);
>  	else
> -		ret = try_to_unmap_file(page, flags);
> -	if (ret != SWAP_MLOCK && !page_mapped(page))
> -		ret = SWAP_SUCCESS;
> -	return ret;
> +		return try_to_unmap_file(page, TTU_MUNLOCK);
>  }
>  
>  /**
> @@ -1693,14 +1736,15 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>   */
>  int try_to_munlock(struct page *page)
>  {
> -	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
> -
> -	if (unlikely(PageKsm(page)))
> -		return try_to_unmap_ksm(page, TTU_MUNLOCK);
> -	else if (PageAnon(page))
> -		return try_to_unmap_anon(page, TTU_MUNLOCK);
> -	else
> -		return try_to_unmap_file(page, TTU_MUNLOCK);
> +	int result, needs_lock;
> +
> +	needs_lock = needs_page_mmap_mutex(page);
> +	if (needs_lock)
> +		mutex_lock(&page->mapping->i_mmap_mutex);
> +	result = __try_to_munlock(page);
> +	if (needs_lock)
> +		mutex_unlock(&page->mapping->i_mmap_mutex);
> +	return result;
>  }
>  
>  void __put_anon_vma(struct anon_vma *anon_vma)
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
