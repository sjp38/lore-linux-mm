Date: Tue, 6 Feb 2007 00:21:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] fs: buffer don't PageUptodate without page locked
Message-Id: <20070206002140.4030a11f.akpm@linux-foundation.org>
In-Reply-To: <20070206054947.21042.32493.sendpatchset@linux.site>
References: <20070206054925.21042.50546.sendpatchset@linux.site>
	<20070206054947.21042.32493.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue,  6 Feb 2007 09:02:23 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:

> __block_write_full_page is calling SetPageUptodate without the page locked.
> This is unusual, but not incorrect, as PG_writeback is still set.
> 
> However with the previous patch, this is now a problem: so don't bother
> setting the page uptodate in this case (it is weird that the write path
> does such a thing anyway). Instead just leave it to the read side to bring
> the page uptodate when it notices that all buffers are uptodate.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Index: linux-2.6/fs/buffer.c
> ===================================================================
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -1679,6 +1679,7 @@ static int __block_write_full_page(struc
>  	 */
>  	BUG_ON(PageWriteback(page));
>  	set_page_writeback(page);
> +	unlock_page(page);
>  
>  	do {
>  		struct buffer_head *next = bh->b_this_page;
> @@ -1688,7 +1689,6 @@ static int __block_write_full_page(struc
>  		}
>  		bh = next;
>  	} while (bh != head);
> -	unlock_page(page);
>  
>  	err = 0;
>  done:

Why this change?  Without looking at it too hard, it seems that if
submit_bh() completes synchronously, this thread can end up playing with
the buffers on a non-locked, non-PageWriteback page.  Someone else could
whip the buffers away and oops?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
