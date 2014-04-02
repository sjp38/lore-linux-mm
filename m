Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3B96B0108
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:35:30 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so835605iec.9
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:30 -0700 (PDT)
Received: from mail-ig0-x249.google.com (mail-ig0-x249.google.com [2607:f8b0:4001:c05::249])
        by mx.google.com with ESMTPS id k7si3673680icu.45.2014.04.02.13.35.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
Received: by mail-ig0-f201.google.com with SMTP id l13so76139iga.4
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:35:29 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 1/3] mm/swap: support per memory cgroup swapfiles
Date: Wed,  2 Apr 2014 13:34:07 -0700
Message-Id: <1396470849-26154-2-git-send-email-yuzhao@google.com>
In-Reply-To: <1396470849-26154-1-git-send-email-yuzhao@google.com>
References: <1396470849-26154-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, jamieliu@google.com, suleiman@google.com, hannes@cmpxchg.org, Yu Zhao <yuzhao@google.com>

From: Suleiman Souhlal <suleiman@google.com>

This patch adds support for per memory cgroup swap file. The swap file
is marked private in swapon() with a new flag SWAP_FLAG_PRIVATE becasue
only the memory cgroup (and its children) that owns it can use it (in
the case of the children that don't own any swap files, they go up the
hierarchy until someone who has swap file set up is found).

The path of the swap file is set by writing to memory.swapfile. Details
of the API can be found in Documentation/cgroups/memory.txt.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 Documentation/cgroups/memory.txt |  15 +++
 include/linux/memcontrol.h       |   2 +
 include/linux/swap.h             |  38 +++---
 mm/memcontrol.c                  |  76 ++++++++++++
 mm/memory.c                      |   3 +-
 mm/shmem.c                       |   2 +-
 mm/swap_state.c                  |   2 +-
 mm/swapfile.c                    | 241 ++++++++++++++++++++++++++++++++++-----
 mm/vmscan.c                      |   2 +-
 9 files changed, 331 insertions(+), 50 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2622115..48a98ad 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -72,6 +72,7 @@ Brief summary of control files.
  memory.move_charge_at_immigrate # set/show controls of moving charges
  memory.oom_control		 # set/show oom controls.
  memory.numa_stat		 # show the number of memory usage per numa node
+ memory.swapfile		 # set/show swap file
 
  memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
  memory.kmem.usage_in_bytes      # show current kernel memory allocation
@@ -342,6 +343,20 @@ set:
     admin a unified view of memory, and it is also useful for people who just
     want to track kernel memory usage.
 
+2.8 Private swap files
+
+It's possible to configure a cgroup to swap to a particular file by using
+memory.swapfile.
+
+A value of "default" in memory.swapfile indicates that this cgroup should
+use the default, system-wide, swap files. A value of "none" indicates that
+this cgroup should never swap. Other values are interpreted as the path
+to a private swap file.
+
+The swap file has to be created and swapon() has to be done on it with
+SWAP_FLAG_PRIVATE, before it can be used. This flag ensures that the swap
+file is private and does not get used by others.
+
 3. User Interface
 
 0. Configuration
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index abd0113..ec4879b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -155,6 +155,8 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 }
 
 bool mem_cgroup_oom_synchronize(bool wait);
+int mem_cgroup_get_page_swap_type(struct page *page);
+void mem_cgroup_remove_swapfile(int type);
 
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6..b6a280e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -23,10 +23,11 @@ struct bio;
 #define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
 #define SWAP_FLAG_DISCARD_ONCE	0x20000 /* discard swap area at swapon-time */
 #define SWAP_FLAG_DISCARD_PAGES 0x40000 /* discard page-clusters after use */
+#define SWAP_FLAG_PRIVATE     0x1000000	/* set if get_swap_page should skip */
 
 #define SWAP_FLAGS_VALID	(SWAP_FLAG_PRIO_MASK | SWAP_FLAG_PREFER | \
 				 SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
