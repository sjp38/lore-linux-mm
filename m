Date: Fri, 17 Oct 2008 20:06:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mm 5/5] memcg: mem+swap accounting
Message-Id: <20081017200646.c49915fa.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Add Swap accounting feature to memory resource controller.

Accounting is done in following logic.

Swap-Getting:
  - When get_swap_page() is called, swp_entry is marked as to be under
    page->page_cgroup->mem_cgroup, and increment res.swaps.
    on_disk flag of the entry is set off.

Swap-out:
  - When swap-cache is uncharged (fully unmapped), we don't uncharge it.
  - When swap-cache is deleted, we uncharge it from memory, increment
    res.disk_swaps, and turn on on_disk flag.

Swap-in:
  - When add_to_swapcache() is called, we do nothing.
  - When swap is mapped, we charge to memory ,decrement res.disk_swaps,
    and turn off on_disk flag.

SwapCache-Deleting:
  - If the page doesn't have page_cgroup, nothing to do.
  - If the page is still mapped or on radix-tree, nothing to do.
    (This can happen at swapin.)
  - Decrement res.pages, increment res.disk_swaps, and turn on on_disk flag.

Swap-Freeing:
  - Decrement res.swaps, and if on_disk flag is set, decrement res.disk_swaps.

Almost all operations are done against SwapCache, which is Locked.

This patch uses an array to remember the owner of swp_entry. Considering
x86-32, we should avoid to use NORMAL memory and vmalloc() area too much.
This patch uses HIGHMEM to record information under kmap_atomic(KM_USER0).
And information is recored in 2 bytes per 1 swap page.
(memory controller's id is defined as smaller than unsigned short)

Changelog: (v2) -> (v3)
 - count real usage of swaps.
 - uncharge all swaps binded to the group on rmdir.
 - rename member of swap_cgroup.
 - rename swap_cgroup_record_info to __swap_cgroup_info, and define helper
   functions to call it.
 - rename swap_cgroup_account to __swap_cgroup_disk_swap, and define helper
   functions to call it.

Changelog: (preview) -> (v2)
 - removed radix-tree. just use array.
 - removed linked-list.
 - use memcgroup_id rather than pointer.
 - added force_empty (temporal) support.
   This should be reworked in future. (But for now, this works well for us.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

diff --git a/include/linux/swap.h b/include/linux/swap.h
index be0b575..8205044 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -299,7 +299,7 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 /* linux/mm/swapfile.c */
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern swp_entry_t get_swap_page(struct page *);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
@@ -336,6 +336,44 @@ static inline void disable_swap_token(void)
 	put_swap_token(swap_token_mm);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+extern int swap_cgroup_swapon(int type, unsigned long max_pages);
+extern void swap_cgroup_swapoff(int type);
+extern void swap_cgroup_delete_swap(swp_entry_t entry);
+extern int swap_cgroup_prepare(swp_entry_t ent);
+extern void swap_cgroup_record_info(struct page *, swp_entry_t ent);
+extern void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry);
+
+#else
+static inline int swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	return 0;
+}
+static inline void swap_cgroup_swapoff(int type)
+{
+	return;
+}
+static inline void swap_cgroup_delete_swap(swp_entry_t entry)
+{
+	return;
+}
+static inline int swap_cgroup_prepare(swp_entry_t ent)
+{
+	return 0;
+}
+static inline
+void swap_cgroup_record_info(struct page *page, swp_entry_t ent)
+{
+	return;
+}
+static inline
+void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry)
+{
+	return;
+}
+#endif
+
+
 #else /* CONFIG_SWAP */
 
 #define total_swap_pages			0
@@ -406,7 +444,7 @@ static inline int remove_exclusive_swap_page_ref(struct page *page)
 	return 0;
 }
 
