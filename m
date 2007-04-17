Message-Id: <20070417071703.197275332@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:51 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/12] mm: bdi init hooks
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
 fs/ramfs/inode.c                |    7 ++++++-
 fs/sysfs/inode.c                |    5 +++++
 fs/sysfs/mount.c                |    2 ++
 fs/sysfs/sysfs.h                |    1 +
 include/linux/backing-dev.h     |    7 +++++++
 kernel/cpuset.c                 |    3 +++
 mm/shmem.c                      |    1 +
 mm/swap.c                       |    2 ++
 20 files changed, 68 insertions(+), 2 deletions(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c	2007-04-12 11:35:53.000000000 +0200
+++ linux-2.6/block/ll_rw_blk.c	2007-04-12 13:19:40.000000000 +0200
@@ -1771,6 +1771,7 @@ static void blk_release_queue(struct kob
 
 	blk_trace_shutdown(q);
 
+	bdi_destroy(&q->backing_dev_info);
 	kmem_cache_free(requestq_cachep, q);
 }
 
@@ -1836,6 +1837,7 @@ request_queue_t *blk_alloc_queue_node(gf
 	q->kobj.ktype = &queue_ktype;
 	kobject_init(&q->kobj);
 	q->backing_dev_info = default_backing_dev_info;
+	bdi_init(&q->backing_dev_info);
 
 	q->backing_dev_info.unplug_io_fn = blk_backing_dev_unplug;
 	q->backing_dev_info.unplug_io_data = q;
Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c	2007-04-12 11:35:51.000000000 +0200
+++ linux-2.6/drivers/block/rd.c	2007-04-12 11:35:59.000000000 +0200
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
--- linux-2.6.orig/drivers/char/mem.c	2007-04-12 11:35:51.000000000 +0200
+++ linux-2.6/drivers/char/mem.c	2007-04-12 11:35:59.000000000 +0200
@@ -987,6 +987,8 @@ static int __init chr_dev_init(void)
 			      MKDEV(MEM_MAJOR, devlist[i].minor),
 			      devlist[i].name);
 
+	bdi_init(&zero_bdi);
+
 	return 0;
 }
 
Index: linux-2.6/fs/char_dev.c
===================================================================
--- linux-2.6.orig/fs/char_dev.c	2007-04-12 11:35:51.000000000 +0200
+++ linux-2.6/fs/char_dev.c	2007-04-12 11:35:59.000000000 +0200
@@ -546,6 +546,7 @@ static struct kobject *base_probe(dev_t 
 void __init chrdev_init(void)
 {
 	cdev_map = kobj_map_init(base_probe, &chrdevs_lock);
+	bdi_init(&directly_mappable_cdev_bdi);
 }
 
 
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c	2007-04-12 11:35:51.000000000 +0200
+++ linux-2.6/fs/fuse/inode.c	2007-04-12 11:35:59.000000000 +0200
@@ -415,6 +415,7 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		bdi_init(&fc->bdi);
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
@@ -428,6 +429,7 @@ void fuse_conn_put(struct fuse_conn *fc)
 		if (fc->destroy_req)
 			fuse_request_free(fc->destroy_req);
 		mutex_destroy(&fc->inst_mutex);
+		bdi_destroy(&fc->bdi);
 		kfree(fc);
 	}
 }
