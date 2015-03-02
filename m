Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id D87A26B006E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 17:34:22 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id v1so29863894oia.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 14:34:22 -0800 (PST)
Received: from smtpproxy19.qq.com (smtpproxy19.qq.com. [184.105.206.84])
        by mx.google.com with ESMTPS id o11si7015746obr.104.2015.03.02.14.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 14:34:21 -0800 (PST)
Message-ID: <54F4E739.6040805@qq.com>
Date: Tue, 03 Mar 2015 06:42:01 +0800
From: Chen Gang <762976180@qq.com>
MIME-Version: 1.0
Subject: [PATCH] mm: memcontrol: Let mem_cgroup_move_account() have effect
 only if MMU enabled
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

When !MMU, it will report warning. The related warning with allmodconfig
under c6x:

    CC      mm/memcontrol.o
  mm/memcontrol.c:2802:12: warning: 'mem_cgroup_move_account' defined but not used [-Wunused-function]
   static int mem_cgroup_move_account(struct page *page,
              ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/memcontrol.c | 172 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 86 insertions(+), 86 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c86945..80f26f5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2785,92 +2785,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-/**
- * mem_cgroup_move_account - move account of the page
- * @page: the page
- * @nr_pages: number of regular pages (>1 for huge pages)
- * @from: mem_cgroup which the page is moved from.
- * @to:	mem_cgroup which the page is moved to. @from != @to.
- *
- * The caller must confirm following.
- * - page is not on LRU (isolate_page() is useful.)
- * - compound_lock is held when nr_pages > 1
- *
- * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
- * from old cgroup.
- */
-static int mem_cgroup_move_account(struct page *page,
-				   unsigned int nr_pages,
-				   struct mem_cgroup *from,
-				   struct mem_cgroup *to)
-{
-	unsigned long flags;
-	int ret;
-
-	VM_BUG_ON(from == to);
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	/*
-	 * The page is isolated from LRU. So, collapse function
-	 * will not handle this page. But page splitting can happen.
-	 * Do this check under compound_page_lock(). The caller should
-	 * hold it.
-	 */
-	ret = -EBUSY;
-	if (nr_pages > 1 && !PageTransHuge(page))
-		goto out;
-
-	/*
-	 * Prevent mem_cgroup_migrate() from looking at page->mem_cgroup
-	 * of its source page while we change it: page migration takes
-	 * both pages off the LRU, but page cache replacement doesn't.
-	 */
-	if (!trylock_page(page))
-		goto out;
-
-	ret = -EINVAL;
-	if (page->mem_cgroup != from)
-		goto out_unlock;
-
-	spin_lock_irqsave(&from->move_lock, flags);
-
-	if (!PageAnon(page) && page_mapped(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
-	}
-
-	if (PageWriteback(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
-	}
-
-	/*
-	 * It is safe to change page->mem_cgroup here because the page
-	 * is referenced, charged, and isolated - we can't race with
-	 * uncharging, charging, migration, or LRU putback.
-	 */
-
-	/* caller should have done css_get */
-	page->mem_cgroup = to;
-	spin_unlock_irqrestore(&from->move_lock, flags);
-
-	ret = 0;
-
-	local_irq_disable();
-	mem_cgroup_charge_statistics(to, page, nr_pages);
-	memcg_check_events(to, page);
-	mem_cgroup_charge_statistics(from, page, -nr_pages);
-	memcg_check_events(from, page);
-	local_irq_enable();
-out_unlock:
-	unlock_page(page);
-out:
-	return ret;
-}
-
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
@@ -4822,6 +4736,92 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	return page;
 }
 
+/**
+ * mem_cgroup_move_account - move account of the page
+ * @page: the page
+ * @nr_pages: number of regular pages (>1 for huge pages)
+ * @from: mem_cgroup which the page is moved from.
+ * @to:	mem_cgroup which the page is moved to. @from != @to.
+ *
+ * The caller must confirm following.
+ * - page is not on LRU (isolate_page() is useful.)
+ * - compound_lock is held when nr_pages > 1
+ *
+ * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
+ * from old cgroup.
+ */
+static int mem_cgroup_move_account(struct page *page,
+				   unsigned int nr_pages,
+				   struct mem_cgroup *from,
+				   struct mem_cgroup *to)
+{
+	unsigned long flags;
+	int ret;
+
+	VM_BUG_ON(from == to);
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	/*
+	 * The page is isolated from LRU. So, collapse function
+	 * will not handle this page. But page splitting can happen.
+	 * Do this check under compound_page_lock(). The caller should
+	 * hold it.
+	 */
+	ret = -EBUSY;
+	if (nr_pages > 1 && !PageTransHuge(page))
+		goto out;
+
+	/*
+	 * Prevent mem_cgroup_migrate() from looking at page->mem_cgroup
+	 * of its source page while we change it: page migration takes
+	 * both pages off the LRU, but page cache replacement doesn't.
+	 */
+	if (!trylock_page(page))
+		goto out;
+
+	ret = -EINVAL;
+	if (page->mem_cgroup != from)
+		goto out_unlock;
+
+	spin_lock_irqsave(&from->move_lock, flags);
+
+	if (!PageAnon(page) && page_mapped(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       nr_pages);
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       nr_pages);
+	}
+
+	if (PageWriteback(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
+			       nr_pages);
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
+			       nr_pages);
+	}
+
+	/*
+	 * It is safe to change page->mem_cgroup here because the page
+	 * is referenced, charged, and isolated - we can't race with
+	 * uncharging, charging, migration, or LRU putback.
+	 */
+
+	/* caller should have done css_get */
+	page->mem_cgroup = to;
+	spin_unlock_irqrestore(&from->move_lock, flags);
+
+	ret = 0;
+
+	local_irq_disable();
+	mem_cgroup_charge_statistics(to, page, nr_pages);
+	memcg_check_events(to, page);
+	mem_cgroup_charge_statistics(from, page, -nr_pages);
+	memcg_check_events(from, page);
+	local_irq_enable();
+out_unlock:
+	unlock_page(page);
+out:
+	return ret;
+}
+
 static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
