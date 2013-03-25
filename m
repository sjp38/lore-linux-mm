Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 461936B007D
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 06:57:03 -0400 (EDT)
Date: Mon, 25 Mar 2013 11:57:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 02/10] migrate: make core migration code aware of hugepage
Message-ID: <20130325105701.GS2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:47, Naoya Horiguchi wrote:
> Before enabling each user of page migration to support hugepage,
> this patch adds necessary changes on core migration code.
> The main change is that the list of pages to migrate can link
> not only LRU pages, but also hugepages.
> Along with this, functions such as migrate_pages() and
> putback_movable_pages() need to be changed to handle hugepages.
> 
> ChangeLog v2:
>  - move code removing VM_HUGETLB from vma_migratable check into a
>    separate patch
>  - hold hugetlb_lock in putback_active_hugepage
>  - update comment near the definition of hugetlb_lock
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h |  4 ++++
>  include/linux/migrate.h |  6 ++++++
>  mm/hugetlb.c            | 21 ++++++++++++++++++++-
>  mm/migrate.c            | 24 +++++++++++++++++++++++-
>  4 files changed, 53 insertions(+), 2 deletions(-)
> 
> diff --git v3.9-rc3.orig/include/linux/hugetlb.h v3.9-rc3/include/linux/hugetlb.h
> index 16e4e9a..baa0aa0 100644
> --- v3.9-rc3.orig/include/linux/hugetlb.h
> +++ v3.9-rc3/include/linux/hugetlb.h
> @@ -66,6 +66,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
>  						vm_flags_t vm_flags);
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
>  int dequeue_hwpoisoned_huge_page(struct page *page);
> +void putback_active_hugepage(struct page *page);
> +void putback_active_hugepages(struct list_head *l);
>  void copy_huge_page(struct page *dst, struct page *src);
>  
>  extern unsigned long hugepages_treat_as_movable;
> @@ -128,6 +130,8 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
>  	return 0;
>  }
>  
> +#define putback_active_hugepage(p) 0
> +#define putback_active_hugepages(l) 0
>  static inline void copy_huge_page(struct page *dst, struct page *src)
>  {
>  }
> diff --git v3.9-rc3.orig/include/linux/migrate.h v3.9-rc3/include/linux/migrate.h
> index a405d3dc..d4c6c08 100644
> --- v3.9-rc3.orig/include/linux/migrate.h
> +++ v3.9-rc3/include/linux/migrate.h
> @@ -41,6 +41,9 @@ extern int migrate_page(struct address_space *,
>  			struct page *, struct page *, enum migrate_mode);
>  extern int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, enum migrate_mode mode, int reason);
> +extern int migrate_movable_pages(struct list_head *from,
> +		new_page_t get_new_page, unsigned long private,
> +		enum migrate_mode mode, int reason);
>  extern int migrate_huge_page(struct page *, new_page_t x,
>  		unsigned long private, enum migrate_mode mode);
>  
> @@ -62,6 +65,9 @@ static inline void putback_movable_pages(struct list_head *l) {}
>  static inline int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, enum migrate_mode mode, int reason)
>  	{ return -ENOSYS; }
> +static inline int migrate_movable_pages(struct list_head *from,
> +		new_page_t get_new_page, unsigned long private, bool offlining,
> +		enum migrate_mode mode, int reason) { return -ENOSYS; }
>  static inline int migrate_huge_page(struct page *page, new_page_t x,
>  		unsigned long private, enum migrate_mode mode)
>  	{ return -ENOSYS; }
> diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> index 98a478e..a787c44 100644
> --- v3.9-rc3.orig/mm/hugetlb.c
> +++ v3.9-rc3/mm/hugetlb.c
> @@ -48,7 +48,8 @@ static unsigned long __initdata default_hstate_max_huge_pages;
>  static unsigned long __initdata default_hstate_size;
>  
>  /*
> - * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> + * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
> + * free_huge_pages, and surplus_huge_pages.
>   */

Could you get this out into a separate patch and add lockdep assertions
to functions which do not lock it directly but they rely on it so that
the locking is more clear?
e.g. dequeue_huge_page_node, update_and_free_page, try_to_free_low, ...

It would a nice cleanup and a lead for future when somebody tries to
make the locking a bit saner.

>  DEFINE_SPINLOCK(hugetlb_lock);
>  
> @@ -3182,3 +3183,21 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
>  	return ret;
>  }
>  #endif
> +
> +void putback_active_hugepage(struct page *page)
> +{
> +	VM_BUG_ON(!PageHead(page));
> +	spin_lock(&hugetlb_lock);
> +	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
> +	spin_unlock(&hugetlb_lock);
> +	put_page(page);
> +}
> +
> +void putback_active_hugepages(struct list_head *l)
> +{
> +	struct page *page;
> +	struct page *page2;
> +
> +	list_for_each_entry_safe(page, page2, l, lru)
> +		putback_active_hugepage(page);
> +}
> diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
> index ec692a3..f69f354 100644
> --- v3.9-rc3.orig/mm/migrate.c
> +++ v3.9-rc3/mm/migrate.c
> @@ -100,6 +100,10 @@ void putback_movable_pages(struct list_head *l)
>  	struct page *page2;
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
> +		if (unlikely(PageHuge(page))) {
> +			putback_active_hugepage(page);
> +			continue;
> +		}
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
> @@ -1023,7 +1027,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  		list_for_each_entry_safe(page, page2, from, lru) {
>  			cond_resched();
>  
> -			rc = unmap_and_move(get_new_page, private,
> +			if (PageHuge(page))
> +				rc = unmap_and_move_huge_page(get_new_page,
> +						private, page, pass > 2, mode);
> +			else
> +				rc = unmap_and_move(get_new_page, private,
>  						page, pass > 2, mode);
>  
>  			switch(rc) {
> @@ -1056,6 +1064,20 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  	return rc;
>  }
>  
> +int migrate_movable_pages(struct list_head *from, new_page_t get_new_page,
> +			unsigned long private,
> +			enum migrate_mode mode, int reason)
> +{
> +	int err = 0;
> +
> +	if (!list_empty(from)) {
> +		err = migrate_pages(from, get_new_page, private, mode, reason);
> +		if (err)
> +			putback_movable_pages(from);
> +	}
> +	return err;
> +}
> +

There doesn't seem to be any caller for this function. Please move it to
the patch which uses it.

>  int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
>  		      unsigned long private, enum migrate_mode mode)
>  {
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