-static inline swp_entry_t get_swap_page(void)
+static inline swp_entry_t get_swap_page(struct page *page)
 {
 	swp_entry_t entry;
 	entry.val = 0;
diff --git a/init/Kconfig b/init/Kconfig
index 14c8205..4460f46 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -416,7 +416,7 @@ config CGROUP_MEM_RES_CTLR
 	  could in turn add some fork/exit overhead.
 
 config CGROUP_MEM_RES_CTLR_SWAP
-	bool "Memory Resource Controller Swap Extension (Broken)"
+	bool "Memory Resource Controller Swap Extension (EXPERIMENTAL)"
 	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
 	help
 	 Add swap management feature to memory resource controller. By this,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d712547..e49364c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -34,6 +34,11 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/swap.h>
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+#include <linux/pagemap.h>
+#include <linux/swapops.h>
+#endif
 
 #include <asm/uaccess.h>
 
@@ -42,9 +47,29 @@ struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define NR_MEMCGRP_ID			(32767)
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+
 #define do_swap_account	(1)
+
+static void swap_cgroup_uncharge_disk_swap(struct page *page);
+static void swap_cgroup_charge_disk_swap(swp_entry_t entry);
+static void swap_cgroup_clean_account(struct mem_cgroup *mem);
+
 #else
+
 #define do_swap_account	(0)
+
+static void swap_cgroup_charge_disk_swap(swp_entry_t entry)
+{
+}
+
+static void
+swap_cgroup_uncharge_disk_swap(struct page *page)
+{
+}
+
+static void swap_cgroup_clean_account(struct mem_cgroup *mem)
+{
+}
 #endif
 
 
@@ -163,6 +188,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
+	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	NR_CHARGE_TYPE,
 };
@@ -178,6 +204,7 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
 	PCGF_CACHE | PCGF_FILE | PCGF_USED | PCGF_LOCK, /* File Cache */
 	PCGF_ACTIVE | PCGF_USED | PCGF_LOCK, /* Anon */
 	PCGF_ACTIVE | PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* Shmem */
+	0, /* MEM_CGROUP_CHARGE_TYPE_SWAPOUT */
 	0, /* FORCE */
 };
 
@@ -314,6 +341,50 @@ static void mem_counter_uncharge_page(struct mem_cgroup *mem, long num)
 	spin_unlock_irqrestore(&mem->res.lock, flags);
 }
 
