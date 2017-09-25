Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3776B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:47:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so17554338pgn.2
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:47:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o185si4481540pga.636.2017.09.25.11.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 11:47:42 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 01/22] mm/shmem: support passing mnt to shmem_file_setup
Date: Mon, 25 Sep 2017 19:47:16 +0100
Message-Id: <20170925184737.8807-2-matthew.auld@intel.com>
In-Reply-To: <20170925184737.8807-1-matthew.auld@intel.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, devel@driverdev.osuosl.org

We are planning to use our own tmpfs mnt in i915 in place of the
shm_mnt such that we can control the mount options, in particular
huge=, which we require to support huge-gtt-pages. So rather than roll
our own version of __shmem_file_setup, it would be preferred if we could
just give shmem our mnt, and let it do the rest.

Based on the patch: https://patchwork.freedesktop.org/patch/178433/

Suggested-by: Chris Wilson <chris@chris-wilson.co.uk>
Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Arve HjA,nnevAJPYg" <arve@android.com>
Cc: Riley Andrews <riandrews@android.com>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-mm@kvack.org
Cc: devel@driverdev.osuosl.org
---
 drivers/gpu/drm/drm_gem.c        |  2 +-
 drivers/gpu/drm/ttm/ttm_tt.c     |  2 +-
 drivers/staging/android/ashmem.c |  3 ++-
 include/linux/shmem_fs.h         |  4 +++-
 mm/shmem.c                       | 24 ++++++++++++++----------
 5 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 7199bba68c37..12e5fdc90a6f 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -138,7 +138,7 @@ int drm_gem_object_init(struct drm_device *dev,
 
 	drm_gem_private_object_init(dev, obj, size);
 
-	filp = shmem_file_setup("drm mm object", size, VM_NORESERVE);
+	filp = shmem_file_setup(TMPFS_MNT, "drm mm object", size, VM_NORESERVE);
 	if (IS_ERR(filp))
 		return PTR_ERR(filp);
 
diff --git a/drivers/gpu/drm/ttm/ttm_tt.c b/drivers/gpu/drm/ttm/ttm_tt.c
index 8ebc8d3560c3..4eef07d8b8ed 100644
--- a/drivers/gpu/drm/ttm/ttm_tt.c
+++ b/drivers/gpu/drm/ttm/ttm_tt.c
@@ -336,7 +336,7 @@ int ttm_tt_swapout(struct ttm_tt *ttm, struct file *persistent_swap_storage)
 	BUG_ON(ttm->caching_state != tt_cached);
 
 	if (!persistent_swap_storage) {
-		swap_storage = shmem_file_setup("ttm swap",
+		swap_storage = shmem_file_setup(TMPFS_MNT, "ttm swap",
 						ttm->num_pages << PAGE_SHIFT,
 						0);
 		if (IS_ERR(swap_storage)) {
diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 0f695df14c9d..184fcbb6d127 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -391,7 +391,8 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 			name = asma->name;
 
 		/* ... and allocate the backing shmem file */
-		vmfile = shmem_file_setup(name, asma->size, vma->vm_flags);
+		vmfile = shmem_file_setup(TMPFS_MNT, name, asma->size,
+					  vma->vm_flags);
 		if (IS_ERR(vmfile)) {
 			ret = PTR_ERR(vmfile);
 			goto out;
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index b6c3540e07bc..00b199d804ca 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -44,12 +44,14 @@ static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
 	return container_of(inode, struct shmem_inode_info, vfs_inode);
 }
 
+#define TMPFS_MNT NULL
+
 /*
  * Functions in mm/shmem.c called directly from elsewhere:
  */
 extern int shmem_init(void);
 extern int shmem_fill_super(struct super_block *sb, void *data, int silent);
-extern struct file *shmem_file_setup(const char *name,
+extern struct file *shmem_file_setup(struct vfsmount *mnt, const char *name,
 					loff_t size, unsigned long flags);
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22807be..ae2e46291ffa 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3715,7 +3715,7 @@ SYSCALL_DEFINE2(memfd_create,
 					(flags >> MFD_HUGE_SHIFT) &
 					MFD_HUGE_MASK);
 	} else
-		file = shmem_file_setup(name, 0, VM_NORESERVE);
+		file = shmem_file_setup(TMPFS_MNT, name, 0, VM_NORESERVE);
 	if (IS_ERR(file)) {
 		error = PTR_ERR(file);
 		goto err_fd;
@@ -4183,7 +4183,7 @@ static const struct dentry_operations anon_ops = {
 	.d_dname = simple_dname
 };
 
-static struct file *__shmem_file_setup(const char *name, loff_t size,
+static struct file *__shmem_file_setup(struct vfsmount *mnt, const char *name, loff_t size,
 				       unsigned long flags, unsigned int i_flags)
 {
 	struct file *res;
@@ -4192,8 +4192,11 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	struct super_block *sb;
 	struct qstr this;
 
-	if (IS_ERR(shm_mnt))
-		return ERR_CAST(shm_mnt);
+	if (mnt == TMPFS_MNT)
+		mnt = shm_mnt;
+
+	if (IS_ERR(mnt))
+		return ERR_CAST(mnt);
 
 	if (size < 0 || size > MAX_LFS_FILESIZE)
 		return ERR_PTR(-EINVAL);
@@ -4205,8 +4208,8 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
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
@@ -4251,18 +4254,19 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
  */
 struct file *shmem_kernel_file_setup(const char *name, loff_t size, unsigned long flags)
 {
-	return __shmem_file_setup(name, size, flags, S_PRIVATE);
+	return __shmem_file_setup(TMPFS_MNT, name, size, flags, S_PRIVATE);
 }
 
 /**
  * shmem_file_setup - get an unlinked file living in tmpfs
+ * @mnt: the tmpfs mount where the file will be created
  * @name: name for dentry (to be seen in /proc/<pid>/maps
  * @size: size to be set for the file
  * @flags: VM_NORESERVE suppresses pre-accounting of the entire object size
  */
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags)
+struct file *shmem_file_setup(struct vfsmount *mnt, const char *name, loff_t size, unsigned long flags)
 {
-	return __shmem_file_setup(name, size, flags, 0);
+	return __shmem_file_setup(mnt, name, size, flags, 0);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);
 
@@ -4281,7 +4285,7 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	 * accessible to the user through its mapping, use S_PRIVATE flag to
 	 * bypass file security, in the same way as shmem_kernel_file_setup().
 	 */
-	file = __shmem_file_setup("dev/zero", size, vma->vm_flags, S_PRIVATE);
+	file = shmem_kernel_file_setup("dev/zero", size, vma->vm_flags);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
