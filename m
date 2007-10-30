From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 4/5] hugetlb: Allow bulk updating in hugetlb_*_quota()
Date: Tue, 30 Oct 2007 13:46:38 -0700
Message-Id: <20071030204638.16585.3618.stgit@kernel>
In-Reply-To: <20071030204554.16585.80588.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Add a second parameter 'delta' to hugetlb_get_quota and hugetlb_put_quota
to allow bulk updating of the sbinfo->free_blocks counter.  This will be
used by the next patch in the series.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 fs/hugetlbfs/inode.c    |   10 +++++-----
 include/linux/hugetlb.h |    4 ++--
 mm/hugetlb.c            |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5f4e888..449ba8b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -858,15 +858,15 @@ out_free:
 	return -ENOMEM;
 }
 
-int hugetlb_get_quota(struct address_space *mapping)
+int hugetlb_get_quota(struct address_space *mapping, long delta)
 {
 	int ret = 0;
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
 
 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
-		if (sbinfo->free_blocks > 0)
-			sbinfo->free_blocks--;
+		if (sbinfo->free_blocks - delta >= 0)
+			sbinfo->free_blocks -= delta;
 		else
 			ret = -ENOMEM;
 		spin_unlock(&sbinfo->stat_lock);
@@ -875,13 +875,13 @@ int hugetlb_get_quota(struct address_space *mapping)
 	return ret;
 }
 
-void hugetlb_put_quota(struct address_space *mapping)
+void hugetlb_put_quota(struct address_space *mapping, long delta)
 {
 	struct hugetlbfs_sb_info *sbinfo = HUGETLBFS_SB(mapping->host->i_sb);
 
 	if (sbinfo->free_blocks > -1) {
 		spin_lock(&sbinfo->stat_lock);
-		sbinfo->free_blocks++;
+		sbinfo->free_blocks += delta;
 		spin_unlock(&sbinfo->stat_lock);
 	}
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ea0f50b..770dbed 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -165,8 +165,8 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t);
-int hugetlb_get_quota(struct address_space *mapping);
-void hugetlb_put_quota(struct address_space *mapping);
+int hugetlb_get_quota(struct address_space *mapping, long delta);
+void hugetlb_put_quota(struct address_space *mapping, long delta);
 
 static inline int is_file_hugepages(struct file *file)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5eacee8..deba411 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -132,7 +132,7 @@ static void free_huge_page(struct page *page)
 	}
 	spin_unlock(&hugetlb_lock);
 	if (mapping)
-		hugetlb_put_quota(mapping);
+		hugetlb_put_quota(mapping, 1);
 	set_page_private(page, 0);
 }
 
@@ -390,7 +390,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 
-	if (hugetlb_get_quota(mapping))
+	if (hugetlb_get_quota(mapping, 1))
 		return ERR_PTR(-VM_FAULT_SIGBUS);
 
 	if (vma->vm_flags & VM_MAYSHARE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
