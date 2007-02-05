Subject: [RFC][PATCH 4/5] RSS accounting per task
Message-Id: <20070205132751.318B11B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:27:51 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Debugging purposes : add a /proc/<tid>/memacct interface to print
the rss of a task.

Signed-off-by: Patrick Le Dot <Patrick.Le-Dot@bull.net>
---

 fs/proc/base.c             |    4
 include/linux/memctlr.h    |    7 +
 include/linux/rmap.h       |    6 -
 kernel/res_group/memctlr.c |  214 +++++++++++++++++++++++++++++++++++++++++++--
 mm/filemap_xip.c           |    2
 mm/fremap.c                |    2
 mm/memory.c                |    6 -
 mm/rmap.c                  |    8 -
 8 files changed, 227 insertions(+), 22 deletions(-)

diff -puN a/kernel/res_group/memctlr.c b/kernel/res_group/memctlr.c
--- a/kernel/res_group/memctlr.c	2006-12-08 12:08:06.000000000 +0100
+++ b/kernel/res_group/memctlr.c	2006-12-08 12:28:39.000000000 +0100
@@ -34,6 +34,9 @@
 #include <linux/module.h>
 #include <linux/res_group_rc.h>
 #include <linux/memctlr.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <asm/pgtable.h>
 
 static const char res_ctlr_name[] = "memctlr";
 static struct resource_group *root_rgroup;
@@ -53,6 +56,7 @@ struct mem_counter {
 struct memctlr {
 	struct res_shares shares;	/* My shares		  */
 	struct mem_counter counter;	/* Accounting information */
+	spinlock_t lock;
 };
 
 struct res_controller memctlr_rg;
@@ -117,31 +121,53 @@ static inline struct memctlr *get_task_m
 }
 
 
-void memctlr_inc_rss(struct page *page)
+void memctlr_inc_rss_mm(struct page *page, struct mm_struct *mm)
 {
 	struct memctlr *res;
 
 	res = get_task_memctlr(current);
-	if (!res)
+	if (!res) {
+		printk(KERN_INFO "inc_rss no res set *---*\n");
 		return;
+	}
 
+	spin_lock(&res->lock);
 	atomic_long_inc(&current->mm->counter->rss);
 	atomic_long_inc(&res->counter.rss);
+	spin_unlock(&res->lock);
 }
 
-void memctlr_dec_rss(struct page *page)
+void memctlr_inc_rss(struct page *page)
 {
 	struct memctlr *res;
+	struct mm_struct *mm = current->mm;
 
 	res = get_task_memctlr(current);
-	if (!res)
+	if (!res) {
+		printk(KERN_INFO "inc_rss no res set *---*\n");
 		return;
+	}
 
-	atomic_long_dec(&res->counter.rss);
+	spin_lock(&res->lock);
+	atomic_long_inc(&mm->counter->rss);
+	atomic_long_inc(&res->counter.rss);
+	spin_unlock(&res->lock);
+}
+
+void memctlr_dec_rss_mm(struct page *page, struct mm_struct *mm)
+{
+	struct memctlr *res;
 
-	if ((current->flags & PF_EXITING) && !current->mm)
+	res = get_task_memctlr(current);
+	if (!res) {
+		printk(KERN_INFO "dec_rss no res set *---*\n");
 		return;
-	atomic_long_dec(&current->mm->counter->rss);
+	}
+
+	spin_lock(&res->lock);
+	atomic_long_dec(&res->counter.rss);
+	atomic_long_dec(&mm->counter->rss);
+	spin_unlock(&res->lock);
 }
 
 static void memctlr_init_new(struct memctlr *res)
@@ -152,6 +178,7 @@ static void memctlr_init_new(struct memc
 	res->shares.unused_min_shares = SHARE_DEFAULT_DIVISOR;
 
 	memctlr_init_mem_counter(&res->counter);
+	spin_lock_init(&res->lock);
 }
 
 static struct res_shares *memctlr_alloc_instance(struct resource_group *rgroup)
@@ -184,6 +211,120 @@ static void memctlr_free_instance(struct
 	kfree(res);
 }
 
