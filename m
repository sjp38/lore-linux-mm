Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A4CE96B0055
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 18:40:38 -0400 (EDT)
Date: Mon, 17 Aug 2009 23:40:38 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: [PATCH 2/3]HTLB mapping for drivers. Hstate for files with hugetlb
 mapping(take 2)
Message-ID: <alpine.LFD.2.00.0908172333410.32114@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch slightly modifies the procedure for getting hstate from inode.
If inode correspond to hugetlbfs - the hugetlbfs hstate will be returned, otherwise 
hstate of vfs mount. We need this since we can have files with hugetlb mapping which are 
not part of hugetlbfs.

Also this patch contains a function which reports hstate related to vfsmount as information
about huge page size is much important for drivers.

Signed-off-by: Alexey Korolev <akorolev@infradead.org>

---
 fs/hugetlbfs/inode.c    |   16 +++++++++++-----
 include/linux/hugetlb.h |   16 ++++++++++++++--
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index f53cf64..6510acc 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -34,9 +34,6 @@
 
 #include <asm/uaccess.h>
 
-/* some random number */
-#define HUGETLBFS_MAGIC	0x958458f6
-
 static const struct super_operations hugetlbfs_ops;
 static const struct address_space_operations hugetlbfs_aops;
 const struct file_operations hugetlbfs_file_operations;
@@ -50,6 +47,8 @@ static struct backing_dev_info hugetlbfs_backing_dev_info = {
 
 int sysctl_hugetlb_shm_group;
 
+struct vfsmount *hugetlbfs_vfsmount;
+
 enum {
 	Opt_size, Opt_nr_inodes,
 	Opt_mode, Opt_uid, Opt_gid,
@@ -928,13 +927,20 @@ static struct file_system_type hugetlbfs_fs_type = {
 	.kill_sb	= kill_litter_super,
 };
 
-static struct vfsmount *hugetlbfs_vfsmount;
-
 static int can_do_hugetlb_shm(void)
 {
 	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
 
+struct hstate *hugetlb_vfsmount_hstate(void)
+{
+	struct hugetlbfs_sb_info *hsb;
+
+	hsb = HUGETLBFS_SB(hugetlbfs_vfsmount->mnt_root->d_sb);
+	return hsb->hstate;
+}
+EXPORT_SYMBOL(hugetlb_vfsmount_hstate);
+
 struct file *hugetlb_file_setup(const char *name, size_t size, int acctflag)
 {
 	int error = -ENOMEM;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index e42fa32..e132a61 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -8,6 +8,7 @@
 #include <linux/mempolicy.h>
 #include <linux/shm.h>
 #include <asm/tlbflush.h>
+#include <linux/mount.h>
 
 struct ctl_table;
 
@@ -110,6 +111,10 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 #endif /* !CONFIG_HUGETLB_PAGE */
 
 #ifdef CONFIG_HUGETLBFS
+
+/* some random number */
+#define HUGETLBFS_MAGIC	0x958458f6
+
 struct hugetlbfs_config {
 	uid_t   uid;
 	gid_t   gid;
@@ -222,11 +227,17 @@ extern unsigned int default_hstate_idx;
 
 #define default_hstate (hstates[default_hstate_idx])
 
+struct hstate *hugetlb_vfsmount_hstate(void);
+
 static inline struct hstate *hstate_inode(struct inode *i)
 {
 	struct hugetlbfs_sb_info *hsb;
-	hsb = HUGETLBFS_SB(i->i_sb);
-	return hsb->hstate;
+
+	if (i->i_sb->s_magic == HUGETLBFS_MAGIC) {
+		hsb = HUGETLBFS_SB(i->i_sb);
+		return hsb->hstate;
+	}
+	return hugetlb_vfsmount_hstate();
 }
 
 static inline struct hstate *hstate_file(struct file *f)
@@ -282,6 +293,7 @@ static inline struct hstate *page_hstate(struct page *page)
 
 #else
 struct hstate {};
+#define hugetlb_vfsmount_hstate() NULL
 #define hugetlb_alloc_pages_immediate(h, n, m) NULL
 #define hugetlb_free_pages_immediate(h, p)
 #define alloc_bootmem_huge_page(h) NULL
-- 

Alternativelly the patch is available here:
http://git.infradead.org/users/akorolev/mm-patches.git/commit/b3eca27294ae47e78234bd8ec87c356998be969a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
