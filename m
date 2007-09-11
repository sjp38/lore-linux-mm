Message-Id: <20070911200014.175999000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:54:01 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/23] mm: bdi init hooks
Content-Disposition: inline; filename=bdi_init.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

provide BDI constructor/destructor hooks

[akpm@linux-foundation.org: compile fix]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c               |   13 ++++++++++---
 drivers/block/rd.c              |   20 +++++++++++++++++++-
 drivers/char/mem.c              |    5 +++++
 fs/char_dev.c                   |    1 +
 fs/configfs/configfs_internal.h |    2 ++
 fs/configfs/inode.c             |    8 ++++++++
 fs/configfs/mount.c             |    9 +++++++++
 fs/fuse/inode.c                 |    9 +++++++++
 fs/hugetlbfs/inode.c            |    9 ++++++++-
 fs/nfs/client.c                 |    6 ++++++
 fs/ocfs2/dlm/dlmfs.c            |    9 ++++++++-
 fs/ramfs/inode.c                |   12 +++++++++++-
 fs/sysfs/inode.c                |    5 +++++
 fs/sysfs/mount.c                |    4 ++++
 fs/sysfs/sysfs.h                |    1 +
 include/linux/backing-dev.h     |    8 ++++++++
 mm/readahead.c                  |    6 ++++++
 mm/shmem.c                      |    6 ++++++
 mm/swap.c                       |    5 +++++
 19 files changed, 131 insertions(+), 7 deletions(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c
+++ linux-2.6/block/ll_rw_blk.c
@@ -1784,6 +1784,7 @@ static void blk_release_queue(struct kob
 
 	blk_trace_shutdown(q);
 
+	bdi_destroy(&q->backing_dev_info);
 	kmem_cache_free(requestq_cachep, q);
 }
 
@@ -1837,21 +1838,27 @@ static struct kobj_type queue_ktype;
 struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 {
 	struct request_queue *q;
+	int err;
 
 	q = kmem_cache_alloc_node(requestq_cachep,
 				gfp_mask | __GFP_ZERO, node_id);
 	if (!q)
 		return NULL;
 
+	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
+	q->backing_dev_info.unplug_io_data = q;
+	err = bdi_init(&q->backing_dev_info);
+	if (err) {
+		kmem_cache_free(requestq_cachep, q);
+		return NULL;
+	}
+
 	init_timer(&q->unplug_timer);
 
 	snprintf(q->kobj.name, KOBJ_NAME_LEN, "%s", "queue");
 	q->kobj.ktype = &queue_ktype;
 	kobject_init(&q->kobj);
 
-	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
-	q->backing_dev_info.unplug_io_data = q;
-
 	mutex_init(&q->sysfs_lock);
 
 	return q;
Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c
+++ linux-2.6/drivers/block/rd.c
@@ -411,6 +411,9 @@ static void __exit rd_cleanup(void)
 		blk_cleanup_queue(rd_queue[i]);
 	}
 	unregister_blkdev(RAMDISK_MAJOR, "ramdisk");
+
+	bdi_destroy(&rd_file_backing_dev_info);
+	bdi_destroy(&rd_backing_dev_info);
 }
 
 /*
@@ -419,7 +422,19 @@ static void __exit rd_cleanup(void)
 static int __init rd_init(void)
 {
 	int i;
-	int err = -ENOMEM;
+	int err;
+
+	err = bdi_init(&rd_backing_dev_info);
+	if (err)
+		goto out2;
+
+	err = bdi_init(&rd_file_backing_dev_info);
+	if (err) {
+		bdi_destroy(&rd_backing_dev_info);
+		goto out2;
+	}
+
+	err = -ENOMEM;
 
 	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
 			(rd_blocksize & (rd_blocksize-1))) {
@@ -473,6 +488,9 @@ out:
 		put_disk(rd_disks[i]);
 		blk_cleanup_queue(rd_queue[i]);
 	}
+	bdi_destroy(&rd_backing_dev_info);
+	bdi_destroy(&rd_file_backing_dev_info);
+out2:
 	return err;
 }
 
Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c
+++ linux-2.6/drivers/char/mem.c
@@ -893,6 +893,11 @@ static struct class *mem_class;
 static int __init chr_dev_init(void)
 {
 	int i;
+	int err;
+
+	err = bdi_init(&zero_bdi);
+	if (err)
+		return err;
 
 	if (register_chrdev(MEM_MAJOR,"mem",&memory_fops))
 		printk("unable to get major %d for memory devs\n", MEM_MAJOR);
Index: linux-2.6/fs/char_dev.c
===================================================================
--- linux-2.6.orig/fs/char_dev.c
+++ linux-2.6/fs/char_dev.c
@@ -545,6 +545,7 @@ static struct kobject *base_probe(dev_t 
 void __init chrdev_init(void)
 {
 	cdev_map = kobj_map_init(base_probe, &chrdevs_lock);
+	bdi_init(&directly_mappable_cdev_bdi);
 }
 
 
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c
+++ linux-2.6/fs/fuse/inode.c
@@ -444,6 +444,7 @@ static int fuse_show_options(struct seq_
 static struct fuse_conn *new_conn(void)
 {
 	struct fuse_conn *fc;
+	int err;
 
 	fc = kzalloc(sizeof(*fc), GFP_KERNEL);
 	if (fc) {
@@ -460,10 +461,17 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		err = bdi_init(&fc->bdi);
+		if (err) {
+			kfree(fc);
+			fc = NULL;
+			goto out;
+		}
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
 	}
+out:
 	return fc;
 }
 
@@ -473,6 +481,7 @@ void fuse_conn_put(struct fuse_conn *fc)
 		if (fc->destroy_req)
 			fuse_request_free(fc->destroy_req);
 		mutex_destroy(&fc->inst_mutex);
+		bdi_destroy(&fc->bdi);
 		kfree(fc);
 	}
 }
Index: linux-2.6/fs/nfs/client.c
===================================================================
--- linux-2.6.orig/fs/nfs/client.c
+++ linux-2.6/fs/nfs/client.c
@@ -632,6 +632,7 @@ static void nfs_server_set_fsinfo(struct
 	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
 
 	if (server->wsize > max_rpc_payload)
@@ -682,6 +683,10 @@ static int nfs_probe_fsinfo(struct nfs_s
 		goto out_error;
 
 	nfs_server_set_fsinfo(server, &fsinfo);
+	error = bdi_init(&server->backing_dev_info);
+	if (error)
+		goto out_error;
+
 
 	/* Get some general file system info */
 	if (server->namelen == 0) {
@@ -761,6 +766,7 @@ void nfs_free_server(struct nfs_server *
 	nfs_put_client(server->nfs_client);
 
 	nfs_free_iostats(server->io_stats);
+	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -34,6 +34,14 @@ struct backing_dev_info {
 	void *unplug_io_data;
 };
 
+static inline int bdi_init(struct backing_dev_info *bdi)
+{
+	return 0;
+}
+
+static inline void bdi_destroy(struct backing_dev_info *bdi)
+{
+}
 
 /*
  * Flags in backing_dev_info::capability
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -964,11 +964,15 @@ static int __init init_hugetlbfs_fs(void
 	int error;
 	struct vfsmount *vfsmount;
 
+	error = bdi_init(&hugetlbfs_backing_dev_info);
+	if (error)
+		return error;
+
 	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
 					sizeof(struct hugetlbfs_inode_info),
 					0, 0, init_once);
 	if (hugetlbfs_inode_cachep == NULL)
-		return -ENOMEM;
+		goto out2;
 
 	error = register_filesystem(&hugetlbfs_fs_type);
 	if (error)
@@ -986,6 +990,8 @@ static int __init init_hugetlbfs_fs(void
  out:
 	if (error)
 		kmem_cache_destroy(hugetlbfs_inode_cachep);
+ out2:
+	bdi_destroy(&hugetlbfs_backing_dev_info);
 	return error;
 }
 
@@ -993,6 +999,7 @@ static void __exit exit_hugetlbfs_fs(voi
 {
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
 	unregister_filesystem(&hugetlbfs_fs_type);
+	bdi_destroy(&hugetlbfs_backing_dev_info);
 }
 
 module_init(init_hugetlbfs_fs)
Index: linux-2.6/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/dlm/dlmfs.c
+++ linux-2.6/fs/ocfs2/dlm/dlmfs.c
@@ -588,13 +588,17 @@ static int __init init_dlmfs_fs(void)
 
 	dlmfs_print_version();
 
+	status = bdi_init(&dlmfs_backing_dev_info);
+	if (status)
+		return status;
+
 	dlmfs_inode_cache = kmem_cache_create("dlmfs_inode_cache",
 				sizeof(struct dlmfs_inode_private),
 				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
 					SLAB_MEM_SPREAD),
 				dlmfs_init_once);
 	if (!dlmfs_inode_cache)
-		return -ENOMEM;
+		goto bail;
 	cleanup_inode = 1;
 
 	user_dlm_worker = create_singlethread_workqueue("user_dlm");
@@ -611,6 +615,7 @@ bail:
 			kmem_cache_destroy(dlmfs_inode_cache);
 		if (cleanup_worker)
 			destroy_workqueue(user_dlm_worker);
+		bdi_destroy(&dlmfs_backing_dev_info);
 	} else
 		printk("OCFS2 User DLM kernel interface loaded\n");
 	return status;
@@ -624,6 +629,8 @@ static void __exit exit_dlmfs_fs(void)
 	destroy_workqueue(user_dlm_worker);
 
 	kmem_cache_destroy(dlmfs_inode_cache);
+
+	bdi_destroy(&dlmfs_backing_dev_info);
 }
 
 MODULE_AUTHOR("Oracle");
Index: linux-2.6/fs/configfs/configfs_internal.h
===================================================================
--- linux-2.6.orig/fs/configfs/configfs_internal.h
+++ linux-2.6/fs/configfs/configfs_internal.h
@@ -56,6 +56,8 @@ extern int configfs_is_root(struct confi
 
 extern struct inode * configfs_new_inode(mode_t mode, struct configfs_dirent *);
 extern int configfs_create(struct dentry *, int mode, int (*init)(struct inode *));
+extern int configfs_inode_init(void);
+extern void configfs_inode_exit(void);
 
 extern int configfs_create_file(struct config_item *, const struct configfs_attribute *);
 extern int configfs_make_dirent(struct configfs_dirent *,
Index: linux-2.6/fs/configfs/inode.c
===================================================================
--- linux-2.6.orig/fs/configfs/inode.c
+++ linux-2.6/fs/configfs/inode.c
@@ -256,4 +256,12 @@ void configfs_hash_and_remove(struct den
 	mutex_unlock(&dir->d_inode->i_mutex);
 }
 
+int __init configfs_inode_init(void)
+{
+	return bdi_init(&configfs_backing_dev_info);
+}
 
+void __exit configfs_inode_exit(void)
+{
+	bdi_destroy(&configfs_backing_dev_info);
+}
Index: linux-2.6/fs/configfs/mount.c
===================================================================
--- linux-2.6.orig/fs/configfs/mount.c
+++ linux-2.6/fs/configfs/mount.c
@@ -154,8 +154,16 @@ static int __init configfs_init(void)
 		subsystem_unregister(&config_subsys);
 		kmem_cache_destroy(configfs_dir_cachep);
 		configfs_dir_cachep = NULL;
+		goto out;
 	}
 
+	err = configfs_inode_init();
+	if (err) {
+		unregister_filesystem(&configfs_fs_type);
+		subsystem_unregister(&config_subsys);
+		kmem_cache_destroy(configfs_dir_cachep);
+		configfs_dir_cachep = NULL;
+	}
 out:
 	return err;
 }
@@ -166,6 +174,7 @@ static void __exit configfs_exit(void)
 	subsystem_unregister(&config_subsys);
 	kmem_cache_destroy(configfs_dir_cachep);
 	configfs_dir_cachep = NULL;
+	configfs_inode_exit();
 }
 
 MODULE_AUTHOR("Oracle");
Index: linux-2.6/fs/ramfs/inode.c
===================================================================
--- linux-2.6.orig/fs/ramfs/inode.c
+++ linux-2.6/fs/ramfs/inode.c
@@ -223,7 +223,17 @@ module_exit(exit_ramfs_fs)
 
 int __init init_rootfs(void)
 {
-	return register_filesystem(&rootfs_fs_type);
+	int err;
+
+	err = bdi_init(&ramfs_backing_dev_info);
+	if (err)
+		return err;
+
+	err = register_filesystem(&rootfs_fs_type);
+	if (err)
+		bdi_destroy(&ramfs_backing_dev_info);
+
+	return err;
 }
 
 MODULE_LICENSE("GPL");
Index: linux-2.6/fs/sysfs/inode.c
===================================================================
--- linux-2.6.orig/fs/sysfs/inode.c
+++ linux-2.6/fs/sysfs/inode.c
@@ -33,6 +33,11 @@ static const struct inode_operations sys
 	.setattr	= sysfs_setattr,
 };
 
+int __init sysfs_inode_init(void)
+{
+	return bdi_init(&sysfs_backing_dev_info);
+}
+
 int sysfs_setattr(struct dentry * dentry, struct iattr * iattr)
 {
 	struct inode * inode = dentry->d_inode;
Index: linux-2.6/fs/sysfs/mount.c
===================================================================
--- linux-2.6.orig/fs/sysfs/mount.c
+++ linux-2.6/fs/sysfs/mount.c
@@ -83,6 +83,10 @@ int __init sysfs_init(void)
 	if (!sysfs_dir_cachep)
 		goto out;
 
+	err = sysfs_inode_init();
+	if (err)
+		goto out_err;
+
 	err = register_filesystem(&sysfs_fs_type);
 	if (!err) {
 		sysfs_mount = kern_mount(&sysfs_fs_type);
Index: linux-2.6/fs/sysfs/sysfs.h
===================================================================
--- linux-2.6.orig/fs/sysfs/sysfs.h
+++ linux-2.6/fs/sysfs/sysfs.h
@@ -68,6 +68,7 @@ extern void sysfs_remove_one(struct sysf
 extern void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
 
 extern struct inode * sysfs_get_inode(struct sysfs_dirent *sd);
+extern int sysfs_inode_init(void);
 
 extern void release_sysfs_dirent(struct sysfs_dirent * sd);
 extern struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -2462,6 +2462,10 @@ static int __init init_tmpfs(void)
 {
 	int error;
 
+	error = bdi_init(&shmem_backing_dev_info);
+	if (error)
+		goto out4;
+
 	error = init_inodecache();
 	if (error)
 		goto out3;
@@ -2486,6 +2490,8 @@ out1:
 out2:
 	destroy_inodecache();
 out3:
+	bdi_destroy(&shmem_backing_dev_info);
+out4:
 	shm_mnt = ERR_PTR(error);
 	return error;
 }
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -29,6 +29,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
+#include <linux/backing-dev.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -505,6 +506,10 @@ void __init swap_setup(void)
 {
 	unsigned long megs = num_physpages >> (20 - PAGE_SHIFT);
 
+#ifdef CONFIG_SWAP
+	bdi_init(swapper_space.backing_dev_info);
+#endif
+
 	/* Use a smaller cluster for small-memory machines */
 	if (megs < 16)
 		page_cluster = 2;
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -232,6 +232,12 @@ unsigned long max_sane_readahead(unsigne
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
+static int __init readahead_init(void)
+{
+	return bdi_init(&default_backing_dev_info);
+}
+subsys_initcall(readahead_init);
+
 /*
  * Submit IO for the read-ahead request in file_ra_state.
  */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
