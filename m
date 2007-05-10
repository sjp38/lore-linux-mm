Message-Id: <20070510101129.138754904@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:45 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/15] mm: bdi init hooks
Content-Disposition: inline; filename=bdi_init.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

provide BDI constructor/destructor hooks

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c               |    2 ++
 drivers/block/rd.c              |    6 ++++++
 drivers/char/mem.c              |    2 ++
 drivers/mtd/mtdcore.c           |    5 +++++
 fs/char_dev.c                   |    1 +
 fs/configfs/configfs_internal.h |    2 ++
 fs/configfs/inode.c             |    8 ++++++++
 fs/configfs/mount.c             |    2 ++
 fs/fuse/inode.c                 |    2 ++
 fs/hugetlbfs/inode.c            |    3 +++
 fs/nfs/client.c                 |    3 +++
 fs/ocfs2/dlm/dlmfs.c            |    6 +++++-
 fs/ramfs/inode.c                |    1 +
 fs/sysfs/inode.c                |    5 +++++
 fs/sysfs/mount.c                |    2 ++
 fs/sysfs/sysfs.h                |    1 +
 include/linux/backing-dev.h     |    7 +++++++
 kernel/cpuset.c                 |    3 +++
 mm/readahead.c                  |   13 ++++++++++---
 mm/shmem.c                      |    1 +
 mm/swap.c                       |    4 ++++
 21 files changed, 75 insertions(+), 4 deletions(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c	2007-05-10 10:19:00.000000000 +0200
+++ linux-2.6/block/ll_rw_blk.c	2007-05-10 10:21:59.000000000 +0200
@@ -1774,6 +1774,7 @@ static void blk_release_queue(struct kob
 
 	blk_trace_shutdown(q);
 
+	bdi_destroy(&q->backing_dev_info);
 	kmem_cache_free(requestq_cachep, q);
 }
 
@@ -1841,6 +1842,7 @@ request_queue_t *blk_alloc_queue_node(gf
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
+	bdi_init(&q->backing_dev_info);
 
 	mutex_init(&q->sysfs_lock);
 
Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/drivers/block/rd.c	2007-05-10 10:21:53.000000000 +0200
@@ -411,6 +411,9 @@ static void __exit rd_cleanup(void)
 		blk_cleanup_queue(rd_queue[i]);
 	}
 	unregister_blkdev(RAMDISK_MAJOR, "ramdisk");
+
+	bdi_destroy(&rd_file_backing_dev_info);
+	bdi_destroy(&rd_backing_dev_info);
 }
 
 /*
@@ -421,6 +424,9 @@ static int __init rd_init(void)
 	int i;
 	int err = -ENOMEM;
 
+	bdi_init(&rd_backing_dev_info);
+	bdi_init(&rd_file_backing_dev_info);
+
 	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
 			(rd_blocksize & (rd_blocksize-1))) {
 		printk("RAMDISK: wrong blocksize %d, reverting to defaults\n",
Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/drivers/char/mem.c	2007-05-10 10:21:53.000000000 +0200
@@ -987,6 +987,8 @@ static int __init chr_dev_init(void)
 			      MKDEV(MEM_MAJOR, devlist[i].minor),
 			      devlist[i].name);
 
+	bdi_init(&zero_bdi);
+
 	return 0;
 }
 
Index: linux-2.6/fs/char_dev.c
===================================================================
--- linux-2.6.orig/fs/char_dev.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/fs/char_dev.c	2007-05-10 10:21:53.000000000 +0200
@@ -546,6 +546,7 @@ static struct kobject *base_probe(dev_t 
 void __init chrdev_init(void)
 {
 	cdev_map = kobj_map_init(base_probe, &chrdevs_lock);
+	bdi_init(&directly_mappable_cdev_bdi);
 }
 
 
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/fuse/inode.c	2007-05-10 10:21:53.000000000 +0200
@@ -432,6 +432,7 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		bdi_init(&fc->bdi);
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
@@ -445,6 +446,7 @@ void fuse_conn_put(struct fuse_conn *fc)
 		if (fc->destroy_req)
 			fuse_request_free(fc->destroy_req);
 		mutex_destroy(&fc->inst_mutex);
+		bdi_destroy(&fc->bdi);
 		kfree(fc);
 	}
 }
Index: linux-2.6/fs/nfs/client.c
===================================================================
--- linux-2.6.orig/fs/nfs/client.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/nfs/client.c	2007-05-10 10:22:09.000000000 +0200
@@ -658,6 +658,8 @@ static void nfs_server_set_fsinfo(struct
 	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+
+	bdi_init(&server->backing_dev_info);
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
 
 	if (server->wsize > max_rpc_payload)
@@ -787,6 +789,7 @@ void nfs_free_server(struct nfs_server *
 	nfs_put_client(server->nfs_client);
 
 	nfs_free_iostats(server->io_stats);
+	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-05-10 10:21:46.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-05-10 10:21:53.000000000 +0200
@@ -34,6 +34,13 @@ struct backing_dev_info {
 	void *unplug_io_data;
 };
 
+static inline void bdi_init(struct backing_dev_info *bdi)
+{
+}
+
+static inline void bdi_destroy(struct backing_dev_info *bdi)
+{
+}
 
 /*
  * Flags in backing_dev_info::capability
Index: linux-2.6/drivers/mtd/mtdcore.c
===================================================================
--- linux-2.6.orig/drivers/mtd/mtdcore.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/drivers/mtd/mtdcore.c	2007-05-10 10:21:53.000000000 +0200
@@ -60,6 +60,7 @@ int add_mtd_device(struct mtd_info *mtd)
 			break;
 		}
 	}
+	bdi_init(mtd->backing_dev_info);
 
 	BUG_ON(mtd->writesize == 0);
 	mutex_lock(&mtd_table_mutex);
@@ -142,6 +143,10 @@ int del_mtd_device (struct mtd_info *mtd
 	}
 
 	mutex_unlock(&mtd_table_mutex);
+
+	if (mtd->backing_dev_info)
+		bdi_destroy(mtd->backing_dev_info);
+
 	return ret;
 }
 
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2007-05-10 10:21:53.000000000 +0200
@@ -828,6 +828,8 @@ static int __init init_hugetlbfs_fs(void
  out:
 	if (error)
 		kmem_cache_destroy(hugetlbfs_inode_cachep);
+	else
+		bdi_init(&hugetlbfs_backing_dev_info);
 	return error;
 }
 
@@ -835,6 +837,7 @@ static void __exit exit_hugetlbfs_fs(voi
 {
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
 	unregister_filesystem(&hugetlbfs_fs_type);
+	bdi_destroy(&hugetlbfs_backing_dev_info);
 }
 
 module_init(init_hugetlbfs_fs)
Index: linux-2.6/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/dlm/dlmfs.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/fs/ocfs2/dlm/dlmfs.c	2007-05-10 10:21:53.000000000 +0200
@@ -613,8 +613,10 @@ bail:
 			kmem_cache_destroy(dlmfs_inode_cache);
 		if (cleanup_worker)
 			destroy_workqueue(user_dlm_worker);
-	} else
+	} else {
+		bdi_init(&dlmfs_backing_dev_info);
 		printk("OCFS2 User DLM kernel interface loaded\n");
+	}
 	return status;
 }
 
@@ -626,6 +628,8 @@ static void __exit exit_dlmfs_fs(void)
 	destroy_workqueue(user_dlm_worker);
 
 	kmem_cache_destroy(dlmfs_inode_cache);
+
+	bdi_destroy(&dlmfs_backing_dev_info);
 }
 
 MODULE_AUTHOR("Oracle");
Index: linux-2.6/fs/configfs/configfs_internal.h
===================================================================
--- linux-2.6.orig/fs/configfs/configfs_internal.h	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/fs/configfs/configfs_internal.h	2007-05-10 10:21:53.000000000 +0200
@@ -55,6 +55,8 @@ extern int configfs_is_root(struct confi
 
 extern struct inode * configfs_new_inode(mode_t mode, struct configfs_dirent *);
 extern int configfs_create(struct dentry *, int mode, int (*init)(struct inode *));
+extern void configfs_inode_init(void);
+extern void configfs_inode_exit(void);
 
 extern int configfs_create_file(struct config_item *, const struct configfs_attribute *);
 extern int configfs_make_dirent(struct configfs_dirent *,
Index: linux-2.6/fs/configfs/inode.c
===================================================================
--- linux-2.6.orig/fs/configfs/inode.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/fs/configfs/inode.c	2007-05-10 10:21:53.000000000 +0200
@@ -255,4 +255,12 @@ void configfs_hash_and_remove(struct den
 	mutex_unlock(&dir->d_inode->i_mutex);
 }
 
+void __init configfs_inode_init(void)
+{
+	bdi_init(&configfs_backing_dev_info);
+}
 
+void __exit configfs_inode_exit(void)
+{
+	bdi_destroy(&configfs_backing_dev_info);
+}
Index: linux-2.6/fs/configfs/mount.c
===================================================================
--- linux-2.6.orig/fs/configfs/mount.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/configfs/mount.c	2007-05-10 10:21:53.000000000 +0200
@@ -156,6 +156,7 @@ static int __init configfs_init(void)
 		configfs_dir_cachep = NULL;
 	}
 
+	configfs_inode_init();
 out:
 	return err;
 }
@@ -166,6 +167,7 @@ static void __exit configfs_exit(void)
 	subsystem_unregister(&config_subsys);
 	kmem_cache_destroy(configfs_dir_cachep);
 	configfs_dir_cachep = NULL;
+	configfs_inode_exit();
 }
 
 MODULE_AUTHOR("Oracle");
Index: linux-2.6/fs/ramfs/inode.c
===================================================================
--- linux-2.6.orig/fs/ramfs/inode.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/fs/ramfs/inode.c	2007-05-10 10:21:53.000000000 +0200
@@ -223,6 +223,7 @@ module_exit(exit_ramfs_fs)
 
 int __init init_rootfs(void)
 {
+	bdi_init(&ramfs_backing_dev_info);
 	return register_filesystem(&rootfs_fs_type);
 }
 
Index: linux-2.6/fs/sysfs/inode.c
===================================================================
--- linux-2.6.orig/fs/sysfs/inode.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/sysfs/inode.c	2007-05-10 10:21:53.000000000 +0200
@@ -33,6 +33,11 @@ static const struct inode_operations sys
 	.setattr	= sysfs_setattr,
 };
 
+void __init sysfs_inode_init(void)
+{
+	bdi_init(&sysfs_backing_dev_info);
+}
+
 void sysfs_delete_inode(struct inode *inode)
 {
 	/* Free the shadowed directory inode operations */
