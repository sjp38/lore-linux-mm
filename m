Message-Id: <200405222204.i4MM43r12404@mail.osdl.org>
Subject: [patch 09/57] slab: consolidate panic code
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:03:33 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Many places do:

	if (kmem_cache_create(...) == NULL)
		panic(...);

We can consolidate all that by passing another flag to kmem_cache_create()
which says "panic if it doesn't work".


---

 25-akpm/fs/aio.c             |    9 ++-------
 25-akpm/fs/bio.c             |   14 ++++++--------
 25-akpm/fs/block_dev.c       |   11 +++--------
 25-akpm/fs/buffer.c          |    2 +-
 25-akpm/fs/dcache.c          |   20 ++++++--------------
 25-akpm/fs/dnotify.c         |    4 +---
 25-akpm/fs/dquot.c           |    5 ++---
 25-akpm/fs/eventpoll.c       |   38 +++++++++++---------------------------
 25-akpm/fs/fcntl.c           |    5 +----
 25-akpm/fs/inode.c           |    8 ++------
 25-akpm/fs/locks.c           |    6 ++----
 25-akpm/fs/namespace.c       |    4 +---
 25-akpm/include/linux/slab.h |    1 +
 25-akpm/kernel/fork.c        |   40 ++++++++++------------------------------
 25-akpm/kernel/signal.c      |    4 +---
 25-akpm/kernel/user.c        |    5 +----
 25-akpm/lib/radix-tree.c     |    4 +---
 25-akpm/mm/rmap.c            |    5 +----
 25-akpm/mm/shmem.c           |    6 +++---
 25-akpm/mm/slab.c            |    8 +++++---
 25-akpm/net/socket.c         |    6 +++---
 21 files changed, 64 insertions(+), 141 deletions(-)