+static long count_pte_rss(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	long count = 0;
+
+	do {
+		pte = pte_offset_map(pmd, addr);
+		if (!pte_present(*pte))
+			continue;
+		count++;
+		pte_unmap(pte);
+	} while (pte++, addr += PAGE_SIZE, (addr != end));
+
+	return count;
+}
+
+static long count_pmd_rss(struct vm_area_struct *vma, pud_t *pud,
+				unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	long count = 0;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		count += count_pte_rss(vma, pmd, addr, next);
+	} while (pmd++, addr = next, (addr != end));
+
+	return count;
+}
+
+static long count_pud_rss(struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+	long count = 0;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		count += count_pmd_rss(vma, pud, addr, next);
+	} while (pud++, addr = next, (addr != end));
+
+	return count;
+}
+
+static long count_pgd_rss(struct vm_area_struct *vma)
+{
+	unsigned long addr, next, end;
+	pgd_t *pgd;
+	long count = 0;
+
+	addr = vma->vm_start;
+	end = vma->vm_end;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		count += count_pud_rss(vma, pgd, addr, next);
+	} while (pgd++, addr = next, (addr != end));
+	return count;
+}
+
+static long count_rss(struct task_struct *p)
+{
+	int count = 0;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma = mm->mmap;
+
+	if (!mm)
+		return 0;
+
+	down_read(&mm->mmap_sem);
+	spin_lock(&mm->page_table_lock);
+
+	while (vma) {
+		count += count_pgd_rss(vma);
+		vma = vma->vm_next;
+	}
+
+	spin_unlock(&mm->page_table_lock);
+	up_read(&mm->mmap_sem);
+	return count;
+}
+
+int  proc_memacct(struct task_struct *p, char *buf)
+{
+	int i = 0, j = 0;
+	struct mm_struct *mm = p->mm;
+
+	if (!mm)
+		return sprintf(buf, "no mm associated with the task\n");
+
+	i = sprintf(buf, "rss pages %ld\n",
+			atomic_long_read(&mm->counter->rss));
+	buf += i;
+	j += i;
+
+	i = sprintf(buf, "pg table walk rss pages %ld\n", count_rss(p));
+	buf += i;
+	j += i;
+
+	return j;
+}
+
 static ssize_t memctlr_show_stats(struct res_shares *shares, char *buf,
 					size_t len)
 {
@@ -202,12 +343,69 @@ static ssize_t memctlr_show_stats(struct
 	return j;
 }
 
+static void double_res_lock(struct memctlr *old, struct memctlr *new)
+{
+	BUG_ON(old == new);
+	if (&old->lock > &new->lock) {
+		spin_lock(&old->lock);
+		spin_lock(&new->lock);
+	} else {
+		spin_lock(&new->lock);
+		spin_lock(&old->lock);
+	}
+}
+
+static void double_res_unlock(struct memctlr *old, struct memctlr *new)
+{
+	BUG_ON(old == new);
+	if (&old->lock > &new->lock) {
+		spin_unlock(&new->lock);
+		spin_unlock(&old->lock);
+	} else {
+		spin_unlock(&old->lock);
+		spin_unlock(&new->lock);
+	}
+}
+
+static void memctlr_move_task(struct task_struct *p, struct res_shares *old,
+				struct res_shares *new)
+{
+	struct memctlr *oldres, *newres;
+	long rss_pages;
+
+	if (old == new)
+		return;
+
+	/*
+	 * If a task has no mm structure associated with it we have
+	 * nothing to do
+	 */
+	if (!old || !new)
+		return;
+
+	if (p->pid != p->tgid)
+		return;
+
+	oldres = get_memctlr_from_shares(old);
+	newres = get_memctlr_from_shares(new);
+
+	double_res_lock(oldres, newres);
+
+	rss_pages = atomic_long_read(&p->mm->counter->rss);
+	atomic_long_sub(rss_pages, &oldres->counter.rss);
+
+	mm_assign_container(p->mm, p);
+	atomic_long_add(rss_pages, &newres->counter.rss);
+
+	double_res_unlock(oldres, newres);
+}
+
 struct res_controller memctlr_rg = {
 	.name = res_ctlr_name,
 	.ctlr_id = NO_RES_ID,
 	.alloc_shares_struct = memctlr_alloc_instance,
 	.free_shares_struct = memctlr_free_instance,
-	.move_task = NULL,
+	.move_task = memctlr_move_task,
 	.shares_changed = NULL,
 	.show_stats = memctlr_show_stats,
 };
diff -puN a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c	2006-12-08 11:54:43.000000000 +0100
+++ b/fs/proc/base.c	2006-12-08 11:52:04.000000000 +0100
@@ -74,6 +74,7 @@
 #include <linux/poll.h>
 #include <linux/nsproxy.h>
 #include <linux/oom.h>
+#include <linux/memctlr.h>
 #include "internal.h"
 
 /* NOTE:
@@ -1762,6 +1763,9 @@ static struct pid_entry tgid_base_stuff[
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, numa_maps),
 #endif
+#ifdef CONFIG_RES_GROUPS_MEMORY
+	INF("memacct",	  S_IRUGO, memacct),
+#endif
 	REG("mem",        S_IRUSR|S_IWUSR, mem),
 #ifdef CONFIG_SECCOMP
 	REG("seccomp",    S_IRUSR|S_IWUSR, seccomp),
diff -puN a/include/linux/memctlr.h b/include/linux/memctlr.h
--- a/include/linux/memctlr.h	2006-12-08 12:08:06.000000000 +0100
+++ b/include/linux/memctlr.h	2006-12-08 11:52:41.000000000 +0100
@@ -32,14 +32,17 @@
 extern int mm_init_mem_counter(struct mm_struct *mm);
 extern void mm_assign_container(struct mm_struct *mm, struct task_struct *p);
 extern void memctlr_inc_rss(struct page *page);
-extern void memctlr_dec_rss(struct page *page);
+extern void memctlr_inc_rss_mm(struct page *page, struct mm_struct *mm);
+extern void memctlr_dec_rss_mm(struct page *page, struct mm_struct *mm);
 extern void mm_free_mem_counter(struct mm_struct *mm);
+extern int  proc_memacct(struct task_struct *task, char *buffer);
 
 #else /* CONFIG_RES_GROUPS_MEMORY */
 
 #define mm_init_mem_counter(mm)		(0)
 #define memctlr_inc_rss(page)		do { ; } while (0)
-#define memctlr_dec_rss(page)		do { ; } while (0)
+#define memctlr_inc_rss_mm(page, mm)	do { ; } while (0)
+#define memctlr_dec_rss_mm(page, mm)	do { ; } while (0)
 #define mm_assign_container(mm, task)	do { ; } while (0)
 #define mm_free_mem_counter(mm)		do { ; } while (0)
 
diff -puN a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c	2006-12-08 11:54:43.000000000 +0100
+++ b/mm/filemap_xip.c	2006-12-08 11:53:03.000000000 +0100
@@ -189,7 +189,7 @@ __xip_unmap (struct address_space * mapp
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
-			page_remove_rmap(page);
+			page_remove_rmap(page, mm);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
diff -puN a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c	2006-12-08 11:54:43.000000000 +0100
+++ b/mm/fremap.c	2006-12-08 11:53:24.000000000 +0100
@@ -33,7 +33,7 @@ static int zap_pte(struct mm_struct *mm,
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
-			page_remove_rmap(page);
+			page_remove_rmap(page, mm);
 			page_cache_release(page);
 		}
 	} else {
diff -puN a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	2006-12-08 11:54:43.000000000 +0100
+++ b/mm/memory.c	2006-12-08 11:53:42.000000000 +0100
@@ -481,7 +481,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, dst_mm);
 		rss[!!PageAnon(page)]++;
 	}
 