Index: linux-2.6/fs/sysfs/mount.c
===================================================================
--- linux-2.6.orig/fs/sysfs/mount.c	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/sysfs/mount.c	2007-05-10 10:21:53.000000000 +0200
@@ -101,6 +101,8 @@ int __init sysfs_init(void)
 	} else
 		goto out_err;
 out:
+	if (!err)
+		sysfs_inode_init();
 	return err;
 out_err:
 	kmem_cache_destroy(sysfs_dir_cachep);
Index: linux-2.6/fs/sysfs/sysfs.h
===================================================================
--- linux-2.6.orig/fs/sysfs/sysfs.h	2007-05-10 10:19:02.000000000 +0200
+++ linux-2.6/fs/sysfs/sysfs.h	2007-05-10 10:22:15.000000000 +0200
@@ -60,6 +60,7 @@ extern void sysfs_delete_inode(struct in
 extern struct inode * sysfs_new_inode(mode_t mode, struct sysfs_dirent *);
 extern int sysfs_create(struct sysfs_dirent *sd, struct dentry *dentry,
 			int mode, int (*init)(struct inode *));
+extern void sysfs_inode_init(void);
 
 extern void release_sysfs_dirent(struct sysfs_dirent * sd);
 extern int sysfs_dirent_exist(struct sysfs_dirent *, const unsigned char *);
Index: linux-2.6/kernel/cpuset.c
===================================================================
--- linux-2.6.orig/kernel/cpuset.c	2007-05-10 10:19:03.000000000 +0200
+++ linux-2.6/kernel/cpuset.c	2007-05-10 10:21:53.000000000 +0200
@@ -1935,6 +1935,7 @@ int __init cpuset_init_early(void)
 
 	tsk->cpuset = &top_cpuset;
 	tsk->cpuset->mems_generation = cpuset_mems_generation++;
+
 	return 0;
 }
 