diff -puN fs/aio.c~slab-panic fs/aio.c
--- 25/fs/aio.c~slab-panic	2004-05-22 14:56:22.494671816 -0700
+++ 25-akpm/fs/aio.c	2004-05-22 14:56:22.527666800 -0700
@@ -64,14 +64,9 @@ static void aio_kick_handler(void *);
 static int __init aio_setup(void)
 {
 	kiocb_cachep = kmem_cache_create("kiocb", sizeof(struct kiocb),
-				0, SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!kiocb_cachep)
-		panic("unable to create kiocb cache\n");
-
+				0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	kioctx_cachep = kmem_cache_create("kioctx", sizeof(struct kioctx),
-				0, SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!kioctx_cachep)
-		panic("unable to create kioctx cache");
+				0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 	aio_wq = create_workqueue("aio");
 
diff -puN fs/bio.c~slab-panic fs/bio.c
--- 25/fs/bio.c~slab-panic	2004-05-22 14:56:22.496671512 -0700
+++ 25-akpm/fs/bio.c	2004-05-22 14:56:22.528666648 -0700
@@ -808,9 +808,7 @@ static void __init biovec_init_pools(voi
 		size = bp->nr_vecs * sizeof(struct bio_vec);
 
 		bp->slab = kmem_cache_create(bp->name, size, 0,
-						SLAB_HWCACHE_ALIGN, NULL, NULL);
-		if (!bp->slab)
-			panic("biovec: can't init slab cache\n");
+				SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 		if (i >= scale)
 			pool_entries >>= 1;
@@ -825,16 +823,16 @@ static void __init biovec_init_pools(voi
 static int __init init_bio(void)
 {
 	bio_slab = kmem_cache_create("bio", sizeof(struct bio), 0,
-					SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!bio_slab)
-		panic("bio: can't create slab cache\n");
-	bio_pool = mempool_create(BIO_POOL_SIZE, mempool_alloc_slab, mempool_free_slab, bio_slab);
+				SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+	bio_pool = mempool_create(BIO_POOL_SIZE, mempool_alloc_slab,
+				mempool_free_slab, bio_slab);
 	if (!bio_pool)
 		panic("bio: can't create mempool\n");
 
 	biovec_init_pools();
 
-	bio_split_pool = mempool_create(BIO_SPLIT_ENTRIES, bio_pair_alloc, bio_pair_free, NULL);
+	bio_split_pool = mempool_create(BIO_SPLIT_ENTRIES,
+				bio_pair_alloc, bio_pair_free, NULL);
 	if (!bio_split_pool)
 		panic("bio: can't create split pool\n");
 
diff -puN fs/block_dev.c~slab-panic fs/block_dev.c
--- 25/fs/block_dev.c~slab-panic	2004-05-22 14:56:22.497671360 -0700
+++ 25-akpm/fs/block_dev.c	2004-05-22 14:56:22.529666496 -0700
@@ -306,14 +306,9 @@ struct super_block *blockdev_superblock;
 void __init bdev_cache_init(void)
 {
 	int err;
-	bdev_cachep = kmem_cache_create("bdev_cache",
-					sizeof(struct bdev_inode),
-					0,
-					SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
-					init_once,
-					NULL);
-	if (!bdev_cachep)
-		panic("Cannot create bdev_cache SLAB cache");
+	bdev_cachep = kmem_cache_create("bdev_cache", sizeof(struct bdev_inode),
+			0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_PANIC,
+			init_once, NULL);
 	err = register_filesystem(&bd_type);
 	if (err)
 		panic("Cannot register bdev pseudo-fs");
diff -puN fs/buffer.c~slab-panic fs/buffer.c
--- 25/fs/buffer.c~slab-panic	2004-05-22 14:56:22.499671056 -0700
+++ 25-akpm/fs/buffer.c	2004-05-22 14:56:22.542664520 -0700
@@ -3100,7 +3100,7 @@ void __init buffer_init(void)
 
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
-			0, init_buffer_head, NULL);
+			SLAB_PANIC, init_buffer_head, NULL);
 	for (i = 0; i < ARRAY_SIZE(bh_wait_queue_heads); i++)
 		init_waitqueue_head(&bh_wait_queue_heads[i].wqh);
 
diff -puN fs/dcache.c~slab-panic fs/dcache.c
--- 25/fs/dcache.c~slab-panic	2004-05-22 14:56:22.501670752 -0700
+++ 25-akpm/fs/dcache.c	2004-05-22 14:56:22.543664368 -0700
@@ -1570,10 +1570,8 @@ static void __init dcache_init(unsigned 
 	dentry_cache = kmem_cache_create("dentry_cache",
 					 sizeof(struct dentry),
 					 0,
-					 SLAB_RECLAIM_ACCOUNT,
+					 SLAB_RECLAIM_ACCOUNT|SLAB_PANIC,
 					 NULL, NULL);
-	if (!dentry_cache)
-		panic("Cannot create dentry cache");
 	
 	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
 
@@ -1638,17 +1636,11 @@ void __init vfs_caches_init(unsigned lon
 	reserve = min((mempages - nr_free_pages()) * 3/2, mempages - 1);
 	mempages -= reserve;
 
-	names_cachep = kmem_cache_create("names_cache",
-			PATH_MAX, 0,
-			SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!names_cachep)
-		panic("Cannot create names SLAB cache");
-
-	filp_cachep = kmem_cache_create("filp",
-			sizeof(struct file), 0,
-			SLAB_HWCACHE_ALIGN, filp_ctor, filp_dtor);
-	if(!filp_cachep)
-		panic("Cannot create filp SLAB cache");
+	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+
+	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, filp_ctor, filp_dtor);
 
 	dcache_init(mempages);
 	inode_init(mempages);
diff -puN fs/dnotify.c~slab-panic fs/dnotify.c
--- 25/fs/dnotify.c~slab-panic	2004-05-22 14:56:22.502670600 -0700
+++ 25-akpm/fs/dnotify.c	2004-05-22 14:56:22.544664216 -0700
@@ -173,9 +173,7 @@ EXPORT_SYMBOL_GPL(dnotify_parent);
 static int __init dnotify_init(void)
 {
 	dn_cache = kmem_cache_create("dnotify_cache",
-		sizeof(struct dnotify_struct), 0, 0, NULL, NULL);
-	if (!dn_cache)
-		panic("cannot create dnotify slab cache");
+		sizeof(struct dnotify_struct), 0, SLAB_PANIC, NULL, NULL);
 	return 0;
 }
 
diff -puN fs/dquot.c~slab-panic fs/dquot.c
--- 25/fs/dquot.c~slab-panic	2004-05-22 14:56:22.504670296 -0700
+++ 25-akpm/fs/dquot.c	2004-05-22 14:56:22.545664064 -0700
@@ -1733,9 +1733,8 @@ static int __init dquot_init(void)
 
 	dquot_cachep = kmem_cache_create("dquot", 
 			sizeof(struct dquot), sizeof(unsigned long) * 4,
-			SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT, NULL, NULL);
-	if (!dquot_cachep)
-		panic("Cannot create dquot SLAB cache");
+			SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_PANIC,
+			NULL, NULL);
 
 	order = 0;
 	dquot_hash = (struct hlist_head *)__get_free_pages(GFP_ATOMIC, order);
diff -puN fs/eventpoll.c~slab-panic fs/eventpoll.c
--- 25/fs/eventpoll.c~slab-panic	2004-05-22 14:56:22.505670144 -0700
+++ 25-akpm/fs/eventpoll.c	2004-05-22 14:56:22.547663760 -0700
@@ -1695,22 +1695,14 @@ static int __init eventpoll_init(void)
 	ep_poll_safewake_init(&psw);
 
 	/* Allocates slab cache used to allocate "struct epitem" items */
-	error = -ENOMEM;
-	epi_cache = kmem_cache_create("eventpoll_epi",
-				      sizeof(struct epitem),
-				      0,
-				      SLAB_HWCACHE_ALIGN | EPI_SLAB_DEBUG, NULL, NULL);
-	if (!epi_cache)
-		goto eexit_1;
+	epi_cache = kmem_cache_create("eventpoll_epi", sizeof(struct epitem),
+			0, SLAB_HWCACHE_ALIGN|EPI_SLAB_DEBUG|SLAB_PANIC,
+			NULL, NULL);
 
 	/* Allocates slab cache used to allocate "struct eppoll_entry" */
-	error = -ENOMEM;
 	pwq_cache = kmem_cache_create("eventpoll_pwq",
-				      sizeof(struct eppoll_entry),
-				      0,
-				      EPI_SLAB_DEBUG, NULL, NULL);
-	if (!pwq_cache)
-		goto eexit_2;
+			sizeof(struct eppoll_entry), 0,
+			EPI_SLAB_DEBUG|SLAB_PANIC, NULL, NULL);
 
 	/*
 	 * Register the virtual file system that will be the source of inodes
@@ -1718,27 +1710,20 @@ static int __init eventpoll_init(void)
 	 */
 	error = register_filesystem(&eventpoll_fs_type);
 	if (error)
-		goto eexit_3;
+		goto epanic;
 
 	/* Mount the above commented virtual file system */
 	eventpoll_mnt = kern_mount(&eventpoll_fs_type);
 	error = PTR_ERR(eventpoll_mnt);
 	if (IS_ERR(eventpoll_mnt))
-		goto eexit_4;
-
-	DNPRINTK(3, (KERN_INFO "[%p] eventpoll: successfully initialized.\n", current));
+		goto epanic;
 
+	DNPRINTK(3, (KERN_INFO "[%p] eventpoll: successfully initialized.\n",
+			current));
 	return 0;
 
-eexit_4:
-	unregister_filesystem(&eventpoll_fs_type);
-eexit_3:
-	kmem_cache_destroy(pwq_cache);
-eexit_2:
-	kmem_cache_destroy(epi_cache);
-eexit_1:
-
-	return error;
+epanic:
+	panic("eventpoll_init() failed\n");
 }
 
 
