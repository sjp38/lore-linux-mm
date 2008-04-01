Date: Tue, 1 Apr 2008 17:35:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 6/6] mem_cgroup_map/new_charge
Message-Id: <20080401173514.b57dda9a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

This patch adds mem_cgroup_new_charge() and mem_cgroup_map_charge().
After this, all charge funcs are divided into

 - page_cgroup_map_charge(). -- for mapping page.
 - page_cgroup_new_charge(). -- for newly allocated anon page.
 - page_cgroup_cache_charge(). -- for page cache.

After this, a page passed by page_cgroup_new_charge() is guaranteed as not
used by anyone. we can avoid unncessary spinlock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>
---
 include/linux/memcontrol.h |    5 +
 mm/memcontrol.c            |  126 ++++++++++++++++++++++++++-------------------
 2 files changed, 77 insertions(+), 54 deletions(-)

Index: mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/memcontrol.c
+++ mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
@@ -469,58 +469,14 @@ unsigned long mem_cgroup_isolate_pages(u
  * 0 if the charge was successful
  * < 0 if the cgroup is over its limit
  */
-static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype,
-				struct mem_cgroup *memcg)
+static int mem_cgroup_charge_core(struct page_cgroup *pc,
+				struct mem_cgroup *mem,
+				gfp_t gfp_mask, enum charge_type ctype)
 {
-	struct mem_cgroup *mem;
-	struct page_cgroup *pc;
 	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
 
-	if (mem_cgroup_subsys.disabled)
-		return 0;
-
-	pc = get_alloc_page_cgroup(page, gfp_mask);
-	/* Before kmalloc initialization, get_page_cgroup can return EBUSY */
-	if (unlikely(IS_ERR(pc))) {
-		if (PTR_ERR(pc) == -EBUSY)
-			return 0;
-		return PTR_ERR(pc);
-	}
-
-	spin_lock_irqsave(&pc->lock, flags);
-	/*
-	 * Has the page already been accounted ?
-	 */
-	if (pc->mem_cgroup) {
-		spin_unlock_irqrestore(&pc->lock, flags);
-		goto success;
-	}
-	spin_unlock_irqrestore(&pc->lock, flags);
-
-	/*
-	 * We always charge the cgroup the mm_struct belongs to.
-	 * The mm_struct's mem_cgroup changes on task migration if the
-	 * thread group leader migrates. It's possible that mm is not
-	 * set, if so charge the init_mm (happens for pagecache usage).
-	 */
-	if (memcg) {
-		mem = memcg;
-		css_get(&mem->css);
-	} else {
-		if (!mm)
-			mm = &init_mm;
-		rcu_read_lock();
-		mem = rcu_dereference(mm->mem_cgroup);
-		/*
-		 * For every charge from the cgroup, increment reference count
-		 */
-		css_get(&mem->css);
-		rcu_read_unlock();
-	}
-
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
@@ -579,23 +535,83 @@ nomem:
 	return -ENOMEM;
 }
 
-int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
+int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
+			gfp_t gfp_mask, enum charge_type ctype)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+	unsigned long flags;
+
+	pc = get_alloc_page_cgroup(page, gfp_mask);
+	if (unlikely(IS_ERR(pc))) {
+		if (PTR_ERR(pc) == -EBUSY)
+			return 0;
+		return PTR_ERR(pc);
+	}
+	spin_lock_irqsave(&pc->lock, flags);
+	if (pc->mem_cgroup) {
+		spin_unlock_irqrestore(&pc->lock, flags);
+		return 0;
+	}
+	spin_unlock_irqrestore(&pc->lock, flags);
+
+	if (!mm)
+		mm = &init_mm;
+	rcu_read_lock();
+	mem = rcu_dereference(mm->mem_cgroup);
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	return mem_cgroup_charge_core(pc, mem, gfp_mask, ctype);
+}
+
+int mem_cgroup_map_charge(struct page *page, struct mm_struct *mm,
+			gfp_t gfp_mask)
 {
+	if (mem_cgroup_subsys.disabled)
+		return 0;
 	if (page_mapped(page))
 		return 0;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED);
