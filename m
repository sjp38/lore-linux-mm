Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B98756B0055
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 18:46:26 -0400 (EDT)
Date: Mon, 17 Aug 2009 23:46:29 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: [PATCH 3/3]HTLB mapping for drivers. Hugetlb files identification
 based on mapping(take 2)
Message-ID: <alpine.LFD.2.00.0908172340430.32114@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch changes the procedures of htlb file identification.
Since we can have non htlbfs files with htlb mapping we need to have
another approach for identification if mapping is hugetlb or not.
Just checking of file operations seems to be a bad approach as drivers
(as well as ipc/shm) need to have own file_operations. 
Now we identify if maping is hugetlb by special mapping flag. 
Since hugetlb identification is based on mapping flags, we no longer
need the workaround made in ipc/shm.c

Signed-off-by: Alexey Korolev <akorolev@infradead.org>
---
 fs/hugetlbfs/inode.c    |    1 +
 include/linux/hugetlb.h |    7 +------
 include/linux/pagemap.h |   13 +++++++++++++
 include/linux/shm.h     |    5 -----
 ipc/shm.c               |   12 ------------
 5 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 6510acc..b92fb38 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -513,6 +513,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 		case S_IFREG:
 			inode->i_op = &hugetlbfs_inode_operations;
 			inode->i_fop = &hugetlbfs_file_operations;
+			mapping_set_hugetlb(inode->i_mapping);
 			break;
 		case S_IFDIR:
 			inode->i_op = &hugetlbfs_dir_inode_operations;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e132a61..1b71f1e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -157,12 +157,7 @@ void hugetlb_put_quota(struct address_space *mapping, long delta);
 
 static inline int is_file_hugepages(struct file *file)
 {
-	if (file->f_op == &hugetlbfs_file_operations)
-		return 1;
-	if (is_file_shm_hugepages(file))
-		return 1;
-
-	return 0;
+	return mapping_hugetlb(file->f_mapping);
 }
 
 static inline void set_file_hugepages(struct file *file)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index aec3252..0b27ede 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -23,6 +23,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_HUGETLB	= __GFP_BITS_SHIFT + 4,	/* under HUGE TLB */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -52,6 +53,18 @@ static inline int mapping_unevictable(struct address_space *mapping)
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
diff --git a/include/linux/shm.h b/include/linux/shm.h
index eca6235..590665f 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -105,17 +105,12 @@ struct shmid_kernel /* private to the kernel */
 
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
-extern int is_file_shm_hugepages(struct file *file);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
 				int shmflg, unsigned long *addr)
 {
 	return -ENOSYS;
 }
-static inline int is_file_shm_hugepages(struct file *file)
-{
-	return 0;
-}
 #endif
 
 #endif /* __KERNEL__ */
diff --git a/ipc/shm.c b/ipc/shm.c
index 15dd238..2bf065e 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -293,18 +293,6 @@ static unsigned long shm_get_unmapped_area(struct file *file,
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


The patch also is available here:
http://git.infradead.org/users/akorolev/mm-patches.git/commit/f2560584f31eab7c35625ff85d6421dab7bd1f5f

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
