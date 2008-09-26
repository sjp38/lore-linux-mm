Date: Fri, 26 Sep 2008 11:21:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH(fixed) 9/12] memcg allocate all page_cgroup at boot
Message-Id: <20080926112156.991c5dc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925153206.281243dc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Because of terrible compile error in FLATMEM/DISCONTIGMEM, I post
fixed version (and avoid patch bomb again.)
I post replacements for 9(fix), and 10,11,12 (adjustment for HUNK).

==
Allocate all page_cgroup at boot and remove page_cgroup poitner
from struct page. This patch adds an interface as

 struct page_cgroup *lookup_page_cgroup(struct page*)

All FLATMEM/DISCONTIGMEM/SPARSEMEM  and MEMORY_HOTPLUG is supported.

Remove page_cgroup pointer reduces the amount of memory by
 - 4 bytes per PAGE_SIZE.
 - 8 bytes per PAGE_SIZE
if memory controller is disabled. (even if configured.)

On usual 8GB x86-32 server, this saves 8MB of NORMAL_ZONE memory.
On my x86-64 server with 48GB of memory, this saves 96MB of memory.
I think this reduction makes sense.

By pre-allocation, kmalloc/kfree in charge/uncharge are removed. 
This means
  - we're not necessary to be afraid of kmalloc faiulre.
    (this can happen because of gfp_mask type.)
  - we can avoid calling kmalloc/kfree.
  - we can avoid allocating tons of small objects which can be fragmented.
  - we can know what amount of memory will be used for this extra-lru handling.

I added printk message as

	"allocated %ld bytes of page_cgroup"
        "please try cgroup_disable=memory option if you don't want"

maybe enough informative for users.

TODO:
  - small race window still remains in do_swap_page(). will be fixed by
    later patch in series.

Changelog: v5 -> v6.
 * removed "ctype" from uncharge.
 * improved comment to show FLAT_NODE_MEM_MAP == !SPARSEMEM
 * fixed errors in !SPARSEMEM codes
 * removed unused function in !SPARSEMEM codes.
(start from v5 because of series..)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/memcontrol.h  |   11 -
 include/linux/mm_types.h    |    4 
 include/linux/mmzone.h      |   14 ++
 include/linux/page_cgroup.h |   90 +++++++++++++++
 mm/Makefile                 |    2 
 mm/memcontrol.c             |  264 ++++++++++++--------------------------------
 mm/page_alloc.c             |   12 --
 mm/page_cgroup.c            |  235 +++++++++++++++++++++++++++++++++++++++
 8 files changed, 416 insertions(+), 216 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/page_cgroup.c
