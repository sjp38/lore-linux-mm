Date: Mon, 22 Sep 2008 20:12:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from
 struct page)
Message-Id: <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Remove page_cgroup pointer from struct page.

This patch removes page_cgroup pointer from struct page and make it be able
to get from pfn. Then, relationship of them is

Before this:
  pfn <-> struct page <-> struct page_cgroup.
After this:
  struct page <-> pfn -> struct page_cgroup -> struct page.

Benefit of this approach is we can remove 8 bytes from struct page.

Other changes are:
  - lock/unlock_page_cgroup() uses its own bit on struct page_cgroup.
  - all necessary page_cgroups are allocated at boot.

Characteristics:
  - page cgroup is allocated as some amount of chunk.
    This patch uses SECTION_SIZE as size of chunk if 64bit/SPARSEMEM is enabled.
    If not, appropriate default number is selected.
  - all page_cgroup struct is maintained by hash. 
    I think we have 2 ways to handle sparse index in general
    ...radix-tree and hash. This uses hash because radix-tree's layout is
    affected by memory map's layout.
  - page_cgroup.h/page_cgroup.c is added.

Changelog: v3 -> v4.
  - changed arguments to lookup_page_cgroup() from "pfn" to "page",

Changelog: v2 -> v3
  - changed arguments from pfn to struct page*.
  - added memory hotplug callback (no undo...needs .more work.)
  - adjusted to new mmotm. 