-				 SWAP_FLAG_DISCARD_PAGES)
+				 SWAP_FLAG_DISCARD_PAGES | SWAP_FLAG_PRIVATE)
 
 static inline int current_is_kswapd(void)
 {
@@ -158,8 +159,14 @@ enum {
 	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
 	SWP_AREA_DISCARD = (1 << 8),	/* single-time swap area discards */
 	SWP_PAGE_DISCARD = (1 << 9),	/* freed swap page-cluster discards */
+	SWP_PRIVATE	= (1 << 10),	/* not for general use */
 					/* add others here before... */
-	SWP_SCANNING	= (1 << 10),	/* refcount in scan_swap_map */
+	SWP_SCANNING	= (1 << 11),	/* refcount in scan_swap_map */
+};
+
+enum {
+	SWAP_TYPE_DEFAULT = -1,	/* use default/global/system swap file */
+	SWAP_TYPE_NONE = -2,	/* swap is disabled */
 };
 
 #define SWAP_CLUSTER_MAX 32UL
@@ -401,22 +408,19 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
-extern atomic_long_t nr_swap_pages;
-extern long total_swap_pages;
-
-/* Swap 50% full? Release swapcache more aggressively.. */
-static inline bool vm_swap_full(void)
-{
-	return atomic_long_read(&nr_swap_pages) * 2 < total_swap_pages;
-}
-
+extern bool vm_swap_full(struct page *page);
+extern atomic_long_t nr_public_swap_pages, nr_private_swap_pages;
 static inline long get_nr_swap_pages(void)
 {
-	return atomic_long_read(&nr_swap_pages);
+	return atomic_long_read(&nr_public_swap_pages) +
+	       atomic_long_read(&nr_private_swap_pages);
 }
-
+extern long total_public_swap_pages, total_private_swap_pages;
+#define total_swap_pages (total_public_swap_pages + total_private_swap_pages)
 extern void si_swapinfo(struct sysinfo *);
-extern swp_entry_t get_swap_page(void);
+extern int swap_retrive_swap_device(const int *, struct seq_file *);
+extern int swap_store_swap_device(const char *, int *);
+extern swp_entry_t get_swap_page(struct page *);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int add_swap_count_continuation(swp_entry_t, gfp_t);
 extern void swap_shmem_alloc(swp_entry_t);
@@ -449,9 +453,11 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 
 #define swap_address_space(entry)		(NULL)
 #define get_nr_swap_pages()			0L
+#define total_public_swap_pages			0L
+#define total_private_swap_pages		0L
 #define total_swap_pages			0L
 #define total_swapcache_pages()			0UL
-#define vm_swap_full()				0
+#define vm_swap_full(page)			0
 
 #define si_swapinfo(val) \
 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
@@ -538,7 +544,7 @@ static inline int try_to_free_swap(struct page *page)
 	return 0;
 }
 
-static inline swp_entry_t get_swap_page(void)
+static inline swp_entry_t get_swap_page(struct page *page)
 {
 	swp_entry_t entry;
 	entry.val = 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5b6b003..7d397a6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -311,6 +311,8 @@ struct mem_cgroup {
 	atomic_t	under_oom;
 	atomic_t	oom_wakeups;
 
+	/* per-memcg swapfile type; protected by swap_lock */
+	int	swap_type;
 	int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
@@ -4358,6 +4360,70 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	if (do_swap_account && swapout && memcg)
 		swap_cgroup_record(ent, mem_cgroup_id(memcg));
 }
+
+static int
+mem_cgroup_swapfile_write(struct cgroup_subsys_state *css,
+	struct cftype *cft, const char *buf)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return swap_store_swap_device(buf, &memcg->swap_type);
+}
+
+static int
+mem_cgroup_swapfile_read(struct seq_file *sf, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
+
+	return swap_retrive_swap_device(&memcg->swap_type, sf);
+}
+
+static int
+mem_cgroup_get_swap_type(struct mem_cgroup *memcg)
+{
+	int type;
+
+	type = SWAP_TYPE_DEFAULT;
+	while (memcg) {
+		type = memcg->swap_type;
+		if (type != SWAP_TYPE_DEFAULT)
+			break;
+		memcg = parent_mem_cgroup(memcg);
+		if (memcg && !memcg->use_hierarchy)
+			break;
+	}
+
+	return type;
+}
+
+int
+mem_cgroup_get_page_swap_type(struct page *page)
+{
+	struct page_cgroup *pc;
+	int type;
+
+	type = SWAP_TYPE_DEFAULT;
+	if (mem_cgroup_disabled())
+		return type;
+
+	rcu_read_lock();
+	pc = lookup_page_cgroup(page);
+	type = mem_cgroup_get_swap_type(pc->mem_cgroup);
+	rcu_read_unlock();
+
+	return type;
+}
+
+/* swap_lock must be held. */
+void
+mem_cgroup_remove_swapfile(int type)
+{
+	struct mem_cgroup *memcg;
+
+	for_each_mem_cgroup(memcg)
+		if (memcg->swap_type == type)
+			memcg->swap_type = SWAP_TYPE_DEFAULT;
+}
 #endif
 
 #ifdef CONFIG_MEMCG_SWAP
