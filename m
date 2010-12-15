Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 842426B008C
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 23:33:10 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oBF4X3tF015130
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 20:33:06 -0800
Received: from iwn38 (iwn38.prod.google.com [10.241.68.102])
	by kpbe16.cbf.corp.google.com with ESMTP id oBF4VghW011513
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 20:33:02 -0800
Received: by iwn38 with SMTP id 38so1663351iwn.36
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 20:33:00 -0800 (PST)
Date: Tue, 14 Dec 2010 20:32:49 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/truncate.c:475!
In-Reply-To: <E1PSSO8-0003sy-Vr@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LSU.2.00.1012142020030.12693@tigran.mtv.corp.google.com>
References: <20101130194945.58962c44@xenia.leun.net> <alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com> <E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu> <20101201124528.6809c539@xenia.leun.net> <E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
 <20101202084159.6bff7355@xenia.leun.net> <20101202091552.4a63f717@xenia.leun.net> <E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu> <20101202115722.1c00afd5@xenia.leun.net> <20101203085350.55f94057@xenia.leun.net> <E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
 <20101206204303.1de6277b@xenia.leun.net> <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu> <20101213142059.643f8080.akpm@linux-foundation.org> <E1PSSO8-0003sy-Vr@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, robert@swiecki.net, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010, Miklos Szeredi wrote:
> On Mon, 13 Dec 2010, Andrew Morton wrote:
> > That's a pretty old bug, isn't it?  5+ years.
> 
> Probably.  Not easy to trigger, though.
> 
> > > +
> > > +	clear_bit_unlock(AS_UNMAPPING, &mapping->flags);
> > > +	smp_mb__after_clear_bit();
> > > +	wake_up_bit(&mapping->flags, AS_UNMAPPING);
> > > +
> > 
> > I do think this was premature optimisation.  The open-coded lock is
> > hidden from lockdep so we won't find out if this introduces potential
> > deadlocks.  It would be better to add a new mutex at least temporarily,
> > then look at replacing it with a MiklosLock later on, when the code is
> > bedded in.
> > 
> > At which time, replacing mutexes with MiklosLocks becomes part of a
> > general "shrink the address_space" exercise in which there's no reason
> > to exclusively concentrate on that new mutex!
> 
> Okay, updated patch appended.
> 
> > How hard is it to avoid adding a new lock and using an existing one,
> > presumablt i_mutex?  Because if we can get i_mutex coverage over
> > unmap_mapping_range() then I suspect all the
> > vm_truncate_count/restart_addr stuff can go away?
> 
> One place I know it's hard to get i_mutex coverage is fuse's
> d_revalidate.  That's because ->d_revalidate might be called with or
> without i_mutex at the discretion of the VFS.

Right, pity we weren't stricter about that.

> 
> You might ask, why does fuse call invalidate_inode_pages2() from
> d_revalidate?  The answer is, fuse does lookup revalidation and
> attribute revalidation in one go, and if it finds that the lookup is
> still valid but the file contents have changed, then it will need to
> invalidate the page cache.
> 
> Thanks,
> Miklos
> 

Yes, this looks to me like what is needed for now.

I'd feel rather happier about it if I thought it would also fix
Robert's kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
but I've still not found time to explain that one.