@@ -1977,6 +1978,8 @@ int __init cpuset_init(void)
 	/* memory_pressure_enabled is in root cpuset only */
 	if (err == 0)
 		err = cpuset_add_file(root, &cft_memory_pressure_enabled);
+	if (!err)
+		bdi_init(&cpuset_backing_dev_info);
 out:
 	return err;
 }
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/mm/shmem.c	2007-05-10 10:21:53.000000000 +0200
@@ -2477,6 +2477,7 @@ static int __init init_tmpfs(void)
 		printk(KERN_ERR "Could not kern_mount tmpfs\n");
 		goto out1;
 	}
+	bdi_init(&shmem_backing_dev_info);
 	return 0;
 
 out1:
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2007-05-10 10:11:53.000000000 +0200
+++ linux-2.6/mm/swap.c	2007-05-10 10:21:53.000000000 +0200
@@ -564,6 +564,10 @@ void __init swap_setup(void)
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
--- linux-2.6.orig/mm/readahead.c	2007-05-10 10:19:03.000000000 +0200
+++ linux-2.6/mm/readahead.c	2007-05-10 10:22:59.000000000 +0200
@@ -581,3 +581,10 @@ unsigned long max_sane_readahead(unsigne
 	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
+
+static int __init readahead_init(void)
+{
+	bdi_init(&default_backing_dev_info);
+	return 0;
+}
+subsys_initcall(readahead_init);
\ No newline at end of file

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