@@ -6330,6 +6396,15 @@ static struct cftype mem_cgroup_files[] = {
 	},
 #endif
 #endif
+#ifdef CONFIG_SWAP
+	{
+		.name = "swapfile",
+		.seq_show = mem_cgroup_swapfile_read,
+		.write_string = mem_cgroup_swapfile_write,
+		.max_write_len = PATH_MAX,
+	},
+#endif
+
 	{ },	/* terminate */
 };
 
@@ -6516,6 +6591,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 	memcg->move_charge_at_immigrate = 0;
+	memcg->swap_type = SWAP_TYPE_DEFAULT;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
diff --git a/mm/memory.c b/mm/memory.c
index 22dfa61..e4cb482 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3136,7 +3136,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
 	swap_free(entry);
-	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	if (vm_swap_full(page) || (vma->vm_flags & VM_LOCKED) ||
+			PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache) {
diff --git a/mm/shmem.c b/mm/shmem.c
index 1f18c9d..1cd4291 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -838,7 +838,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		SetPageUptodate(page);
 	}
 
-	swap = get_swap_page();
+	swap = get_swap_page(page);
 	if (!swap.val)
 		goto redirty;
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e76ace3..21f4d66 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -170,7 +170,7 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
-	entry = get_swap_page();
+	entry = get_swap_page(page);
 	if (!entry.val)
 		return 0;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4a7f7e6..18a8eee 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -34,6 +34,7 @@
 #include <linux/frontswap.h>
 #include <linux/swapfile.h>
 #include <linux/export.h>
+#include <linux/file.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -47,9 +48,11 @@ static sector_t map_swap_entry(swp_entry_t, struct block_device**);
 
 DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
-atomic_long_t nr_swap_pages;
+atomic_long_t nr_public_swap_pages; /* available public/global swap pages. */
+atomic_long_t nr_private_swap_pages; /* available per-cgroup swap pages. */
 /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
-long total_swap_pages;
+long total_public_swap_pages; /* number of public/global swap pages. */
+long total_private_swap_pages; /* number of per-cgroup swap pages. */
 static int least_priority;
 static atomic_t highest_priority_index = ATOMIC_INIT(-1);
 
@@ -473,6 +476,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 	unsigned long scan_base;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
+	bool nearly_full;
 
 	/*
 	 * We try to cluster swap pages by allocating them sequentially
@@ -487,6 +491,11 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 	si->flags += SWP_SCANNING;
 	scan_base = offset = si->cluster_next;
+	if (si->flags & SWP_PRIVATE)
+		nearly_full = (si->inuse_pages * 2 > si->pages);
+	else
+		nearly_full = (atomic_long_read(&nr_public_swap_pages) * 2 <
+			      total_public_swap_pages);
 
 	/* SSD algorithm */
 	if (si->cluster_info) {
@@ -569,7 +578,7 @@ checks:
 		scan_base = offset = si->lowest_bit;
 
 	/* reuse swap entry of cache-only swap if not busy. */
-	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+	if (nearly_full && si->swap_map[offset] == SWAP_HAS_CACHE) {
 		int swap_was_freed;
 		spin_unlock(&si->lock);
 		swap_was_freed = __try_to_reclaim_swap(si, offset);
@@ -606,7 +615,7 @@ scan:
 			spin_lock(&si->lock);
 			goto checks;
 		}
-		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+		if (nearly_full && si->swap_map[offset] == SWAP_HAS_CACHE) {
 			spin_lock(&si->lock);
 			goto checks;
 		}
@@ -621,7 +630,7 @@ scan:
 			spin_lock(&si->lock);
 			goto checks;
 		}
