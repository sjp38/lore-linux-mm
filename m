Date: Fri, 6 Jun 2008 18:05:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 15/25] Ramfs and Ram Disk pages are non-reclaimable
Message-Id: <20080606180510.87a49e19.akpm@linux-foundation.org>
In-Reply-To: <20080606202859.408662219@redhat.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.408662219@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 06 Jun 2008 16:28:53 -0400
Rik van Riel <riel@redhat.com> wrote:

> 
> From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> Christoph Lameter pointed out that ram disk pages also clutter the
> LRU lists.  When vmscan finds them dirty and tries to clean them,
> the ram disk writeback function just redirties the page so that it
> goes back onto the active list.  Round and round she goes...
> 
> Define new address_space flag [shares address_space flags member
> with mapping's gfp mask] to indicate that the address space contains
> all non-reclaimable pages.  This will provide for efficient testing
> of ramdisk pages in page_reclaimable().
> 
> Also provide wrapper functions to set/test the noreclaim state to
> minimize #ifdefs in ramdisk driver and any other users of this
> facility.
> 
> Set the noreclaim state on address_space structures for new
> ramdisk inodes.  Test the noreclaim state in page_reclaimable()
> to cull non-reclaimable pages.
> 
> Similarly, ramfs pages are non-reclaimable.  Set the 'noreclaim'
> address_space flag for new ramfs inodes.
> 
> These changes depend on [CONFIG_]NORECLAIM_LRU.

hm

> 
> @@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
>  		inode->i_mapping->a_ops = &ramfs_aops;
>  		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
>  		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
> +		mapping_set_noreclaim(inode->i_mapping);
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>  		switch (mode & S_IFMT) {
>  		default:

That's OK.

> Index: linux-2.6.26-rc2-mm1/drivers/block/brd.c
> ===================================================================
> --- linux-2.6.26-rc2-mm1.orig/drivers/block/brd.c	2008-05-29 16:21:04.000000000 -0400
> +++ linux-2.6.26-rc2-mm1/drivers/block/brd.c	2008-06-06 16:06:20.000000000 -0400
> @@ -374,8 +374,21 @@ static int brd_ioctl(struct inode *inode
>  	return error;
>  }
>  
> +/*
> + * brd_open():
> + * Just mark the mapping as containing non-reclaimable pages
> + */
> +static int brd_open(struct inode *inode, struct file *filp)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +
> +	mapping_set_noreclaim(mapping);
> +	return 0;
> +}
> +
>  static struct block_device_operations brd_fops = {
>  	.owner =		THIS_MODULE,
> +	.open  =		brd_open,
>  	.ioctl =		brd_ioctl,
>  #ifdef CONFIG_BLK_DEV_XIP
>  	.direct_access =	brd_direct_access,

But this only works for pagecache in /dev/ramN.  afaict the pagecache
for files which are written onto that "blokk device" remain on the LRU.
But that's OK, isn't it?  For the ramdisk driver these pages _do_ have
backing store and _can_ be written back and reclaimed, yes?


Still, I'm unsure about the whole implementation.  We already maintain
this sort of information in the backing_dev.  Would it not be better to
just avoid ever putting such pages onto the LRU in the first place?


Also, I expect there are a whole host of pseudo-filesystems (sysfs?)
which have this problem.  Does the patch address all of them?  If not,
can we come up with something which _does_ address them all without
having to hunt down and change every such fs?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
