Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 47EFC6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 06:57:22 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so5703737obb.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 03:57:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z8si5976725obk.95.2015.11.09.03.57.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Nov 2015 03:57:20 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Date: Mon,  9 Nov 2015 20:56:10 +0900
Message-Id: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Russell King <linux@arm.linux.org.uk>, linux-acpi@vger.kernel.org, drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, codalist@coda.cs.cmu.edu, linux-mtd@lists.infradead.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org

There are many locations that do

  if (memory_was_allocated_by_vmalloc)
    vfree(ptr);
  else
    kfree(ptr);

but kvfree() can handle both kmalloc()ed memory and vmalloc()ed memory
using is_vmalloc_addr(). Unless callers have special reasons, we can
replace this branch with kvfree(). Please check and reply if you found
problems.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Russell King <linux@arm.linux.org.uk> # arm
Cc: <linux-acpi@vger.kernel.org> # apei
Cc: <drbd-user@lists.linbit.com> # drbd
Cc: <linux-kernel@vger.kernel.org> # mspec
Cc: <dri-devel@lists.freedesktop.org> # drm
Cc: Oleg Drokin <oleg.drokin@intel.com> # lustre
Cc: Andreas Dilger <andreas.dilger@intel.com> # lustre
Cc: <codalist@coda.cs.cmu.edu> # coda
Cc: <linux-mtd@lists.infradead.org> # jffs2
Cc: Jan Kara <jack@suse.com> # udf
Cc: <linux-fsdevel@vger.kernel.org> # xattr
Cc: <linux-mm@kvack.org> # ipc + mm
Cc: <netdev@vger.kernel.org> # ipv4
---
 arch/arm/mm/dma-mapping.c                          | 11 ++------
 drivers/acpi/apei/erst.c                           |  6 ++--
 drivers/block/drbd/drbd_bitmap.c                   | 26 +++++------------
 drivers/block/drbd/drbd_int.h                      |  3 --
 drivers/char/mspec.c                               | 15 ++--------
 drivers/gpu/drm/drm_hashtab.c                      |  5 +---
 .../lustre/include/linux/libcfs/libcfs_private.h   |  8 ++----
 fs/coda/coda_linux.h                               |  3 +-
 fs/jffs2/build.c                                   |  8 ++----
 fs/jffs2/fs.c                                      |  5 +---
 fs/jffs2/super.c                                   |  5 +---
 fs/udf/super.c                                     |  7 +----
 fs/xattr.c                                         | 33 ++++++----------------
 ipc/sem.c                                          |  2 +-
 ipc/util.c                                         | 11 ++------
 ipc/util.h                                         |  2 +-
 mm/percpu.c                                        | 18 +++++-------
 mm/vmalloc.c                                       |  5 +---
 net/ipv4/fib_trie.c                                |  4 +--
 19 files changed, 46 insertions(+), 131 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index e62400e..492bf3e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1200,10 +1200,7 @@ error:
 	while (i--)
 		if (pages[i])
 			__free_pages(pages[i], 0);
-	if (array_size <= PAGE_SIZE)
-		kfree(pages);
-	else
-		vfree(pages);
+	kvfree(pages);
 	return NULL;
 }
 
@@ -1211,7 +1208,6 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
 			       size_t size, struct dma_attrs *attrs)
 {
 	int count = size >> PAGE_SHIFT;
-	int array_size = count * sizeof(struct page *);
 	int i;
 
 	if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS, attrs)) {
@@ -1222,10 +1218,7 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages,
 				__free_pages(pages[i], 0);
 	}
 
-	if (array_size <= PAGE_SIZE)
-		kfree(pages);
-	else
-		vfree(pages);
+	kvfree(pages);
 	return 0;
 }
 
