Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3445A8D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 17:20:45 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p1NMKK30019693
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 14:20:20 -0800
Received: from yxi11 (yxi11.prod.google.com [10.190.3.11])
	by wpaz1.hot.corp.google.com with ESMTP id p1NMKH1Q029210
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 14:20:19 -0800
Received: by yxi11 with SMTP id 11so2985589yxi.15
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 14:20:17 -0800 (PST)
Date: Wed, 23 Feb 2011 14:20:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH]  mm: prevent concurrent unmap_mapping_range() on the
 same inode
In-Reply-To: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LSU.2.00.1102231354140.5493@sister.anvils>
References: <E1PsEA7-0007G0-29@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hch@infradead.org, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, rjw@sisk.pl, florian@mickler.org, trond.myklebust@fys.uio.no, maciej.rutecki@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 23 Feb 2011, Miklos Szeredi wrote:

> Linus, Andrew,
> 
> This resolves Bug 25822 listed in the regressions since 2.6.36 (though
> it's a bug much older than that, for some reason it only started
> triggering for people recently).
> 
> Summary of discussion of below patch by Hugh:
> 
>    An executive summary of the thread that followed would be that hch
>    dislikes the bloat, as we all do, but Miklos and I don't see a
>    decent alternative (and hch has not proposed one).
> 
> Please consider this for 2.6.38.
> 
> Thanks,
> Miklos
> 
> ----
> Subject: mm: prevent concurrent unmap_mapping_range() on the same inode
> 
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> Michael Leun reported that running parallel opens on a fuse filesystem
> can trigger a "kernel BUG at mm/truncate.c:475"
> 
> Gurudas Pai reported the same bug on NFS.
> 
> The reason is, unmap_mapping_range() is not prepared for more than
> one concurrent invocation per inode.  For example:

Yes, at the time I did that preemptible restart stuff 6 years ago,
i_mutex was always held by callers of unmap_mapping_range(); and
I built that in as an assumption, without ever enforcing it with
a BUG to check.

>From that very time exceptions have been added, some with their own
serialization, some with none, so that now it's all too messy to fix
without a leadin time for weeding out and and trying (with uncertain
success) to rework its usage in miscellaneous filesystems (including
fuse, nfs, spufs, others and gpu/drm/i915 use of shmobjects).

> 
>   thread1: going through a big range, stops in the middle of a vma and
>      stores the restart address in vm_truncate_count.
> 
>   thread2: comes in with a small (e.g. single page) unmap request on
>      the same vma, somewhere before restart_address, finds that the
>      vma was already unmapped up to the restart address and happily
>      returns without doing anything.

We could probably hack something in cheaply to fix that part of it.

> 
> Another scenario would be two big unmap requests, both having to
> restart the unmapping and each one setting vm_truncate_count to its
> own value.  This could go on forever without any of them being able to
> finish.

But I don't know how to fix this part without proper serialization.

> 
> Truncate and hole punching already serialize with i_mutex.  Other
> callers of unmap_mapping_range() do not, and it's difficult to get
> i_mutex protection for all callers.  In particular ->d_revalidate(),
> which calls invalidate_inode_pages2_range() in fuse, may be called
> with or without i_mutex.
> 
> This patch adds a new mutex to 'struct address_space' to prevent
> running multiple concurrent unmap_mapping_range() on the same mapping.

Yes, I once had hopes to reuse i_alloc_sem for this purpose; but
it's taken outside of mmap_sem and this needs to be taken inside.

> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> Reported-by: Michael Leun <lkml20101129@newton.leun.net>
> Reported-by: Gurudas Pai <gurudas.pai@oracle.com>
> Tested-by: Gurudas Pai <gurudas.pai@oracle.com>

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org

I just tried again, and failed again, to come up with a better answer:
thanks for persisting, Miklos.

