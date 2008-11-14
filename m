Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAEAJa6p012628
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 Nov 2008 19:19:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 492C745DD7A
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:19:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2398A45DD79
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:19:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3871DB8043
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:19:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 251F01DB8041
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:19:35 +0900 (JST)
Date: Fri, 14 Nov 2008 19:18:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 6/9] memcg : swap cgroup for remembering usage
Message-Id: <20081114191855.9b5181a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

For accounting swap, we need a record per swap entry, at least.

This patch adds following function.
  - swap_cgroup_swapon() .... called from swapon
  - swap_cgroup_swapoff() ... called at the end of swapoff.

  - swap_cgroup_record() .... record information of swap entry.
  - swap_cgroup_lookup() .... lookup information of swap entry.

This patch just implements "how to record information". No actual
method for limit the usage of swap. These routine uses flat table
to record and lookup. "wise" lookup system like radix-tree requires
requires memory allocation at new records but swap-out is usually
called under memory shortage (or memcg hits limit.)
So, I used static allocation. (maybe dynamic allocation is not very
hard but it adds additional memory allocation in memory shortage path.)


Note1: In this, we use pointer to record information and this means
      8bytes per swap entry. I think we can reduce this when we
      create "id of cgroup" in the range of 0-65535 or 0-255.

Note2: array of swap_cgroup is allocated from HIGHMEM. maybe good for x86-32.

Changelog: v2 -> v3
 - fixed typo

Changelog: v1 -> v2
 - fixed bug in swapoff.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/page_cgroup.h |   35 +++++++
 mm/page_cgroup.c            |  201 ++++++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c               |    8 +
 3 files changed, 244 insertions(+)

Index: mmotm-2.6.28-Nov13/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Nov13.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Nov13/mm/page_cgroup.c
@@ -8,6 +8,8 @@
 #include <linux/memory.h>
 #include <linux/vmalloc.h>
 #include <linux/cgroup.h>
+#include <linux/swapops.h>
+#include <linux/highmem.h>
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
@@ -266,3 +268,202 @@ void __init pgdat_page_cgroup_init(struc
 }
 
 #endif