Changelog: v1 -> v2
  - Fixed memory allocation failure at boot to do panic with good message.
  - rewrote charge/uncharge path (no changes in logic.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/mm_types.h    |    4 
 include/linux/page_cgroup.h |   89 +++++++++++++++
 mm/Makefile                 |    2 
 mm/memcontrol.c             |  251 +++++++++++---------------------------------
 mm/page_alloc.c             |    9 -
 mm/page_cgroup.c            |  235 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 394 insertions(+), 196 deletions(-)

Index: mmotm-2.6.27-rc6+/mm/page_cgroup.c
===================================================================
--- /dev/null
+++ mmotm-2.6.27-rc6+/mm/page_cgroup.c
@@ -0,0 +1,235 @@
+#include <linux/mm.h>
+#include <linux/rcupdate.h>
+#include <linux/rculist.h>
+#include <linux/bootmem.h>
+#include <linux/bit_spinlock.h>
+#include <linux/page_cgroup.h>
+#include <linux/hash.h>
+#include <linux/memory.h>
+
+
+
+struct pcg_hash_head {
+	spinlock_t		lock;
+	struct hlist_head	head;
+};
+
+static struct pcg_hash_head	*pcg_hashtable __read_mostly;
+
+struct pcg_hash {
+	struct hlist_node	node;
+	unsigned long		index;
+	struct page_cgroup	*map;
+};
+
+#if BITS_PER_LONG == 32 /* we use kmalloc() */
+#define ENTS_PER_CHUNK_SHIFT	(7)
+const bool chunk_vmalloc = false;
+#else /* we'll use vmalloc */
+#ifdef SECTION_SIZE_BITS
+#define ENTS_PER_CHUNK_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
+#else
+#define ENTS_PER_CHUNK_SHIFT	(14) /* covers 128MB on x86-64 */
+#endif
+const bool chunk_vmalloc = true;
+#endif
+
+#define ENTS_PER_CHUNK		(1 << (ENTS_PER_CHUNK_SHIFT))
+#define ENTS_PER_CHUNK_MASK	(ENTS_PER_CHUNK - 1)
+
+static int pcg_hashshift __read_mostly;
+static int pcg_hashmask  __read_mostly;
+
+#define PCG_HASHSHIFT		(pcg_hashshift)
+#define PCG_HASHMASK		(pcg_hashmask)
+#define PCG_HASHSIZE		(1 << pcg_hashshift)
+
+static int pcg_hashfun(unsigned long index)
+{
+	return hash_long(index, pcg_hashshift);
+}
+
+struct page_cgroup *lookup_page_cgroup(unsigned long pfn)
+{
+	unsigned long index = pfn >> ENTS_PER_CHUNK_SHIFT;
+	struct pcg_hash *ent;
+	struct pcg_hash_head *head;
+	struct hlist_node *node;
+	struct page_cgroup *pc = NULL;
+	int hnum;
+
+	hnum = pcg_hashfun(index);
+	head = pcg_hashtable + hnum;
+	rcu_read_lock();
+	hlist_for_each_entry(ent, node, &head->head, node) {
+		if (ent->index == index) {
+			pc = ent->map + pfn;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return pc;
+}
+
+static int __meminit alloc_page_cgroup(int node, unsigned long index)
+{
+	struct pcg_hash *ent;
+	struct pcg_hash_head *head;
+	struct page_cgroup *pc;
+	unsigned long flags, base;
+	int hnum, i;
+	int mapsize = sizeof(struct page_cgroup) * ENTS_PER_CHUNK;
+
+	if (lookup_page_cgroup(index << ENTS_PER_CHUNK_SHIFT))
+		return 0;
+
+	if (!chunk_vmalloc) {
+		int ent_size = sizeof(*ent) + mapsize;
+		ent = kmalloc_node(ent_size, GFP_KERNEL, node);
+		if (!ent)
+			return 1;
+		pc = (void *)(ent + 1);
+	} else {
+		ent = kmalloc_node(sizeof(*ent), GFP_KERNEL, node);
+		if (!ent)
+			return 1;
+		pc =  vmalloc_node(mapsize, node);
+		if (!pc) {
+			kfree(ent);
+			return 1;
+		}
+	}
+	ent->map = pc - (index << ENTS_PER_CHUNK_SHIFT);
+	ent->index = index;
+	INIT_HLIST_NODE(&ent->node);
+
+	for (base = index << ENTS_PER_CHUNK_SHIFT, i = 0;
+		i < ENTS_PER_CHUNK; i++) {
+		unsigned long pfn = base + i;
+		pc = ent->map + pfn;
+		pc->page = pfn_to_page(pfn);
+		pc->mem_cgroup = NULL;
+		pc->flags = 0;
+	}
+
+	hnum = pcg_hashfun(index);
+	head = &pcg_hashtable[hnum];
+	spin_lock_irqsave(&head->lock, flags);
+	hlist_add_head_rcu(&ent->node, &head->head);
+	spin_unlock_irqrestore(&head->lock, flags);
+	return 0;
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+
+int online_page_cgroup(unsigned long start_pfn,
+			unsigned long nr_pages,
+			int nid)
+{
+	unsigned long index, end_pfn, start, end;
+	int fail = 0;
+
+	end_pfn = start_pfn + nr_pages;
+	start = start_pfn >> ENTS_PER_CHUNK_SHIFT;
+	end = (end_pfn + ENTS_PER_CHUNK - 1) >> ENTS_PER_CHUNK_SHIFT;
+
+	for (index = start; (!fail) && (index < end); index++) {
+		unsigned long pfn = index << ENTS_PER_CHUNK_SHIFT;
+		if (lookup_page_cgroup(pfn))
+			continue;
+		fail = alloc_page_cgroup(nid, index);
+	}
+	return fail;
+}
+
+static int pcg_memory_callback(struct notifier_block *self,
+			       unsigned long action, void *arg)
+{
+	struct memory_notify *mn = arg;
+	int ret = 0;
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = online_page_cgroup(mn->start_pfn,
+				   mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_GOING_OFFLINE:
+		break;
+	case MEM_CANCEL_ONLINE:
+	case MEM_OFFLINE:
+        case MEM_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		break;
+	}
+	ret = notifier_from_errno(ret);
+	return ret;
+}
+
+#endif
+
+/* Called From mem_cgroup's initilization */
+void __init page_cgroup_init(void)
+{
+	struct pcg_hash_head *head;
+	int node, i, fail;
+	unsigned long start, pfn, end, index, offset;
+	long default_pcg_hash_size;
+
+	/* we don't need too large hash */
+	default_pcg_hash_size = (max_pfn/ENTS_PER_CHUNK);
+	default_pcg_hash_size *= 2;
+	/* if too big, use automatic calclation */
+	if (default_pcg_hash_size > 1024 * 1024)
+		default_pcg_hash_size = 0;
+
+	pcg_hashtable = alloc_large_system_hash("PageCgroup Hash",
+				sizeof(struct pcg_hash_head),
+				default_pcg_hash_size,
+				13,
+				0,
+				&pcg_hashshift,
+				&pcg_hashmask,
+				0);
+	if (!pcg_hashtable) {
+		fail = 1;
+		goto nomem;
+	}
+
+	for (i = 0; i < PCG_HASHSIZE; i++) {
+		head = &pcg_hashtable[i];
+		spin_lock_init(&head->lock);
+		INIT_HLIST_HEAD(&head->head);
+	}
+
+	fail = 0;
+	for_each_node(node) {
+		start = NODE_DATA(node)->node_start_pfn;
+		end = start + NODE_DATA(node)->node_spanned_pages;
+		start >>= ENTS_PER_CHUNK_SHIFT;
+		end = (end  + ENTS_PER_CHUNK - 1) >> ENTS_PER_CHUNK_SHIFT;
+		for (index = start; (!fail) && (index < end); index++) {
+			pfn = index << ENTS_PER_CHUNK_SHIFT;
+			/*
+			 * In usual, this loop breaks at offset=0.
+			 * Handle a case a hole in MAX_ORDER (ia64 only...)
+			 */
+			for (offset = 0; offset < ENTS_PER_CHUNK; offset++) {
+				if (pfn_valid(pfn + offset)) {
+					fail = alloc_page_cgroup(node, index);
+					break;
+				}
+			}
+		}
+		if (fail)
+			break;
+	}
+
+	hotplug_memory_notifier(pcg_memory_callback, 0);
+nomem:
+	if (fail) {
+		printk("Not enough memory for memory resource controller.\n");
+		panic("please try cgroup_disable=memory boot option.");
+	}
+	return;
+}
+
+
Index: mmotm-2.6.27-rc6+/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.27-rc6+.orig/include/linux/mm_types.h
+++ mmotm-2.6.27-rc6+/include/linux/mm_types.h
@@ -94,10 +94,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
-#endif
-
 #ifdef CONFIG_KMEMCHECK
 	void *shadow;
 #endif
Index: mmotm-2.6.27-rc6+/mm/Makefile
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/Makefile
+++ mmotm-2.6.27-rc6+/mm/Makefile
@@ -34,6 +34,6 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_CGROUP_MEMRLIMIT_CTLR) += memrlimitcgroup.o
 obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
Index: mmotm-2.6.27-rc6+/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ mmotm-2.6.27-rc6+/include/linux/page_cgroup.h
@@ -0,0 +1,89 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+
+/*
+ * Page Cgroup can be considered as an extended mem_map.
+ * A page_cgroup page is associated with every page descriptor. The
+ * page_cgroup helps us identify information about the cgroup
+ * All page cgroups are allocated at boot or memory hotplug event,
+ * then the page cgroup for pfn always exists.
+ */
+struct page_cgroup {
+	unsigned long flags;
+	struct mem_cgroup *mem_cgroup;
+	struct page *page;
+	struct list_head lru;		/* per cgroup LRU list */
+};
+
+void __init page_cgroup_init(void);
+struct page_cgroup *lookup_page_cgroup(unsigned long pfn);
+
+enum {
+	/* flags for mem_cgroup */
+	PCG_LOCK,  /* page cgroup is locked */
+	PCG_CACHE, /* charged as cache */
+	PCG_USED, /* this object is in use. */
+	/* flags for LRU placement */
+	PCG_ACTIVE, /* page is active in this cgroup */
+	PCG_FILE, /* page is file system backed */
+	PCG_UNEVICTABLE, /* page is unevictableable */
+};
+
+#define TESTPCGFLAG(uname, lname)			\
+static inline int PageCgroup##uname(struct page_cgroup *pc)	\
+	{ return test_bit(PCG_##lname, &pc->flags); }
+
+#define SETPCGFLAG(uname, lname)			\
+static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
+	{ set_bit(PCG_##lname, &pc->flags);  }
+
+#define CLEARPCGFLAG(uname, lname)			\
+static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
+	{ clear_bit(PCG_##lname, &pc->flags);  }
+
+/* Cache flag is set only once (at allocation) */
+TESTPCGFLAG(Cache, CACHE)
+
+TESTPCGFLAG(Used, USED)
+CLEARPCGFLAG(Used, USED)
+
+/* LRU management flags (from global-lru definition) */
+TESTPCGFLAG(File, FILE)
+SETPCGFLAG(File, FILE)
+CLEARPCGFLAG(File, FILE)
+
+TESTPCGFLAG(Active, ACTIVE)
+SETPCGFLAG(Active, ACTIVE)
+CLEARPCGFLAG(Active, ACTIVE)
+
+TESTPCGFLAG(Unevictable, UNEVICTABLE)
+SETPCGFLAG(Unevictable, UNEVICTABLE)
+CLEARPCGFLAG(Unevictable, UNEVICTABLE)
+
+static inline int page_cgroup_nid(struct page_cgroup *pc)
+{
+	return page_to_nid(pc->page);
+}
+
+static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
+{
+	return page_zonenum(pc->page);
+}
+
+static inline void lock_page_cgroup(struct page_cgroup *pc)
+{
+	bit_spin_lock(PCG_LOCK, &pc->flags);
+}
+
+static inline int trylock_page_cgroup(struct page_cgroup *pc)
+{
+	return bit_spin_trylock(PCG_LOCK, &pc->flags);
+}
+
+static inline void unlock_page_cgroup(struct page_cgroup *pc)
+{
+	bit_spin_unlock(PCG_LOCK, &pc->flags);
+}
+
+
+#endif
Index: mmotm-2.6.27-rc6+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc6+/mm/memcontrol.c
@@ -34,11 +34,11 @@
 #include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
-static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
 /*
@@ -138,80 +138,6 @@ static struct mem_cgroup init_mem_cgroup
 
 #define is_root_cgroup(cgrp)	((cgrp) == &init_mem_cgroup)
 
-
-/*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	unsigned long flags;
-};
-
-enum {
-	/* flags for mem_cgroup */
-	PCG_CACHE, /* charged as cache */
-	/* flags for LRU placement */
-	PCG_ACTIVE, /* page is active in this cgroup */
-	PCG_FILE, /* page is file system backed */
-	PCG_UNEVICTABLE, /* page is unevictableable */
-};
-
-#define TESTPCGFLAG(uname, lname)			\
-static inline int PageCgroup##uname(struct page_cgroup *pc)	\
-	{ return test_bit(PCG_##lname, &pc->flags); }
-
-#define SETPCGFLAG(uname, lname)			\
-static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
-	{ set_bit(PCG_##lname, &pc->flags);  }
-
-#define CLEARPCGFLAG(uname, lname)			\
-static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
-	{ clear_bit(PCG_##lname, &pc->flags);  }
-
-
-/* Cache flag is set only once (at allocation) */
-TESTPCGFLAG(Cache, CACHE)
-
-/* LRU management flags (from global-lru definition) */
-TESTPCGFLAG(File, FILE)
-SETPCGFLAG(File, FILE)
-CLEARPCGFLAG(File, FILE)
-
-TESTPCGFLAG(Active, ACTIVE)
-SETPCGFLAG(Active, ACTIVE)
-CLEARPCGFLAG(Active, ACTIVE)
-
-TESTPCGFLAG(Unevictable, UNEVICTABLE)
-SETPCGFLAG(Unevictable, UNEVICTABLE)
-CLEARPCGFLAG(Unevictable, UNEVICTABLE)
-
-static int page_cgroup_nid(struct page_cgroup *pc)
-{
-	return page_to_nid(pc->page);
-}
-
-static enum zone_type page_cgroup_zid(struct page_cgroup *pc)
-{
-	return page_zonenum(pc->page);
-}
-
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
@@ -222,9 +148,9 @@ enum charge_type {
 
 static const unsigned long
 pcg_default_flags[NR_CHARGE_TYPE] = {
-	((1 << PCG_CACHE) | (1 << PCG_FILE)),
-	((1 << PCG_ACTIVE)),
-	((1 << PCG_ACTIVE) | (1 << PCG_CACHE)),
+	(1 << PCG_CACHE) | (1 << PCG_FILE) | (1 << PCG_USED) | (1 << PCG_LOCK),
+	(1 << PCG_ACTIVE) | (1 << PCG_LOCK) | (1 << PCG_USED),
+	(1 << PCG_ACTIVE) | (1 << PCG_CACHE) | (1 << PCG_USED)|  (1 << PCG_LOCK),
 	0,
 };
 
@@ -307,37 +233,6 @@ struct mem_cgroup *mem_cgroup_from_task(
 				struct mem_cgroup, css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
-{
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
-}
-
-struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
-}
-
-static void lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
 static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 			struct page_cgroup *pc)
 {
@@ -441,22 +336,19 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	pc = lookup_page_cgroup(page_to_pfn(page));
+
+	if (!trylock_page_cgroup(pc))
 		return;
 
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
 		spin_lock_irqsave(&mz->lru_lock, flags);
-		/*
-		 * check against the race with move_account.
-		 */
-		if (likely(mem == pc->mem_cgroup))
-			__mem_cgroup_move_lists(pc, lru);
+		__mem_cgroup_move_lists(pc, lru);
 		spin_unlock_irqrestore(&mz->lru_lock, flags);
 	}
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 }
 
 /*
@@ -543,6 +435,8 @@ unsigned long mem_cgroup_isolate_pages(u
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
+		if (unlikely(!PageCgroupUsed(pc)))
+			continue;
 		page = pc->page;
 
 		if (unlikely(!PageLRU(page)))
@@ -611,12 +505,12 @@ int mem_cgroup_move_account(struct page 
 		/* Now, we assume no_limit...no failure here. */
 		return ret;
 	}
-	if (!try_lock_page_cgroup(page)) {
+	if (!trylock_page_cgroup(pc)) {
 		res_counter_uncharge(&to->res, PAGE_SIZE);
 		return ret;
 	}
 
-	if (page_get_page_cgroup(page) != pc) {
+	if (!PageCgroupUsed(pc)) {
 		res_counter_uncharge(&to->res, PAGE_SIZE);
 		goto out;
 	}
@@ -634,7 +528,7 @@ int mem_cgroup_move_account(struct page 
 		res_counter_uncharge(&to->res, PAGE_SIZE);
 	}
 out:
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 
 	return ret;
 }
@@ -651,26 +545,27 @@ static int mem_cgroup_charge_common(stru
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
-	unsigned long flags;
 	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup_per_zone *mz;
+	unsigned long flags;
 
-	pc = kmem_cache_alloc(page_cgroup_cache, gfp_mask);
-	if (unlikely(pc == NULL))
-		goto err;
-
+	pc = lookup_page_cgroup(page_to_pfn(page));
+	/* can happen at boot */
+	if (unlikely(!pc))
+		return 0;
+	prefetchw(pc);
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
+
 	if (likely(!memcg)) {
 		rcu_read_lock();
 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
 		if (unlikely(!mem)) {
 			rcu_read_unlock();
-			kmem_cache_free(page_cgroup_cache, pc);
 			return 0;
 		}
 		/*
@@ -706,36 +601,34 @@ static int mem_cgroup_charge_common(stru
 		}
 	}
 
+	preempt_disable();
+	lock_page_cgroup(pc);
+	if (unlikely(PageCgroupUsed(pc))) {
+		unlock_page_cgroup(pc);
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		css_put(&mem->css);
+		preempt_enable();
+		goto done;
+	}
 	pc->mem_cgroup = mem;
-	pc->page = page;
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
 	 */
 	pc->flags = pcg_default_flags[ctype];
 
-	lock_page_cgroup(page);
-	if (unlikely(page_get_page_cgroup(page))) {
-		unlock_page_cgroup(page);
-		res_counter_uncharge(&mem->res, PAGE_SIZE);
-		css_put(&mem->css);
-		kmem_cache_free(page_cgroup_cache, pc);
-		goto done;
-	}
-	page_assign_page_cgroup(page, pc);
-
 	mz = page_cgroup_zoneinfo(pc);
+
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	unlock_page_cgroup(pc);
+	preempt_enable();
 
-	unlock_page_cgroup(page);
 done:
 	return 0;
 out:
 	css_put(&mem->css);
-	kmem_cache_free(page_cgroup_cache, pc);
-err:
 	return -ENOMEM;
 }
 
@@ -743,7 +636,8 @@ int mem_cgroup_charge(struct page *page,
 {
 	if (mem_cgroup_subsys.disabled)
 		return 0;
-
+	if (PageCompound(page))
+		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -764,7 +658,8 @@ int mem_cgroup_cache_charge(struct page 
 {
 	if (mem_cgroup_subsys.disabled)
 		return 0;
-
+	if (PageCompound(page))
+		return 0;
 	/*
 	 * Corner case handling. This is called from add_to_page_cache()
 	 * in usual. But some FS (shmem) precharges this page before calling it
@@ -777,15 +672,16 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
-		if (pc) {
-			VM_BUG_ON(pc->page != page);
-			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
+
+		pc = lookup_page_cgroup(page_to_pfn(page));
+		if (!pc)
+			return 0;
+		lock_page_cgroup(pc);
+		if (PageCgroupUsed(pc)) {
+			unlock_page_cgroup(pc);
 			return 0;
 		}
-		unlock_page_cgroup(page);
+		unlock_page_cgroup(pc);
 	}
 
 	if (unlikely(!mm))
@@ -808,53 +704,46 @@ __mem_cgroup_uncharge_common(struct page
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
 	struct mem_cgroup_per_zone *mz;
+	unsigned long pfn = page_to_pfn(page);
 	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
+	/* check the condition we can know from page */
 
-	/*
-	 * Check if our page_cgroup is valid
-	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (unlikely(!pc))
-		goto unlock;
-
-	VM_BUG_ON(pc->page != page);
+	pc = lookup_page_cgroup(pfn);
+	if (unlikely(!pc || !PageCgroupUsed(pc)))
+		return;
+	preempt_disable();
+	lock_page_cgroup(pc);
+	if (unlikely(page_mapped(page))) {
+		unlock_page_cgroup(pc);
+		preempt_enable();
+		return;
+	}
+	ClearPageCgroupUsed(pc);
+	unlock_page_cgroup(pc);
 
-	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-	    && ((PageCgroupCache(pc) || page_mapped(page))))
-		goto unlock;
-retry:
 	mem = pc->mem_cgroup;
 	mz = page_cgroup_zoneinfo(pc);
+
 	spin_lock_irqsave(&mz->lru_lock, flags);
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED &&
-	    unlikely(mem != pc->mem_cgroup)) {
-		/* MAPPED account can be done without lock_page().
-		   Check race with mem_cgroup_move_account() */
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		goto retry;
-	}
 	__mem_cgroup_remove_list(mz, pc);
 	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-
-
-	res_counter_uncharge(&mem->res, PAGE_SIZE);
+	pc->mem_cgroup = NULL;
 	css_put(&mem->css);
+	preempt_enable();
+	res_counter_uncharge(&mem->res, PAGE_SIZE);
 
-	kmem_cache_free(page_cgroup_cache, pc);
 	return;
-unlock:
-	unlock_page_cgroup(page);
 }
 
 void mem_cgroup_uncharge_page(struct page *page)
 {
+	if (page_mapped(page))
+		return;
+	if (page->mapping && !PageAnon(page))
+		return;
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
@@ -878,9 +767,9 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	pc = lookup_page_cgroup(page_to_pfn(page));
+	lock_page_cgroup(pc);
+	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (PageCgroupCache(pc)) {
@@ -890,7 +779,7 @@ int mem_cgroup_prepare_migration(struct 
 				ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 		}
 	}
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
@@ -1271,8 +1160,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
+		page_cgroup_init();
 		mem = &init_mem_cgroup;
-		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
Index: mmotm-2.6.27-rc6+/mm/page_alloc.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/page_alloc.c
+++ mmotm-2.6.27-rc6+/mm/page_alloc.c
@@ -223,17 +223,12 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	void *pc = page_get_page_cgroup(page);
-
 	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
 		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
-	if (pc) {
-		printk(KERN_EMERG "cgroup:%p\n", pc);
-		page_reset_bad_cgroup(page);
-	}
+
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
@@ -472,7 +467,6 @@ static inline void free_pages_check(stru
 	free_page_mlock(page);
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
 		bad_page(page);
@@ -609,7 +603,6 @@ static void prep_new_page(struct page *p
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP)))
 		bad_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
