Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F02386B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 09:30:04 -0400 (EDT)
Received: by pzk6 with SMTP id 6so612969pzk.1
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 06:29:59 -0700 (PDT)
Date: Fri, 4 Jun 2010 22:29:48 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH V2 3/7] Cleancache (was Transcendent Memory): VFS hooks
Message-ID: <20100604132948.GC1879@barrios-desktop>
References: <20100528173610.GA12270@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528173610.GA12270@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Hi, Dan. 
I reviewed quickly. So I may be wrong. :) 

On Fri, May 28, 2010 at 10:36:10AM -0700, Dan Magenheimer wrote:
> [PATCH V2 3/7] Cleancache (was Transcendent Memory): VFS hooks
> 
> Implement core hooks in VFS for: initializing cleancache
> per filesystem; capturing clean pages evicted by page cache;
> attempting to get pages from cleancache before filesystem
> read; and ensuring coherency between pagecache, disk,
> and cleancache.  All hooks become no-ops if CONFIG_CLEANCACHE
> is unset, or become compare-pointer-to-NULL if
> CONFIG_CLEANCACHE is set but no cleancache "backend" has
> claimed cleancache_ops.
> 
> Signed-off-by: Chris Mason <chris.mason@oracle.com>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Diffstat:
>  fs/buffer.c                              |    5 +++++
>  fs/mpage.c                               |    7 +++++++
>  fs/super.c                               |    8 ++++++++
>  mm/filemap.c                             |   11 +++++++++++
>  mm/truncate.c                            |   10 ++++++++++
>  5 files changed, 41 insertions(+)
> 
> --- linux-2.6.34/fs/super.c	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-cleancache/fs/super.c	2010-05-24 12:15:20.000000000 -0600
> @@ -38,6 +38,7 @@
>  #include <linux/mutex.h>
>  #include <linux/file.h>
>  #include <linux/backing-dev.h>
> +#include <linux/cleancache.h>
>  #include <asm/uaccess.h>
>  #include "internal.h"
>  
> @@ -105,6 +106,7 @@ static struct super_block *alloc_super(s
>  		s->s_qcop = sb_quotactl_ops;
>  		s->s_op = &default_op;
>  		s->s_time_gran = 1000000000;
> +		s->cleancache_poolid = -1;
>  	}
>  out:
>  	return s;
> @@ -195,6 +197,11 @@ void deactivate_super(struct super_block
>  		vfs_dq_off(s, 0);
>  		down_write(&s->s_umount);
>  		fs->kill_sb(s);
> +		if (s->cleancache_poolid > 0) {
> +			int cleancache_poolid = s->cleancache_poolid;
> +			s->cleancache_poolid = -1; /* avoid races */
> +			cleancache_flush_fs(cleancache_poolid);
> +		}
>  		put_filesystem(fs);
>  		put_super(s);
>  	}
> @@ -221,6 +228,7 @@ void deactivate_locked_super(struct supe
>  		spin_unlock(&sb_lock);
>  		vfs_dq_off(s, 0);
>  		fs->kill_sb(s);
> +		cleancache_flush_fs(s->cleancache_poolid);
>  		put_filesystem(fs);
>  		put_super(s);
>  	} else {
> --- linux-2.6.34/fs/buffer.c	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-cleancache/fs/buffer.c	2010-05-24 12:14:44.000000000 -0600
> @@ -41,6 +41,7 @@
>  #include <linux/bitops.h>
>  #include <linux/mpage.h>
>  #include <linux/bit_spinlock.h>
> +#include <linux/cleancache.h>
>  
>  static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
>  
> @@ -276,6 +277,10 @@ void invalidate_bdev(struct block_device
>  
>  	invalidate_bh_lrus();
>  	invalidate_mapping_pages(mapping, 0, -1);
> +	/* 99% of the time, we don't need to flush the cleancache on the bdev.
> +	 * But, for the strange corners, lets be cautious
> +	 */
> +	cleancache_flush_inode(mapping);
>  }
>  EXPORT_SYMBOL(invalidate_bdev);
>  
> --- linux-2.6.34/fs/mpage.c	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-cleancache/fs/mpage.c	2010-05-24 12:29:28.000000000 -0600
> @@ -27,6 +27,7 @@
>  #include <linux/writeback.h>
>  #include <linux/backing-dev.h>
>  #include <linux/pagevec.h>
> +#include <linux/cleancache.h>
>  
>  /*
>   * I/O completion handler for multipage BIOs.
> @@ -286,6 +287,12 @@ do_mpage_readpage(struct bio *bio, struc
>  		SetPageMappedToDisk(page);
>  	}
>  
> +	if (fully_mapped && blocks_per_page == 1 && !PageUptodate(page) &&
> +	    cleancache_get_page(page) == CLEANCACHE_GET_PAGE_SUCCESS) {
> +		SetPageUptodate(page);
> +		goto confused;
> +	}
> +
>  	/*
>  	 * This page will go to BIO.  Do we need to send this BIO off first?
>  	 */
> --- linux-2.6.34/mm/filemap.c	2010-05-16 15:17:36.000000000 -0600
> +++ linux-2.6.34-cleancache/mm/filemap.c	2010-05-24 12:14:44.000000000 -0600
> @@ -34,6 +34,7 @@
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>  #include <linux/memcontrol.h>
>  #include <linux/mm_inline.h> /* for page_is_file_cache() */
> +#include <linux/cleancache.h>
>  #include "internal.h"
>  
>  /*
> @@ -119,6 +120,16 @@ void __remove_from_page_cache(struct pag
>  {
>  	struct address_space *mapping = page->mapping;
>  
> +	/*
> +	 * if we're uptodate, flush out into the cleancache, otherwise
> +	 * invalidate any existing cleancache entries.  We can't leave
> +	 * stale data around in the cleancache once our page is gone
> +	 */
> +	if (PageUptodate(page))
> +		cleancache_put_page(page);
> +	else
> +		cleancache_flush_page(mapping, page);
> +
>  	radix_tree_delete(&mapping->page_tree, page->index);

I doubt it's right place related to PFRA.

1)
You mentiond PFRA in you description and I understood cleancache has 
a cold clean page which is evicted by reclaimer. 
But __remove_from_page_cache can be called by other call sites.

For example, shmem_write page calls it for moving the page from page cache
to swap cache. Although there isn't the page in page cache, it is in swap cache.
So next read/write of shmem until swapout happens can be read/write in swap cache. 

I didn't looked into whole of callsites. But please review again them. 

2) 
While I review this, I found GFP_ATOMIC of add_to_swap_cache. 
I don't know why it is in there. But at least when you review them, 
please consider gfp_flag of the context. 

If PFRA is going on, it means there is system memory pressure. 
So we can't allocate page easily. So each functions cold be use GFP_NOIO, 
GFP_NOFS, GFP_ATOMIC and so one. It means your backend can't call alloc_pages 
freely. 

I think it's the best if you call your hooks in no limited place. 
Maybe you already have done it. :)

3)
Please consider system memory pressure. 
Without this, PFRA might reclaim the page but cleancache's backend(non-virtualized)
may consume another page for putting clean page. It could change system behivor 
althought it can reduce I/O cost. 
I don't know which is important. Let us discuss it in another thread in next chance. 

In this thread, my concern is that we need new hook which notify urgent memory
reclaim. (ex, direct reclaim) 
I think at least if system momory pressure is high, backend need to free own 
cache memory. Of course, backend can monitor it but it's awkward. 
I think frontend should it. 

And I hope Nitin consider this, too. 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
