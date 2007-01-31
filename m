Date: Wed, 31 Jan 2007 17:17:10 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] simplify shmem_aops.set_page_dirty method
In-Reply-To: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701311648450.28314@blonde.wat.veritas.com>
References: <b040c32a0701302006y429dc981u980bee08f6a42854@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jan 2007, Ken Chen wrote:

> shmem backed file does not have page write back, nor it participates in
> BDI_CAP_NO_ACCT_DIRTY or BDI_CAP_NO_WRITEBACK accounting. So using generic
> __set_page_dirty_nobuffers() for its .set_page_dirty aops method is a bit
> overkill.  It unnecessarily prolonged shm unmap latency.
> 
> For example, on a densely populated large shm segment (sevearl GBs), the
> unmapping operation becomes painfully long. Because at unmap, kernel
> transfers dirty bit in PTE into page struct and to the radix tree tag. The
> operation of tagging the radix tree is particularlly expensive because it
> has to traverse the tree from the root to the leaf node on every dirty page.
> What's bothering is that radix tree tag is used for page write back. However,
> shmem is memory backed and there is no page write back for such file system.
> And in the end, we spend all that time tagging radix tree and none of that
> fancy tagging will be used.  So let's simplify it by introduce a new aops
> __set_page_dirty_no_write_back and this will speed up shm unmap.
> 
> 
> Signed-off-by: Ken Chen <kenchen@google.com>
> 
> ---
> Hugh, would you please kindly review this patch?

Sure.  Thanks for doing this, Ken: I certainly approve of your intention
here, I remember having a patch doing much the same when set_page_dirty
first came in.  I think it was part of some series which got rejected or
abandoned for other reasons; and lacking the numbers to justify it, I
just let it go and forgot.  You've now seen the improvement, great,
please go ahead - with a few changes.

1.  Would you mind changing the name to either
__set_page_dirty_no_writeback or __set_page_dirty_nowriteback?
I would prefer the former (we speak of "writeback" not "write back"
elsewhere), except __set_page_dirty_nobuffers has set a precedent
for the latter.

2.  Please remind me what good __mark_inode_dirty will do for shmem:
in my patch the equivalent function did nothing beyond SetPageDirty
(your TestSetPageDirty looks better, less redirtying the cacheline).
The world may have moved on and __mark_inode_dirty now be important,
but I suspect still not - I think it just puts the inode on some
hashlist which serves no good purpose for nowriteback mappings.

3.  There's some other places which should benefit from it too:
ramfs (which will cover tiny-shmem) for one, swap_aops for another.
Change those over at the same time?  Or leave them to another patch?
Up to you.

Some of the baroqueness (e.g. mapping2) in __set_page_dirty_nobuffers
reflects how tmpfs pages used to come there; but I think leave it as is.

Hugh

> 
> 
> diff -Nurp linux-2.6.20-rc6/include/linux/mm.h
> linux-2.6.20-rc6.unmap/include/linux/mm.h
> --- linux-2.6.20-rc6/include/linux/mm.h	2007-01-30 19:23:44.000000000 -0800
> +++ linux-2.6.20-rc6.unmap/include/linux/mm.h	2007-01-30
> 19:25:06.000000000 -0800
> @@ -785,6 +785,7 @@ extern int try_to_release_page(struct pa
> extern void do_invalidatepage(struct page *page, unsigned long offset);
> 
> int __set_page_dirty_nobuffers(struct page *page);
> +int __set_page_dirty_no_write_back(struct page *page);
> int redirty_page_for_writepage(struct writeback_control *wbc,
> 				struct page *page);
> int FASTCALL(set_page_dirty(struct page *page));
> diff -Nurp linux-2.6.20-rc6/mm/page-writeback.c
> linux-2.6.20-rc6.unmap/mm/page-writeback.c
> --- linux-2.6.20-rc6/mm/page-writeback.c	2007-01-30 19:23:45.000000000
> -0800
> +++ linux-2.6.20-rc6.unmap/mm/page-writeback.c	2007-01-30
> 19:58:46.000000000 -0800
> @@ -742,6 +742,21 @@ int write_one_page(struct page *page, in
> EXPORT_SYMBOL(write_one_page);
> 
> /*
> + * For address_spaces which do not use buffers nor page write back.
> + */
> +int __set_page_dirty_no_write_back(struct page *page)
> +{
> +	if (!TestSetPageDirty(page)) {
> +		struct address_space *mapping = page_mapping(page);
> +		if (mapping && mapping->host) {
> +			/* !PageAnon && !swapper_space */
> +			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +		}
> +	}
> +	return 0;
> +}
> +
> +/*
>  * For address_spaces which do not use buffers.  Just tag the page as dirty in
>  * its radix tree.
>  *
> diff -Nurp linux-2.6.20-rc6/mm/shmem.c linux-2.6.20-rc6.unmap/mm/shmem.c
> --- linux-2.6.20-rc6/mm/shmem.c	2007-01-30 19:23:45.000000000 -0800
> +++ linux-2.6.20-rc6.unmap/mm/shmem.c	2007-01-30 19:38:26.000000000 -0800
> @@ -2316,7 +2316,7 @@ static void destroy_inodecache(void)
> 
> static const struct address_space_operations shmem_aops = {
> 	.writepage	= shmem_writepage,
> -	.set_page_dirty	= __set_page_dirty_nobuffers,
> +	.set_page_dirty	= __set_page_dirty_no_write_back,
> #ifdef CONFIG_TMPFS
> 	.prepare_write	= shmem_prepare_write,
> 	.commit_write	= simple_commit_write,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
