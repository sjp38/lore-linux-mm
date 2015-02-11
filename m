Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A921A6B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:50:30 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so4366876pab.13
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 06:50:30 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id e10si1115213pdp.183.2015.02.11.06.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 11 Feb 2015 06:50:29 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJM00K1X42ONA90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Feb 2015 14:54:24 +0000 (GMT)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC] shmem: Add eventfd notification on utlilization level
Date: Wed, 11 Feb 2015 15:50:08 +0100
Message-id: <1423666208-10681-2-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Allow notifying user space when used space of tmpfs exceeds specified
level.

The utilization level is passed as mount option 'warn_used'. The kernel
will notify user-space through eventfd after exceeding this number of
used blocks.

The eventfd descriptor has to be passed through sysfs file:
/sys/fs/tmpfs/tmpfs-[0-9]+/warn_used_blocks_efd

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/shmem_fs.h |   4 ++
 mm/shmem.c               | 138 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 140 insertions(+), 2 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5b1e4c..c2ec9909da95 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -35,6 +35,10 @@ struct shmem_sb_info {
 	kgid_t gid;		    /* Mount gid for root directory */
 	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
+	unsigned long warn_used;    /* Warn on reaching used blocks */
+	struct kobject s_kobj;      /* kobj for sysfs attributes */
+	struct completion s_kobj_unregister; /* synchronization for put_super */
+	struct eventfd_ctx *warn_used_efd; /* user-space passed eventfd */
 };
 
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
diff --git a/mm/shmem.c b/mm/shmem.c
index f69d296bd0a3..b559adcef3b3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -34,6 +34,7 @@
 #include <linux/aio.h>
 
 static struct vfsmount *shm_mnt;
