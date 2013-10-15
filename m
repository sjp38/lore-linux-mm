Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5928B6B0036
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 06:02:21 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so8618268pdj.4
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 03:02:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131015001201.GC3432@hippobay.mtv.corp.google.com>
References: <20131015001201.GC3432@hippobay.mtv.corp.google.com>
Subject: RE: [PATCH 02/12] mm, thp, tmpfs: support to add huge page into page
 cache for tmpfs
Content-Transfer-Encoding: 7bit
Message-Id: <20131015100213.A0189E0090@blue.fi.intel.com>
Date: Tue, 15 Oct 2013 13:02:13 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> For replacing a page inside page cache, we assume the huge page
> has been splitted before getting here.
> 
> For adding a new page to page cache, huge page support has been added.
> 
> Also refactor the shm_add_to_page_cache function.
> 
> Signed-off-by: Ning Qu <quning@gmail.com>
> ---
>  mm/shmem.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 88 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index a857ba8..447bd14 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -277,27 +277,23 @@ static bool shmem_confirm_swap(struct address_space *mapping,
>  }
>  
>  /*
> - * Like add_to_page_cache_locked, but error if expected item has gone.
> + * Replace the swap entry with page cache entry
>   */
> -static int shmem_add_to_page_cache(struct page *page,
> +static int shmem_replace_page_page_cache(struct page *page,
>  				   struct address_space *mapping,
>  				   pgoff_t index, gfp_t gfp, void *expected)
>  {
>  	int error;
>  
> -	VM_BUG_ON(!PageLocked(page));
> -	VM_BUG_ON(!PageSwapBacked(page));
> +	BUG_ON(PageTransHugeCache(page));
>  
>  	page_cache_get(page);
>  	page->mapping = mapping;
>  	page->index = index;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	if (!expected)
> -		error = radix_tree_insert(&mapping->page_tree, index, page);
> -	else
> -		error = shmem_radix_tree_replace(mapping, index, expected,
> -								 page);
> +
> +	error = shmem_radix_tree_replace(mapping, index, expected, page);
>  	if (!error) {
>  		mapping->nrpages++;
>  		__inc_zone_page_state(page, NR_FILE_PAGES);
> @@ -312,6 +308,87 @@ static int shmem_add_to_page_cache(struct page *page,
>  }
>  
>  /*
> + * Insert new page into with page cache
> + */
> +static int shmem_insert_page_page_cache(struct page *page,
> +				   struct address_space *mapping,
> +				   pgoff_t index, gfp_t gfp)
> +{

You copy-paste most of add_to_page_cache_locked() code here. Is there a
way to share the code? Move common part into __add_to_page_cache_locked()
or something.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