===================================================================
--- /dev/null
+++ mmotm-2.6.27-rc7+/mm/page_cgroup.c
@@ -0,0 +1,235 @@
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/bootmem.h>
+#include <linux/bit_spinlock.h>
+#include <linux/page_cgroup.h>
+#include <linux/hash.h>
+#include <linux/memory.h>
+
+static void __meminit
+__init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
+{
+	pc->flags = 0;
+	pc->mem_cgroup = NULL;
+	pc->page = pfn_to_page(pfn);
+}
+static unsigned long total_usage = 0;
+
+#if !defined(CONFIG_SPARSEMEM)
+
+
+void __init pgdat_page_cgroup_init(struct pglist_data *pgdat)
+{
+	pgdat->node_page_cgroup = NULL;
+}
+
+struct page_cgroup *lookup_page_cgroup(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long offset;
+	struct page_cgroup *base;
+
+	base = NODE_DATA(page_to_nid(page))->node_page_cgroup;
+	if (unlikely(!base))
+		return NULL;
+
+	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
+	return base + offset;
+}
+
+static int __init alloc_node_page_cgroup(int nid)
+{
+	struct page_cgroup *base, *pc;
+	unsigned long table_size;
+	unsigned long start_pfn, nr_pages, index;
+
+	start_pfn = NODE_DATA(nid)->node_start_pfn;
+	nr_pages = NODE_DATA(nid)->node_spanned_pages;
+
+	table_size = sizeof(struct page_cgroup) * nr_pages;
+
+	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
+			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	if (!base)
+		return -ENOMEM;
+	for (index = 0; index < nr_pages; index++) {
+		pc = base + index;
+		__init_page_cgroup(pc, start_pfn + index);
+	}
+	NODE_DATA(nid)->node_page_cgroup = base;
+	total_usage += table_size;
+	return 0;
+}
+
+void __init page_cgroup_init(void)
+{
+
+	int nid, fail;
+
+	for_each_online_node(nid)  {
+		fail = alloc_node_page_cgroup(nid);
+		if (fail)
+			goto fail;
+	}
+	printk("allocated %ld bytes of page_cgroup\n", total_usage);
+	printk("please try cgroup_disable=memory option if you don't want\n");
+	return;
+fail:
+	printk("allocation of page_cgroup was failed.\n");
+	printk("please try cgroup_disable=memory boot option\n");
+	panic("Out of memory");
+}
+
+#else /* CONFIG_FLAT_NODE_MEM_MAP */
+
+struct page_cgroup *lookup_page_cgroup(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct mem_section *section = __pfn_to_section(pfn);
+
+	return section->page_cgroup + pfn;
+}
+
+int __meminit init_section_page_cgroup(unsigned long pfn)
+{
+	struct mem_section *section;
+	struct page_cgroup *base, *pc;
+	unsigned long table_size;
+	int nid, index;
+
+	section = __pfn_to_section(pfn);
+
+	if (section->page_cgroup)
+		return 0;
+
+	nid = page_to_nid(pfn_to_page(pfn));
+
+	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
+	base = kmalloc_node(table_size, GFP_KERNEL, nid);
+	if (!base)
+		base = vmalloc_node(table_size, nid);
+
+	if (!base) {
+		printk("page cgroup allocation failure\n");
+		return -ENOMEM;
+	}
+
+	for (index = 0; index < PAGES_PER_SECTION; index++) {
+		pc = base + index;
+		__init_page_cgroup(pc, pfn + index);
+	}
+
+	section = __pfn_to_section(pfn);
+	section->page_cgroup = base - pfn;
+	total_usage += table_size;
+	return 0;
+}
+#ifdef CONFIG_MEMORY_HOTPLUG
+void __free_page_cgroup(unsigned long pfn)
+{
+	struct mem_section *ms;
+	struct page_cgroup *base;
+
+	ms = __pfn_to_section(pfn);
+	if (!ms || !ms->page_cgroup)
+		return;
+	base = ms->page_cgroup + pfn;
+	ms->page_cgroup = NULL;
+	if (is_vmalloc_addr(base))
+		vfree(base);
+	else
+		kfree(base);
+}
+
+int online_page_cgroup(unsigned long start_pfn,
+			unsigned long nr_pages,
+			int nid)
+{
+	unsigned long start, end, pfn;
+	int fail = 0;
+
+	start = start_pfn & (PAGES_PER_SECTION - 1);
+	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
+
+	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
+		if (!pfn_present(pfn))
+			continue;
+		fail = init_section_page_cgroup(pfn);
+	}
+	if (!fail)
+		return 0;
+
+	/* rollback */
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
+		__free_page_cgroup(pfn);
+
+	return -ENOMEM;
+}
+
+int offline_page_cgroup(unsigned long start_pfn,
+		unsigned long nr_pages, int nid)
+{
+	unsigned long start, end, pfn;
+
+	start = start_pfn & (PAGES_PER_SECTION - 1);
+	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
+
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
+                __free_page_cgroup(pfn);
+	return 0;
+
+}
+
+static int page_cgroup_callback(struct notifier_block *self,
+			       unsigned long action, void *arg)
+{
+	struct memory_notify *mn = arg;
+	int ret = 0;
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = online_page_cgroup(mn->start_pfn,
+				   mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_CANCEL_ONLINE:
+	case MEM_OFFLINE:
+		offline_page_cgroup(mn->start_pfn,
+				mn->nr_pages, mn->status_change_nid);
+		break;
+	case MEM_GOING_OFFLINE:
+		break;
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
+void __init page_cgroup_init(void)
+{
+	unsigned long pfn;
+	int fail = 0;
+
+	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
+		if (!pfn_present(pfn))
+			continue;
+		fail = init_section_page_cgroup(pfn);
+	}
+	if (fail) {
+		printk("please try cgroup_disable=memory boot option\n");
+		panic("Out of memory");
+	} else {
+		hotplug_memory_notifier(page_cgroup_callback, 0);
+	}
+	printk("allocated %ld bytes of page_cgroup\n", total_usage);
+	printk("please try cgroup_disable=memory option if you don't want\n");
+}
+
+void __init pgdat_page_cgroup_init(struct pglist_data *pgdat)
+{
+	return;
+}
+
+#endif
Index: mmotm-2.6.27-rc7+/include/linux/mm_types.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/mm_types.h
+++ mmotm-2.6.27-rc7+/include/linux/mm_types.h
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
Index: mmotm-2.6.27-rc7+/mm/Makefile
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/Makefile
+++ mmotm-2.6.27-rc7+/mm/Makefile
@@ -34,6 +34,6 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_CGROUP_MEMRLIMIT_CTLR) += memrlimitcgroup.o
 obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