-		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+		if (nearly_full && si->swap_map[offset] == SWAP_HAS_CACHE) {
 			spin_lock(&si->lock);
 			goto checks;
 		}
@@ -638,18 +647,123 @@ no_page:
 	return 0;
 }
 
-swp_entry_t get_swap_page(void)
+#ifdef CONFIG_MEMCG
+int swap_retrive_swap_device(const int *_type, struct seq_file *swap)
+{
+	struct swap_info_struct *si;
+	struct file *file;
+	int type;
+
+	spin_lock(&swap_lock);
+	type = *_type;
+	if (type == SWAP_TYPE_NONE) {
+		spin_unlock(&swap_lock);
+		seq_puts(swap, "none\n");
+		return 0;
+	}
+	if (type == SWAP_TYPE_DEFAULT) {
+		spin_unlock(&swap_lock);
+		seq_puts(swap, "default\n");
+		return 0;
+	}
+	BUG_ON(type < 0);
+	BUG_ON(type >= nr_swapfiles);
+
+	si = swap_info[type];
+	spin_lock(&si->lock);
+	spin_unlock(&swap_lock);
+	BUG_ON(!(si->flags & SWP_USED));
+	file = si->swap_file;
+	seq_path(swap, &file->f_path, " \t\n\\");
+	seq_putc(swap, '\n');
+	spin_unlock(&si->lock);
+
+	return 0;
+}
+
+int swap_store_swap_device(const char *buf, int *_type)
+{
+	struct swap_info_struct *si = NULL;
+	struct file *victim;
+	struct address_space *mapping;
+	int type;
+	int err;
+	char *nl;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	nl = strchr(buf, '\n');
+	if (nl != NULL)
+		*nl = '\0';
+	if (strcmp(buf, "none") == 0) {
+		*_type = SWAP_TYPE_NONE;
+		return 0;
+	}
+	if (strcmp(buf, "default") == 0) {
+		*_type = SWAP_TYPE_DEFAULT;
+		return 0;
+	}
+
+	victim = filp_open(buf, O_RDWR|O_LARGEFILE, 0);
+	err = PTR_ERR(victim);
+	if (IS_ERR(victim))
+		return err;
+
+	mapping = victim->f_mapping;
+	spin_lock(&swap_lock);
+	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) {
+		si = swap_info[type];
+		if ((si->flags & SWP_WRITEOK) == SWP_WRITEOK) {
+			if (si->swap_file->f_mapping == mapping)
+				break;
+		}
+	}
+	if (type < 0) {
+		err = -EINVAL;
+	} else {
+		err = 0;
+		*_type = type;
+	}
+	spin_unlock(&swap_lock);
+	filp_close(victim, NULL);
+	return err;
+}
+#else
+static inline int mem_cgroup_get_page_swap_type(struct page *page)
+{
+	return SWAP_TYPE_DEFAULT;
+}
+
+static inline void mem_cgroup_remove_swapfile(int type)
+{
+}
+#endif /* CONFIG_MEMCG */
+
+static swp_entry_t __get_swap_page_of_type(int type, int usage);
+
+swp_entry_t get_swap_page(struct page *page)
 {
 	struct swap_info_struct *si;
 	pgoff_t offset;
 	int type, next;
 	int wrapped = 0;
 	int hp_index;
+	swp_entry_t ret = {0};
+
+	type = mem_cgroup_get_page_swap_type(page);
+	if (type == SWAP_TYPE_NONE)
+		goto out_unlocked;
+	if (type != SWAP_TYPE_DEFAULT) {
+		ret = __get_swap_page_of_type(type, SWAP_HAS_CACHE);
+		goto out_unlocked;
+	}
 
 	spin_lock(&swap_lock);
-	if (atomic_long_read(&nr_swap_pages) <= 0)
-		goto noswap;
-	atomic_long_dec(&nr_swap_pages);
+
+	if (atomic_long_read(&nr_public_swap_pages) <= 0)
+		goto out;
+	atomic_long_dec(&nr_public_swap_pages);
 
 	for (type = swap_list.next; type >= 0 && wrapped < 2; type = next) {
 		hp_index = atomic_xchg(&highest_priority_index, -1);
@@ -689,6 +803,10 @@ swp_entry_t get_swap_page(void)
 			spin_unlock(&si->lock);
 			continue;
 		}
+		if (si->flags & SWP_PRIVATE) {
+			spin_unlock(&si->lock);
+			continue;
+		}
 
 		swap_list.next = next;
 
@@ -702,14 +820,14 @@ swp_entry_t get_swap_page(void)
 		next = swap_list.next;
 	}
 