+}
+
+int mem_cgroup_new_charge(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_subsys.disabled)
+		return 0;
+
+	VM_BUG_ON(page_mapped(page));
+
+	pc = get_alloc_page_cgroup(page, gfp_mask);
+	if (unlikely(IS_ERR(pc))) {
+		if (PTR_ERR(pc) == -EBUSY)
+			return 0;
+		return PTR_ERR(pc);
+	}
+	/* mm is *always* valid under us .*/
+	mem = mm->mem_cgroup;
+	css_get(&mem->css);
+	return mem_cgroup_charge_core(pc, mem, gfp_mask,
+			MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
+	if (mem_cgroup_subsys.disabled)
+		return 0;
 	if (!mm)
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
+				MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+
 /*
  * Uncharging is always a welcome operation, we never complain, simply
  * uncharge.
@@ -710,8 +726,12 @@ int mem_cgroup_prepare_migration(struct 
 		}
 		spin_unlock_irqrestore(&pc->lock, flags);
 		if (mem) {
-			ret = mem_cgroup_charge_common(newpage, NULL,
-				GFP_KERNEL, type, mem);
+			pc = get_alloc_page_cgroup(newpage, GFP_KERNEL);
+			if (!IS_ERR(pc)) {
+				ret = mem_cgroup_charge_core(pc, mem,
+					GFP_KERNEL, type);
+			} else
+				ret = PTR_ERR(pc);
 			css_put(&mem->css);
 		}
 	}
Index: mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/include/linux/memcontrol.h
+++ mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
@@ -27,14 +27,17 @@ struct page;
 struct mm_struct;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern struct cgroup_subsys mem_cgroup_subsys;
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
 
-extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
+extern int mem_cgroup_map_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
+extern int mem_cgroup_new_charge(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern void mem_cgroup_move_lists(struct page *page, bool active);
Index: mm-2.6.25-rc5-mm1-k/mm/migrate.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/migrate.c
+++ mm-2.6.25-rc5-mm1-k/mm/migrate.c
@@ -176,7 +176,7 @@ static void remove_migration_pte(struct 
 	 * be reliable, and this charge can actually fail: oh well, we don't
 	 * make the situation any worse by proceeding as if it had succeeded.
 	 */
-	mem_cgroup_charge(new, mm, GFP_ATOMIC);
+	mem_cgroup_map_charge(new, mm, GFP_ATOMIC);
 
 	get_page(new);
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
Index: mm-2.6.25-rc5-mm1-k/mm/swapfile.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/swapfile.c
+++ mm-2.6.25-rc5-mm1-k/mm/swapfile.c
@@ -514,7 +514,7 @@ static int unuse_pte(struct vm_area_stru
 	pte_t *pte;
 	int ret = 1;
 
-	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL))
+	if (mem_cgroup_map_charge(page, vma->vm_mm, GFP_KERNEL))
 		ret = -ENOMEM;
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
Index: mm-2.6.25-rc5-mm1-k/mm/memory.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/memory.c
+++ mm-2.6.25-rc5-mm1-k/mm/memory.c
@@ -1146,7 +1146,7 @@ static int insert_page(struct mm_struct 
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	retval = mem_cgroup_charge(page, mm, GFP_KERNEL);
+	retval = mem_cgroup_map_charge(page, mm, GFP_KERNEL);
 	if (retval)
 		goto out;
 
@@ -1649,7 +1649,7 @@ gotten:
 	cow_user_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_charge(new_page, mm, GFP_KERNEL))
+	if (mem_cgroup_new_charge(new_page, mm, GFP_KERNEL))
 		goto oom_free_new;
 
 	/*
@@ -2051,7 +2051,7 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
-	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
+	if (mem_cgroup_map_charge(page, mm, GFP_KERNEL)) {
 		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 		ret = VM_FAULT_OOM;
 		goto out;
@@ -2135,7 +2135,7 @@ static int do_anonymous_page(struct mm_s
 		goto oom;
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_charge(page, mm, GFP_KERNEL))
+	if (mem_cgroup_new_charge(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
@@ -2262,7 +2262,7 @@ static int __do_fault(struct mm_struct *
 
 	}
 
-	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
+	if (mem_cgroup_map_charge(page, mm, GFP_KERNEL)) {
 		ret = VM_FAULT_OOM;
 		goto out;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