+static struct kset *shmem_kset;
 
 #ifdef CONFIG_SHMEM
 /*
@@ -69,6 +70,7 @@ static struct vfsmount *shm_mnt;
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
 #include <uapi/linux/memfd.h>
+#include <linux/eventfd.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -199,6 +201,106 @@ static struct backing_dev_info shmem_backing_dev_info  __read_mostly = {
 static LIST_HEAD(shmem_swaplist);
 static DEFINE_MUTEX(shmem_swaplist_mutex);
 
+
+struct shmem_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct shmem_attr *, struct shmem_sb_info *, char *);
+	ssize_t (*store)(struct shmem_attr *, struct shmem_sb_info *,
+			 const char *, size_t);
+};
+
+static int shmem_setup_warn_used_blocks_eventfd(struct shmem_sb_info *sbinfo,
+					unsigned int efd)
+{
+	int ret = 0;
+
+	if (sbinfo->warn_used_efd) {
+		eventfd_ctx_put(sbinfo->warn_used_efd);
+		sbinfo->warn_used_efd = NULL;
+	}
+
+	sbinfo->warn_used_efd = eventfd_ctx_fdget(efd);
+	if (IS_ERR(sbinfo->warn_used_efd)) {
+		ret = PTR_ERR(sbinfo->warn_used_efd);
+		sbinfo->warn_used_efd = NULL;
+	}
+
+	return ret;
+}
+
+static int parse_strtouint(const char *buf,
+		unsigned long long max, unsigned int *value)
+{
+	int ret;
+
+	ret = kstrtouint(skip_spaces(buf), 0, value);
+	if (!ret && *value > max)
+		ret = -EINVAL;
+	return ret;
+}
+
+static ssize_t warn_used_blocks_efd_store(struct shmem_attr *a,
+					struct shmem_sb_info *sbinfo,
+					const char *buf, size_t count)
+{
+	unsigned int val;
+	int ret;
+
+	if (parse_strtouint(buf, -1ULL, &val))
+		return -EINVAL;
+
+	ret = shmem_setup_warn_used_blocks_eventfd(sbinfo, val);
+
+	return ret ? ret : count;
+}
+
+static struct shmem_attr
+shmem_attr_warn_used_blocks_efd = __ATTR_WO(warn_used_blocks_efd);
+
+static struct attribute *shmem_attrs[] = {
+	&shmem_attr_warn_used_blocks_efd.attr,
+	NULL,
+};
+
+static ssize_t shmem_attr_show(struct kobject *kobj,
+			      struct attribute *attr, char *buf)
+{
+	struct shmem_sb_info *sbinfo = container_of(kobj, struct shmem_sb_info,
+						s_kobj);
+	struct shmem_attr *a = container_of(attr, struct shmem_attr, attr);
+
+	return a->show ? a->show(a, sbinfo, buf) : 0;
+}
+
+static ssize_t shmem_attr_store(struct kobject *kobj,
+			       struct attribute *attr,
+			       const char *buf, size_t len)
+{
+	struct shmem_sb_info *sbinfo = container_of(kobj, struct shmem_sb_info,
+						s_kobj);
+	struct shmem_attr *a = container_of(attr, struct shmem_attr, attr);
+
+	return a->store ? a->store(a, sbinfo, buf, len) : 0;
+}
+
+static void shmem_sb_release(struct kobject *kobj)
+{
+	struct shmem_sb_info *sbinfo = container_of(kobj, struct shmem_sb_info,
+						s_kobj);
+	complete(&sbinfo->s_kobj_unregister);
+}
+
+static const struct sysfs_ops shmem_attr_ops = {
+	.show	= shmem_attr_show,
+	.store	= shmem_attr_store,
+};
+
+static struct kobj_type shmem_ktype = {
+	.default_attrs	= shmem_attrs,
+	.sysfs_ops	= &shmem_attr_ops,
+	.release	= shmem_sb_release,
+};
+
 static int shmem_reserve_inode(struct super_block *sb)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
@@ -1170,6 +1272,13 @@ repeat:
 			}
 			percpu_counter_inc(&sbinfo->used_blocks);
 		}
+		if (sbinfo->warn_used) {
+			if (percpu_counter_compare(&sbinfo->used_blocks,
+						sbinfo->warn_used) >= 0) {
+				if (sbinfo->warn_used_efd)
+					eventfd_signal(sbinfo->warn_used_efd, 1);
+			}
+		}
 
 		page = shmem_alloc_page(gfp, info, index);
 		if (!page) {
@@ -2824,6 +2933,10 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			mpol = NULL;
 			if (mpol_parse_str(value, &mpol))
 				goto bad_val;
+		} else if (!strcmp(this_char,"warn_used")) {
+			sbinfo->warn_used = memparse(value, &rest);
+			if (*rest)
+				goto bad_val;
 		} else {
 			printk(KERN_ERR "tmpfs: Bad mount option %s\n",
 			       this_char);
@@ -2984,6 +3097,13 @@ static void shmem_put_super(struct super_block *sb)
 	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
 
 	percpu_counter_destroy(&sbinfo->used_blocks);
+	if (sbinfo->warn_used_efd) {
+		eventfd_ctx_put(sbinfo->warn_used_efd);
+		sbinfo->warn_used_efd = NULL;
+	}
+	kobject_del(&sbinfo->s_kobj);
+	kobject_put(&sbinfo->s_kobj);
+	wait_for_completion(&sbinfo->s_kobj_unregister);
 	mpol_put(sbinfo->mpol);
 	kfree(sbinfo);
 	sb->s_fs_info = NULL;
@@ -2994,6 +3114,7 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	struct shmem_sb_info *sbinfo;
 	int err = -ENOMEM;
+	static unsigned int no;
 
 	/* Round up to L1_CACHE_BYTES to resist false sharing */
 	sbinfo = kzalloc(max((int)sizeof(struct shmem_sb_info),
@@ -3045,17 +3166,25 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_TMPFS_POSIX_ACL
 	sb->s_flags |= MS_POSIXACL;
 #endif
+	sbinfo->s_kobj.kset = shmem_kset;
+	init_completion(&sbinfo->s_kobj_unregister);
+	err = kobject_init_and_add(&sbinfo->s_kobj, &shmem_ktype, NULL,
+				   "%s-%u", sb->s_id, no++);
+	if (err)
+		goto failed;
 
 	inode = shmem_get_inode(sb, NULL, S_IFDIR | sbinfo->mode, 0, VM_NORESERVE);
 	if (!inode)
-		goto failed;
+		goto failed_kobj;
 	inode->i_uid = sbinfo->uid;
 	inode->i_gid = sbinfo->gid;
 	sb->s_root = d_make_root(inode);
 	if (!sb->s_root)
-		goto failed;
+		goto failed_kobj;
 	return 0;
 
+failed_kobj:
+	kobject_del(&sbinfo->s_kobj);
 failed:
 	shmem_put_super(sb);
 	return err;
@@ -3225,6 +3354,10 @@ int __init shmem_init(void)
 	if (shmem_inode_cachep)
 		return 0;
 
+	shmem_kset = kset_create_and_add("tmpfs", NULL, fs_kobj);
+	if (!shmem_kset)
+		return -ENOMEM;
+
 	error = bdi_init(&shmem_backing_dev_info);
 	if (error)
 		goto out4;
@@ -3255,6 +3388,7 @@ out3:
 	bdi_destroy(&shmem_backing_dev_info);
 out4:
 	shm_mnt = ERR_PTR(error);
+	kset_unregister(shmem_kset);
 	return error;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