Index: linux-2.6/fs/nfs/client.c
===================================================================
--- linux-2.6.orig/fs/nfs/client.c	2007-04-12 11:35:51.000000000 +0200
+++ linux-2.6/fs/nfs/client.c	2007-04-12 11:35:59.000000000 +0200
@@ -657,6 +657,8 @@ static void nfs_server_set_fsinfo(struct
 	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+
+	bdi_init(&server->backing_dev_info);
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
 	server->backing_dev_info.ra_pages0 = min_t(unsigned, server->rpages,
 				VM_MIN_READAHEAD >> (PAGE_CACHE_SHIFT - 10));
@@ -789,6 +791,7 @@ void nfs_free_server(struct nfs_server *
 	nfs_put_client(server->nfs_client);
 
 	nfs_free_iostats(server->io_stats);
+	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
 	dprintk("<-- nfs_free_server()\n");
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-12 11:35:57.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-12 13:19:40.000000000 +0200
@@ -36,6 +36,13 @@ struct backing_dev_info {
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
--- linux-2.6.orig/drivers/mtd/mtdcore.c	2007-04-03 13:58:08.000000000 +0200
+++ linux-2.6/drivers/mtd/mtdcore.c	2007-04-12 11:37:45.000000000 +0200
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
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2007-04-12 12:11:15.000000000 +0200
@@ -819,6 +819,8 @@ static int __init init_hugetlbfs_fs(void
  out:
 	if (error)
 		kmem_cache_destroy(hugetlbfs_inode_cachep);
+	else
+		bdi_init(&hugetlbfs_backing_dev_info);
 	return error;
 }
 
@@ -826,6 +828,7 @@ static void __exit exit_hugetlbfs_fs(voi
 {
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
 	unregister_filesystem(&hugetlbfs_fs_type);
+	bdi_destroy(&hugetlbfs_backing_dev_info);
 }
 
 module_init(init_hugetlbfs_fs)
Index: linux-2.6/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/dlm/dlmfs.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/ocfs2/dlm/dlmfs.c	2007-04-12 12:08:18.000000000 +0200
@@ -614,8 +614,10 @@ bail:
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
 
@@ -627,6 +629,8 @@ static void __exit exit_dlmfs_fs(void)
 	destroy_workqueue(user_dlm_worker);
 
 	kmem_cache_destroy(dlmfs_inode_cache);
+
+	bdi_destroy(&dlmfs_backing_dev_info);
 }
 
 MODULE_AUTHOR("Oracle");
Index: linux-2.6/fs/configfs/configfs_internal.h
===================================================================
--- linux-2.6.orig/fs/configfs/configfs_internal.h	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/configfs/configfs_internal.h	2007-04-12 11:51:13.000000000 +0200
@@ -55,6 +55,8 @@ extern int configfs_is_root(struct confi
 
 extern struct inode * configfs_new_inode(mode_t mode, struct configfs_dirent *);
 extern int configfs_create(struct dentry *, int mode, int (*init)(struct inode *));
+extern void configfs_inode_init(void);
+extern void configfs_inode_exit(void);
 
 extern int configfs_create_file(struct config_item *, const struct configfs_attribute *);
 extern int configfs_make_dirent(struct configfs_dirent *,
Index: linux-2.6/fs/configfs/inode.c
===================================================================
--- linux-2.6.orig/fs/configfs/inode.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/configfs/inode.c	2007-04-12 13:04:45.000000000 +0200
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
--- linux-2.6.orig/fs/configfs/mount.c	2007-04-03 13:58:17.000000000 +0200
+++ linux-2.6/fs/configfs/mount.c	2007-04-12 12:07:34.000000000 +0200
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
--- linux-2.6.orig/fs/ramfs/inode.c	2007-04-12 11:53:41.000000000 +0200
+++ linux-2.6/fs/ramfs/inode.c	2007-04-12 12:06:22.000000000 +0200
@@ -210,12 +210,17 @@ static struct file_system_type rootfs_fs
 
 static int __init init_ramfs_fs(void)
 {
-	return register_filesystem(&ramfs_fs_type);
+	int ret;
+	ret = register_filesystem(&ramfs_fs_type);
+	if (!ret)
+		bdi_init(&ramfs_backing_dev_info);
+	return ret;
 }
 
 static void __exit exit_ramfs_fs(void)
 {
 	unregister_filesystem(&ramfs_fs_type);
+	bdi_destroy(&ramfs_backing_dev_info);
 }
 
 module_init(init_ramfs_fs)
Index: linux-2.6/fs/sysfs/inode.c
===================================================================
--- linux-2.6.orig/fs/sysfs/inode.c	2007-04-03 13:58:18.000000000 +0200
+++ linux-2.6/fs/sysfs/inode.c	2007-04-12 12:23:04.000000000 +0200
@@ -299,3 +299,8 @@ int sysfs_hash_and_remove(struct dentry 
 
 	return found ? 0 : -ENOENT;
 }
+
+void __init sysfs_inode_init(void)
+{
+	bdi_init(&sysfs_backing_dev_info);
+}
Index: linux-2.6/fs/sysfs/mount.c
===================================================================
--- linux-2.6.orig/fs/sysfs/mount.c	2007-04-03 13:58:18.000000000 +0200
+++ linux-2.6/fs/sysfs/mount.c	2007-04-12 12:23:08.000000000 +0200
@@ -108,6 +108,8 @@ int __init sysfs_init(void)
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
--- linux-2.6.orig/fs/sysfs/sysfs.h	2007-04-03 13:58:18.000000000 +0200
+++ linux-2.6/fs/sysfs/sysfs.h	2007-04-12 12:22:53.000000000 +0200
@@ -16,6 +16,7 @@ extern struct kmem_cache *sysfs_dir_cach
 extern void sysfs_delete_inode(struct inode *inode);
 extern struct inode * sysfs_new_inode(mode_t mode, struct sysfs_dirent *);
 extern int sysfs_create(struct dentry *, int mode, int (*init)(struct inode *));
+extern void sysfs_inode_init(void);
 
 extern int sysfs_dirent_exist(struct sysfs_dirent *, const unsigned char *);
 extern int sysfs_make_dirent(struct sysfs_dirent *, struct dentry *, void *,
Index: linux-2.6/kernel/cpuset.c
===================================================================
--- linux-2.6.orig/kernel/cpuset.c	2007-04-12 12:26:33.000000000 +0200
+++ linux-2.6/kernel/cpuset.c	2007-04-12 12:37:43.000000000 +0200
@@ -1921,6 +1921,7 @@ int __init cpuset_init_early(void)
 
 	tsk->cpuset = &top_cpuset;
 	tsk->cpuset->mems_generation = cpuset_mems_generation++;
+
 	return 0;
 }
 
@@ -1963,6 +1964,8 @@ int __init cpuset_init(void)
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
--- linux-2.6.orig/mm/shmem.c	2007-04-12 12:28:01.000000000 +0200
+++ linux-2.6/mm/shmem.c	2007-04-12 12:28:14.000000000 +0200
@@ -2478,6 +2478,7 @@ static int __init init_tmpfs(void)
 		printk(KERN_ERR "Could not kern_mount tmpfs\n");
 		goto out1;
 	}
+	bdi_init(&shmem_backing_dev_info);
 	return 0;
 
 out1:
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2007-04-12 12:30:04.000000000 +0200
+++ linux-2.6/mm/swap.c	2007-04-12 12:37:18.000000000 +0200
@@ -550,6 +550,8 @@ void __init swap_setup(void)
 {
 	unsigned long megs = num_physpages >> (20 - PAGE_SHIFT);
 
+	bdi_init(swapper_space.backing_dev_info);
+
 	/* Use a smaller cluster for small-memory machines */
 	if (megs < 16)
 		page_cluster = 2;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
