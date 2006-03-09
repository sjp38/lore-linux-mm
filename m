Message-Id: <200603091100.k29B0vg18723@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] convert hugetlbfs_counter to atomic
Date: Thu, 9 Mar 2006 03:00:58 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Implementation of hugetlbfs_counter() is functionally equivalent
to atomic_inc_return().  Use the simpler atomic form.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./fs/hugetlbfs/inode.c.orig	2006-03-08 22:18:38.000000000 -0800
+++ ./fs/hugetlbfs/inode.c	2006-03-08 22:34:58.000000000 -0800
@@ -771,21 +771,6 @@ static struct file_system_type hugetlbfs
 
 static struct vfsmount *hugetlbfs_vfsmount;
 
-/*
- * Return the next identifier for a shm file
- */
-static unsigned long hugetlbfs_counter(void)
-{
-	static DEFINE_SPINLOCK(lock);
-	static unsigned long counter;
-	unsigned long ret;
-
-	spin_lock(&lock);
-	ret = ++counter;
-	spin_unlock(&lock);
-	return ret;
-}
-
 static int can_do_hugetlb_shm(void)
 {
 	return likely(capable(CAP_IPC_LOCK) ||
@@ -801,6 +786,7 @@ struct file *hugetlb_zero_setup(size_t s
 	struct dentry *dentry, *root;
 	struct qstr quick_string;
 	char buf[16];
+	static atomic_t counter;
 
 	if (!can_do_hugetlb_shm())
 		return ERR_PTR(-EPERM);
@@ -812,7 +798,7 @@ struct file *hugetlb_zero_setup(size_t s
 		return ERR_PTR(-ENOMEM);
 
 	root = hugetlbfs_vfsmount->mnt_root;
-	snprintf(buf, 16, "%lu", hugetlbfs_counter());
+	snprintf(buf, 16, "%u", atomic_inc_return(&counter));
 	quick_string.name = buf;
 	quick_string.len = strlen(quick_string.name);
 	quick_string.hash = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