Robert, you said yours is usually repeatable in 12 hours - any chance
you could give iknowthis a run with the patch below, to see if it
makes any difference to yours?  (I admit I don't see how it would.)

Thanks,
Hugh

> 
> ---
 fs/gfs2/main.c     |    9 +--------
 fs/inode.c         |   22 +++++++++++++++-------
 fs/nilfs2/btnode.c |    5 -----
 fs/nilfs2/btnode.h |    1 -
 fs/nilfs2/mdt.c    |    4 ++--
 fs/nilfs2/page.c   |   13 -------------
 fs/nilfs2/page.h   |    1 -
 fs/nilfs2/super.c  |    2 +-
 include/linux/fs.h |    2 ++
 mm/memory.c        |    2 ++
 10 files changed, 23 insertions(+), 38 deletions(-)

Index: linux.git/mm/memory.c
===================================================================
--- linux.git.orig/mm/memory.c	2010-12-11 14:09:55.000000000 +0100
+++ linux.git/mm/memory.c	2010-12-14 11:20:47.000000000 +0100
@@ -2572,6 +2572,7 @@ void unmap_mapping_range(struct address_
 		details.last_index = ULONG_MAX;
 	details.i_mmap_lock = &mapping->i_mmap_lock;
 
+	mutex_lock(&mapping->unmap_mutex);
 	spin_lock(&mapping->i_mmap_lock);
 
 	/* Protect against endless unmapping loops */
@@ -2588,6 +2589,7 @@ void unmap_mapping_range(struct address_
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
 	spin_unlock(&mapping->i_mmap_lock);
+	mutex_unlock(&mapping->unmap_mutex);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
Index: linux.git/fs/gfs2/main.c
===================================================================
--- linux.git.orig/fs/gfs2/main.c	2010-11-26 10:52:16.000000000 +0100
+++ linux.git/fs/gfs2/main.c	2010-12-14 11:15:53.000000000 +0100
@@ -59,14 +59,7 @@ static void gfs2_init_gl_aspace_once(voi
 	struct address_space *mapping = (struct address_space *)(gl + 1);
 
 	gfs2_init_glock_once(gl);
-	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
-	spin_lock_init(&mapping->tree_lock);
-	spin_lock_init(&mapping->i_mmap_lock);
-	INIT_LIST_HEAD(&mapping->private_list);
-	spin_lock_init(&mapping->private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	address_space_init_once(mapping);
 }
 
 /**
Index: linux.git/fs/inode.c
===================================================================
--- linux.git.orig/fs/inode.c	2010-11-26 10:52:16.000000000 +0100
+++ linux.git/fs/inode.c	2010-12-14 11:21:49.000000000 +0100
@@ -280,6 +280,20 @@ static void destroy_inode(struct inode *
 		kmem_cache_free(inode_cachep, (inode));
 }
 
+void address_space_init_once(struct address_space *mapping)
+{
+	memset(mapping, 0, sizeof(*mapping));
+	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
+	spin_lock_init(&mapping->tree_lock);
+	spin_lock_init(&mapping->i_mmap_lock);
+	INIT_LIST_HEAD(&mapping->private_list);
+	spin_lock_init(&mapping->private_lock);
+	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
+	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
+	mutex_init(&mapping->unmap_mutex);
+}
+EXPORT_SYMBOL(address_space_init_once);
+
 /*
  * These are initializations that only need to be done
  * once, because the fields are idempotent across use
@@ -293,13 +307,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_devices);
 	INIT_LIST_HEAD(&inode->i_wb_list);
 	INIT_LIST_HEAD(&inode->i_lru);
-	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	spin_lock_init(&inode->i_data.tree_lock);
-	spin_lock_init(&inode->i_data.i_mmap_lock);
-	INIT_LIST_HEAD(&inode->i_data.private_list);
-	spin_lock_init(&inode->i_data.private_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
-	INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
+	address_space_init_once(&inode->i_data);
 	i_size_ordered_init(inode);
 #ifdef CONFIG_FSNOTIFY
 	INIT_HLIST_HEAD(&inode->i_fsnotify_marks);
Index: linux.git/fs/nilfs2/btnode.c
===================================================================
--- linux.git.orig/fs/nilfs2/btnode.c	2010-11-26 10:52:17.000000000 +0100
+++ linux.git/fs/nilfs2/btnode.c	2010-12-14 11:19:52.000000000 +0100
@@ -35,11 +35,6 @@
 #include "btnode.h"
 
 
-void nilfs_btnode_cache_init_once(struct address_space *btnc)
-{
-	nilfs_mapping_init_once(btnc);
-}
-
 static const struct address_space_operations def_btnode_aops = {
 	.sync_page		= block_sync_page,
 };
Index: linux.git/fs/nilfs2/btnode.h
===================================================================
--- linux.git.orig/fs/nilfs2/btnode.h	2010-10-05 18:49:12.000000000 +0200
+++ linux.git/fs/nilfs2/btnode.h	2010-12-14 11:20:01.000000000 +0100
@@ -37,7 +37,6 @@ struct nilfs_btnode_chkey_ctxt {
 	struct buffer_head *newbh;
 };
 
-void nilfs_btnode_cache_init_once(struct address_space *);
 void nilfs_btnode_cache_init(struct address_space *, struct backing_dev_info *);
 void nilfs_btnode_cache_clear(struct address_space *);
 struct buffer_head *nilfs_btnode_create_block(struct address_space *btnc,
Index: linux.git/fs/nilfs2/mdt.c
===================================================================
--- linux.git.orig/fs/nilfs2/mdt.c	2010-11-26 10:52:17.000000000 +0100
+++ linux.git/fs/nilfs2/mdt.c	2010-12-14 11:18:18.000000000 +0100
@@ -460,9 +460,9 @@ int nilfs_mdt_setup_shadow_map(struct in
 	struct backing_dev_info *bdi = inode->i_sb->s_bdi;
 
 	INIT_LIST_HEAD(&shadow->frozen_buffers);
-	nilfs_mapping_init_once(&shadow->frozen_data);
+	address_space_init_once(&shadow->frozen_data);
 	nilfs_mapping_init(&shadow->frozen_data, bdi, &shadow_map_aops);
-	nilfs_mapping_init_once(&shadow->frozen_btnodes);
+	address_space_init_once(&shadow->frozen_btnodes);
 	nilfs_mapping_init(&shadow->frozen_btnodes, bdi, &shadow_map_aops);
 	mi->mi_shadow = shadow;
 	return 0;
Index: linux.git/fs/nilfs2/page.c
===================================================================
--- linux.git.orig/fs/nilfs2/page.c	2010-11-26 10:52:17.000000000 +0100
+++ linux.git/fs/nilfs2/page.c	2010-12-14 11:17:26.000000000 +0100
@@ -492,19 +492,6 @@ unsigned nilfs_page_count_clean_buffers(
 	return nc;
 }
  
-void nilfs_mapping_init_once(struct address_space *mapping)
-{
-	memset(mapping, 0, sizeof(*mapping));
-	INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
-	spin_lock_init(&mapping->tree_lock);
-	INIT_LIST_HEAD(&mapping->private_list);
-	spin_lock_init(&mapping->private_lock);
-
-	spin_lock_init(&mapping->i_mmap_lock);
-	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
-	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-}
-
 void nilfs_mapping_init(struct address_space *mapping,
 			struct backing_dev_info *bdi,
 			const struct address_space_operations *aops)
Index: linux.git/fs/nilfs2/page.h
===================================================================
--- linux.git.orig/fs/nilfs2/page.h	2010-11-26 10:52:17.000000000 +0100
+++ linux.git/fs/nilfs2/page.h	2010-12-14 11:17:35.000000000 +0100
@@ -61,7 +61,6 @@ void nilfs_free_private_page(struct page
 int nilfs_copy_dirty_pages(struct address_space *, struct address_space *);
 void nilfs_copy_back_pages(struct address_space *, struct address_space *);
 void nilfs_clear_dirty_pages(struct address_space *);
-void nilfs_mapping_init_once(struct address_space *mapping);
 void nilfs_mapping_init(struct address_space *mapping,
 			struct backing_dev_info *bdi,
 			const struct address_space_operations *aops);
Index: linux.git/fs/nilfs2/super.c
===================================================================
--- linux.git.orig/fs/nilfs2/super.c	2010-11-26 10:52:17.000000000 +0100
+++ linux.git/fs/nilfs2/super.c	2010-12-14 11:20:19.000000000 +0100
@@ -1262,7 +1262,7 @@ static void nilfs_inode_init_once(void *
 #ifdef CONFIG_NILFS_XATTR
 	init_rwsem(&ii->xattr_sem);
 #endif
-	nilfs_btnode_cache_init_once(&ii->i_btnode_cache);
+	address_space_init_once(&ii->i_btnode_cache);
 	ii->i_bmap = &ii->i_bmap_data;
 	inode_init_once(&ii->vfs_inode);
 }
Index: linux.git/include/linux/fs.h
===================================================================
--- linux.git.orig/include/linux/fs.h	2010-12-07 20:17:55.000000000 +0100
+++ linux.git/include/linux/fs.h	2010-12-14 11:21:30.000000000 +0100
@@ -645,6 +645,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+	struct mutex		unmap_mutex;    /* to protect unmapping */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -2205,6 +2206,7 @@ extern loff_t vfs_llseek(struct file *fi
 
 extern int inode_init_always(struct super_block *, struct inode *);
 extern void inode_init_once(struct inode *);
+extern void address_space_init_once(struct address_space *mapping);
 extern void ihold(struct inode * inode);
 extern void iput(struct inode *);
 extern struct inode * igrab(struct inode *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