+static void mem_counter_charge_swap(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	if (do_swap_account) {
+		spin_lock_irqsave(&mem->res.lock, flags);
+		mem->res.swaps += 1;
+		spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
+static void mem_counter_uncharge_swap(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	if (do_swap_account) {
+		spin_lock_irqsave(&mem->res.lock, flags);
+		if (!WARN_ON(mem->res.swaps >= 1))
+			mem->res.swaps -= 1;
+		spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
+static void mem_counter_charge_disk_swap(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	if (do_swap_account) {
+		spin_lock_irqsave(&mem->res.lock, flags);
+		/* res.pages will be decremented later if needed */
+		mem->res.disk_swaps += 1;
+		spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
+static void mem_counter_uncharge_disk_swap(struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	if (do_swap_account) {
+		spin_lock_irqsave(&mem->res.lock, flags);
+		/* res.pages has been already incremented if needed */
+		if (!WARN_ON(mem->res.disk_swaps >= 1))
+			mem->res.disk_swaps -= 1;
+		spin_unlock_irqrestore(&mem->res.lock, flags);
+	}
+}
+
 static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
 					unsigned long num)
 {
@@ -1019,6 +1090,9 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 	pc->flags = pcg_default_flags[ctype];
 	unlock_page_cgroup(pc);
 
+	/* We did swap-in, uncharge disk_swap. */
+	if (do_swap_account && PageSwapCache(pc->page))
+		swap_cgroup_uncharge_disk_swap(pc->page);
 	set_page_cgroup_lru(pc);
 	css_put(&mem->css);
 }
@@ -1240,7 +1314,8 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
  * uncharge if !page_mapped(page)
  */
 static void
-__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
+__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
+				swp_entry_t entry)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
@@ -1256,14 +1331,20 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		return;
 
 	lock_page_cgroup(pc);
-	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && page_mapped(page))
-	     || !PageCgroupUsed(pc)) {
+	if (!PageCgroupUsed(pc)
+	    || PageSwapCache(page)
+	    || ((ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) &&
+		(page_mapped(page) || (page->mapping && !PageAnon(page))))
+		/* This happens at swapin */
+	    || (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && page_mapped(page))) {
 		/* This happens at race in zap_pte_range() and do_swap_page()*/
 		unlock_page_cgroup(pc);
 		return;
 	}
 	ClearPageCgroupUsed(pc);
 	mem = pc->mem_cgroup;
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		swap_cgroup_charge_disk_swap(entry);
 	/*
 	 * We must uncharge here because "reuse" can occur just after we
 	 * unlock this.
@@ -1281,14 +1362,16 @@ void mem_cgroup_uncharge_page(struct page *page)
 		return;
 	if (page->mapping && !PageAnon(page))
 		return;
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED,
+					(swp_entry_t){0});
 }
 
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON(page_mapped(page));
 	VM_BUG_ON(page->mapping);
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE,
+					(swp_entry_t){0});
 }
 
 /*
@@ -1347,9 +1430,8 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 
-	/* unused page is not on radix-tree now. */
-	if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)
-		__mem_cgroup_uncharge_common(unused, ctype);
+	if (unused)
+		__mem_cgroup_uncharge_common(unused, ctype, (swp_entry_t){0});
 
 	pc = lookup_page_cgroup(target);
 	/*
@@ -1912,6 +1994,7 @@ static void mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 	mem_cgroup_force_empty(mem);
+	swap_cgroup_clean_account(mem);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
@@ -1970,3 +2053,304 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 };
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+/*
+ * swap accounting infrastructure.
+ */
+DEFINE_MUTEX(swap_cgroup_mutex);
+spinlock_t swap_cgroup_lock[MAX_SWAPFILES];
+struct page **swap_cgroup_map[MAX_SWAPFILES];
+unsigned long swap_cgroup_pages[MAX_SWAPFILES];
+
+
+/* This definition is based onf NR_MEM_CGROUP==32768 */
+struct swap_cgroup {
+	unsigned short memcgrp_id:15;
+	unsigned short on_disk:1;
+};
+#define ENTS_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
+
+/*
+ * Called from get_swap_page().
+ */
+int swap_cgroup_prepare(swp_entry_t ent)
+{
+	struct page *page;
+	unsigned long array_index = swp_offset(ent) / ENTS_PER_PAGE;
+	int type = swp_type(ent);
+	unsigned long flags;
+
+	if (swap_cgroup_map[type][array_index])
+		return 0;
+	page = alloc_page(GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
+	if (!page)
+		return -ENOMEM;
+	spin_lock_irqsave(&swap_cgroup_lock[type], flags);
+	if (swap_cgroup_map[type][array_index] == NULL) {
+		swap_cgroup_map[type][array_index] = page;
+		page = NULL;
+	}
+	spin_unlock_irqrestore(&swap_cgroup_lock[type], flags);
+
+	if (page)
+		__free_page(page);
+	return 0;
+}
+
+/**
+ * __swap_cgroup_info
+ * @page ..... a page which is in some mem_cgroup.
+ * @entry .... swp_entry of the page. (or old swp_entry of the page)
+ * @delete ... if 0 add entry, if 1 delete entry.
+ */
+static void
+__swap_cgroup_info(struct page *page, swp_entry_t entry, bool del)
+{
+	unsigned long flags;
+	int type = swp_type(entry);
+	unsigned long offset = swp_offset(entry);
+	unsigned long array_index = offset/ENTS_PER_PAGE;
+	unsigned long index = offset & (ENTS_PER_PAGE - 1);
+	struct page *mappage;
+	struct swap_cgroup *map;
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem = NULL;
+
+	if (!del) {
+		VM_BUG_ON(!page);
+
+		pc = lookup_page_cgroup(page);
+		lock_page_cgroup(pc);
+		if (PageCgroupUsed(pc)) {
+			mem = pc->mem_cgroup;
+			css_get(&mem->css);
+		}
+		unlock_page_cgroup(pc);
+
+		if (!mem)
+			goto out;
+	}
+
+	if (!swap_cgroup_map[type])
+		goto out;
+
+	mappage = swap_cgroup_map[type][array_index];
+	VM_BUG_ON(!mappage);
+
+	local_irq_save(flags);
+	map = kmap_atomic(mappage, KM_USER0);
+	if (!del) {
+		if (map[index].memcgrp_id)
+			/* already binded to some group */
+			goto unlock;
+		map[index].memcgrp_id = mem->memcgrp_id;
+		map[index].on_disk = 0;
+		mem_counter_charge_swap(mem);
+	} else {
+		mem = mem_cgroup_id_lookup(map[index].memcgrp_id);
+		if (!mem) {
+			mem_counter_uncharge_swap(mem);
+			if (map[index].on_disk)
+				mem_counter_uncharge_disk_swap(mem);
+			map[index].memcgrp_id = 0;
+			map[index].on_disk = 0;
+		}
+	}
+	kunmap_atomic(mappage, KM_USER0);
+
+unlock:
+	local_irq_restore(flags);
+	if (!del)
+		css_put(&mem->css);
+out:
+	return;
+}
+
+/*
+ * Called from get_swap_page().
+ */
+void swap_cgroup_record_info(struct page *page, swp_entry_t entry)
+{
+	__swap_cgroup_info(page, entry, false);
+	return;
+}
+
+static void swap_cgroup_delete_info(swp_entry_t entry)
+{
+	__swap_cgroup_info(NULL, entry, true);
+	return;
+}
+
+/*
+ * called from swap_entry_free().
+ */
+void swap_cgroup_delete_swap(swp_entry_t entry)
+{
+	swap_cgroup_delete_info(entry);
+	return;
+}
+
+
+/*
+ * set/clear on_disk information of swap_cgroup, and increment/decrement
+ * disk_swaps.
+ */
+static void __swap_cgroup_disk_swap(swp_entry_t entry, bool set)
+{
+	unsigned long flags;
+	int type = swp_type(entry);
+	unsigned long offset = swp_offset(entry);
+	unsigned long array_index = offset/ENTS_PER_PAGE;
+	unsigned long index = offset & (ENTS_PER_PAGE - 1);
+	struct page *mappage;
+	struct swap_cgroup *map;
+	struct mem_cgroup *mem;
+
+	if (!swap_cgroup_map[type])
+		return;
+
+	mappage = swap_cgroup_map[type][array_index];
+	VM_BUG_ON(!mappage);
+
+	local_irq_save(flags);
+	map = kmap_atomic(mappage, KM_USER0);
+	mem = mem_cgroup_id_lookup(map[index].memcgrp_id);
+	if (!mem) {
+		if (set && map[index].on_disk == 0) {
+			map[index].on_disk = 1;
+			mem_counter_charge_disk_swap(mem);
+		} else if (!set && map[index].on_disk == 1) {
+			mem_counter_uncharge_disk_swap(mem);
+			map[index].on_disk = 0;
+		}
+	}
+	kunmap_atomic(mappage, KM_USER0);
+	local_irq_restore(flags);
+
+	return;
+}
+
+static void swap_cgroup_uncharge_disk_swap(struct page *page)
+{
+	swp_entry_t entry = { .val = page_private(page) };
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	__swap_cgroup_disk_swap(entry, false);
+}
+
+static void
+swap_cgroup_charge_disk_swap(swp_entry_t entry)
+{
+	__swap_cgroup_disk_swap(entry, true);
+}
+
+/*
+ * Called from delete_from_swap_cache() then, page is Locked! and
+ * swp_entry is still in use.
+ */
+void swap_cgroup_delete_swapcache(struct page *page, swp_entry_t entry)
+{
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_SWAPOUT,
+					entry);
+	return;
+}
+
+
+/*
+ * Forget all accounts under swap_cgroup of memcg.
+ * Called from destroying context.
+ */
+static void swap_cgroup_clean_account(struct mem_cgroup *memcg)
+{
+	int type;
+	unsigned long array_index, flags;
+	int index;
+	struct page *mappage;
+	struct swap_cgroup *map;
+
+	if (!memcg->res.swaps)
+		return;
+
+	while (!memcg->res.swaps) {
+		mutex_lock(&swap_cgroup_mutex);
+		for (type = 0; type < MAX_SWAPFILES; type++) {
+			if (swap_cgroup_pages[type] == 0)
+				continue;
+			for (array_index = 0;
+			     array_index < swap_cgroup_pages[type];
+			     array_index++) {
+				mappage = swap_cgroup_map[type][array_index];
+				if (!mappage)
+					continue;
+				local_irq_save(flags);
+				map = kmap_atomic(mappage, KM_USER0);
+				for (index = 0; index < ENTS_PER_PAGE;
+				     index++) {
+					if (map[index].memcgrp_id
+					    == memcg->memcgrp_id) {
+						mem_counter_uncharge_swap(memcg);
+						map[index].memcgrp_id = 0;
+					}
+				}
+				kunmap_atomic(mappage, KM_USER0);
+				local_irq_restore(flags);
+			}
+			mutex_unlock(&swap_cgroup_mutex);
+			cond_resched();
+			mutex_lock(&swap_cgroup_mutex);
+			if (!memcg->res.swaps)
+				break;
+		}
+		mutex_unlock(&swap_cgroup_mutex);
+	}
+}
+
+
+/*
+ * called from swapon().
+ */
+int swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	void *array;
+	int array_size;
+
+	VM_BUG_ON(swap_cgroup_map[type]);
+
+	array_size = ((max_pages/ENTS_PER_PAGE) + 1) * sizeof(void *);
+
+	array = vmalloc(array_size);
+	if (!array) {
+		printk("swap %d will not be accounted\n", type);
+		return -ENOMEM;
+	}
+	memset(array, 0, array_size);
+	mutex_lock(&swap_cgroup_mutex);
+	swap_cgroup_pages[type] = (max_pages/ENTS_PER_PAGE + 1);
+	swap_cgroup_map[type] = array;
+	mutex_unlock(&swap_cgroup_mutex);
+	spin_lock_init(&swap_cgroup_lock[type]);
+	return 0;
+}
+
+/*
+ * called from swapoff().
+ */
+void swap_cgroup_swapoff(int type)
+{
+	int i;
+	for (i = 0; i < swap_cgroup_pages[type]; i++) {
+		struct page *page = swap_cgroup_map[type][i];
+		if (page)
+			__free_page(page);
+	}
+	mutex_lock(&swap_cgroup_mutex);
+	vfree(swap_cgroup_map[type]);
+	swap_cgroup_map[type] = NULL;
+	mutex_unlock(&swap_cgroup_mutex);
+	swap_cgroup_pages[type] = 0;
+}
+
+#endif
diff --git a/mm/shmem.c b/mm/shmem.c
index 72b5f03..686a2b4 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1025,7 +1025,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	 * want to check if there's a redundant swappage to be discarded.
 	 */
 	if (wbc->for_reclaim)
-		swap = get_swap_page();
+		swap = get_swap_page(page);
 	else
 		swap.val = 0;
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3353c90..5515400 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -108,6 +108,8 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	swp_entry_t entry = { .val = page_private(page) };
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!PageSwapCache(page));
 	BUG_ON(PageWriteback(page));