diff --git a/drivers/acpi/apei/erst.c b/drivers/acpi/apei/erst.c
index 6682c5d..6e6bc10 100644
--- a/drivers/acpi/apei/erst.c
+++ b/drivers/acpi/apei/erst.c
@@ -32,6 +32,7 @@
 #include <linux/hardirq.h>
 #include <linux/pstore.h>
 #include <linux/vmalloc.h>
+#include <linux/mm.h> /* kvfree() */
 #include <acpi/apei.h>
 
 #include "apei-internal.h"
@@ -532,10 +533,7 @@ retry:
 			return -ENOMEM;
 		memcpy(new_entries, entries,
 		       erst_record_id_cache.len * sizeof(entries[0]));
-		if (erst_record_id_cache.size < PAGE_SIZE)
-			kfree(entries);
-		else
-			vfree(entries);
+		kvfree(entries);
 		erst_record_id_cache.entries = entries = new_entries;
 		erst_record_id_cache.size = new_size;
 	}
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 9462d27..2daaafb 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -364,12 +364,9 @@ static void bm_free_pages(struct page **pages, unsigned long number)
 	}
 }
 
-static void bm_vk_free(void *ptr, int v)
+static inline void bm_vk_free(void *ptr)
 {
-	if (v)
-		vfree(ptr);
-	else
-		kfree(ptr);
+	kvfree(ptr);
 }
 
 /*
@@ -379,7 +376,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 {
 	struct page **old_pages = b->bm_pages;
 	struct page **new_pages, *page;
-	unsigned int i, bytes, vmalloced = 0;
+	unsigned int i, bytes;
 	unsigned long have = b->bm_number_of_pages;
 
 	BUG_ON(have == 0 && old_pages != NULL);
@@ -401,7 +398,6 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 				PAGE_KERNEL);
 		if (!new_pages)
 			return NULL;
-		vmalloced = 1;
 	}
 
 	if (want >= have) {
@@ -411,7 +407,7 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 			page = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
 			if (!page) {
 				bm_free_pages(new_pages + have, i - have);
-				bm_vk_free(new_pages, vmalloced);
+				bm_vk_free(new_pages);
 				return NULL;
 			}
 			/* we want to know which page it is
@@ -427,11 +423,6 @@ static struct page **bm_realloc_pages(struct drbd_bitmap *b, unsigned long want)
 		*/
 	}
 
-	if (vmalloced)
-		b->bm_flags |= BM_P_VMALLOCED;
-	else
-		b->bm_flags &= ~BM_P_VMALLOCED;
-
 	return new_pages;
 }
 
@@ -469,7 +460,7 @@ void drbd_bm_cleanup(struct drbd_device *device)
 	if (!expect(device->bitmap))
 		return;
 	bm_free_pages(device->bitmap->bm_pages, device->bitmap->bm_number_of_pages);
-	bm_vk_free(device->bitmap->bm_pages, (BM_P_VMALLOCED & device->bitmap->bm_flags));
+	bm_vk_free(device->bitmap->bm_pages);
 	kfree(device->bitmap);
 	device->bitmap = NULL;
 }