Index: mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ mmotm-2.6.27-rc7+/include/linux/page_cgroup.h
@@ -0,0 +1,90 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+#include <linux/bit_spinlock.h>
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
+void __init pgdat_page_cgroup_init(struct pglist_data *pgdat);
+void __init page_cgroup_init(void);
+struct page_cgroup *lookup_page_cgroup(struct page *page);
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
Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -35,11 +35,11 @@
 #include <linux/vmalloc.h>
 #include <linux/mm_inline.h>
 #include <linux/writeback.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/uaccess.h>
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
-static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
 /*
@@ -139,94 +139,18 @@ static struct mem_cgroup init_mem_cgroup
 
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
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
-	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	NR_CHARGE_TYPE,
 };
 
 static const unsigned long
 pcg_default_flags[NR_CHARGE_TYPE] = {
-	((1 << PCG_CACHE) | (1 << PCG_FILE)),
-	((1 << PCG_ACTIVE)),
-	((1 << PCG_ACTIVE) | (1 << PCG_CACHE)),
-	0,
+	(1 << PCG_CACHE) | (1 << PCG_FILE) | (1 << PCG_USED) | (1 << PCG_LOCK),
+	(1 << PCG_ACTIVE) | (1 << PCG_LOCK) | (1 << PCG_USED),
+	(1 << PCG_ACTIVE) | (1 << PCG_CACHE) | (1 << PCG_USED)|  (1 << PCG_LOCK),
 };
 
 /*
@@ -308,37 +232,6 @@ struct mem_cgroup *mem_cgroup_from_task(
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
@@ -442,22 +335,19 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	pc = lookup_page_cgroup(page);
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
@@ -544,6 +434,8 @@ unsigned long mem_cgroup_isolate_pages(u
 	list_for_each_entry_safe_reverse(pc, tmp, src, lru) {
 		if (scan >= nr_to_scan)
 			break;
+		if (unlikely(!PageCgroupUsed(pc)))
+			continue;
 		page = pc->page;
 
 		if (unlikely(!PageLRU(page)))
@@ -611,12 +503,12 @@ int mem_cgroup_move_account(struct page 
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
@@ -634,7 +526,7 @@ int mem_cgroup_move_account(struct page 
 		res_counter_uncharge(&to->res, PAGE_SIZE);
 	}
 out:
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 
 	return ret;
 }
@@ -651,26 +543,27 @@ static int mem_cgroup_charge_common(stru
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
+	pc = lookup_page_cgroup(page);
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
@@ -706,36 +599,34 @@ static int mem_cgroup_charge_common(stru
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
 
@@ -743,7 +634,8 @@ int mem_cgroup_charge(struct page *page,
 {
 	if (mem_cgroup_subsys.disabled)
 		return 0;
-
+	if (PageCompound(page))
+		return 0;
 	/*
 	 * If already mapped, we don't have to account.
 	 * If page cache, page->mapping has address_space.
@@ -764,7 +656,8 @@ int mem_cgroup_cache_charge(struct page 
 {
 	if (mem_cgroup_subsys.disabled)
 		return 0;
-
+	if (PageCompound(page))
+		return 0;
 	/*
 	 * Corner case handling. This is called from add_to_page_cache()
 	 * in usual. But some FS (shmem) precharges this page before calling it
@@ -777,15 +670,16 @@ int mem_cgroup_cache_charge(struct page 
 	if (!(gfp_mask & __GFP_WAIT)) {
 		struct page_cgroup *pc;
 
-		lock_page_cgroup(page);
-		pc = page_get_page_cgroup(page);
-		if (pc) {
-			VM_BUG_ON(pc->page != page);
-			VM_BUG_ON(!pc->mem_cgroup);
-			unlock_page_cgroup(page);
+
+		pc = lookup_page_cgroup(page);
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
@@ -803,7 +697,7 @@ int mem_cgroup_cache_charge(struct page 
  * uncharge if !page_mapped(page)
  */
 static void
