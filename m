Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77A066B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 01:16:12 -0400 (EDT)
Received: by yxe12 with SMTP id 12so3916511yxe.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 22:16:13 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Sep 2009 17:16:13 +1200
Message-ID: <202cde0e0909132216l79aae251ya3a6685587c7692c@mail.gmail.com>
Subject: [PATCH 1/3] Identification of huge pages mapping (Take 3)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch changes a little bit the procedures of huge pages file
identification. We need this because we may have huge page mapping for
files which are not on hugetlbfs (the same case in ipc/shm.c).
Just file operations check will not work as drivers should have own
file operations. So if we need to identify if file has huge pages
mapping, we need to check the file mapping flags.
New identification procedure obsoletes existing workaround for hugetlb
file identification in ipc/shm.c
Also having huge page mapping for files which are not on hugetlbfs do
not allow us to get hstate based on file dentry, we need to be based
on file mapping instead.

fs/hugetlbfs/inode.c    |    1 +
include/linux/hugetlb.h |   15 ++-------------
include/linux/pagemap.h |   13 +++++++++++++
ipc/shm.c               |   12 ------------
4 files changed, 16 insertions(+), 25 deletions(-)

---
Signed-off-by: Alexey Korolev <akorolev@infradead.org>

diff -aurp clean/fs/hugetlbfs/inode.c patched/fs/hugetlbfs/inode.c
--- clean/fs/hugetlbfs/inode.c	2009-09-10 17:48:38.000000000 +1200
+++ patched/fs/hugetlbfs/inode.c	2009-09-11 15:12:17.000000000 +1200
@@ -521,6 +521,7 @@ static struct inode *hugetlbfs_get_inode
 		case S_IFREG:
 			inode->i_op = &hugetlbfs_inode_operations;
 			inode->i_fop = &hugetlbfs_file_operations;
+			mapping_set_hugetlb(inode->i_mapping);
 			break;
 		case S_IFDIR:
 			inode->i_op = &hugetlbfs_dir_inode_operations;
diff -aurp clean/include/linux/hugetlb.h patched/include/linux/hugetlb.h
--- clean/include/linux/hugetlb.h	2009-09-10 17:48:28.000000000 +1200
+++ patched/include/linux/hugetlb.h	2009-09-11 15:15:30.000000000 +1200
@@ -169,22 +169,11 @@ void hugetlb_put_quota(struct address_sp

 static inline int is_file_hugepages(struct file *file)
 {
-	if (file->f_op == &hugetlbfs_file_operations)
-		return 1;
-	if (is_file_shm_hugepages(file))
-		return 1;
-
-	return 0;
-}
-
-static inline void set_file_hugepages(struct file *file)
-{
-	file->f_op = &hugetlbfs_file_operations;
+	return mapping_hugetlb(file->f_mapping);
 }
 #else /* !CONFIG_HUGETLBFS */

 #define is_file_hugepages(file)			0
-#define set_file_hugepages(file)		BUG()
 #define hugetlb_file_setup(name,size,acct,user,creat)	ERR_PTR(-ENOSYS)

 #endif /* !CONFIG_HUGETLBFS */
@@ -245,7 +234,7 @@ static inline struct hstate *hstate_inod

 static inline struct hstate *hstate_file(struct file *f)
 {
-	return hstate_inode(f->f_dentry->d_inode);
+	return hstate_inode(f->f_mapping->host);
 }

 static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
diff -aurp clean/include/linux/pagemap.h patched/include/linux/pagemap.h
--- clean/include/linux/pagemap.h	2009-09-06 11:38:12.000000000 +1200
+++ patched/include/linux/pagemap.h	2009-09-11 15:17:04.000000000 +1200
@@ -23,6 +23,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_HUGETLB	= __GFP_BITS_SHIFT + 4,	/* under HUGE TLB */
 };

 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -52,6 +53,18 @@ static inline int mapping_unevictable(st
 	return !!mapping;
 }

+static inline void mapping_set_hugetlb(struct address_space *mapping)
+{
+	set_bit(AS_HUGETLB, &mapping->flags);
+}
+
+static inline int mapping_hugetlb(struct address_space *mapping)
+{
+	if (likely(mapping))
+		return test_bit(AS_HUGETLB, &mapping->flags);
+	return 0;
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
diff -aurp clean/ipc/shm.c patched/ipc/shm.c
--- clean/ipc/shm.c	2009-09-10 17:48:23.000000000 +1200
+++ patched/ipc/shm.c	2009-09-11 15:17:04.000000000 +1200
@@ -293,18 +293,6 @@ static unsigned long shm_get_unmapped_ar
 	return get_unmapped_area(sfd->file, addr, len, pgoff, flags);
 }

-int is_file_shm_hugepages(struct file *file)
-{
-	int ret = 0;
-
-	if (file->f_op == &shm_file_operations) {
-		struct shm_file_data *sfd;
-		sfd = shm_file_data(file);
-		ret = is_file_hugepages(sfd->file);
-	}
-	return ret;
-}
-
 static const struct file_operations shm_file_operations = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