@@ -639,7 +630,6 @@ int drbd_bm_resize(struct drbd_device *device, sector_t capacity, int set_new_bi
 	unsigned long want, have, onpages; /* number of pages */
 	struct page **npages, **opages = NULL;
 	int err = 0, growing;
-	int opages_vmalloced;
 
 	if (!expect(b))
 		return -ENOMEM;
@@ -652,8 +642,6 @@ int drbd_bm_resize(struct drbd_device *device, sector_t capacity, int set_new_bi
 	if (capacity == b->bm_dev_capacity)
 		goto out;
 
-	opages_vmalloced = (BM_P_VMALLOCED & b->bm_flags);
-
 	if (capacity == 0) {
 		spin_lock_irq(&b->bm_lock);
 		opages = b->bm_pages;
@@ -667,7 +655,7 @@ int drbd_bm_resize(struct drbd_device *device, sector_t capacity, int set_new_bi
 		b->bm_dev_capacity = 0;
 		spin_unlock_irq(&b->bm_lock);
 		bm_free_pages(opages, onpages);
-		bm_vk_free(opages, opages_vmalloced);
+		bm_vk_free(opages);
 		goto out;
 	}
 	bits  = BM_SECT_TO_BIT(ALIGN(capacity, BM_SECT_PER_BIT));
@@ -740,7 +728,7 @@ int drbd_bm_resize(struct drbd_device *device, sector_t capacity, int set_new_bi
 
 	spin_unlock_irq(&b->bm_lock);
 	if (opages != npages)
-		bm_vk_free(opages, opages_vmalloced);
+		bm_vk_free(opages);
 	if (!growing)
 		b->bm_set = bm_count_bits(b);
 	drbd_info(device, "resync bitmap: bits=%lu words=%lu pages=%lu\n", bits, words, want);
diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
index e66d453..07e75ae 100644
--- a/drivers/block/drbd/drbd_int.h
+++ b/drivers/block/drbd/drbd_int.h
@@ -541,9 +541,6 @@ struct drbd_bitmap; /* opaque for drbd_device */
 /* definition of bits in bm_flags to be used in drbd_bm_lock
  * and drbd_bitmap_io and friends. */
 enum bm_flag {
-	/* do we need to kfree, or vfree bm_pages? */
-	BM_P_VMALLOCED = 0x10000, /* internal use only, will be masked out */
-
 	/* currently locked for bulk operation */
 	BM_LOCKED_MASK = 0xf,
 
diff --git a/drivers/char/mspec.c b/drivers/char/mspec.c
index f1d7fa4..f3f92d5 100644
--- a/drivers/char/mspec.c
+++ b/drivers/char/mspec.c
@@ -93,14 +93,11 @@ struct vma_data {
 	spinlock_t lock;	/* Serialize access to this structure. */
 	int count;		/* Number of pages allocated. */
 	enum mspec_page_type type; /* Type of pages allocated. */
-	int flags;		/* See VMD_xxx below. */
 	unsigned long vm_start;	/* Original (unsplit) base. */
 	unsigned long vm_end;	/* Original (unsplit) end. */
 	unsigned long maddr[0];	/* Array of MSPEC addresses. */
 };
 
-#define VMD_VMALLOCED 0x1	/* vmalloc'd rather than kmalloc'd */
-
 /* used on shub2 to clear FOP cache in the HUB */
 static unsigned long scratch_page[MAX_NUMNODES];
 #define SH2_AMO_CACHE_ENTRIES	4
@@ -185,10 +182,7 @@ mspec_close(struct vm_area_struct *vma)
 			       "failed to zero page %ld\n", my_page);
 	}
 
-	if (vdata->flags & VMD_VMALLOCED)
-		vfree(vdata);
-	else
-		kfree(vdata);
+	kvfree(vdata);
 }
 
 /*
@@ -256,7 +250,7 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 					enum mspec_page_type type)
 {
 	struct vma_data *vdata;
-	int pages, vdata_size, flags = 0;
+	int pages, vdata_size;
 
 	if (vma->vm_pgoff != 0)
 		return -EINVAL;
@@ -271,16 +265,13 @@ mspec_mmap(struct file *file, struct vm_area_struct *vma,
 	vdata_size = sizeof(struct vma_data) + pages * sizeof(long);
 	if (vdata_size <= PAGE_SIZE)
 		vdata = kzalloc(vdata_size, GFP_KERNEL);
-	else {
+	else
 		vdata = vzalloc(vdata_size);
-		flags = VMD_VMALLOCED;
-	}
 	if (!vdata)
 		return -ENOMEM;
 
 	vdata->vm_start = vma->vm_start;
 	vdata->vm_end = vma->vm_end;
-	vdata->flags = flags;
 	vdata->type = type;
 	spin_lock_init(&vdata->lock);
 	atomic_set(&vdata->refcnt, 1);
diff --git a/drivers/gpu/drm/drm_hashtab.c b/drivers/gpu/drm/drm_hashtab.c
index c3b80fd..7b30b30 100644
--- a/drivers/gpu/drm/drm_hashtab.c
+++ b/drivers/gpu/drm/drm_hashtab.c
@@ -198,10 +198,7 @@ EXPORT_SYMBOL(drm_ht_remove_item);
 void drm_ht_remove(struct drm_open_hash *ht)
 {
 	if (ht->table) {
-		if ((PAGE_SIZE / sizeof(*ht->table)) >> ht->order)
-			kfree(ht->table);
-		else
-			vfree(ht->table);
+		kvfree(ht->table);
 		ht->table = NULL;
 	}
 }
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index f0b0423..f40fa98 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -151,16 +151,12 @@ do {									    \
 
 #define LIBCFS_FREE(ptr, size)					  \
 do {								    \
-	int s = (size);						 \
 	if (unlikely((ptr) == NULL)) {				  \
 		CERROR("LIBCFS: free NULL '" #ptr "' (%d bytes) at "    \
-		       "%s:%d\n", s, __FILE__, __LINE__);	       \
+		       "%s:%d\n", (int)(size), __FILE__, __LINE__);	\
 		break;						  \
 	}							       \
-	if (unlikely(s > LIBCFS_VMALLOC_SIZE))			  \
-		vfree(ptr);				    \
-	else							    \
-		kfree(ptr);					  \
+	kvfree(ptr);					  \
 } while (0)
 
 /******************************************************************************/
diff --git a/fs/coda/coda_linux.h b/fs/coda/coda_linux.h
index f829fe9..5104d84 100644
--- a/fs/coda/coda_linux.h
+++ b/fs/coda/coda_linux.h
@@ -72,8 +72,7 @@ void coda_sysctl_clean(void);
 } while (0)
 
 
-#define CODA_FREE(ptr,size) \
-    do { if (size < PAGE_SIZE) kfree((ptr)); else vfree((ptr)); } while (0)
+#define CODA_FREE(ptr, size) kvfree((ptr))
 
 /* inode to cnode access functions */
 
diff --git a/fs/jffs2/build.c b/fs/jffs2/build.c
index a3750f9..0ae91ad 100644
--- a/fs/jffs2/build.c
+++ b/fs/jffs2/build.c
@@ -17,6 +17,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mtd/mtd.h>
+#include <linux/mm.h> /* kvfree() */
 #include "nodelist.h"
 
 static void jffs2_build_remove_unlinked_inode(struct jffs2_sb_info *,
@@ -383,12 +384,7 @@ int jffs2_do_mount_fs(struct jffs2_sb_info *c)
 	return 0;
 
  out_free:
-#ifndef __ECOS
-	if (jffs2_blocks_use_vmalloc(c))
-		vfree(c->blocks);
-	else
-#endif
-		kfree(c->blocks);
+	kvfree(c->blocks);
 
 	return ret;
 }
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index 2caf168..bead25a 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -596,10 +596,7 @@ int jffs2_do_fill_super(struct super_block *sb, void *data, int silent)
 out_root:
 	jffs2_free_ino_caches(c);
 	jffs2_free_raw_node_refs(c);
-	if (jffs2_blocks_use_vmalloc(c))
-		vfree(c->blocks);
-	else
-		kfree(c->blocks);
+	kvfree(c->blocks);
  out_inohash:
 	jffs2_clear_xattr_subsystem(c);
 	kfree(c->inocache_list);
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index d86c5e3..3749e65 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -331,10 +331,7 @@ static void jffs2_put_super (struct super_block *sb)
 
 	jffs2_free_ino_caches(c);
 	jffs2_free_raw_node_refs(c);
-	if (jffs2_blocks_use_vmalloc(c))
-		vfree(c->blocks);
-	else
-		kfree(c->blocks);
+	kvfree(c->blocks);
 	jffs2_flash_cleanup(c);
 	kfree(c->inocache_list);
 	jffs2_clear_xattr_subsystem(c);
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 81155b9..0ecd754 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -278,17 +278,12 @@ static void udf_sb_free_bitmap(struct udf_bitmap *bitmap)
 {
 	int i;
 	int nr_groups = bitmap->s_nr_groups;
-	int size = sizeof(struct udf_bitmap) + (sizeof(struct buffer_head *) *
-						nr_groups);
 
 	for (i = 0; i < nr_groups; i++)
 		if (bitmap->s_block_bitmap[i])
 			brelse(bitmap->s_block_bitmap[i]);
 
-	if (size <= PAGE_SIZE)
-		kfree(bitmap);
-	else
-		vfree(bitmap);
+	kvfree(bitmap);
 }
 
 static void udf_free_partition(struct udf_part_map *map)
diff --git a/fs/xattr.c b/fs/xattr.c
index 072fee1..6276b04 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -324,7 +324,6 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 {
 	int error;
 	void *kvalue = NULL;
-	void *vvalue = NULL;	/* If non-NULL, we used vmalloc() */
 	char kname[XATTR_NAME_MAX + 1];
 
 	if (flags & ~(XATTR_CREATE|XATTR_REPLACE))
@@ -341,10 +340,9 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 			return -E2BIG;
 		kvalue = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!kvalue) {
-			vvalue = vmalloc(size);
-			if (!vvalue)
+			kvalue = vmalloc(size);
+			if (!kvalue)
 				return -ENOMEM;
-			kvalue = vvalue;
 		}
 		if (copy_from_user(kvalue, value, size)) {
 			error = -EFAULT;
@@ -357,10 +355,7 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 
 	error = vfs_setxattr(d, kname, kvalue, size, flags);
 out:
-	if (vvalue)
-		vfree(vvalue);
-	else
-		kfree(kvalue);
+	kvfree(kvalue);
 	return error;
 }
 
@@ -428,7 +423,6 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 {
 	ssize_t error;
 	void *kvalue = NULL;
-	void *vvalue = NULL;
 	char kname[XATTR_NAME_MAX + 1];
 
 	error = strncpy_from_user(kname, name, sizeof(kname));
@@ -442,10 +436,9 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 			size = XATTR_SIZE_MAX;
 		kvalue = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!kvalue) {
-			vvalue = vmalloc(size);
-			if (!vvalue)
+			kvalue = vmalloc(size);
+			if (!kvalue)
 				return -ENOMEM;
-			kvalue = vvalue;
 		}
 	}
 