-	atomic_long_inc(&nr_swap_pages);
-noswap:
+	atomic_long_inc(&nr_public_swap_pages);
+out:
 	spin_unlock(&swap_lock);
-	return (swp_entry_t) {0};
+out_unlocked:
+	return ret;
 }
 
-/* The only caller of this function is now suspend routine */
-swp_entry_t get_swap_page_of_type(int type)
+static swp_entry_t __get_swap_page_of_type(int type, int usage)
 {
 	struct swap_info_struct *si;
 	pgoff_t offset;
@@ -717,19 +835,28 @@ swp_entry_t get_swap_page_of_type(int type)
 	si = swap_info[type];
 	spin_lock(&si->lock);
 	if (si && (si->flags & SWP_WRITEOK)) {
-		atomic_long_dec(&nr_swap_pages);
+		atomic_long_t *counter = (si->flags & SWP_PRIVATE) ?
+					 &nr_private_swap_pages :
+					 &nr_public_swap_pages;
+		atomic_long_dec(counter);
 		/* This is called for allocating swap entry, not cache */
-		offset = scan_swap_map(si, 1);
+		offset = scan_swap_map(si, usage);
 		if (offset) {
 			spin_unlock(&si->lock);
 			return swp_entry(type, offset);
 		}
-		atomic_long_inc(&nr_swap_pages);
+		atomic_long_inc(counter);
 	}
 	spin_unlock(&si->lock);
 	return (swp_entry_t) {0};
 }
 
+/* The only caller of this function is now suspend routine */
+swp_entry_t get_swap_page_of_type(int type)
+{
+	return __get_swap_page_of_type(type, 1);
+}
+
 static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
@@ -831,7 +958,10 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		if (offset > p->highest_bit)
 			p->highest_bit = offset;
 		set_highest_priority_index(p->type);
-		atomic_long_inc(&nr_swap_pages);
+		if (p->flags & SWP_PRIVATE)
+			atomic_long_inc(&nr_private_swap_pages);
+		else
+			atomic_long_inc(&nr_public_swap_pages);
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
 		if (p->flags & SWP_BLKDEV) {
@@ -989,7 +1119,7 @@ int free_swap_and_cache(swp_entry_t entry)
 		 * Also recheck PageSwapCache now page is locked (above).
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
-				(!page_mapped(page) || vm_swap_full())) {
+				(!page_mapped(page) || vm_swap_full(page))) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
@@ -1774,9 +1904,13 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
-	atomic_long_add(p->pages, &nr_swap_pages);
-	total_swap_pages += p->pages;
-
+	if (p->flags & SWP_PRIVATE) {
+		atomic_long_add(p->pages, &nr_private_swap_pages);
+		total_private_swap_pages += p->pages;
+	} else {
+		atomic_long_add(p->pages, &nr_public_swap_pages);
+		total_public_swap_pages += p->pages;
+	}
 	/* insert swap space into swap_list: */
 	prev = -1;
 	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
@@ -1878,8 +2012,13 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 			swap_info[i]->prio = p->prio--;
 		least_priority++;
 	}
-	atomic_long_sub(p->pages, &nr_swap_pages);
-	total_swap_pages -= p->pages;
+	if (p->flags & SWP_PRIVATE) {
+		atomic_long_sub(p->pages, &nr_private_swap_pages);
+		total_private_swap_pages -= p->pages;
+	} else {
+		atomic_long_sub(p->pages, &nr_public_swap_pages);
+		total_public_swap_pages -= p->pages;
+	}
 	p->flags &= ~SWP_WRITEOK;
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
@@ -1924,6 +2063,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	cluster_info = p->cluster_info;
 	p->cluster_info = NULL;
 	frontswap_map = frontswap_map_get(p);
