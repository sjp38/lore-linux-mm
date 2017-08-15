Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1FBF6B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 14:16:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so28705599pgb.13
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 11:16:57 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 71si5727721pga.0.2017.08.15.11.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 11:16:56 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 01/22] mm/shmem: introduce shmem_file_setup_with_mnt
Date: Tue, 15 Aug 2017 19:11:54 +0100
Message-Id: <20170815181215.18310-2-matthew.auld@intel.com>
In-Reply-To: <20170815181215.18310-1-matthew.auld@intel.com>
References: <20170815181215.18310-1-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

We are planning to use our own tmpfs mnt in i915 in place of the
shm_mnt, such that we can control the mount options, in particular
huge=, which we require to support huge-gtt-pages. So rather than roll
our own version of __shmem_file_setup, it would be preferred if we could
just give shmem our mnt, and let it do the rest.

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
---
 include/linux/shmem_fs.h |  2 ++
 mm/shmem.c               | 30 ++++++++++++++++++++++--------
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index a7d6bd2a918f..27de676f0b63 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -53,6 +53,8 @@ extern struct file *shmem_file_setup(const char *name,
 					loff_t size, unsigned long flags);
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
+extern struct file *shmem_file_setup_with_mnt(struct vfsmount *mnt,
+		const char *name, loff_t size, unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags);
diff --git a/mm/shmem.c b/mm/shmem.c
index 6540e5982444..0975e65ea61c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4141,7 +4141,7 @@ static const struct dentry_operations anon_ops = {
 	.d_dname = simple_dname
 };
 
-static struct file *__shmem_file_setup(const char *name, loff_t size,
+static struct file *__shmem_file_setup(struct vfsmount *mnt, const char *name, loff_t size,
 				       unsigned long flags, unsigned int i_flags)
 {
 	struct file *res;
@@ -4150,8 +4150,8 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	struct super_block *sb;
 	struct qstr this;
 
-	if (IS_ERR(shm_mnt))
-		return ERR_CAST(shm_mnt);
+	if (IS_ERR(mnt))
+		return ERR_CAST(mnt);
 
 	if (size < 0 || size > MAX_LFS_FILESIZE)
 		return ERR_PTR(-EINVAL);
@@ -4163,8 +4163,8 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	this.name = name;
 	this.len = strlen(name);
 	this.hash = 0; /* will go */
-	sb = shm_mnt->mnt_sb;
-	path.mnt = mntget(shm_mnt);
+	sb = mnt->mnt_sb;
+	path.mnt = mntget(mnt);
 	path.dentry = d_alloc_pseudo(sb, &this);
 	if (!path.dentry)
 		goto put_memory;
@@ -4209,7 +4209,7 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
  */
 struct file *shmem_kernel_file_setup(const char *name, loff_t size, unsigned long flags)
 {
-	return __shmem_file_setup(name, size, flags, S_PRIVATE);
+	return __shmem_file_setup(shm_mnt, name, size, flags, S_PRIVATE);
 }
 
 /**
@@ -4220,11 +4220,25 @@ struct file *shmem_kernel_file_setup(const char *name, loff_t size, unsigned lon
  */
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags)
 {
-	return __shmem_file_setup(name, size, flags, 0);
+	return __shmem_file_setup(shm_mnt, name, size, flags, 0);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);
 
 /**
+ * shmem_file_setup_with_mnt - get an unlinked file living in tmpfs
+ * @mnt: the tmpfs mount where the file will be created
+ * @name: name for dentry (to be seen in /proc/<pid>/maps
+ * @size: size to be set for the file
+ * @flags: VM_NORESERVE suppresses pre-accounting of the entire object size
+ */
+struct file *shmem_file_setup_with_mnt(struct vfsmount *mnt, const char *name,
+				       loff_t size, unsigned long flags)
+{
+	return __shmem_file_setup(mnt, name, size, flags, 0);
+}
+EXPORT_SYMBOL_GPL(shmem_file_setup_with_mnt);
+
+/**
  * shmem_zero_setup - setup a shared anonymous mapping
  * @vma: the vma to be mmapped is prepared by do_mmap_pgoff
  */
@@ -4239,7 +4253,7 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	 * accessible to the user through its mapping, use S_PRIVATE flag to
 	 * bypass file security, in the same way as shmem_kernel_file_setup().
 	 */
-	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
+	file = shmem_kernel_file_setup("dev/zero", size, vma->vm_flags);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