@@ -461,10 +454,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 		   than XATTR_SIZE_MAX bytes. Not possible. */
 		error = -E2BIG;
 	}
-	if (vvalue)
-		vfree(vvalue);
-	else
-		kfree(kvalue);
+	kvfree(kvalue);
 	return error;
 }
 
@@ -521,17 +511,15 @@ listxattr(struct dentry *d, char __user *list, size_t size)
 {
 	ssize_t error;
 	char *klist = NULL;
-	char *vlist = NULL;	/* If non-NULL, we used vmalloc() */
 
 	if (size) {
 		if (size > XATTR_LIST_MAX)
 			size = XATTR_LIST_MAX;
 		klist = kmalloc(size, __GFP_NOWARN | GFP_KERNEL);
 		if (!klist) {
-			vlist = vmalloc(size);
-			if (!vlist)
+			klist = vmalloc(size);
+			if (!klist)
 				return -ENOMEM;
-			klist = vlist;
 		}
 	}
 
@@ -544,10 +532,7 @@ listxattr(struct dentry *d, char __user *list, size_t size)
 		   than XATTR_LIST_MAX bytes. Not possible. */
 		error = -E2BIG;
 	}
-	if (vlist)
-		vfree(vlist);
-	else
-		kfree(klist);
+	kvfree(klist);
 	return error;
 }
 
