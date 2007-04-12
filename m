Date: Thu, 12 Apr 2007 09:53:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: optimize kill_bdev()
Message-Id: <20070412095341.c53219ae.akpm@linux-foundation.org>
In-Reply-To: <1176391282.4114.10.camel@taijtu>
References: <1176391282.4114.10.camel@taijtu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Zhao Forrest <forrest.zhao@gmail.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2007 17:21:22 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> Remove duplicate work in kill_bdev().
> 
> It currently invalidates and then truncates the bdev's mapping.
> invalidate_mapping_pages() will opportunistically remove pages from the
> mapping. And truncate_inode_pages() will forcefully remove all pages.
> 
> The only thing truncate doesn't do is flush the bh lrus. So do that explicitly.
> This avoids (very unlikely) but possible invalid lookup results if the
> same bdev is quickyl re-issued.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/block_dev.c              |    2 +-
>  fs/buffer.c                 |    3 +--
>  include/linux/buffer_head.h |    1 +
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/fs/block_dev.c
> ===================================================================
> --- linux-2.6.orig/fs/block_dev.c	2007-04-12 16:01:13.000000000 +0200
> +++ linux-2.6/fs/block_dev.c	2007-04-12 16:20:14.000000000 +0200
> @@ -61,7 +61,7 @@ static sector_t max_block(struct block_d
>  /* Kill _all_ buffers, dirty or not.. */
>  static void kill_bdev(struct block_device *bdev)
>  {
> -	invalidate_bdev(bdev);
> +	invalidate_bh_lrus();
>  	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
>  }	

Fair enough, thanks.

The check for mapping->nr_pages != 0 was added to invalidate_bdev() to
avoid unpleasant IPI-induced stalls when large ia64 machines poll their
CDROM drives for media.  I don't know if kill_bdev() gets called on the
probe-a-cdrom path, but we might as well put

	 if (bdev->bd_inode->i_mapping->nr_pages == 0)
		return;

into kill_bdev().  I'll make that change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
