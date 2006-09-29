Message-ID: <451D94A7.9060905@oracle.com>
Date: Fri, 29 Sep 2006 17:48:23 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>	<451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org>	<20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com>	<20060928100306.0b58f3c7.akpm@osdl.org>	<451C01C8.7020104@oracle.com>	<451C6AAC.1080203@yahoo.com.au>	<451D8371.2070101@oracle.com>	<1159562724.13651.39.camel@lappy>	<451D89E7.7020307@oracle.com>	<1159564637.13651.44.camel@lappy> <20060929144421.48f9f1bd.akpm@osdl.org>
In-Reply-To: <20060929144421.48f9f1bd.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> buggerit, let's do this.  It'll fix NFS, yes?

It looks right to me.  I'll discuss a patch with Trond that adds a 
warning in nfs_revalidate_mapping() and perhaps a performance counter to 
see how many times we hit this in practice.

> From: Andrew Morton <akpm@osdl.org>
> 
> The recent fix to invalidate_inode_pages() (git commit 016eb4a) managed to
> unfix invalidate_inode_pages2().
> 
> The problem is that various bits of code in the kernel can take transient refs
> on pages: the page scanner will do this when inspecting a batch of pages, and
> the lru_cache_add() batching pagevecs also hold a ref.
> 
> Net result is transient failures in invalidate_inode_pages2().  This affects
> NFS directory invalidation (observed) and presumably also block-backed
> direct-io (not yet reported).
> 
> Fix it by reverting invalidate_inode_pages2() back to the old version which
> ignores the page refcounts.
> 
> We may come up with something more clever later, but for now we need a 2.6.18
> fix for NFS.
> 
> Cc: Chuck Lever <cel@citi.umich.edu>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  mm/truncate.c |   34 ++++++++++++++++++++++++++++++++--
>  1 files changed, 32 insertions(+), 2 deletions(-)
> 
> diff -puN mm/truncate.c~invalidate_inode_pages2-ignore-page-refcounts mm/truncate.c
> --- a/mm/truncate.c~invalidate_inode_pages2-ignore-page-refcounts
> +++ a/mm/truncate.c
> @@ -261,9 +261,39 @@ unsigned long invalidate_inode_pages(str
>  {
>  	return invalidate_mapping_pages(mapping, 0, ~0UL);
>  }
> -
>  EXPORT_SYMBOL(invalidate_inode_pages);
>  
> +/*
> + * This is like invalidate_complete_page(), except it ignores the page's
> + * refcount.  We do this because invalidate_indoe_pages2() needs stronger
> + * invalidation guarantees, and cannot afford to leave pages behind because
> + * shrink_list() has a temp ref on them, or because they're transiently sitting
> + * in the lru_cache_add() pagevecs.
> + */
> +static int
> +invalidate_complete_page2(struct address_space *mapping, struct page *page)
> +{
> +	if (page->mapping != mapping)
> +		return 0;
> +
> +	if (PagePrivate(page) && !try_to_release_page(page, 0))
> +		return 0;
> +
> +	write_lock_irq(&mapping->tree_lock);
> +	if (PageDirty(page))
> +		goto failed;
> +
> +	BUG_ON(PagePrivate(page));
> +	__remove_from_page_cache(page);
> +	write_unlock_irq(&mapping->tree_lock);
> +	ClearPageUptodate(page);
> +	page_cache_release(page);	/* pagecache ref */
> +	return 1;
> +failed:
> +	write_unlock_irq(&mapping->tree_lock);
> +	return 0;
> +}
> +
>  /**
>   * invalidate_inode_pages2_range - remove range of pages from an address_space
>   * @mapping: the address_space
> @@ -330,7 +360,7 @@ int invalidate_inode_pages2_range(struct
>  				}
>  			}
>  			was_dirty = test_clear_page_dirty(page);
> -			if (!invalidate_complete_page(mapping, page)) {
> +			if (!invalidate_complete_page2(mapping, page)) {
>  				if (was_dirty)
>  					set_page_dirty(page);
>  				ret = -EIO;
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
