Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA0FB6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:44:46 -0400 (EDT)
Received: by obdfc2 with SMTP id fc2so134682662obd.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:44:46 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id y126si1224790oiy.105.2015.03.23.15.44.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 15:44:46 -0700 (PDT)
Message-ID: <1427150680.2515.36.camel@j-VirtualBox>
Subject: [PATCH] mm: Remove usages of ACCESS_ONCE
From: Jason Low <jason.low2@hp.com>
Date: Mon, 23 Mar 2015 15:44:40 -0700
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Jason Low <jason.low2@hp.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>

Commit 38c5ce936a08 converted ACCESS_ONCE usage in gup_pmd_range() to
READ_ONCE, since ACCESS_ONCE doesn't work reliably on non-scalar types.

This patch removes the rest of the usages of ACCESS_ONCE, and use
READ_ONCE for the read accesses. This also makes things cleaner,
instead of using separate/multiple sets of APIs.

Signed-off-by: Jason Low <jason.low2@hp.com>
---
 mm/gup.c         |    4 ++--
 mm/huge_memory.c |    4 ++--
 mm/internal.h    |    4 ++--
 mm/ksm.c         |   10 +++++-----
 mm/memcontrol.c  |   18 +++++++++---------
 mm/memory.c      |    2 +-
 mm/mmap.c        |    8 ++++----
 mm/page_alloc.c  |    6 +++---
 mm/rmap.c        |    6 +++---
 mm/slub.c        |    4 ++--
 mm/swap_state.c  |    2 +-
 mm/swapfile.c    |    2 +-
 12 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ca7b607..6297f6b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1019,7 +1019,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 *
 		 * for an example see gup_get_pte in arch/x86/mm/gup.c
 		 */
-		pte_t pte = ACCESS_ONCE(*ptep);
+		pte_t pte = READ_ONCE(*ptep);
 		struct page *page;
 
 		/*
@@ -1309,7 +1309,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
-		pgd_t pgd = ACCESS_ONCE(*pgdp);
+		pgd_t pgd = READ_ONCE(*pgdp);
 
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3412cc8..3ae874c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -183,7 +183,7 @@ static struct page *get_huge_zero_page(void)
 	struct page *zero_page;
 retry:
 	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
-		return ACCESS_ONCE(huge_zero_page);
+		return READ_ONCE(huge_zero_page);
 
 	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
 			HPAGE_PMD_ORDER);
@@ -202,7 +202,7 @@ retry:
 	/* We take additional reference here. It will be put back by shrinker */
 	atomic_set(&huge_zero_refcount, 2);
 	preempt_enable();
-	return ACCESS_ONCE(huge_zero_page);
+	return READ_ONCE(huge_zero_page);
 }
 
 static void put_huge_zero_page(void)
diff --git a/mm/internal.h b/mm/internal.h
index edaab69..a25e359 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -224,13 +224,13 @@ static inline unsigned long page_order(struct page *page)
  * PageBuddy() should be checked first by the caller to minimize race window,
  * and invalid values must be handled gracefully.
  *
- * ACCESS_ONCE is used so that if the caller assigns the result into a local
+ * READ_ONCE is used so that if the caller assigns the result into a local
  * variable and e.g. tests it for valid range before using, the compiler cannot
  * decide to remove the variable and inline the page_private(page) multiple
  * times, potentially observing different values in the tests and the actual
  * use of the result.
  */
