Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A1F646B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:48:19 -0400 (EDT)
Date: Tue, 9 Jun 2009 11:18:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [11/15] HWPOISON: Refactor truncate to allow direct truncating of page v2
Message-ID: <20090609091821.GA16940@wotan.suse.de>
References: <200906041128.112757038@firstfloor.org> <20090604212823.16F901D0293@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604212823.16F901D0293@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 11:28:23PM +0200, Andi Kleen wrote:
> 
> From: Nick Piggin <npiggin@suse.de>
> 
> Extract out truncate_inode_page() out of the truncate path so that
> it can be used by memory-failure.c
> 
> [AK: description, headers, fix typos]
> v2: Some white space changes from Fengguang Wu 
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Thank you muchly :) Seems the description is still missing? Something
like the below?

Signed-off-by: Nick Piggin <npiggin@suse.de>

> ---
>  include/linux/mm.h |    2 ++
>  mm/truncate.c      |   24 ++++++++++++------------
>  2 files changed, 14 insertions(+), 12 deletions(-)
> 
> Index: linux/mm/truncate.c
> ===================================================================
> --- linux.orig/mm/truncate.c
> +++ linux/mm/truncate.c
> @@ -135,6 +135,16 @@ invalidate_complete_page(struct address_
>  	return ret;
>  }
>  
/*
 * Remove one page from its pagecache mapping. The page must be locked.
 * This does not truncate the file on disk, it performs the pagecache
 * side of the truncate operation. Dirty data will be discarded, and
 * concurrent page references are ignored.
 *
 * Generic mm/fs code cannot call this on filesystem metadata mappings
 * because those can assume that a page reference is enough to pin the
 * page to its mapping.
 */

> +void truncate_inode_page(struct address_space *mapping, struct page *page)
> +{
> +	if (page_mapped(page)) {
> +		unmap_mapping_range(mapping,
> +				   (loff_t)page->index << PAGE_CACHE_SHIFT,
> +				   PAGE_CACHE_SIZE, 0);
> +	}
> +	truncate_complete_page(mapping, page);
> +}
> +
>  /**
>   * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
>   * @mapping: mapping to truncate
> @@ -196,12 +206,7 @@ void truncate_inode_pages_range(struct a
>  				unlock_page(page);
>  				continue;
>  			}
> -			if (page_mapped(page)) {
> -				unmap_mapping_range(mapping,
> -				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
> -				  PAGE_CACHE_SIZE, 0);
> -			}
> -			truncate_complete_page(mapping, page);
> +			truncate_inode_page(mapping, page);
>  			unlock_page(page);
>  		}
>  		pagevec_release(&pvec);
> @@ -238,15 +243,10 @@ void truncate_inode_pages_range(struct a
>  				break;
>  			lock_page(page);
>  			wait_on_page_writeback(page);
> -			if (page_mapped(page)) {
> -				unmap_mapping_range(mapping,
> -				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
> -				  PAGE_CACHE_SIZE, 0);
> -			}
> +			truncate_inode_page(mapping, page);
>  			if (page->index > next)
>  				next = page->index;
>  			next++;
> -			truncate_complete_page(mapping, page);
>  			unlock_page(page);
>  		}
>  		pagevec_release(&pvec);
> Index: linux/include/linux/mm.h
> ===================================================================
> --- linux.orig/include/linux/mm.h
> +++ linux/include/linux/mm.h
> @@ -811,6 +811,8 @@ static inline void unmap_shared_mapping_
>  extern int vmtruncate(struct inode * inode, loff_t offset);
>  extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
>  
> +void truncate_inode_page(struct address_space *mapping, struct page *page);
> +
>  #ifdef CONFIG_MMU
>  extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, int write_access);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
