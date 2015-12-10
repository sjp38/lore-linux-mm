Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 90D716B0254
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:33 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so46621575pac.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:33 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q81si19882802pfa.141.2015.12.10.03.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:32 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Date: Thu, 10 Dec 2015 14:39:14 +0300
Message-ID: <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the legacy hierarchy we charge memsw, which is dubious, because:

 - memsw.limit must be >= memory.limit, so it is impossible to limit
   swap usage less than memory usage. Taking into account the fact that
   the primary limiting mechanism in the unified hierarchy is
   memory.high while memory.limit is either left unset or set to a very
   large value, moving memsw.limit knob to the unified hierarchy would
   effectively make it impossible to limit swap usage according to the
   user preference.

 - memsw.usage != memory.usage + swap.usage, because a page occupying
   both swap entry and a swap cache page is charged only once to memsw
   counter. As a result, it is possible to effectively eat up to
   memory.limit of memory pages *and* memsw.limit of swap entries, which
   looks unexpected.

That said, we should provide a different swap limiting mechanism for
cgroup2.

This patch adds mem_cgroup->swap counter, which charges the actual
number of swap entries used by a cgroup. It is only charged in the
unified hierarchy, while the legacy hierarchy memsw logic is left
intact.

The swap usage can be monitored using new memory.swap.current file and
limited using memory.swap.max.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h |   1 +
 include/linux/swap.h       |   5 ++
 mm/memcontrol.c            | 123 +++++++++++++++++++++++++++++++++++++++++----
 mm/shmem.c                 |   4 ++
 mm/swap_state.c            |   5 ++
 5 files changed, 129 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c6a5ed2f2744..993c9a26b637 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -169,6 +169,7 @@ struct mem_cgroup {
 
 	/* Accounted resources */
 	struct page_counter memory;
+	struct page_counter swap;
 	struct page_counter memsw;
 	struct page_counter kmem;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 457181844b6e..f4b3ccdcba91 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -368,11 +368,16 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 #endif
 #ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
+extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
 #else
 static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
 }
+static inline int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
+{
+	return 0;
+}
 static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7f5c6abf5421..9d10e2819ec4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1212,7 +1212,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		pr_cont(":");
 
 		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-			if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
+			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 				continue;
 			pr_cont(" %s:%luKB", mem_cgroup_stat_names[i],
 				K(mem_cgroup_read_stat(iter, i)));
@@ -1248,12 +1248,15 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	unsigned long limit;
 
-	limit = memcg->memory.limit;
+	limit = READ_ONCE(memcg->memory.limit);
 	if (mem_cgroup_swappiness(memcg)) {
 		unsigned long memsw_limit;
+		unsigned long swap_limit;
 
-		memsw_limit = memcg->memsw.limit;
-		limit = min(limit + total_swap_pages, memsw_limit);
+		memsw_limit = READ_ONCE(memcg->memsw.limit);
+		swap_limit = min(READ_ONCE(memcg->swap.limit),
+				 (unsigned long)total_swap_pages);
+		limit = min(limit + swap_limit, memsw_limit);
 	}
 	return limit;
 }
@@ -4226,6 +4229,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		page_counter_init(&memcg->memory, NULL);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
+		page_counter_init(&memcg->swap, NULL);
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 	}
@@ -4276,6 +4280,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		page_counter_init(&memcg->memory, &parent->memory);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
+		page_counter_init(&memcg->swap, &parent->swap);
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
 #if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
@@ -4291,6 +4296,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		page_counter_init(&memcg->memory, NULL);
 		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
+		page_counter_init(&memcg->swap, NULL);
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 #if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
@@ -5291,7 +5297,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		if (page->mem_cgroup)
 			goto out;
 
