Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B2F4C6B00B3
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 01:02:03 -0400 (EDT)
Date: Tue, 13 Oct 2009 13:58:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 8/8] memcg: recharge charges of shmem swap
Message-Id: <20091013135810.784cbfb5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch enables recharge of shmem swaps.

To find the shmem's page or swap entry corresponding to a non pte_present pte,
this patch add a function(mem_cgroup_get_shmem_target()) to search them from the
inode and the offset.

This patch also enables recharge of non pte_present but not uncharged file
caches by getting the target pages via find_get_page() as do_mincore() does.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |    4 ++++
 mm/memcontrol.c      |   25 +++++++++++++++++++++----
 mm/shmem.c           |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4ec9001..e232653 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -278,6 +278,10 @@ extern int kswapd_run(int nid);
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 #endif /* CONFIG_MMU */
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
+					struct page **pagep, swp_entry_t *ent);
+#endif
 
 extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7e82448..cd63403 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3553,10 +3553,27 @@ static int is_target_pte_for_recharge(struct vm_area_struct *vma,
 	int ret = 0;
 
 	if (!pte_present(ptent)) {
-		/* TODO: handle swap of shmes/tmpfs */
-		if (pte_none(ptent) || pte_file(ptent))
-			return 0;
-		else if (is_swap_pte(ptent)) {
+		if (pte_none(ptent) || pte_file(ptent)) {
+			struct inode *inode;
+			struct address_space *mapping;
+			pgoff_t pgoff = 0;
+
+			if (!vma->vm_file)
+				return 0;
+
+			inode = vma->vm_file->f_path.dentry->d_inode;
+			mapping = vma->vm_file->f_mapping;
+			if (pte_none(ptent))
+				pgoff = linear_page_index(vma, addr);
+			if (pte_file(ptent))
+				pgoff = pte_to_pgoff(ptent);
+
+			if (mapping_cap_swap_backed(mapping))
+				mem_cgroup_get_shmem_target(inode, pgoff,
+								&page, &ent);
+			else
+				page = find_get_page(mapping, pgoff);
+		} else if (is_swap_pte(ptent)) {
 			ent = pte_to_swp_entry(ptent);
 			if (is_migration_entry(ent))
 				return 0;
diff --git a/mm/shmem.c b/mm/shmem.c
index 356dd99..170ec44 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2693,3 +2693,40 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	vma->vm_ops = &shmem_vm_ops;
 	return 0;
 }
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/**
+ * mem_cgroup_get_shmem_target - find a page or entry assigned to the shmem file
+ * @inode: the inode to be searched
+ * @pgoff: the offset to be searched
+ * @pagep: the pointer for the found page to be stored
+ * @ent: the pointer for the found swap entry to be stored
+ *
+ * If a page is found, refcount of it is incremented. Callers should handle
+ * these refcount.
+ */
+void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
+					struct page **pagep, swp_entry_t *ent)
+{
+	swp_entry_t entry = { .val = 0 }, *ptr;
+	struct page *page = NULL;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	if ((pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
+		goto out;
+
+	spin_lock(&info->lock);
+	ptr = shmem_swp_entry(info, pgoff, NULL);
+	if (ptr && ptr->val) {
+		entry.val = ptr->val;
+		page = find_get_page(&swapper_space, entry.val);
+	} else
+		page = find_get_page(inode->i_mapping, pgoff);
+	if (ptr)
+		shmem_swp_unmap(ptr);
+	spin_unlock(&info->lock);
+out:
+	*pagep = page;
+	*ent = entry;
+}
+#endif
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
