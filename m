Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9A446B0006
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:01:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a38-v6so8502167wra.10
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:01:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si14169edc.12.2018.04.20.05.01.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 05:01:03 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH v11 19/63] page cache: Convert page deletion to XArray
References: <20180414141316.7167-1-willy@infradead.org>
 <20180414141316.7167-20-willy@infradead.org>
Message-ID: <979c1602-42e3-349d-a5e4-d28de14112dd@suse.de>
Date: Fri, 20 Apr 2018 07:00:57 -0500
MIME-Version: 1.0
In-Reply-To: <20180414141316.7167-20-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>



On 04/14/2018 09:12 AM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The code is slightly shorter and simpler.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  mm/filemap.c | 30 ++++++++++++++----------------
>  1 file changed, 14 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 070b5e4527ac..4af06a1a9818 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -111,30 +111,28 @@
>   *   ->tasklist_lock            (memory_failure, collect_procs_ao)
>   */
>  
> -static void page_cache_tree_delete(struct address_space *mapping,
> +static void page_cache_delete(struct address_space *mapping,
>  				   struct page *page, void *shadow)
>  {
> -	int i, nr;
> +	XA_STATE(xas, &mapping->i_pages, page->index);
> +	unsigned int i, nr;
>  
> -	/* hugetlb pages are represented by one entry in the radix tree */
> +	mapping_set_update(&xas, mapping);
> +
> +	/* hugetlb pages are represented by a single entry in the xarray */
>  	nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageTail(page), page);
>  	VM_BUG_ON_PAGE(nr != 1 && shadow, page);
>  
> -	for (i = 0; i < nr; i++) {
> -		struct radix_tree_node *node;
> -		void **slot;
> -
> -		__radix_tree_lookup(&mapping->i_pages, page->index + i,
> -				    &node, &slot);
> -
> -		VM_BUG_ON_PAGE(!node && nr != 1, page);
> -
> -		radix_tree_clear_tags(&mapping->i_pages, node, slot);
> -		__radix_tree_replace(&mapping->i_pages, node, slot, shadow,
> -				workingset_lookup_update(mapping));
> +	i = nr;
> +repeat:
> +	xas_store(&xas, shadow);
> +	xas_init_tags(&xas);
> +	if (--i) {
> +		xas_next(&xas);
> +		goto repeat;
>  	}

Can this be converted into a do {} while (or even for) loop instead?
Loops are easier to read and understand in such a situation.

>  
>  	page->mapping = NULL;
> @@ -234,7 +232,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
>  	trace_mm_filemap_delete_from_page_cache(page);
>  
>  	unaccount_page_cache_page(mapping, page);
> -	page_cache_tree_delete(mapping, page, shadow);
> +	page_cache_delete(mapping, page, shadow);
>  }
>  
>  static void page_cache_free_page(struct address_space *mapping,
> 

-- 
Goldwyn