-		if (do_memsw_account()) {
+		if (do_swap_account) {
 			swp_entry_t ent = { .val = page_private(page), };
 			unsigned short id = lookup_swap_cgroup_id(ent);
 
@@ -5754,26 +5760,66 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	memcg_check_events(memcg, page);
 }
 
+/*
+ * mem_cgroup_charge_swap - charge a swap entry
+ * @page: page being added to swap
+ * @entry: swap entry to charge
+ *
+ * Try to charge @entry to the memcg that @page belongs to.
+ *
+ * Returns 0 on success, -ENOMEM on failure.
+ */
+int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry)
+{
+	struct mem_cgroup *memcg;
+	struct page_counter *counter;
+	unsigned short oldid;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) || !do_swap_account)
+		return 0;
+
+	memcg = page->mem_cgroup;
+
+	/* Readahead page, never charged */
+	if (!memcg)
+		return 0;
+
+	if (!mem_cgroup_is_root(memcg) &&
+	    !page_counter_try_charge(&memcg->swap, 1, &counter))
+		return -ENOMEM;
+
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
+	VM_BUG_ON_PAGE(oldid, page);
+	mem_cgroup_swap_statistics(memcg, true);
+
+	css_get(&memcg->css);
+	return 0;
+}
+
 /**
  * mem_cgroup_uncharge_swap - uncharge a swap entry
  * @entry: swap entry to uncharge
  *
- * Drop the memsw charge associated with @entry.
+ * Drop the swap charge associated with @entry.
  */
 void mem_cgroup_uncharge_swap(swp_entry_t entry)
 {
 	struct mem_cgroup *memcg;
 	unsigned short id;
 
-	if (!do_memsw_account())
+	if (!do_swap_account)
 		return;
 
 	id = swap_cgroup_record(entry, 0);
 	rcu_read_lock();
 	memcg = mem_cgroup_from_id(id);
 	if (memcg) {
-		if (!mem_cgroup_is_root(memcg))
-			page_counter_uncharge(&memcg->memsw, 1);
+		if (!mem_cgroup_is_root(memcg)) {
+			if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
+				page_counter_uncharge(&memcg->swap, 1);
+			else
+				page_counter_uncharge(&memcg->memsw, 1);
+		}
 		mem_cgroup_swap_statistics(memcg, false);
 		css_put(&memcg->css);
 	}
@@ -5797,6 +5843,63 @@ static int __init enable_swap_account(char *s)
 }
 __setup("swapaccount=", enable_swap_account);
 
+static u64 swap_current_read(struct cgroup_subsys_state *css,
+			     struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return (u64)page_counter_read(&memcg->swap) * PAGE_SIZE;
+}
+
+static int swap_max_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long max = READ_ONCE(memcg->swap.limit);
+
+	if (max == PAGE_COUNTER_MAX)
+		seq_puts(m, "max\n");
+	else
+		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t swap_max_write(struct kernfs_open_file *of,
+			      char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long max;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "max", &max);
+	if (err)
+		return err;
+
+	mutex_lock(&memcg_limit_mutex);
+	err = page_counter_limit(&memcg->swap, max);
+	mutex_unlock(&memcg_limit_mutex);
+	if (err)
+		return err;
+
+	return nbytes;
+}
+
+static struct cftype swap_files[] = {
+	{
+		.name = "swap.current",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_u64 = swap_current_read,
+	},
+	{
+		.name = "swap.max",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = swap_max_show,
+		.write = swap_max_write,
+	},
+	{ }	/* terminate */
+};
+
 static struct cftype memsw_cgroup_files[] = {
 	{
 		.name = "memsw.usage_in_bytes",
@@ -5828,6 +5931,8 @@ static int __init mem_cgroup_swap_init(void)
 {
 	if (!mem_cgroup_disabled() && really_do_swap_account) {
 		do_swap_account = 1;
+		WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
+					       swap_files));
 		WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
 						  memsw_cgroup_files));
 	}
diff --git a/mm/shmem.c b/mm/shmem.c
index 9b051115a100..659a90d8305c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -912,6 +912,9 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (!swap.val)
 		goto redirty;
 
+	if (mem_cgroup_charge_swap(page, swap))
+		goto free_swap;
+
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
 	 * if it's not already there.  Do it now before the page is
@@ -940,6 +943,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
+free_swap:
 	swapcache_free(swap);
 redirty:
 	set_page_dirty(page);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index d783872d746c..dea39cb03967 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -170,6 +170,11 @@ int add_to_swap(struct page *page, struct list_head *list)
 	if (!entry.val)
 		return 0;
 
+	if (mem_cgroup_charge_swap(page, entry)) {
+		swapcache_free(entry);
+		return 0;
+	}
+
 	if (unlikely(PageTransHuge(page)))
 		if (unlikely(split_huge_page_to_list(page, list))) {
 			swapcache_free(entry);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
