Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0CFBC6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 18:53:31 -0400 (EDT)
Date: Tue, 1 May 2012 15:53:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/11] mm: Add support for a filesystem to activate swap
 files and use direct_IO for writing swap pages
Message-Id: <20120501155308.5679a09b.akpm@linux-foundation.org>
In-Reply-To: <1334578675-23445-5-git-send-email-mgorman@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
	<1334578675-23445-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Mon, 16 Apr 2012 13:17:48 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Currently swapfiles are managed entirely by the core VM by using ->bmap
> to allocate space and write to the blocks directly. This effectively
> ensures that the underlying blocks are allocated and avoids the need
> for the swap subsystem to locate what physical blocks store offsets
> within a file.
> 
> If the swap subsystem is to use the filesystem information to locate
> the blocks, it is critical that information such as block groups,
> block bitmaps and the block descriptor table that map the swap file
> were resident in memory. This patch adds address_space_operations that
> the VM can call when activating or deactivating swap backed by a file.
> 
>   int swap_activate(struct file *);
>   int swap_deactivate(struct file *);
> 
> The ->swap_activate() method is used to communicate to the
> file that the VM relies on it, and the address_space should take
> adequate measures such as reserving space in the underlying device,
> reserving memory for mempools and pinning information such as the
> block descriptor table in memory. The ->swap_deactivate() method is
> called on sys_swapoff() if ->swap_activate() returned success.
> 
> After a successful swapfile ->swap_activate, the swapfile
> is marked SWP_FILE and swapper_space.a_ops will proxy to
> sis->swap_file->f_mappings->a_ops using ->direct_io to write swapcache
> pages and ->readpage to read.
> 
> It is perfectly possible that direct_IO be used to read the swap
> pages but it is an unnecessary complication. Similarly, it is possible
> that ->writepage be used instead of direct_io to write the pages but
> filesystem developers have stated that calling writepage from the VM
> is undesirable for a variety of reasons and using direct_IO opens up
> the possibility of writing back batches of swap pages in the future.

This all seems a bit odd.  And abusive.

Yes, it would be more pleasing if direct-io was used for reading as
well.  How much more complication would it add?

If I understand correctly, on the read path we're taking a fresh page
which is destined for swapcache and then pretending that it is a
pagecache page for the purpose of the I/O?  If there already existed a
pagecache page for that file offset then we let it just sit there and
bypass it?

I'm surprised that this works at all - I guess nothing under
->readpage() goes poking around in the address_space.  For NFS, at
least!

>
> ...
>
> @@ -93,11 +94,38 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>  {
>  	struct bio *bio;
>  	int ret = 0, rw = WRITE;
> +	struct swap_info_struct *sis = page_swap_info(page);
>  
>  	if (try_to_free_swap(page)) {
>  		unlock_page(page);
>  		goto out;
>  	}
> +
> +	if (sis->flags & SWP_FILE) {
> +		struct kiocb kiocb;
> +		struct file *swap_file = sis->swap_file;
> +		struct address_space *mapping = swap_file->f_mapping;
> +		struct iovec iov = {
> +			.iov_base = page_address(page),

Didn't we need to kmap the page?

> +			.iov_len  = PAGE_SIZE,
> +		};
> +
> +		init_sync_kiocb(&kiocb, swap_file);
> +		kiocb.ki_pos = page_file_offset(page);
> +		kiocb.ki_left = PAGE_SIZE;
> +		kiocb.ki_nbytes = PAGE_SIZE;
> +
> +		unlock_page(page);
> +		ret = mapping->a_ops->direct_IO(KERNEL_WRITE,
> +						&kiocb, &iov,
> +						kiocb.ki_pos, 1);

I wonder if there's any point in setting PG_writeback around the IO.  I
can't think of a reason.

> +		if (ret == PAGE_SIZE) {
> +			count_vm_event(PSWPOUT);
> +			ret = 0;
> +		}
> +		return ret;
> +	}
> +
>  	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
>  	if (bio == NULL) {
>  		set_page_dirty(page);
> @@ -119,9 +147,21 @@ int swap_readpage(struct page *page)
>  {
>  	struct bio *bio;
>  	int ret = 0;
> +	struct swap_info_struct *sis = page_swap_info(page);
>  
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(PageUptodate(page));
> +
> +	if (sis->flags & SWP_FILE) {
> +		struct file *swap_file = sis->swap_file;
> +		struct address_space *mapping = swap_file->f_mapping;
> +
> +		ret = mapping->a_ops->readpage(swap_file, page);
> +		if (!ret)
> +			count_vm_event(PSWPIN);
> +		return ret;
> +	}

Confused.  Where did we set up page->index with the file offset?

>  	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
>  	if (bio == NULL) {
>  		unlock_page(page);
> @@ -133,3 +173,15 @@ int swap_readpage(struct page *page)
>  out:
>  	return ret;
>  }
> +
> +int swap_set_page_dirty(struct page *page)
> +{
> +	struct swap_info_struct *sis = page_swap_info(page);
> +
> +	if (sis->flags & SWP_FILE) {
> +		struct address_space *mapping = sis->swap_file->f_mapping;
> +		return mapping->a_ops->set_page_dirty(page);
> +	} else {
> +		return __set_page_dirty_nobuffers(page);
> +	}
> +}

More confused.  This is a swapcache page, not a pagecache page?  Why
are we running set_page_dirty() against it?

And what are we doing on the !SWP_FILE path?  Newly setting PG_dirty
against block-device-backed swapcache pages?  Why?  Where does it get
cleared again?

> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 9d3dd37..c25b9cf 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -26,7 +26,7 @@
>   */
>  static const struct address_space_operations swap_aops = {
>  	.writepage	= swap_writepage,
> -	.set_page_dirty	= __set_page_dirty_nobuffers,
> +	.set_page_dirty	= swap_set_page_dirty,
>  	.migratepage	= migrate_page,
>  };
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