@@ -1755,4 +1740,3 @@ module_init(eventpoll_init);
 module_exit(eventpoll_exit);
 
 MODULE_LICENSE("GPL");
-
diff -puN fs/fcntl.c~slab-panic fs/fcntl.c
--- 25/fs/fcntl.c~slab-panic	2004-05-22 14:56:22.506669992 -0700
+++ 25-akpm/fs/fcntl.c	2004-05-22 14:56:22.548663608 -0700
@@ -627,15 +627,12 @@ void kill_fasync(struct fasync_struct **
 		read_unlock(&fasync_lock);
 	}
 }
-
 EXPORT_SYMBOL(kill_fasync);
 
 static int __init fasync_init(void)
 {
 	fasync_cache = kmem_cache_create("fasync_cache",
-		sizeof(struct fasync_struct), 0, 0, NULL, NULL);
-	if (!fasync_cache)
-		panic("cannot create fasync slab cache");
+		sizeof(struct fasync_struct), 0, SLAB_PANIC, NULL, NULL);
 	return 0;
 }
 
diff -puN fs/inode.c~slab-panic fs/inode.c
--- 25/fs/inode.c~slab-panic	2004-05-22 14:56:22.508669688 -0700
+++ 25-akpm/fs/inode.c	2004-05-22 14:59:42.125323344 -0700
@@ -1396,11 +1396,8 @@ void __init inode_init(unsigned long mem
 
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache", sizeof(struct inode),
-					 0, SLAB_HWCACHE_ALIGN, init_once,
-					 NULL);
-	if (!inode_cachep)
-		panic("cannot create inode slab cache");
-
+				0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, init_once,
+				NULL);
 	set_shrinker(DEFAULT_SEEKS, shrink_icache_memory);
 }
 