+
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+
+DEFINE_MUTEX(swap_cgroup_mutex);
+struct swap_cgroup_ctrl {
+	spinlock_t lock;
+	struct page **map;
+	unsigned long length;
+};
+
+struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
+
+/*
+ * This 8bytes seems big..maybe we can reduce this when we can use "id" for
+ * cgroup rather than pointer.
+ */
+struct swap_cgroup {
+	struct mem_cgroup	*val;
+};
+#define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
+#define SC_POS_MASK	(SC_PER_PAGE - 1)
+
+/*
+ * allocate buffer for swap_cgroup.
+ */
+static int swap_cgroup_prepare(int type)
+{
+	struct page *page;
+	struct swap_cgroup_ctrl *ctrl;
+	unsigned long idx, max;
+
+	if (!do_swap_account)
+		return 0;
+	ctrl = &swap_cgroup_ctrl[type];
+
+	for (idx = 0; idx < ctrl->length; idx++) {
+		page = alloc_page(GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
+		if (!page)
+			goto not_enough_page;
+		ctrl->map[idx] = page;
+	}
+	return 0;
+not_enough_page:
+	max = idx;
+	for (idx = 0; idx < max; idx++)
+		__free_page(ctrl->map[idx]);
+
+	return -ENOMEM;
+}
+
+/**
+ * swap_cgroup_record - record mem_cgroup for this swp_entry.
+ * @ent: swap entry to be recorded into
+ * @mem: mem_cgroup to be recorded
+ *
+ * Returns old value at success, NULL at failure.
+ * (Of course, old value can be NULL.)
+ */
+struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
+{
+	unsigned long flags;
+	int type = swp_type(ent);
+	unsigned long offset = swp_offset(ent);
+	unsigned long idx = offset / SC_PER_PAGE;
+	unsigned long pos = offset & SC_POS_MASK;
+	struct swap_cgroup_ctrl *ctrl;
+	struct page *mappage;
+	struct swap_cgroup *sc;
+	struct mem_cgroup *old;
+
+	if (!do_swap_account)
+		return NULL;
+
+	ctrl = &swap_cgroup_ctrl[type];
+
+	mappage = ctrl->map[idx];
+	spin_lock_irqsave(&ctrl->lock, flags);
+	sc = kmap_atomic(mappage, KM_USER0);
+	sc += pos;
+	old = sc->val;
+	sc->val = mem;
+	kunmap_atomic(mappage, KM_USER0);
+	spin_unlock_irqrestore(&ctrl->lock, flags);
+	return old;
+}
+
+/**
+ * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
+ * @ent: swap entry to be looked up.
+ *
+ * Returns pointer to mem_cgroup at success. NULL at failure.
+ */
+struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
+{
+	int type = swp_type(ent);
+	unsigned long flags;
+	unsigned long offset = swp_offset(ent);
+	unsigned long idx = offset / SC_PER_PAGE;
+	unsigned long pos = offset & SC_POS_MASK;
+	struct swap_cgroup_ctrl *ctrl;
+	struct page *mappage;
+	struct swap_cgroup *sc;
+	struct mem_cgroup *ret;
+
+	if (!do_swap_account)
+		return NULL;
+
+	ctrl = &swap_cgroup_ctrl[type];
+
+	mappage = ctrl->map[idx];
+
+	spin_lock_irqsave(&ctrl->lock, flags);
+	sc = kmap_atomic(mappage, KM_USER0);
+	sc += pos;
+	ret = sc->val;
+	kunmap_atomic(mappage, KM_USER0);
+	spin_unlock_irqrestore(&ctrl->lock, flags);
+	return ret;
+}
+
+int swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	void *array;
+	unsigned long array_size;
+	unsigned long length;
+	struct swap_cgroup_ctrl *ctrl;
+
+	if (!do_swap_account)
+		return 0;
+
+	length = ((max_pages/SC_PER_PAGE) + 1);
+	array_size = length * sizeof(void *);
+
+	array = vmalloc(array_size);
+	if (!array)
+		goto nomem;
+
+	memset(array, 0, array_size);
+	ctrl = &swap_cgroup_ctrl[type];
+	mutex_lock(&swap_cgroup_mutex);
+	ctrl->length = length;
+	ctrl->map = array;
+	if (swap_cgroup_prepare(type)) {
+		/* memory shortage */
+		ctrl->map = NULL;
+		ctrl->length = 0;
+		vfree(array);
+		mutex_unlock(&swap_cgroup_mutex);
+		goto nomem;
+	}
+	mutex_unlock(&swap_cgroup_mutex);
+
+	printk(KERN_INFO
+		"swap_cgroup: uses %ld bytes vmalloc and %ld bytes buffres\n",
+		array_size, length * PAGE_SIZE);
+	printk(KERN_INFO
+	"swap_cgroup can be disabled by noswapaccount boot option.\n");
+
+	return 0;
+nomem:
+	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
+	printk(KERN_INFO
+		"swap_cgroup can be disabled by noswapaccount boot option\n");
+	return -ENOMEM;
+}
+
+void swap_cgroup_swapoff(int type)
+{
+	int i;
+	struct swap_cgroup_ctrl *ctrl;
+
+	if (!do_swap_account)
+		return;
+
+	mutex_lock(&swap_cgroup_mutex);
+	ctrl = &swap_cgroup_ctrl[type];
+	if (ctrl->map) {
+		for (i = 0; i < ctrl->length; i++) {
+			struct page *page = ctrl->map[i];
+			if (page)
+				__free_page(page);
+		}
+		vfree(ctrl->map);
+		ctrl->map = NULL;
+		ctrl->length = 0;
+	}
+	mutex_unlock(&swap_cgroup_mutex);
+}
+
+static int __init swap_cgroup_init(void)
+{
+	int i;
+	for (i = 0; i < MAX_SWAPFILES; i++)
+		spin_lock_init(&swap_cgroup_ctrl[i].lock);
+	return 0;
+}
+late_initcall(swap_cgroup_init);
+#endif
Index: mmotm-2.6.28-Nov13/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.28-Nov13.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.28-Nov13/include/linux/page_cgroup.h
@@ -105,4 +105,39 @@ static inline void page_cgroup_init(void
 }
 
 #endif
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+#include <linux/swap.h>
+extern struct mem_cgroup *
+swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem);
+extern struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent);
+extern int swap_cgroup_swapon(int type, unsigned long max_pages);
+extern void swap_cgroup_swapoff(int type);
+#else
+#include <linux/swap.h>
+
+static inline
+struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
+{
+	return NULL;
+}
+
+static inline
+struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
+{
+	return NULL;
+}
+
+static inline int
+swap_cgroup_swapon(int type, unsigned long max_pages)
+{
+	return 0;
+}
+
+static inline void swap_cgroup_swapoff(int type)
+{
+	return;
+}
+
+#endif
 #endif
Index: mmotm-2.6.28-Nov13/mm/swapfile.c
===================================================================
--- mmotm-2.6.28-Nov13.orig/mm/swapfile.c
+++ mmotm-2.6.28-Nov13/mm/swapfile.c
@@ -32,6 +32,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
+#include <linux/page_cgroup.h>
 
 static DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
@@ -1345,6 +1346,9 @@ asmlinkage long sys_swapoff(const char _
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+	/* Destroy swap account informatin */
+	swap_cgroup_swapoff(type);
+
 	inode = mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		struct block_device *bdev = I_BDEV(inode);
@@ -1669,6 +1673,10 @@ asmlinkage long sys_swapon(const char __
 		nr_good_pages = swap_header->info.last_page -
 				swap_header->info.nr_badpages -
 				1 /* header page */;
+
+		if (!error)
+			error = swap_cgroup_swapon(type, maxpages);
+
 		if (error)
 			goto bad_swap;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
