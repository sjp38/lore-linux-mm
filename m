Date: Sat, 25 Jun 2005 19:32:43 +0900 (JST)
Message-Id: <20050625.193243.112617952.taka@valinux.co.jp>
Subject: Re: [PATCH 2.6.12-rc5 4/10] mm: manual page migration-rc3 --
 add-sys_migrate_pages-rc3.patch
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050622163934.25515.22804.81297@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
	<20050622163934.25515.22804.81297@tomahawk.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, raybry@austin.rr.com, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, pj@sgi.com, nathans@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Ray,

> +static int
> +migrate_vma(struct task_struct *task, struct mm_struct *mm,
> +	struct vm_area_struct *vma, int *node_map)
> +{
> +	struct page *page, *page2;
> +	unsigned long vaddr;
> +	int count = 0, nr_busy;
> +	LIST_HEAD(page_list);
> +
> +	/* can't migrate mlock()'d pages */
> +	if (vma->vm_flags & VM_LOCKED)
> +		return 0;
> +
> +	/*
> +	 * gather all of the pages to be migrated from this vma into page_list
> +	 */
> +	spin_lock(&mm->page_table_lock);
> + 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
> +		page = follow_page(mm, vaddr, 0);
> +		/*
> +		 * follow_page has been known to return pages with zero mapcount
> +		 * and NULL mapping.  Skip those pages as well
> +		 */
> +		if (page && page_mapcount(page)) {
> +			if (node_map[page_to_nid(page)] >= 0) {
> +				if (steal_page_from_lru(page_zone(page), page,
> +					&page_list))
> +						count++;
> +				else
> +					BUG();
> +			}
> +		}
> +	}
> +	spin_unlock(&mm->page_table_lock);

I think you shouldn't call BUG() here because the swap code can remove
any pages from the LRU lists at any moment even though mm->page_table_lock
is held.

The preferable code would be:

		if (page && page_mapcount(page)) {
			if (node_map[page_to_nid(page)] >= 0) {
				if (steal_page_from_lru(page_zone(page), page,
					&page_list))
						count++;
				else
					continue;
			}
		}

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