-__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
+__mem_cgroup_uncharge_common(struct page *page)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem;
@@ -812,57 +706,44 @@ __mem_cgroup_uncharge_common(struct page
 
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
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc || !PageCgroupUsed(pc)))
+		return;
+	preempt_disable();
+	lock_page_cgroup(pc);
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
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+	if (page_mapped(page))
+		return;
+	if (page->mapping && !PageAnon(page))
+		return;
+	__mem_cgroup_uncharge_common(page);
 }
 
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON(page_mapped(page));
 	VM_BUG_ON(page->mapping);
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
+	__mem_cgroup_uncharge_common(page);
 }
 
 /*
@@ -878,9 +759,9 @@ int mem_cgroup_prepare_migration(struct 
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	pc = lookup_page_cgroup(page);
+	lock_page_cgroup(pc);
+	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
 		if (PageCgroupCache(pc)) {
@@ -890,7 +771,7 @@ int mem_cgroup_prepare_migration(struct 
 				ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 		}
 	}
-	unlock_page_cgroup(page);
+	unlock_page_cgroup(pc);
 	if (mem) {
 		ret = mem_cgroup_charge_common(newpage, NULL, GFP_KERNEL,
 			ctype, mem);
@@ -914,8 +795,7 @@ void mem_cgroup_end_migration(struct pag
 	 *    care it.
 	 */
 	if (!newpage->mapping)
-		__mem_cgroup_uncharge_common(newpage,
-					 MEM_CGROUP_CHARGE_TYPE_FORCE);
+		__mem_cgroup_uncharge_common(newpage);
 	else if (PageAnon(newpage))
 		mem_cgroup_uncharge_page(newpage);
 }
@@ -997,6 +877,8 @@ static void mem_cgroup_force_empty_list(
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	list_for_each_entry_safe(pc, tmp, list, lru) {
 		page = pc->page;
+		if (!PageCgroupUsed(pc))
+			continue;
 		/* For avoiding race with speculative page cache handling. */
 		if (!PageLRU(page) || !get_page_unless_zero(page)) {
 			continue;
@@ -1270,8 +1152,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
+		page_cgroup_init();
 		mem = &init_mem_cgroup;
-		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
Index: mmotm-2.6.27-rc7+/mm/page_alloc.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/page_alloc.c
+++ mmotm-2.6.27-rc7+/mm/page_alloc.c
@@ -44,7 +44,7 @@
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
-#include <linux/memcontrol.h>
+#include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
 
 #include <asm/tlbflush.h>
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
@@ -3495,6 +3488,7 @@ static void __paginginit free_area_init_
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;
+	pgdat_page_cgroup_init(pgdat);
 	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
Index: mmotm-2.6.27-rc7+/include/linux/mmzone.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/mmzone.h
+++ mmotm-2.6.27-rc7+/include/linux/mmzone.h
@@ -602,8 +602,11 @@ typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
 	struct zonelist node_zonelists[MAX_ZONELISTS];
 	int nr_zones;
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
+#ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
 	struct page *node_mem_map;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	struct page_cgroup *node_page_cgroup;
+#endif
 #endif
 	struct bootmem_data *bdata;
 #ifdef CONFIG_MEMORY_HOTPLUG
@@ -932,6 +935,7 @@ static inline unsigned long early_pfn_to
 #endif
 
 struct page;
+struct page_cgroup;
 struct mem_section {
 	/*
 	 * This is, logically, a pointer to an array of struct
@@ -949,6 +953,14 @@ struct mem_section {
 
 	/* See declaration of similar field in struct zone */
 	unsigned long *pageblock_flags;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	/*
+  	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
+	 * section. (see memcontrol.h/page_cgroup.h about this.)
+	 */
+	struct page_cgroup *page_cgroup;
+	unsigned long pad;
+#endif
 };
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
Index: mmotm-2.6.27-rc7+/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.27-rc7+.orig/include/linux/memcontrol.h
+++ mmotm-2.6.27-rc7+/include/linux/memcontrol.h
@@ -29,7 +29,6 @@ struct mm_struct;
 
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -72,16 +71,8 @@ extern void mem_cgroup_record_reclaim_pr
 extern long mem_cgroup_calc_reclaim(struct mem_cgroup *mem, struct zone *zone,
 					int priority, enum lru_list lru);
 
-#else /* CONFIG_CGROUP_MEM_RES_CTLR */
-static inline void page_reset_bad_cgroup(struct page *page)
-{
-}
-
-static inline struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return NULL;
-}
 
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline int mem_cgroup_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