+	mem_cgroup_remove_swapfile(type);
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 	frontswap_invalidate_area(type);
@@ -1969,6 +2109,42 @@ out:
 	return err;
 }
 
+/*
+ * Swap 50% full? Release swapcache more aggressively..
+ */
+bool vm_swap_full(struct page *page)
+{
+	int type;
+	struct swap_info_struct *si;
+
+	/*
+	 * This function could hold swap_lock throughout, ensuring that:
+	 * - type cannot change during the function's execution
+	 * - {nr,total}_{public,private}_swap_pages cannot change
+	 * But for performance, we don't hold any locks. As a result:
+	 * - Changes to nr_public_swap_pages aren't atomic with changes to
+	 *   total_public_swap_pages, and changes to si->inuse_pages aren't
+	 *   atomic with changes to si->pages. This is ok because vm_swap_full
+	 *   is a best-effort heuristic anyway, so being occasionally wrong
+	 *   doesn't hurt too much.
+	 * - The memcg's swap type can change from when it is read to when it is
+	 *   used. This is ok because it can't cause us to crash; swap_info is
+	 *   never shrunk, so swap_info[type] will be a non-NULL
+	 *   swap_info_struct even if type is stale; and, as before, being
+	 *   occasionally wrong is ok.
+	 */
+	type = mem_cgroup_get_page_swap_type(page);
+	if (type == SWAP_TYPE_NONE)
+		return true;
+	if (type == SWAP_TYPE_DEFAULT)
+		return (atomic_long_read(&nr_public_swap_pages) * 2 <
+			total_public_swap_pages);
+	BUG_ON(type < 0);
+	BUG_ON(type >= nr_swapfiles);
+	si = swap_info[type];
+	return si->inuse_pages * 2 > si->pages;
+}
+
 #ifdef CONFIG_PROC_FS
 static unsigned swaps_poll(struct file *file, poll_table *wait)
 {
@@ -2048,13 +2224,16 @@ static int swap_show(struct seq_file *swap, void *v)
 
 	file = si->swap_file;
 	len = seq_path(swap, &file->f_path, " \t\n\\");
-	seq_printf(swap, "%*s%s\t%u\t%u\t%d\n",
+	seq_printf(swap, "%*s%s\t%u\t%u\t",
 			len < 40 ? 40 - len : 1, " ",
 			S_ISBLK(file_inode(file)->i_mode) ?
 				"partition" : "file\t",
 			si->pages << (PAGE_SHIFT - 10),
-			si->inuse_pages << (PAGE_SHIFT - 10),
-			si->prio);
+			si->inuse_pages << (PAGE_SHIFT - 10));
+	if (si->flags & SWP_PRIVATE)
+		seq_puts(swap, "private\n");
+	else
+		seq_printf(swap, "%d\n", si->prio);
 	return 0;
 }
 
@@ -2104,7 +2283,7 @@ static int __init max_swapfiles_check(void)
 late_initcall(max_swapfiles_check);
 #endif
 
-static struct swap_info_struct *alloc_swap_info(void)
+static struct swap_info_struct *alloc_swap_info(int swap_flags)
 {
 	struct swap_info_struct *p;
 	unsigned int type;
@@ -2143,6 +2322,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	p->flags = SWP_USED;
+	if (swap_flags & SWAP_FLAG_PRIVATE)
+		p->flags |= SWP_PRIVATE;
 	p->next = -1;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
@@ -2381,7 +2562,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	p = alloc_swap_info();
+	p = alloc_swap_info(swap_flags);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
@@ -2587,7 +2768,7 @@ void si_swapinfo(struct sysinfo *val)
 		if ((si->flags & SWP_USED) && !(si->flags & SWP_WRITEOK))
 			nr_to_be_unused += si->inuse_pages;
 	}
-	val->freeswap = atomic_long_read(&nr_swap_pages) + nr_to_be_unused;
+	val->freeswap = get_nr_swap_pages() + nr_to_be_unused;
 	val->totalswap = total_swap_pages + nr_to_be_unused;
 	spin_unlock(&swap_lock);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b4..abb5fee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1095,7 +1095,7 @@ cull_mlocked:
 
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && vm_swap_full())
+		if (PageSwapCache(page) && vm_swap_full(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		SetPageActive(page);
-- 
1.9.1.423.g4596e3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
