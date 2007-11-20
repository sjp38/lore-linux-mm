Date: Mon, 19 Nov 2007 20:30:00 -0500
Message-Id: <200711200130.lAK1U0QN016973@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Sat, 17 Nov 2007 21:24:01 GMT."
             <Pine.LNX.4.64.0711172103040.10619@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Dave Hansen <haveblue@us.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0711172103040.10619@blonde.wat.veritas.com>, Hugh Dickins writes:
> On Tue, 13 Nov 2007, Erez Zadok wrote:
[...]
> I'm glad to report that this unionfs, not the one in 2.6.24-rc2-mm1
> but the one including those 9 patches you posted, now gets through
> my testing with tmpfs without a problem.  I do still get occasional
> "unionfs: new lower inode mtime (bindex=0, name=<directory>)"
> messages, but nothing worse seen yet: a big improvement.

Excellent.

> I did think you could clean up the doubled set_page_dirtys,
> but it's of no consequence.

Yes, looks good.  I'll send that as a patch.  Thanks.

> Hugh
> 
> --- 2.6.24-rc2-mm1+9/fs/unionfs/mmap.c	2007-11-17 12:23:30.000000000 +0000
> +++ linux/fs/unionfs/mmap.c	2007-11-17 20:22:29.000000000 +0000
> @@ -56,6 +56,7 @@ static int unionfs_writepage(struct page
>  	copy_highpage(lower_page, page);
>  	flush_dcache_page(lower_page);
>  	SetPageUptodate(lower_page);
> +	set_page_dirty(lower_page);
>  
>  	/*
>  	 * Call lower writepage (expects locked page).  However, if we are
> @@ -66,12 +67,11 @@ static int unionfs_writepage(struct page
>  	 * success.
>  	 */
>  	if (wbc->for_reclaim) {
> -		set_page_dirty(lower_page);
>  		unlock_page(lower_page);
>  		goto out_release;
>  	}
> +
>  	BUG_ON(!lower_mapping->a_ops->writepage);
> -	set_page_dirty(lower_page);
>  	clear_page_dirty_for_io(lower_page); /* emulate VFS behavior */
>  	err = lower_mapping->a_ops->writepage(lower_page, wbc);
>  	if (err < 0)

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
