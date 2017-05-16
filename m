Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5E066B02E1
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:30:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16so119778457pfj.15
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:30:02 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p2si10265605pfg.78.2017.05.16.01.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 01:30:01 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 06/17] mm/shmem: expose driver overridable huge option
Date: Tue, 16 May 2017 09:29:37 +0100
Message-Id: <20170516082948.28090-7-matthew.auld@intel.com>
In-Reply-To: <20170516082948.28090-1-matthew.auld@intel.com>
References: <20170516082948.28090-1-matthew.auld@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Daniel Vetter <daniel@ffwll.ch>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

In i915 we are aiming to support huge GTT pages for the GPU, and to
complement this we also want to enable THP for our shmem backed objects.
Even though THP is supported in shmemfs it can only be enabled through
the huge= mount option, but for users of the kernel mounted shm_mnt like
i915, we are a little stuck. There is the sysfs knob shmem_enabled to
either forcefully enable/disable the feature, but that seems to only be
useful for testing purposes. What we propose is to expose a driver
overridable huge option as part of shmem_inode_info to control the use
of THP for a given mapping.

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 include/linux/shmem_fs.h | 20 ++++++++++++++++++++
 mm/shmem.c               | 37 +++++++++++++++----------------------
 2 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index a7d6bd2a918f..4cfdb2e8e1d8 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -21,8 +21,28 @@ struct shmem_inode_info {
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
 	struct inode		vfs_inode;
+	unsigned char		huge;           /* driver override sbinfo->huge */
 };
 
+/*
+ * Definitions for "huge tmpfs": tmpfs mounted with the huge= option
+ *
+ * SHMEM_HUGE_NEVER:
+ *	disables huge pages for the mount;
+ * SHMEM_HUGE_ALWAYS:
+ *	enables huge pages for the mount;
+ * SHMEM_HUGE_WITHIN_SIZE:
+ *	only allocate huge pages if the page will be fully within i_size,
+ *	also respect fadvise()/madvise() hints;
+ * SHMEM_HUGE_ADVISE:
+ *	only allocate huge pages if requested with fadvise()/madvise();
+ */
+
+#define SHMEM_HUGE_NEVER	0
+#define SHMEM_HUGE_ALWAYS	1
+#define SHMEM_HUGE_WITHIN_SIZE	2
+#define SHMEM_HUGE_ADVISE	3
+
 struct shmem_sb_info {
 	unsigned long max_blocks;   /* How many blocks are allowed */
 	struct percpu_counter used_blocks;  /* How many are allocated */
diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba4e98e..4fa042694957 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -346,25 +346,6 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 }
 
 /*
- * Definitions for "huge tmpfs": tmpfs mounted with the huge= option
- *
- * SHMEM_HUGE_NEVER:
- *	disables huge pages for the mount;
- * SHMEM_HUGE_ALWAYS:
- *	enables huge pages for the mount;
- * SHMEM_HUGE_WITHIN_SIZE:
- *	only allocate huge pages if the page will be fully within i_size,
- *	also respect fadvise()/madvise() hints;
- * SHMEM_HUGE_ADVISE:
- *	only allocate huge pages if requested with fadvise()/madvise();
- */
-
-#define SHMEM_HUGE_NEVER	0
-#define SHMEM_HUGE_ALWAYS	1
-#define SHMEM_HUGE_WITHIN_SIZE	2
-#define SHMEM_HUGE_ADVISE	3
-
-/*
  * Special values.
  * Only can be set via /sys/kernel/mm/transparent_hugepage/shmem_enabled:
  *
@@ -1715,6 +1696,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		swap_free(swap);
 
 	} else {
+		unsigned char sbinfo_huge = sbinfo->huge;
+
 		if (vma && userfaultfd_missing(vma)) {
 			*fault_type = handle_userfault(vmf, VM_UFFD_MISSING);
 			return 0;
@@ -1727,7 +1710,10 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			goto alloc_nohuge;
 		if (shmem_huge == SHMEM_HUGE_FORCE)
 			goto alloc_huge;
-		switch (sbinfo->huge) {
+		/* driver override sbinfo->huge */
+		if (info->huge)
+			sbinfo_huge = info->huge;
+		switch (sbinfo_huge) {
 			loff_t i_size;
 			pgoff_t off;
 		case SHMEM_HUGE_NEVER:
@@ -2032,10 +2018,13 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 
 	if (shmem_huge != SHMEM_HUGE_FORCE) {
 		struct super_block *sb;
+		unsigned char sbinfo_huge = 0;
 
 		if (file) {
 			VM_BUG_ON(file->f_op != &shmem_file_operations);
 			sb = file_inode(file)->i_sb;
+			/* driver override sbinfo->huge */
+			sbinfo_huge = SHMEM_I(file_inode(file))->huge;
 		} else {
 			/*
 			 * Called directly from mm/mmap.c, or drivers/char/mem.c
@@ -2045,7 +2034,8 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 				return addr;
 			sb = shm_mnt->mnt_sb;
 		}
-		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
+		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER &&
+		    sbinfo_huge == SHMEM_HUGE_NEVER)
 			return addr;
 	}
 
@@ -4031,6 +4021,7 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(vma->vm_file);
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	unsigned char sbinfo_huge = sbinfo->huge;
 	loff_t i_size;
 	pgoff_t off;
 
@@ -4038,7 +4029,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 		return true;
 	if (shmem_huge == SHMEM_HUGE_DENY)
 		return false;
-	switch (sbinfo->huge) {
+	if (SHMEM_I(inode)->huge)
+		sbinfo_huge = SHMEM_I(inode)->huge;
+	switch (sbinfo_huge) {
 		case SHMEM_HUGE_NEVER:
 			return false;
 		case SHMEM_HUGE_ALWAYS:
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