diff --git a/ipc/sem.c b/ipc/sem.c
index b471e5a..cddd5b5 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1493,7 +1493,7 @@ out_rcu_wakeup:
 	wake_up_sem_queue_do(&tasks);
 out_free:
 	if (sem_io != fast_sem_io)
-		ipc_free(sem_io, sizeof(ushort)*nsems);
+		ipc_free(sem_io);
 	return err;
 }
 
diff --git a/ipc/util.c b/ipc/util.c
index 0f401d9..798cad1 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -414,17 +414,12 @@ void *ipc_alloc(int size)
 /**
  * ipc_free - free ipc space
  * @ptr: pointer returned by ipc_alloc
- * @size: size of block
  *
- * Free a block created with ipc_alloc(). The caller must know the size
- * used in the allocation call.
+ * Free a block created with ipc_alloc().
  */
-void ipc_free(void *ptr, int size)
+void ipc_free(void *ptr)
 {
-	if (size > PAGE_SIZE)
-		vfree(ptr);
-	else
-		kfree(ptr);
+	kvfree(ptr);
 }
 
 /**
diff --git a/ipc/util.h b/ipc/util.h
index 3a8a5a0..51f7ca5 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -118,7 +118,7 @@ int ipcperms(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp, short flg);
  * both function can sleep
  */
 void *ipc_alloc(int size);