@@ -117,6 +119,7 @@ void __delete_from_swap_cache(struct page *page)
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	total_swapcache_pages--;
+	swap_cgroup_delete_swapcache(page, entry);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
 }
@@ -138,7 +141,7 @@ int add_to_swap(struct page * page, gfp_t gfp_mask)
 	BUG_ON(!PageUptodate(page));
 
 	for (;;) {
-		entry = get_swap_page();
+		entry = get_swap_page(page);
 		if (!entry.val)
 			return 0;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index aa68bac..7e1be45 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -184,7 +184,9 @@ no_page:
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+/* get_swap_page() calls this */
+static int swap_entry_free(struct swap_info_struct *, swp_entry_t);
+swp_entry_t get_swap_page(struct page *page)
 {
 	struct swap_info_struct *si;
 	pgoff_t offset;
@@ -213,7 +215,19 @@ swp_entry_t get_swap_page(void)
 		swap_list.next = next;
 		offset = scan_swap_map(si);
 		if (offset) {
+			swp_entry_t entry = swp_entry(type, offset);
+
 			spin_unlock(&swap_lock);
+			/*
+			 * swap_cgroup_prepare tries to allocate memory,
+			 * so should be called without holding swap_lock.
+			 */
+			if (swap_cgroup_prepare(entry)) {
+				spin_lock(&swap_lock);
+				swap_entry_free(si, entry);
+				goto noswap;
+			}
+			swap_cgroup_record_info(page, entry);
 			return swp_entry(type, offset);
 		}
 		next = swap_list.next;
@@ -281,8 +295,9 @@ out:
 	return NULL;
 }	
 
-static int swap_entry_free(struct swap_info_struct *p, unsigned long offset)
+static int swap_entry_free(struct swap_info_struct *p, swp_entry_t entry)
 {
+	unsigned long offset = swp_offset(entry);
 	int count = p->swap_map[offset];
 
 	if (count < SWAP_MAP_MAX) {
@@ -297,6 +312,7 @@ static int swap_entry_free(struct swap_info_struct *p, unsigned long offset)
 				swap_list.next = p - swap_info;
 			nr_swap_pages++;
 			p->inuse_pages--;
+			swap_cgroup_delete_swap(entry);
 		}
 	}
 	return count;
@@ -312,7 +328,7 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, swp_offset(entry));
+		swap_entry_free(p, entry);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -431,7 +447,7 @@ void free_swap_and_cache(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, swp_offset(entry)) == 1) {
+		if (swap_entry_free(p, entry) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && !trylock_page(page)) {
 				page_cache_release(page);
@@ -1356,6 +1372,7 @@ asmlinkage long sys_swapoff(const char __user * specialfile)
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	swap_cgroup_swapoff(type);
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
@@ -1682,6 +1699,11 @@ asmlinkage long sys_swapon(const char __user * specialfile, int swap_flags)
 				1 /* header page */;
 		if (error)
 			goto bad_swap;
+
+		if (swap_cgroup_swapon(type, maxpages)) {
+			printk("We don't enable swap accounting because of"
+				"memory shortage\n");
+		}
 	}
 
 	if (nr_good_pages) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
