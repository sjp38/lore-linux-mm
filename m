Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E983B6B006C
	for <linux-mm@kvack.org>; Thu,  9 May 2013 05:51:55 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wd20so2666247obb.6
        for <linux-mm@kvack.org>; Thu, 09 May 2013 02:51:55 -0700 (PDT)
From: wenchaolinux@gmail.com
Subject: [RFC PATCH V1 5/6] mm : add parameter remove_old in move_page_tables
Date: Thu,  9 May 2013 17:50:10 +0800
Message-Id: <1368093011-4867-6-git-send-email-wenchaolinux@gmail.com>
In-Reply-To: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, kirill.shutemov@linux.intel.com, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com, Wenchao Xia <wenchaolinux@gmail.com>

From: Wenchao Xia <wenchaolinux@gmail.com>

Signed-off-by: Wenchao Xia <wenchaolinux@gmail.com>
---
 fs/exec.c          |    2 +-
 include/linux/mm.h |    2 +-
 mm/mremap.c        |   97 ++++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 93 insertions(+), 8 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index a96a488..12721e1 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -603,7 +603,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
 	 * process cleanup to remove whatever mess we made.
 	 */
 	if (length != move_page_tables(vma, old_start,
-				       vma, new_start, length, false))
+				       vma, new_start, length, false, true))
 		return -ENOMEM;
 
 	lru_add_drain();
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9bd01f5..a5eb34c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1085,7 +1085,7 @@ vm_is_stack(struct task_struct *task, struct vm_area_struct *vma, int in_group);
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
-		bool need_rmap_locks);
+		bool need_rmap_locks, bool remove_old);
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
diff --git a/mm/mremap.c b/mm/mremap.c
index 0f3c5be..2cc1cae 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -140,18 +140,93 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		mutex_unlock(&mapping->i_mmap_mutex);
 }
 
+static unsigned long dup_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
+			unsigned long old_addr, unsigned long old_end,
+			struct vm_area_struct *new_vma, pmd_t *new_pmd,
+			unsigned long new_addr, bool need_rmap_locks)
+{
+	struct address_space *mapping = NULL;
+	struct anon_vma *anon_vma = NULL;
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *old_pte, *new_pte;
+	spinlock_t *old_ptl, *new_ptl;
+	pte_t *orig_old_pte, *orig_new_pte;
+	int rss[NR_MM_COUNTERS];
+	swp_entry_t entry = (swp_entry_t){0};
+
+again:
+	init_rss_vec(rss);
+
+	/* Same with move_ptes */
+	if (need_rmap_locks) {
+		if (vma->vm_file) {
+			mapping = vma->vm_file->f_mapping;
+			mutex_lock(&mapping->i_mmap_mutex);
+		}
+		if (vma->anon_vma) {
+			anon_vma = vma->anon_vma;
+			anon_vma_lock_write(anon_vma);
+		}
+	}
+
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * pte locks because exclusive mmap_sem prevents deadlock.
+	 */
+	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
+	new_pte = pte_offset_map(new_pmd, new_addr);
+	new_ptl = pte_lockptr(mm, new_pmd);
+	if (new_ptl != old_ptl)
+		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	arch_enter_lazy_mmu_mode();
+	orig_old_pte = old_pte;
+	orig_new_pte = new_pte;
+
+	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
+				   new_pte++, new_addr += PAGE_SIZE) {
+		if (pte_none(*old_pte))
+			continue;
+		entry.val = copy_one_pte(mm, mm, new_pte, old_pte,
+					 new_addr, old_addr, vma, rss);
+		if (entry.val)
+			break;
+	}
+
+	arch_leave_lazy_mmu_mode();
+	add_mm_rss_vec(mm, rss);
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap(orig_new_pte);
+	pte_unmap_unlock(orig_old_pte, old_ptl);
+	if (anon_vma)
+		anon_vma_unlock_write(anon_vma);
+	if (mapping)
+		mutex_unlock(&mapping->i_mmap_mutex);
+
+	if (entry.val) {
+		cond_resched();
+		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
+			goto out;
+	}
+	if (old_addr < old_end)
+		goto again;
+ out:
+	return old_addr;
+}
+
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
 
 unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
-		bool need_rmap_locks)
+		bool need_rmap_locks, bool remove_old)
 {
 	unsigned long extent, next, old_end;
 	pmd_t *old_pmd, *new_pmd;
 	bool need_flush = false;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	unsigned long t;
 
 	old_end = old_addr + len;
 	flush_cache_range(vma, old_addr, old_end);
@@ -178,7 +253,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			if (extent == HPAGE_PMD_SIZE)
 				err = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
-						    old_pmd, new_pmd, true);
+						    old_pmd, new_pmd,
+						    remove_old);
 			if (err > 0) {
 				need_flush = true;
 				continue;
@@ -195,8 +271,17 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			extent = next - new_addr;
 		if (extent > LATENCY_LIMIT)
 			extent = LATENCY_LIMIT;
-		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
-			  new_vma, new_pmd, new_addr, need_rmap_locks);
+		if (remove_old) {
+			move_ptes(vma, old_pmd, old_addr, old_addr + extent,
+				  new_vma, new_pmd, new_addr, need_rmap_locks);
+		} else {
+			t = dup_ptes(vma, old_pmd, old_addr, old_addr + extent,
+				  new_vma, new_pmd, new_addr, need_rmap_locks);
+			if (t < old_addr + extent) {
+				old_addr = t;
+				break;
+			}
+		}
 		need_flush = true;
 	}
 	if (likely(need_flush))
@@ -248,7 +333,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		return -ENOMEM;
 
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
-				     need_rmap_locks);
+				     need_rmap_locks, true);
 	if (moved_len < old_len) {
 		/*
 		 * On error, move entries back from new area to old,
@@ -256,7 +341,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 * and then proceed to unmap new area instead of old.
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
-				 true);
+				 true, true);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
