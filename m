From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm 14/24] Ramfs and Ram Disk pages are unevictable
Date: Thu, 12 Jun 2008 10:54:18 +1000
References: <20080611184214.605110868@redhat.com> <20080611184339.693975681@redhat.com>
In-Reply-To: <20080611184339.693975681@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806121054.19253.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thursday 12 June 2008 04:42, Rik van Riel wrote:
> From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
>
> Christoph Lameter pointed out that ram disk pages also clutter the
> LRU lists.  When vmscan finds them dirty and tries to clean them,
> the ram disk writeback function just redirties the page so that it
> goes back onto the active list.  Round and round she goes...


> Index: linux-2.6.26-rc5-mm2/drivers/block/brd.c
> ===================================================================
> --- linux-2.6.26-rc5-mm2.orig/drivers/block/brd.c	2008-06-10
> 10:46:18.000000000 -0400 +++
> linux-2.6.26-rc5-mm2/drivers/block/brd.c	2008-06-10 16:47:23.000000000
> -0400 @@ -374,8 +374,21 @@ static int brd_ioctl(struct inode *inode
>  	return error;
>  }
>
> +/*
> + * brd_open():
> + * Just mark the mapping as containing unevictable pages
> + */
> +static int brd_open(struct inode *inode, struct file *filp)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +
> +	mapping_set_unevictable(mapping);
> +	return 0;
> +}
> +
>  static struct block_device_operations brd_fops = {
>  	.owner =		THIS_MODULE,
> +	.open  =		brd_open,
>  	.ioctl =		brd_ioctl,
>  #ifdef CONFIG_BLK_DEV_XIP
>  	.direct_access =	brd_direct_access,

This isn't the case for brd any longer. It doesn't use the buffer
cache as its backing store, so the buffer cache is reclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
