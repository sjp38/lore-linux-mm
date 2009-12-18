Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33DFC6B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 20:07:13 -0500 (EST)
Message-ID: <4B2AD5BB.8060100@goop.org>
Date: Thu, 17 Dec 2009 17:07:07 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Tmem [PATCH 2/5] (Take 3): Implement cleancache on top of tmem
 layer
References: <dee07055-5763-4e91-b6a2-964bbc8217aa@default>
In-Reply-To: <dee07055-5763-4e91-b6a2-964bbc8217aa@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

On 12/17/2009 04:37 PM, Dan Magenheimer wrote:
> Tmem [PATCH 2/5] (Take 3): Implement cleancache on top of tmem layer.
>
> Hooks added to existing page cache, VFS, and FS (ext3, ocfs2, btrfs,
> and ext4 supported as of now) routines to:
> 1) create a tmem pool when filesystem is mounted and record its id
> 2) "put" clean pages that are being evicted
> 3) attempt to "get" pages prior to reading from a mounted FS and
>     fallback to reading from the FS if "get" fails
> 4) "flush" as necessary to ensure coherency btwn page cache&  cleancache
> 5) destroy the tmem pool when the FS is unmounted
>
> Hooks for page cache and VFS placed by Chris Mason
>    

No particular comments on the content of the patch for now, but on form:

I'd suggest splitting this up into several patches: one for the core VFS 
changes, and one for each filesystem, so that each filesystem maintainer 
can Ack the changes independently of the rest.  Also so you can set the 
patch author/signoffs appropriately for whoever did the work.

     J

