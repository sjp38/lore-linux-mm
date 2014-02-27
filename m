Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id BEA166B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:20:00 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1285835pbb.26
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:20:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id se8si5906467pbb.66.2014.02.27.13.19.59
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 13:19:59 -0800 (PST)
Date: Thu, 27 Feb 2014 13:19:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm, hugetlbfs: fix rmapping for anonymous hugepages
 with page_pgoff()
Message-Id: <20140227131957.d81cf9a643f4d3fd6b8d8b16@linux-foundation.org>
In-Reply-To: <1393475977-3381-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1393475977-3381-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Wed, 26 Feb 2014 23:39:36 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> page->index stores pagecache index when the page is mapped into file mapping
> region, and the index is in pagecache size unit, so it depends on the page
> size. Some of users of reverse mapping obviously assumes that page->index
> is in PAGE_CACHE_SHIFT unit, so they don't work for anonymous hugepage.
> 
> For example, consider that we have 3-hugepage vma and try to mbind the 2nd
> hugepage to migrate to another node. Then the vma is split and migrate_page()
> is called for the 2nd hugepage (belonging to the middle vma.)
> In migrate operation, rmap_walk_anon() tries to find the relevant vma to
> which the target hugepage belongs, but here we miscalculate pgoff.
> So anon_vma_interval_tree_foreach() grabs invalid vma, which fires VM_BUG_ON.
> 
> This patch introduces a new API that is usable both for normal page and
> hugepage to get PAGE_SIZE offset from page->index. Users should clearly
> distinguish page_index for pagecache index and page_pgoff for page offset.

So this patch is really independent of the page-walker changes, but the
page walker changes need it.  So it is appropriate that this patch be
staged before that series, and separately.  Agree?

> Reported-by: Sasha Levin <sasha.levin@oracle.com> # if the reported problem is fixed
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.12+

Why cc:stable?  This problem will only cause runtime issues when the
page walker patches are present?

> index 4f591df66778..a8bd14f42032 100644
> --- next-20140220.orig/include/linux/pagemap.h
> +++ next-20140220/include/linux/pagemap.h
> @@ -316,6 +316,19 @@ static inline loff_t page_file_offset(struct page *page)
>  	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
>  }
>  
> +extern pgoff_t hugepage_pgoff(struct page *page);
> +
> +/*
> + * page->index stores pagecache index whose unit is not always PAGE_SIZE.
> + * This function converts it into PAGE_SIZE offset.
> + */
> +#define page_pgoff(page)					\
> +({								\
> +	unlikely(PageHuge(page)) ?				\
> +		hugepage_pgoff(page) :				\
> +		page->index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);	\
> +})

- I don't think this needs to be implemented in a macro?  Can we do
  it in good old C?

- Is PageHuge() the appropriate test?
  /*
   * PageHuge() only returns true for hugetlbfs pages, but not for normal or
   * transparent huge pages.  See the PageTransHuge() documentation for more
   * details.
   */

- Should page->index be shifted right or left?  Probably left - I
  doubt if PAGE_CACHE_SHIFT will ever be less than PAGE_SHIFT.

- I'm surprised we don't have a general what-is-this-page's-order
  function, so you can just do

	static inline pgoff_t page_pgoff(struct page *page)
	{
		return page->index << page_size_order(page);
	}

  And I think this would be a better implementation, as the (new)
  page_size_order() could be used elsewhere.

  page_size_order() would be a crappy name - can't think of anything
  better at present.

> --- next-20140220.orig/mm/memory-failure.c
> +++ next-20140220/mm/memory-failure.c
> @@ -404,7 +404,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
>  	if (av == NULL)	/* Not actually mapped anymore */
>  		return;
>  
> -	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

See this did a left shift.

> +	pgoff = page_pgoff(page);
>  	read_lock(&tasklist_lock);
>  	for_each_process (tsk) {
>  		struct anon_vma_chain *vmac;
> @@ -437,7 +437,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
>  	mutex_lock(&mapping->i_mmap_mutex);
>  	read_lock(&tasklist_lock);
>  	for_each_process(tsk) {
> -		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

him too.

> +		pgoff_t pgoff = page_pgoff(page);
>  
>  		if (!task_early_kill(tsk))
>  			continue;
> diff --git next-20140220.orig/mm/rmap.c next-20140220/mm/rmap.c
> index 9056a1f00b87..78405051474a 100644
> --- next-20140220.orig/mm/rmap.c
> +++ next-20140220/mm/rmap.c
> @@ -515,11 +515,7 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
>  static inline unsigned long
>  __vma_address(struct page *page, struct vm_area_struct *vma)
>  {
> -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

And him.

> -
> -	if (unlikely(is_vm_hugetlb_page(vma)))
> -		pgoff = page->index << huge_page_order(page_hstate(page));
> -
> +	pgoff_t pgoff = page_pgoff(page);
>  	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  }
>  
> @@ -1598,7 +1594,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
>  static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
>  {
>  	struct anon_vma *anon_vma;
> -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);

again.

> +	pgoff_t pgoff = page_pgoff(page);
>  	struct anon_vma_chain *avc;
>  	int ret = SWAP_AGAIN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