@@ -681,7 +681,7 @@ static unsigned long zap_pte_range(struc
 					mark_page_accessed(page);
 				file_rss--;
 			}
-			page_remove_rmap(page);
+			page_remove_rmap(page, mm);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -1576,7 +1576,7 @@ gotten:
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
-			page_remove_rmap(old_page);
+			page_remove_rmap(old_page, mm);
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
diff -puN a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	2006-12-08 12:08:06.000000000 +0100
+++ b/mm/rmap.c	2006-12-08 11:54:02.000000000 +0100
@@ -570,7 +570,7 @@ void page_add_file_rmap(struct page *pag
  *
  * The caller needs to hold the pte lock.
  */
-void page_remove_rmap(struct page *page)
+void page_remove_rmap(struct page *page, struct mm_struct *mm)
 {
 	if (atomic_add_negative(-1, &page->_mapcount)) {
 		if (unlikely(page_mapcount(page) < 0)) {
@@ -595,7 +595,7 @@ void page_remove_rmap(struct page *page)
		__dec_zone_page_state(page,
				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
	}
-	memctlr_dec_rss(page);
+	memctlr_dec_rss_mm(page, mm);
 }

 /*
@@ -683,7 +683,7 @@ static int try_to_unmap_one(struct page 
 		dec_mm_counter(mm, file_rss);
 
 
-	page_remove_rmap(page);
+	page_remove_rmap(page, mm);
 	page_cache_release(page);
 
 out_unmap:
@@ -773,7 +773,7 @@ static void try_to_unmap_cluster(unsigne
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
+		page_remove_rmap(page, mm);
 		page_cache_release(page);
 		dec_mm_counter(mm, file_rss);
 		(*mapcount)--;
diff -puN a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h	2006-12-08 12:08:06.000000000 +0100
+++ b/include/linux/rmap.h	2006-12-08 11:54:24.000000000 +0100
@@ -73,7 +73,7 @@ void __anon_vma_link(struct vm_area_stru
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
-void page_remove_rmap(struct page *);
+void page_remove_rmap(struct page *, struct mm_struct *);
 
 /**
  * page_dup_rmap - duplicate pte mapping to a page
@@ -82,10 +82,10 @@ void page_remove_rmap(struct page *);
  * For copy_page_range only: minimal extract from page_add_rmap,
  * avoiding unnecessary tests (already checked) so it's quicker.
  */
-static inline void page_dup_rmap(struct page *page)
+static inline void page_dup_rmap(struct page *page, struct mm_struct *mm)
 {
 	atomic_inc(&page->_mapcount);
-	memctlr_inc_rss(page);
+	memctlr_inc_rss_mm(page, mm);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