> The term "cleancache" is used because only clean data
> can be cached using this interface.  The previous term
> ("precache") was deemed too generic and overloaded.
>
> Signed-off-by: Dan Magenheimer<dan.magenheimer@oracle.com>
>
>
>   fs/btrfs/extent_io.c                     |    9 +
>   fs/btrfs/super.c                         |    2
>   fs/buffer.c                              |    5
>   fs/ext3/super.c                          |    2
>   fs/ext4/super.c                          |    2
>   fs/mpage.c                               |    8
>   fs/ocfs2/super.c                         |    2
>   fs/super.c                               |    6
>   include/linux/cleancache.h               |   55 ++++++
>   include/linux/fs.h                       |    7
>   mm/cleancache.c                          |  184 +++++++++++++++++++++
>   mm/filemap.c                             |   11 +
>   mm/truncate.c                            |   10 +
>   13 files changed, 303 insertions(+)
>
> --- linux-2.6.32/fs/super.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/super.c	2009-12-17 13:51:04.000000000 -0700
> @@ -37,6 +37,7 @@
>   #include<linux/kobject.h>
>   #include<linux/mutex.h>
>   #include<linux/file.h>
> +#include<linux/cleancache.h>
>   #include<asm/uaccess.h>
>   #include "internal.h"
>
> @@ -104,6 +105,9 @@ static struct super_block *alloc_super(s
>   		s->s_qcop = sb_quotactl_ops;
>   		s->s_op =&default_op;
>   		s->s_time_gran = 1000000000;
> +#ifdef CONFIG_CLEANCACHE
> +		s->cleancache_poolid = -1;
> +#endif
>   	}
>   out:
>   	return s;
> @@ -194,6 +198,7 @@ void deactivate_super(struct super_block
>   		vfs_dq_off(s, 0);
>   		down_write(&s->s_umount);
>   		fs->kill_sb(s);
> +		cleancache_flush_filesystem(s);
>   		put_filesystem(fs);
>   		put_super(s);
>   	}
> @@ -220,6 +225,7 @@ void deactivate_locked_super(struct supe
>   		spin_unlock(&sb_lock);
>   		vfs_dq_off(s, 0);
>   		fs->kill_sb(s);
> +		cleancache_flush_filesystem(s);
>   		put_filesystem(fs);
>   		put_super(s);
>   	} else {
> --- linux-2.6.32/fs/ext3/super.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/ext3/super.c	2009-12-17 13:51:24.000000000 -0700
> @@ -37,6 +37,7 @@
>   #include<linux/quotaops.h>
>   #include<linux/seq_file.h>
>   #include<linux/log2.h>
> +#include<linux/cleancache.h>
>
>   #include<asm/uaccess.h>
>
> @@ -1307,6 +1308,7 @@ static int ext3_setup_super(struct super
>   	} else {
>   		printk("internal journal\n");
>   	}
> +	cleancache_init(sb);
>   	return res;
>   }
>
> --- linux-2.6.32/include/linux/fs.h	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/include/linux/fs.h	2009-12-17 15:29:35.000000000 -0700
> @@ -1380,6 +1380,13 @@ struct super_block {
>   	 * generic_show_options()
>   	 */
>   	char *s_options;
> +
> +#ifdef CONFIG_CLEANCACHE
> +	/*
> +	 * Saved pool identifier for cleancache (-1 means none)
> +	 */
> +	u32 cleancache_poolid;
> +#endif
>   };
>
>   extern struct timespec current_fs_time(struct super_block *sb);
> --- linux-2.6.32/fs/buffer.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/buffer.c	2009-12-17 13:50:32.000000000 -0700
> @@ -41,6 +41,7 @@
>   #include<linux/bitops.h>
>   #include<linux/mpage.h>
>   #include<linux/bit_spinlock.h>
> +#include<linux/cleancache.h>
>
>   static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
>
> @@ -276,6 +277,10 @@ void invalidate_bdev(struct block_device
>
>   	invalidate_bh_lrus();
>   	invalidate_mapping_pages(mapping, 0, -1);
> +	/* 99% of the time, we don't need to flush the cleancache on the bdev.
> +	 * But, for the strange corners, lets be cautious
> +	 */
> +	cleancache_flush_inode(mapping);
>   }
>   EXPORT_SYMBOL(invalidate_bdev);
>
> --- linux-2.6.32/fs/mpage.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/mpage.c	2009-12-17 13:50:37.000000000 -0700
> @@ -26,6 +26,7 @@
>   #include<linux/writeback.h>
>   #include<linux/backing-dev.h>
>   #include<linux/pagevec.h>
> +#include<linux/cleancache.h>
>
>   /*
>    * I/O completion handler for multipage BIOs.
> @@ -285,6 +286,13 @@ do_mpage_readpage(struct bio *bio, struc
>   		SetPageMappedToDisk(page);
>   	}
>
> +	if (fully_mapped&&
> +	    blocks_per_page == 1&&  !PageUptodate(page)&&
> +	    cleancache_get(page->mapping, page->index, page) == 1) {
> +		SetPageUptodate(page);
> +		goto confused;
> +	}
> +
>   	/*
>   	 * This page will go to BIO.  Do we need to send this BIO off first?
>   	 */
> --- linux-2.6.32/fs/btrfs/super.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/btrfs/super.c	2009-12-17 13:50:16.000000000 -0700
> @@ -38,6 +38,7 @@
>   #include<linux/namei.h>
>   #include<linux/miscdevice.h>
>   #include<linux/magic.h>
> +#include<linux/cleancache.h>
>   #include "compat.h"
>   #include "ctree.h"
>   #include "disk-io.h"
> @@ -387,6 +388,7 @@ static int btrfs_fill_super(struct super
>   	sb->s_root = root_dentry;
>
>   	save_mount_options(sb, data);
> +	cleancache_init(sb);
>   	return 0;
>
>   fail_close:
> --- linux-2.6.32/fs/btrfs/extent_io.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/btrfs/extent_io.c	2009-12-17 15:28:33.000000000 -0700
> @@ -11,6 +11,7 @@
>   #include<linux/swap.h>
>   #include<linux/writeback.h>
>   #include<linux/pagevec.h>
> +#include<linux/cleancache.h>
>   #include "extent_io.h"
>   #include "extent_map.h"
>   #include "compat.h"
> @@ -2015,6 +2016,13 @@ static int __extent_read_full_page(struc
>
>   	set_page_extent_mapped(page);
>
> +	if (!PageUptodate(page)) {
> +		if (cleancache_get(page->mapping, page->index, page) == 1) {
> +			BUG_ON(blocksize != PAGE_SIZE);
> +			goto out;
> +		}
> +	}
> +
>   	end = page_end;
>   	lock_extent(tree, start, end, GFP_NOFS);
>
> @@ -2131,6 +2139,7 @@ static int __extent_read_full_page(struc
>   		cur = cur + iosize;
>   		page_offset += iosize;
>   	}
> +out:
>   	if (!nr) {
>   		if (!PageError(page))
>   			SetPageUptodate(page);
> --- linux-2.6.32/fs/ocfs2/super.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/ocfs2/super.c	2009-12-17 13:51:11.000000000 -0700
> @@ -42,6 +42,7 @@
>   #include<linux/seq_file.h>
>   #include<linux/quotaops.h>
>   #include<linux/smp_lock.h>
> +#include<linux/cleancache.h>
>
>   #define MLOG_MASK_PREFIX ML_SUPER
>   #include<cluster/masklog.h>
> @@ -2228,6 +2229,7 @@ static int ocfs2_initialize_super(struct
>   		mlog_errno(status);
>   		goto bail;
>   	}
> +	shared_cleancache_init(sb,&di->id2.i_super.s_uuid[0]);
>
>   bail:
>   	mlog_exit(status);
> --- linux-2.6.32/fs/ext4/super.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/fs/ext4/super.c	2009-12-17 13:51:17.000000000 -0700
> @@ -39,6 +39,7 @@
>   #include<linux/ctype.h>
>   #include<linux/log2.h>
>   #include<linux/crc16.h>
> +#include<linux/cleancache.h>
>   #include<asm/uaccess.h>
>
>   #include "ext4.h"
> @@ -1660,6 +1661,7 @@ static int ext4_setup_super(struct super
>   			EXT4_INODES_PER_GROUP(sb),
>   			sbi->s_mount_opt);
>
> +	cleancache_init(sb);
>   	return res;
>   }
>
> --- linux-2.6.32/mm/truncate.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/mm/truncate.c	2009-12-17 13:56:31.000000000 -0700
> @@ -18,6 +18,7 @@
>   #include<linux/task_io_accounting_ops.h>
>   #include<linux/buffer_head.h>	/* grr. try_to_release_page,
>   				   do_invalidatepage */
> +#include<linux/cleancache.h>
>   #include "internal.h"
>
>
> @@ -50,6 +51,7 @@ void do_invalidatepage(struct page *page
>   static inline void truncate_partial_page(struct page *page, unsigned partial)
>   {
>   	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
> +	cleancache_flush(page->mapping, page->index);
>   	if (page_has_private(page))
>   		do_invalidatepage(page, partial);
>   }
> @@ -107,6 +109,10 @@ truncate_complete_page(struct address_sp
>   	clear_page_mlock(page);
>   	remove_from_page_cache(page);
>   	ClearPageMappedToDisk(page);
> +	/* this must be after the remove_from_page_cache which
> +	 * calls cleancache_put
> +	 */
> +	cleancache_flush(mapping, page->index);
>   	page_cache_release(page);	/* pagecache ref */
>   	return 0;
>   }
> @@ -214,6 +220,7 @@ void truncate_inode_pages_range(struct a
>   	pgoff_t next;
>   	int i;
>
> +	cleancache_flush_inode(mapping);
>   	if (mapping->nrpages == 0)
>   		return;
>
> @@ -287,6 +294,7 @@ void truncate_inode_pages_range(struct a
>   		}
>   		pagevec_release(&pvec);
>   	}
> +	cleancache_flush_inode(mapping);
>   }
>   EXPORT_SYMBOL(truncate_inode_pages_range);
>
> @@ -423,6 +431,7 @@ int invalidate_inode_pages2_range(struct
>   	int did_range_unmap = 0;
>   	int wrapped = 0;
>
> +	cleancache_flush_inode(mapping);
>   	pagevec_init(&pvec, 0);
>   	next = start;
>   	while (next<= end&&  !wrapped&&
> @@ -479,6 +488,7 @@ int invalidate_inode_pages2_range(struct
>   		pagevec_release(&pvec);
>   		cond_resched();
>   	}
> +	cleancache_flush_inode(mapping);
>   	return ret;
>   }
>   EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);
> --- linux-2.6.32/mm/filemap.c	2009-12-02 20:51:21.000000000 -0700
> +++ linux-2.6.32-tmem/mm/filemap.c	2009-12-17 13:56:55.000000000 -0700
> @@ -34,6 +34,7 @@
>   #include<linux/hardirq.h>  /* for BUG_ON(!in_atomic()) only */
>   #include<linux/memcontrol.h>
>   #include<linux/mm_inline.h>  /* for page_is_file_cache() */
> +#include<linux/cleancache.h>
>   #include "internal.h"
>
>   /*
> @@ -119,6 +120,16 @@ void __remove_from_page_cache(struct pag
>   {
>   	struct address_space *mapping = page->mapping;
>
> +	/*
> +	 * if we're uptodate, flush out into the cleancache, otherwise
> +	 * invalidate any existing cleancache entries.  We can't leave
> +	 * stale data around in the cleancache once our page is gone
> +	 */
> +	if (PageUptodate(page))
> +		cleancache_put(page->mapping, page->index, page);
> +	else
> +		cleancache_flush(page->mapping, page->index);
> +
>   	radix_tree_delete(&mapping->page_tree, page->index);
>   	page->mapping = NULL;
>   	mapping->nrpages--;
> --- linux-2.6.32/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.32-tmem/include/linux/cleancache.h	2009-12-17 13:41:04.000000000 -0700
> @@ -0,0 +1,55 @@
> +#ifndef _LINUX_CLEANCACHE_H
> +
> +#include<linux/fs.h>
> +#include<linux/mm.h>
> +
> +#ifdef CONFIG_CLEANCACHE
> +extern void cleancache_init(struct super_block *sb);
> +extern void shared_cleancache_init(struct super_block *sb, char *uuid);
> +extern int cleancache_get(struct address_space *mapping, unsigned long index,
> +	       struct page *empty_page);
> +extern int cleancache_put(struct address_space *mapping, unsigned long index,
> +		struct page *page);
> +extern int cleancache_flush(struct address_space *mapping, unsigned long index);
> +extern int cleancache_flush_inode(struct address_space *mapping);
> +extern int cleancache_flush_filesystem(struct super_block *s);
> +#else
> +static inline void cleancache_init(struct super_block *sb)
> +{
> +}
> +
> +static inline void shared_cleancache_init(struct super_block *sb, char *uuid)
> +{
> +}
> +
> +static inline int cleancache_get(struct address_space *mapping,
> +		unsigned long index, struct page *empty_page)
> +{
> +	return 0;
> +}
> +
> +static inline int cleancache_put(struct address_space *mapping,
> +		unsigned long index, struct page *page)
> +{
> +	return 0;
> +}
> +
> +static inline int cleancache_flush(struct address_space *mapping,
> +		unsigned long index)
> +{
> +	return 0;
> +}
> +
> +static inline int cleancache_flush_inode(struct address_space *mapping)
> +{
> +	return 0;
> +}
> +
> +static inline int cleancache_flush_filesystem(struct super_block *s)
> +{
> +	return 0;
> +}
> +#endif
> +
> +#define _LINUX_CLEANCACHE_H
> +#endif /* _LINUX_CLEANCACHE_H */
> --- linux-2.6.32/mm/cleancache.c	1969-12-31 17:00:00.000000000 -0700
> +++ linux-2.6.32-tmem/mm/cleancache.c	2009-12-17 15:30:59.000000000 -0700
> @@ -0,0 +1,184 @@
> +/*
> + * linux/mm/cleancache.c
> + *
> + * Implements a page-granularity clean cache for filesystems/pagecache on the
> + * transcendent * memory ("tmem") API.  A filesystem creates an "ephemeral
> + * tmem pool" and retains the returned pool_id in its superblock.  Clean pages
> + * evicted from pagecache may be "put" into the pool and associated with a
> + * "handle" consisting of the pool_id, an object (inode) id, and an index (page
> + * offset).  Note that the page is copied to tmem; no kernel mappings are
> + * changed. If the page is later needed, the filesystem (or VFS) issues a "get",
> + * passing the same handle and an empty pageframe.  If successful, the page is
> + * copied into the pageframe and a disk read is avoided.  But since the tmem
> + * pool is of indeterminate size, a "put" page has indeterminate longevity
> + * ("ephemeral"), and the "get" may fail, in which case the filesystem must
> + * read the page from disk as before.  Note that the filesystem/pagecache are
> + * responsible for maintaining coherency between the pagecache, tmem's clean
> + * cache and the disk, for which "flush page" and "flush object" actions
> + * are provided.  And when a filesystem is unmounted, it must "destroy"
> + * the pool.
> + *
> + * Tmem supports two different modes for a cleancache: "private" or "shared".
> + * Shared pools are still under development. For a private pool, a successful
> + * "get" always flushes, implementing "exclusive cache" semantics.  Note
> + * that a failed "duplicate" put (overwrite) always guarantees the old data
> + * is flushed.
> + *
> + * Note also that multiple accesses to a tmem pool may be concurrent and any
> + * ordering must be guaranteed by the caller.
> + *
> + * Copyright (C) 2008,2009 Dan Magenheimer, Oracle Corp.
> + */
> +
> +#include<linux/cleancache.h>
> +#include<linux/module.h>
> +#include<linux/tmem.h>
> +
> +static int cleancache_auto_allocate; /* set to 1 to auto_allocate */
> +static unsigned long cleancache_puts;
> +static unsigned long cleancache_succ_gets;
> +static unsigned long cleancache_failed_gets;
> +
> +int cleancache_put(struct address_space *mapping, unsigned long index,
> + struct page *page)
> +{
> +	u32 tmem_pool = mapping->host->i_sb->cleancache_poolid;
> +	u64 obj = (unsigned long) mapping->host->i_ino;
> +	u32 ind = (u32) index;
> +	unsigned long pfn = page_to_pfn(page);
> +	struct tmem_pool_uuid uuid_private = TMEM_POOL_PRIVATE_UUID;
> +	int ret;
> +
> +	if ((s32)tmem_pool<  0) {
> +		if (!cleancache_auto_allocate)
> +			return 0;
> +		/* a put on a non-existent cleancache may auto-allocate one */
> +		ret = tmem_new_pool(uuid_private, 0);
> +		if (ret<  0)
> +			return 0;
> +		printk(KERN_INFO
> +			"Mapping superblock for s_id=%s to cleancache_id=%d\n",
> +			mapping->host->i_sb->s_id, tmem_pool);
> +		mapping->host->i_sb->cleancache_poolid = tmem_pool;
> +	}
> +	if (ind != index)
> +		return 0;
> +	mb(); /* ensure page is quiescent; tmem may address it with an alias */
> +	cleancache_puts++;
> +	return tmem_put_page(tmem_pool, obj, ind, pfn);
> +}
> +
> +int cleancache_get(struct address_space *mapping, unsigned long index,
> + struct page *empty_page)
> +{
> +	u32 tmem_pool = mapping->host->i_sb->cleancache_poolid;
> +	u64 obj = (unsigned long) mapping->host->i_ino;
> +	u32 ind = (u32) index;
> +	unsigned long pfn = page_to_pfn(empty_page);
> +	int ret;
> +
> +	if ((s32)tmem_pool<  0)
> +		return 0;
> +	if (ind != index)
> +		return 0;
> +
> +	ret = tmem_get_page(tmem_pool, obj, ind, pfn);
> +	if (ret == 1)
> +		cleancache_succ_gets++;
> +	else
> +		cleancache_failed_gets++;
> +	return ret;
> +}
> +EXPORT_SYMBOL(cleancache_get);
> +
> +int cleancache_flush(struct address_space *mapping, unsigned long index)
> +{
> +	u32 tmem_pool = mapping->host->i_sb->cleancache_poolid;
> +	u64 obj = (unsigned long) mapping->host->i_ino;
> +	u32 ind = (u32) index;
> +
> +	if ((s32)tmem_pool<  0)
> +		return 0;
> +	if (ind != index)
> +		return 0;
> +
> +	return tmem_flush_page(tmem_pool, obj, ind);
> +}
> +EXPORT_SYMBOL(cleancache_flush);
> +
> +int cleancache_flush_inode(struct address_space *mapping)
> +{
> +	u32 tmem_pool = mapping->host->i_sb->cleancache_poolid;
> +	u64 obj = (unsigned long) mapping->host->i_ino;
> +
> +	if ((s32)tmem_pool<  0)
> +		return 0;
> +
> +	return tmem_flush_object(tmem_pool, obj);
> +}
> +EXPORT_SYMBOL(cleancache_flush_inode);
> +
> +int cleancache_flush_filesystem(struct super_block *sb)
> +{
> +	u32 tmem_pool = sb->cleancache_poolid;
> +	int ret;
> +
> +	if ((s32)tmem_pool<  0)
> +		return 0;
> +	ret = tmem_destroy_pool(tmem_pool);
> +	if (!ret)
> +		return 0;
> +	printk(KERN_INFO
> +		"Unmapping superblock for s_id=%s from cleancache_id=%d\n",
> +		sb->s_id, ret);
> +	sb->cleancache_poolid = 0;
> +	return 1;
> +}
> +EXPORT_SYMBOL(cleancache_flush_filesystem);
> +
> +void cleancache_init(struct super_block *sb)
> +{
> +	struct tmem_pool_uuid uuid_private = TMEM_POOL_PRIVATE_UUID;
> +
> +	sb->cleancache_poolid = tmem_new_pool(uuid_private, 0);
> +}
> +EXPORT_SYMBOL(cleancache_init);
> +
> +void shared_cleancache_init(struct super_block *sb, char *uuid)
> +{
> +	struct tmem_pool_uuid shared_uuid;
> +
> +	shared_uuid.uuid_lo = *(u64 *)uuid;
> +	shared_uuid.uuid_hi = *(u64 *)(&uuid[8]);
> +	sb->cleancache_poolid = tmem_new_pool(shared_uuid, TMEM_POOL_SHARED);
> +}
> +EXPORT_SYMBOL(shared_cleancache_init);
> +
> +#ifdef CONFIG_SYSCTL
> +#include<linux/sysctl.h>
> +
> +ctl_table cleancache_table[] = {
> +	{
> +		.procname	= "puts",
> +		.data		=&cleancache_puts,
> +		.maxlen		= sizeof(unsigned long),
> +		.mode		= 0444,
> +		.proc_handler	=&proc_doulongvec_minmax,
> +	},
> +	{
> +		.procname	= "succ_gets",
> +		.data		=&cleancache_succ_gets,
> +		.maxlen		= sizeof(unsigned long),
> +		.mode		= 0444,
> +		.proc_handler	=&proc_doulongvec_minmax,
> +	},
> +	{
> +		.procname	= "failed_gets",
> +		.data		=&cleancache_failed_gets,
> +		.maxlen		= sizeof(unsigned long),
> +		.mode		= 0444,
> +		.proc_handler	=&proc_doulongvec_minmax,
> +	},
> +	{ .ctl_name = 0 }
> +};
> +#endif /* CONFIG_SYSCTL */
>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