-void ipc_free(void *ptr, int size);
+void ipc_free(void *ptr);
 
 /*
  * For allocation that need to be freed by RCU.
diff --git a/mm/percpu.c b/mm/percpu.c
index 8a943b9..998607a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -305,16 +305,12 @@ static void *pcpu_mem_zalloc(size_t size)
 /**
  * pcpu_mem_free - free memory
  * @ptr: memory to free
- * @size: size of the area
  *
  * Free @ptr.  @ptr should have been allocated using pcpu_mem_zalloc().
  */
-static void pcpu_mem_free(void *ptr, size_t size)
+static void pcpu_mem_free(void *ptr)
 {
-	if (size <= PAGE_SIZE)
-		kfree(ptr);
-	else
-		vfree(ptr);
+	kvfree(ptr);
 }
 
 /**
@@ -463,8 +459,8 @@ out_unlock:
 	 * pcpu_mem_free() might end up calling vfree() which uses
 	 * IRQ-unsafe lock and thus can't be called under pcpu_lock.
 	 */
-	pcpu_mem_free(old, old_size);
-	pcpu_mem_free(new, new_size);
+	pcpu_mem_free(old);
+	pcpu_mem_free(new);
 
 	return 0;
 }
@@ -732,7 +728,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
 						sizeof(chunk->map[0]));
 	if (!chunk->map) {
-		pcpu_mem_free(chunk, pcpu_chunk_struct_size);
+		pcpu_mem_free(chunk);
 		return NULL;
 	}
 
@@ -753,8 +749,8 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
 {
 	if (!chunk)
 		return;
-	pcpu_mem_free(chunk->map, chunk->map_alloc * sizeof(chunk->map[0]));
-	pcpu_mem_free(chunk, pcpu_chunk_struct_size);
+	pcpu_mem_free(chunk->map);
+	pcpu_mem_free(chunk);
 }
 
 /**
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d045634..b1c9fe8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1481,10 +1481,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			__free_page(page);
 		}
 
-		if (area->flags & VM_VPAGES)
-			vfree(area->pages);
-		else
-			kfree(area->pages);
+		kvfree(area->pages);
 	}
 
 	kfree(area);
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 744e593..7aea0cc 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -289,10 +289,8 @@ static void __node_free_rcu(struct rcu_head *head)
 
 	if (!n->tn_bits)
 		kmem_cache_free(trie_leaf_kmem, n);
-	else if (n->tn_bits <= TNODE_KMALLOC_MAX)
-		kfree(n);
 	else
-		vfree(n);
+		kvfree(n);
 }
 
 #define node_free(n) call_rcu(&tn_info(n)->rcu, __node_free_rcu)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