-#define page_order_unsafe(page)		ACCESS_ONCE(page_private(page))
+#define page_order_unsafe(page)		READ_ONCE(page_private(page))
 
 static inline bool is_cow_mapping(vm_flags_t flags)
 {
diff --git a/mm/ksm.c b/mm/ksm.c
index 4162dce..7ee101e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -542,7 +542,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	expected_mapping = (void *)stable_node +
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 again:
-	kpfn = ACCESS_ONCE(stable_node->kpfn);
+	kpfn = READ_ONCE(stable_node->kpfn);
 	page = pfn_to_page(kpfn);
 
 	/*
@@ -551,7 +551,7 @@ again:
 	 * but on Alpha we need to be more careful.
 	 */
 	smp_read_barrier_depends();
-	if (ACCESS_ONCE(page->mapping) != expected_mapping)
+	if (READ_ONCE(page->mapping) != expected_mapping)
 		goto stale;
 
 	/*
@@ -577,14 +577,14 @@ again:
 		cpu_relax();
 	}
 
-	if (ACCESS_ONCE(page->mapping) != expected_mapping) {
+	if (READ_ONCE(page->mapping) != expected_mapping) {
 		put_page(page);
 		goto stale;
 	}
 
 	if (lock_it) {
 		lock_page(page);
-		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
+		if (READ_ONCE(page->mapping) != expected_mapping) {
 			unlock_page(page);
 			put_page(page);
 			goto stale;
@@ -600,7 +600,7 @@ stale:
 	 * before checking whether node->kpfn has been changed.
 	 */
 	smp_rmb();
-	if (ACCESS_ONCE(stable_node->kpfn) != kpfn)
+	if (READ_ONCE(stable_node->kpfn) != kpfn)
 		goto again;
 	remove_node_from_stable_tree(stable_node);
 	return NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 74a9641..14c2f20 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -674,7 +674,7 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
 static unsigned long soft_limit_excess(struct mem_cgroup *memcg)
 {
 	unsigned long nr_pages = page_counter_read(&memcg->memory);
-	unsigned long soft_limit = ACCESS_ONCE(memcg->soft_limit);
+	unsigned long soft_limit = READ_ONCE(memcg->soft_limit);
 	unsigned long excess = 0;
 
 	if (nr_pages > soft_limit)
@@ -1042,7 +1042,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			goto out_unlock;
 
 		do {
-			pos = ACCESS_ONCE(iter->position);
+			pos = READ_ONCE(iter->position);
 			/*
 			 * A racing update may change the position and
 			 * put the last reference, hence css_tryget(),
@@ -1359,13 +1359,13 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 	unsigned long limit;
 
 	count = page_counter_read(&memcg->memory);
-	limit = ACCESS_ONCE(memcg->memory.limit);
+	limit = READ_ONCE(memcg->memory.limit);
 	if (count < limit)
 		margin = limit - count;
 
 	if (do_swap_account) {
 		count = page_counter_read(&memcg->memsw);
-		limit = ACCESS_ONCE(memcg->memsw.limit);
+		limit = READ_ONCE(memcg->memsw.limit);
 		if (count <= limit)
 			margin = min(margin, limit - count);
 	}
@@ -2637,7 +2637,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 		return cachep;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-	kmemcg_id = ACCESS_ONCE(memcg->kmemcg_id);
+	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
 		goto out;
 
@@ -5007,7 +5007,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	 * tunable will only affect upcoming migrations, not the current one.
 	 * So we need to save it, and keep it going.
 	 */
-	move_flags = ACCESS_ONCE(memcg->move_charge_at_immigrate);
+	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
 	if (move_flags) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);
@@ -5241,7 +5241,7 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 static int memory_low_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long low = ACCESS_ONCE(memcg->low);
+	unsigned long low = READ_ONCE(memcg->low);
 
 	if (low == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -5271,7 +5271,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 static int memory_high_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long high = ACCESS_ONCE(memcg->high);
+	unsigned long high = READ_ONCE(memcg->high);
 
 	if (high == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -5301,7 +5301,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 static int memory_max_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long max = ACCESS_ONCE(memcg->memory.limit);
+	unsigned long max = READ_ONCE(memcg->memory.limit);
 
 	if (max == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
diff --git a/mm/memory.c b/mm/memory.c
index 5ec794f..9f6d3c6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2845,7 +2845,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 	struct vm_fault vmf;
 	int off;
 
-	nr_pages = ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;
+	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
 
 	start_addr = max(address & mask, vma->vm_start);
diff --git a/mm/mmap.c b/mm/mmap.c
index 06a6076..e65cbe0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1133,7 +1133,7 @@ static int anon_vma_compatible(struct vm_area_struct *a, struct vm_area_struct *
  * by another page fault trying to merge _that_. But that's ok: if it
  * is being set up, that automatically means that it will be a singleton
  * acceptable for merging, so we can do all of this optimistically. But
- * we do that ACCESS_ONCE() to make sure that we never re-load the pointer.
+ * we do that READ_ONCE() to make sure that we never re-load the pointer.
  *
  * IOW: that the "list_is_singular()" test on the anon_vma_chain only
  * matters for the 'stable anon_vma' case (ie the thing we want to avoid
@@ -1147,7 +1147,7 @@ static int anon_vma_compatible(struct vm_area_struct *a, struct vm_area_struct *
 static struct anon_vma *reusable_anon_vma(struct vm_area_struct *old, struct vm_area_struct *a, struct vm_area_struct *b)
 {
 	if (anon_vma_compatible(a, b)) {
-		struct anon_vma *anon_vma = ACCESS_ONCE(old->anon_vma);
+		struct anon_vma *anon_vma = READ_ONCE(old->anon_vma);
 
 		if (anon_vma && list_is_singular(&old->anon_vma_chain))
 			return anon_vma;
@@ -2100,7 +2100,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	actual_size = size;
 	if (size && (vma->vm_flags & (VM_GROWSUP | VM_GROWSDOWN)))
 		actual_size -= PAGE_SIZE;
-	if (actual_size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur))
+	if (actual_size > READ_ONCE(rlim[RLIMIT_STACK].rlim_cur))
 		return -ENOMEM;
 
 	/* mlock limit tests */
@@ -2108,7 +2108,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		unsigned long locked;
 		unsigned long limit;
 		locked = mm->locked_vm + grow;
-		limit = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
+		limit = READ_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
 		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
 			return -ENOMEM;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b84950..ebffa0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1371,7 +1371,7 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	int to_drain, batch;
 
 	local_irq_save(flags);
-	batch = ACCESS_ONCE(pcp->batch);
+	batch = READ_ONCE(pcp->batch);
 	to_drain = min(pcp->count, batch);
 	if (to_drain > 0) {
 		free_pcppages_bulk(zone, to_drain, pcp);
@@ -1570,7 +1570,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
-		unsigned long batch = ACCESS_ONCE(pcp->batch);
+		unsigned long batch = READ_ONCE(pcp->batch);
 		free_pcppages_bulk(zone, batch, pcp);
 		pcp->count -= batch;
 	}
@@ -6207,7 +6207,7 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	mask <<= (BITS_PER_LONG - bitidx - 1);
 	flags <<= (BITS_PER_LONG - bitidx - 1);
 
-	word = ACCESS_ONCE(bitmap[word_bitidx]);
+	word = READ_ONCE(bitmap[word_bitidx]);
 	for (;;) {
 		old_word = cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
 		if (word == old_word)
diff --git a/mm/rmap.c b/mm/rmap.c
index 8030382..dad23a4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -456,7 +456,7 @@ struct anon_vma *page_get_anon_vma(struct page *page)
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
-	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
+	anon_mapping = (unsigned long)READ_ONCE(page->mapping);
 	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
 		goto out;
 	if (!page_mapped(page))
@@ -500,14 +500,14 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
-	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
+	anon_mapping = (unsigned long)READ_ONCE(page->mapping);
 	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
 		goto out;
 	if (!page_mapped(page))
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	root_anon_vma = ACCESS_ONCE(anon_vma->root);
+	root_anon_vma = READ_ONCE(anon_vma->root);
 	if (down_read_trylock(&root_anon_vma->rwsem)) {
 		/*
 		 * If the page is still mapped, then this anon_vma is still
diff --git a/mm/slub.c b/mm/slub.c
index d01f912..3b5cb6b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4277,7 +4277,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			int node;
 			struct page *page;
 
-			page = ACCESS_ONCE(c->page);
+			page = READ_ONCE(c->page);
 			if (!page)
 				continue;
 
@@ -4292,7 +4292,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			total += x;
 			nodes[node] += x;
 
-			page = ACCESS_ONCE(c->partial);
+			page = READ_ONCE(c->partial);
 			if (page) {
 				node = page_to_nid(page);
 				if (flags & SO_TOTAL)
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 405923f..8bc8e66 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -390,7 +390,7 @@ static unsigned long swapin_nr_pages(unsigned long offset)
 	unsigned int pages, max_pages, last_ra;
 	static atomic_t last_readahead_pages;
 
-	max_pages = 1 << ACCESS_ONCE(page_cluster);
+	max_pages = 1 << READ_ONCE(page_cluster);
 	if (max_pages <= 1)
 		return 1;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63f55cc..a7e7210 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1312,7 +1312,7 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 			else
 				continue;
 		}
-		count = ACCESS_ONCE(si->swap_map[i]);
+		count = READ_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
 	}
-- 
1.7.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