@@ -1421,5 +1418,4 @@ void init_special_inode(struct inode *in
 		printk(KERN_DEBUG "init_special_inode: bogus i_mode (%o)\n",
 		       mode);
 }
-
 EXPORT_SYMBOL(init_special_inode);
diff -puN fs/locks.c~slab-panic fs/locks.c
--- 25/fs/locks.c~slab-panic	2004-05-22 14:56:22.509669536 -0700
+++ 25-akpm/fs/locks.c	2004-05-22 14:56:22.550663304 -0700
@@ -1994,15 +1994,13 @@ void steal_locks(fl_owner_t from)
 	}
 	unlock_kernel();
 }
-
 EXPORT_SYMBOL(steal_locks);
 
 static int __init filelock_init(void)
 {
 	filelock_cache = kmem_cache_create("file_lock_cache",
-			sizeof(struct file_lock), 0, 0, init_once, NULL);
-	if (!filelock_cache)
-		panic("cannot create file lock slab cache");
+			sizeof(struct file_lock), 0, SLAB_PANIC,
+			init_once, NULL);
 	return 0;
 }
 
diff -puN fs/namespace.c~slab-panic fs/namespace.c
--- 25/fs/namespace.c~slab-panic	2004-05-22 14:56:22.511669232 -0700
+++ 25-akpm/fs/namespace.c	2004-05-22 14:56:22.552663000 -0700
@@ -1206,9 +1206,7 @@ void __init mnt_init(unsigned long mempa
 	int i;
 
 	mnt_cache = kmem_cache_create("mnt_cache", sizeof(struct vfsmount),
-					0, SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!mnt_cache)
-		panic("Cannot create vfsmount cache");
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 	order = 0; 
 	mount_hashtable = (struct list_head *)
diff -puN include/linux/slab.h~slab-panic include/linux/slab.h
--- 25/include/linux/slab.h~slab-panic	2004-05-22 14:56:22.512669080 -0700
+++ 25-akpm/include/linux/slab.h	2004-05-22 14:56:22.552663000 -0700
@@ -44,6 +44,7 @@ typedef struct kmem_cache_s kmem_cache_t
 #define SLAB_STORE_USER		0x00010000UL	/* store the last owner for bug hunting */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* track pages allocated to indicate
 						   what is reclaimable later*/
+#define SLAB_PANIC		0x00040000UL	/* panic if kmem_cache_create() fails */
 
 /* flags passed to a constructor func */
 #define	SLAB_CTOR_CONSTRUCTOR	0x001UL		/* if not set, then deconstructor */
diff -puN kernel/fork.c~slab-panic kernel/fork.c
--- 25/kernel/fork.c~slab-panic	2004-05-22 14:56:22.513668928 -0700
+++ 25-akpm/kernel/fork.c	2004-05-22 14:59:43.074179096 -0700
@@ -216,11 +216,8 @@ void __init fork_init(unsigned long memp
 #endif
 	/* create a slab on which task_structs can be allocated */
 	task_struct_cachep =
-		kmem_cache_create("task_struct",
-				  sizeof(struct task_struct),ARCH_MIN_TASKALIGN,
-				  0, NULL, NULL);
-	if (!task_struct_cachep)
-		panic("fork_init(): cannot create task_struct SLAB cache");
+		kmem_cache_create("task_struct", sizeof(struct task_struct),
+			ARCH_MIN_TASKALIGN, SLAB_PANIC, NULL, NULL);
 #endif
 
 	/*
@@ -1249,37 +1246,20 @@ void __init proc_caches_init(void)
 {
 	sighand_cachep = kmem_cache_create("sighand_cache",
 			sizeof(struct sighand_struct), 0,
-			SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!sighand_cachep)
-		panic("Cannot create sighand SLAB cache");
-
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	signal_cachep = kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
-			SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!signal_cachep)
-		panic("Cannot create signal SLAB cache");
-
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	files_cachep = kmem_cache_create("files_cache", 
-			 sizeof(struct files_struct), 0, 
-			 SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!files_cachep) 
-		panic("Cannot create files SLAB cache");
-
+			sizeof(struct files_struct), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	fs_cachep = kmem_cache_create("fs_cache", 
-			 sizeof(struct fs_struct), 0, 
-			 SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if (!fs_cachep) 
-		panic("Cannot create fs_struct SLAB cache");
- 
+			sizeof(struct fs_struct), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 	vm_area_cachep = kmem_cache_create("vm_area_struct",
 			sizeof(struct vm_area_struct), 0,
-			0, NULL, NULL);
-	if(!vm_area_cachep)
-		panic("vma_init: Cannot alloc vm_area_struct SLAB cache");
-
+			SLAB_PANIC, NULL, NULL);
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), 0,
-			SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if(!mm_cachep)
-		panic("vma_init: Cannot alloc mm_struct SLAB cache");
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 }
diff -puN kernel/signal.c~slab-panic kernel/signal.c
--- 25/kernel/signal.c~slab-panic	2004-05-22 14:56:22.515668624 -0700
+++ 25-akpm/kernel/signal.c	2004-05-22 14:56:22.561661632 -0700
@@ -2573,7 +2573,5 @@ void __init signals_init(void)
 		kmem_cache_create("sigqueue",
 				  sizeof(struct sigqueue),
 				  __alignof__(struct sigqueue),
-				  0, NULL, NULL);
-	if (!sigqueue_cachep)
-		panic("signals_init(): cannot create sigqueue SLAB cache");
+				  SLAB_PANIC, NULL, NULL);
 }
diff -puN kernel/user.c~slab-panic kernel/user.c
--- 25/kernel/user.c~slab-panic	2004-05-22 14:56:22.516668472 -0700
+++ 25-akpm/kernel/user.c	2004-05-22 14:56:22.562661480 -0700
@@ -149,10 +149,7 @@ static int __init uid_cache_init(void)
 	int n;
 
 	uid_cachep = kmem_cache_create("uid_cache", sizeof(struct user_struct),
-				       0,
-				       SLAB_HWCACHE_ALIGN, NULL, NULL);
-	if(!uid_cachep)
-		panic("Cannot create uid taskcount SLAB cache\n");
+			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
 	for(n = 0; n < UIDHASH_SZ; ++n)
 		INIT_LIST_HEAD(uidhash_table + n);
diff -puN lib/radix-tree.c~slab-panic lib/radix-tree.c
--- 25/lib/radix-tree.c~slab-panic	2004-05-22 14:56:22.517668320 -0700
+++ 25-akpm/lib/radix-tree.c	2004-05-22 14:56:22.563661328 -0700
@@ -799,9 +799,7 @@ void __init radix_tree_init(void)
 {
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
-			0, radix_tree_node_ctor, NULL);
-	if (!radix_tree_node_cachep)
-		panic ("Failed to create radix_tree_node cache\n");
+			SLAB_PANIC, radix_tree_node_ctor, NULL);
 	radix_tree_init_maxindex();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
diff -puN mm/rmap.c~slab-panic mm/rmap.c
--- 25/mm/rmap.c~slab-panic	2004-05-22 14:56:22.518668168 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:43.295145504 -0700
@@ -977,10 +977,7 @@ void __init pte_chain_init(void)
 	pte_chain_cache = kmem_cache_create(	"pte_chain",
 						sizeof(struct pte_chain),
 						sizeof(struct pte_chain),
-						0,
+						SLAB_PANIC,
 						pte_chain_ctor,
 						NULL);
-
-	if (!pte_chain_cache)
-		panic("failed to create pte_chain cache!\n");
 }
diff -puN mm/shmem.c~slab-panic mm/shmem.c
--- 25/mm/shmem.c~slab-panic	2004-05-22 14:56:22.520667864 -0700
+++ 25-akpm/mm/shmem.c	2004-05-22 14:59:40.593556208 -0700
@@ -1808,9 +1808,9 @@ static void init_once(void *foo, kmem_ca
 static int init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
-					     sizeof(struct shmem_inode_info),
-					     0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
-					     init_once, NULL);
+				sizeof(struct shmem_inode_info),
+				0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
+				init_once, NULL);
 	if (shmem_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff -puN mm/slab.c~slab-panic mm/slab.c
--- 25/mm/slab.c~slab-panic	2004-05-22 14:56:22.522667560 -0700
+++ 25-akpm/mm/slab.c	2004-05-22 14:56:22.567660720 -0700
@@ -135,11 +135,11 @@
 			 SLAB_POISON | SLAB_HWCACHE_ALIGN | \
 			 SLAB_NO_REAP | SLAB_CACHE_DMA | \
 			 SLAB_MUST_HWCACHE_ALIGN | SLAB_STORE_USER | \
-			 SLAB_RECLAIM_ACCOUNT )
+			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC)
 #else
 # define CREATE_MASK	(SLAB_HWCACHE_ALIGN | SLAB_NO_REAP | \
 			 SLAB_CACHE_DMA | SLAB_MUST_HWCACHE_ALIGN | \
-			 SLAB_RECLAIM_ACCOUNT)
+			 SLAB_RECLAIM_ACCOUNT | SLAB_PANIC)
 #endif
 
 /*
@@ -1402,9 +1402,11 @@ next:
 	up(&cache_chain_sem);
 	unlock_cpu_hotplug();
 opps:
+	if (!cachep && (flags & SLAB_PANIC))
+		panic("kmem_cache_create(): failed to create slab `%s'\n",
+			name);
 	return cachep;
 }
-
 EXPORT_SYMBOL(kmem_cache_create);
 
 static inline void check_irq_off(void)
diff -puN net/socket.c~slab-panic net/socket.c
--- 25/net/socket.c~slab-panic	2004-05-22 14:56:22.524667256 -0700
+++ 25-akpm/net/socket.c	2004-05-22 14:56:22.569660416 -0700
@@ -310,9 +310,9 @@ static void init_once(void * foo, kmem_c
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
-					     sizeof(struct socket_alloc),
-					     0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
-					     init_once, NULL);
+				sizeof(struct socket_alloc),
+				0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
+				init_once, NULL);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