> ---
>  fs/gfs2/main.c     |    9 +--------
>  fs/inode.c         |   22 +++++++++++++++-------
>  fs/nilfs2/btnode.c |    5 -----
>  fs/nilfs2/btnode.h |    1 -
>  fs/nilfs2/mdt.c    |    4 ++--
>  fs/nilfs2/page.c   |   13 -------------
>  fs/nilfs2/page.h   |    1 -
>  fs/nilfs2/super.c  |    2 +-
>  include/linux/fs.h |    2 ++
>  mm/memory.c        |    2 ++
>  10 files changed, 23 insertions(+), 38 deletions(-)
> 
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c	2011-02-22 11:05:15.000000000 +0100
> +++ linux-2.6/mm/memory.c	2011-02-23 13:35:30.000000000 +0100
> @@ -2648,6 +2648,7 @@ void unmap_mapping_range(struct address_
>  		details.last_index = ULONG_MAX;
>  	details.i_mmap_lock = &mapping->i_mmap_lock;
>  
> +	mutex_lock(&mapping->unmap_mutex);
>  	spin_lock(&mapping->i_mmap_lock);
>  
>  	/* Protect against endless unmapping loops */
> @@ -2664,6 +2665,7 @@ void unmap_mapping_range(struct address_
>  	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
>  		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
>  	spin_unlock(&mapping->i_mmap_lock);
> +	mutex_unlock(&mapping->unmap_mutex);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> Index: linux-2.6/fs/gfs2/main.c
> ===================================================================
> --- linux-2.6.orig/fs/gfs2/main.c	2011-02-22 11:05:15.000000000 +0100
> +++ linux-2.6/fs/gfs2/main.c	2011-02-23 13:35:30.000000000 +0100
> @@ -59,14 +59,7 @@ static void gfs2_init_gl_aspace_once(voi
>  	struct address_space *mapping = (struct address_space *)(gl + 1);
>  
>  	gfs2_init_glock_once(gl);
> -	memset(mapping, 0, sizeof(*mapping));
> -	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> -	spin_lock_init(&mapping->tree_lock);
> -	spin_lock_init(&mapping->i_mmap_lock);
> -	INIT_LIST_HEAD(&mapping->private_list);
> -	spin_lock_init(&mapping->private_lock);
> -	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> -	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> +	address_space_init_once(mapping);
>  }
>  
>  /**
> Index: linux-2.6/fs/inode.c
> ===================================================================
> --- linux-2.6.orig/fs/inode.c	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/inode.c	2011-02-23 13:35:30.000000000 +0100
> @@ -295,6 +295,20 @@ static void destroy_inode(struct inode *
>  		call_rcu(&inode->i_rcu, i_callback);
>  }
>  
> +void address_space_init_once(struct address_space *mapping)
> +{
> +	memset(mapping, 0, sizeof(*mapping));
> +	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> +	spin_lock_init(&mapping->tree_lock);
> +	spin_lock_init(&mapping->i_mmap_lock);
> +	INIT_LIST_HEAD(&mapping->private_list);
> +	spin_lock_init(&mapping->private_lock);
> +	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> +	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> +	mutex_init(&mapping->unmap_mutex);
> +}
> +EXPORT_SYMBOL(address_space_init_once);
> +
>  /*
>   * These are initializations that only need to be done
>   * once, because the fields are idempotent across use
> @@ -308,13 +322,7 @@ void inode_init_once(struct inode *inode
>  	INIT_LIST_HEAD(&inode->i_devices);
>  	INIT_LIST_HEAD(&inode->i_wb_list);
>  	INIT_LIST_HEAD(&inode->i_lru);
> -	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
> -	spin_lock_init(&inode->i_data.tree_lock);
> -	spin_lock_init(&inode->i_data.i_mmap_lock);
> -	INIT_LIST_HEAD(&inode->i_data.private_list);
> -	spin_lock_init(&inode->i_data.private_lock);
> -	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
> -	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
> +	address_space_init_once(&inode->i_data);
>  	i_size_ordered_init(inode);
>  #ifdef CONFIG_FSNOTIFY
>  	INIT_HLIST_HEAD(&inode->i_fsnotify_marks);
> Index: linux-2.6/fs/nilfs2/btnode.c
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/btnode.c	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/nilfs2/btnode.c	2011-02-23 13:35:30.000000000 +0100
> @@ -35,11 +35,6 @@
>  #include "btnode.h"
>  
>  
> -void nilfs_btnode_cache_init_once(struct address_space *btnc)
> -{
> -	nilfs_mapping_init_once(btnc);
> -}
> -
>  static const struct address_space_operations def_btnode_aops = {
>  	.sync_page		= block_sync_page,
>  };
> Index: linux-2.6/fs/nilfs2/btnode.h
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/btnode.h	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/nilfs2/btnode.h	2011-02-23 13:35:30.000000000 +0100
> @@ -37,7 +37,6 @@ struct nilfs_btnode_chkey_ctxt {
>  	struct buffer_head *newbh;
>  };
>  
> -void nilfs_btnode_cache_init_once(struct address_space *);
>  void nilfs_btnode_cache_init(struct address_space *, struct backing_dev_info *);
>  void nilfs_btnode_cache_clear(struct address_space *);
>  struct buffer_head *nilfs_btnode_create_block(struct address_space *btnc,
> Index: linux-2.6/fs/nilfs2/mdt.c
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/mdt.c	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/nilfs2/mdt.c	2011-02-23 13:35:30.000000000 +0100
> @@ -454,9 +454,9 @@ int nilfs_mdt_setup_shadow_map(struct in
>  	struct backing_dev_info *bdi = inode->i_sb->s_bdi;
>  
>  	INIT_LIST_HEAD(&shadow->frozen_buffers);
> -	nilfs_mapping_init_once(&shadow->frozen_data);
> +	address_space_init_once(&shadow->frozen_data);
>  	nilfs_mapping_init(&shadow->frozen_data, bdi, &shadow_map_aops);
> -	nilfs_mapping_init_once(&shadow->frozen_btnodes);
> +	address_space_init_once(&shadow->frozen_btnodes);
>  	nilfs_mapping_init(&shadow->frozen_btnodes, bdi, &shadow_map_aops);
>  	mi->mi_shadow = shadow;
>  	return 0;
> Index: linux-2.6/fs/nilfs2/page.c
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/page.c	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/nilfs2/page.c	2011-02-23 13:35:30.000000000 +0100
> @@ -492,19 +492,6 @@ unsigned nilfs_page_count_clean_buffers(
>  	return nc;
>  }
>  
> -void nilfs_mapping_init_once(struct address_space *mapping)
> -{
> -	memset(mapping, 0, sizeof(*mapping));
> -	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> -	spin_lock_init(&mapping->tree_lock);
> -	INIT_LIST_HEAD(&mapping->private_list);
> -	spin_lock_init(&mapping->private_lock);
> -
> -	spin_lock_init(&mapping->i_mmap_lock);
> -	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> -	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> -}
> -
>  void nilfs_mapping_init(struct address_space *mapping,
>  			struct backing_dev_info *bdi,
>  			const struct address_space_operations *aops)
> Index: linux-2.6/fs/nilfs2/page.h
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/page.h	2011-01-20 13:28:34.000000000 +0100
> +++ linux-2.6/fs/nilfs2/page.h	2011-02-23 13:35:30.000000000 +0100
> @@ -61,7 +61,6 @@ void nilfs_free_private_page(struct page
>  int nilfs_copy_dirty_pages(struct address_space *, struct address_space *);
>  void nilfs_copy_back_pages(struct address_space *, struct address_space *);
>  void nilfs_clear_dirty_pages(struct address_space *);
> -void nilfs_mapping_init_once(struct address_space *mapping);
>  void nilfs_mapping_init(struct address_space *mapping,
>  			struct backing_dev_info *bdi,
>  			const struct address_space_operations *aops);
> Index: linux-2.6/fs/nilfs2/super.c
> ===================================================================
> --- linux-2.6.orig/fs/nilfs2/super.c	2011-02-07 17:05:19.000000000 +0100
> +++ linux-2.6/fs/nilfs2/super.c	2011-02-23 13:35:30.000000000 +0100
> @@ -1279,7 +1279,7 @@ static void nilfs_inode_init_once(void *
>  #ifdef CONFIG_NILFS_XATTR
>  	init_rwsem(&ii->xattr_sem);
>  #endif
> -	nilfs_btnode_cache_init_once(&ii->i_btnode_cache);
> +	address_space_init_once(&ii->i_btnode_cache);
>  	ii->i_bmap = &ii->i_bmap_data;
>  	inode_init_once(&ii->vfs_inode);
>  }
> Index: linux-2.6/include/linux/fs.h
> ===================================================================
> --- linux-2.6.orig/include/linux/fs.h	2011-02-22 11:04:39.000000000 +0100
> +++ linux-2.6/include/linux/fs.h	2011-02-23 13:35:30.000000000 +0100
> @@ -649,6 +649,7 @@ struct address_space {
>  	spinlock_t		private_lock;	/* for use by the address_space */
>  	struct list_head	private_list;	/* ditto */
>  	struct address_space	*assoc_mapping;	/* ditto */
> +	struct mutex		unmap_mutex;    /* to protect unmapping */
>  } __attribute__((aligned(sizeof(long))));
>  	/*
>  	 * On most architectures that alignment is already the case; but
> @@ -2225,6 +2226,7 @@ extern loff_t vfs_llseek(struct file *fi
>  
>  extern int inode_init_always(struct super_block *, struct inode *);
>  extern void inode_init_once(struct inode *);
> +extern void address_space_init_once(struct address_space *mapping);
>  extern void ihold(struct inode * inode);
>  extern void iput(struct inode *);
>  extern struct inode * igrab(struct inode *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
