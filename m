Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C84E6B00D5
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 01:27:37 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1P6RXdI018322
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Feb 2009 15:27:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B215545DE4D
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 15:27:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C4C645DE51
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 15:27:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 44EADE08003
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 15:27:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E371DB8038
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 15:27:32 +0900 (JST)
Date: Wed, 25 Feb 2009 15:26:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use CSS ID in swap_cgroup for saving memory
Message-Id: <20090225152617.df4eeb35.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Maybe ready for wider test. This is original purpose for adding CSS ID to cgroup.
against mmotm-2009-02-24-16-23
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch tires to use CSS ID for records in swap_cgroup.
By this, on 64bit machine, size of swap_cgroup goes down to 2 bytes from 8bytes.

This means, when 2GB of swap is equipped, (assume the page size is 4096bytes)
	From size of swap_cgroup = 2G/4k * 8 = 4Mbytes.
	To   size of swap_cgroup = 2G/4k * 2 = 1Mbytes.
Reduction is large. Of course, there are trade-offs. This CSS ID will add
overhead to swap-in/swap-out/swap-free.

But in general,
  - swap is a resource which the user tend to avoid use.
  - If swap is never used, swap_cgroup area is not used.
  - Reading traditional manuals, size of swap should be proportional to
    size of memory. Memory size of machine is increasing now.

I think reducing size of swap_cgroup makes sense.
    
Note:
  - ID->CSS lookup routine has no locks, it's under RCU-Read-Side.
  - memcg can be obsolete at rmdir() but not freed while refcnt from
    swap_cgroup is available.

Changelog: v2 -> v3
 - fixed a NULL pointer bug reported by Nishimura.
 - fixed message in dmesg

Changelog: v1 -> v2
 - removed css_tryget().
 - fixed texts

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    9 ++----
 mm/memcontrol.c             |   66 ++++++++++++++++++++++++++++++++++++--------
 mm/page_cgroup.c            |   28 +++++++++---------
 3 files changed, 73 insertions(+), 30 deletions(-)

Index: mmotm-2.6.29-Feb24/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.29-Feb24.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.29-Feb24/include/linux/page_cgroup.h
@@ -91,22 +91,21 @@ static inline void page_cgroup_init(void
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 #include <linux/swap.h>
-extern struct mem_cgroup *
-swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem);
-extern struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent);
+extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
+extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
 #else
 #include <linux/swap.h>
 
 static inline
-struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 {
 	return NULL;
 }
 
 static inline
-struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
+unsigned short lookup_swap_cgroup(swp_entry_t ent)
 {
 	return NULL;
 }
Index: mmotm-2.6.29-Feb24/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Feb24.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Feb24/mm/memcontrol.c
@@ -991,20 +991,41 @@ nomem:
 	return -ENOMEM;
 }
 
+/*
+ * A helper function to get mem_cgroup from ID. must be called under
+ * rcu_read_lock(). The caller must check css_is_removed() or some if
+ * it's concern. (dropping refcnt from swap can be called against removed
+ * memcg.)
+ */
+static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
+{
+	struct cgroup_subsys_state *css;
+
+	/* ID 0 is unused ID */
+	if (!id)
+		return NULL;
+	css = css_lookup(&mem_cgroup_subsys, id);
+	if (!css)
+		return NULL;
+	return container_of(css, struct mem_cgroup, css);
+}
+
 static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
 {
-	struct mem_cgroup *mem;
+	unsigned short id;
+	struct mem_cgroup *mem = NULL;
 	swp_entry_t ent;
 
 	if (!PageSwapCache(page))
 		return NULL;
 
 	ent.val = page_private(page);
-	mem = lookup_swap_cgroup(ent);
-	if (!mem)
-		return NULL;
-	if (!css_tryget(&mem->css))
-		return NULL;
+	id = lookup_swap_cgroup(ent);
+	rcu_read_lock();
+	mem = mem_cgroup_lookup(id);
+	if (mem && !css_tryget(&mem->css))
+		mem = NULL;
+	rcu_read_unlock();
 	return mem;
 }
 
@@ -1265,12 +1286,20 @@ int mem_cgroup_cache_charge(struct page 
 
 	if (do_swap_account && !ret && PageSwapCache(page)) {
 		swp_entry_t ent = {.val = page_private(page)};
+		unsigned short id;
 		/* avoid double counting */
-		mem = swap_cgroup_record(ent, NULL);
+		id = swap_cgroup_record(ent, 0);
+		rcu_read_lock();
+		mem = mem_cgroup_lookup(id);
 		if (mem) {
+			/*
+			 * Recorded ID can be obsolete. We avoid calling
+			 * css_tryget()
+			 */
 			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 			mem_cgroup_put(mem);
 		}
+		rcu_read_unlock();
 	}
 	return ret;
 }
@@ -1335,13 +1364,21 @@ void mem_cgroup_commit_charge_swapin(str
 	 */
 	if (do_swap_account && PageSwapCache(page)) {
 		swp_entry_t ent = {.val = page_private(page)};
+		unsigned short id;
 		struct mem_cgroup *memcg;
-		memcg = swap_cgroup_record(ent, NULL);
+
+		id = swap_cgroup_record(ent, 0);
+		rcu_read_lock();
+		memcg = mem_cgroup_lookup(id);
 		if (memcg) {
+			/*
+			 * This recorded memcg can be obsolete one. So, avoid
+			 * calling css_tryget
+			 */
 			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 			mem_cgroup_put(memcg);
 		}
-
+		rcu_read_unlock();
 	}
 	/* add this page(page_cgroup) to the LRU we want. */
 
@@ -1462,7 +1499,7 @@ void mem_cgroup_uncharge_swapcache(struc
 					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
 	/* record memcg information */
 	if (do_swap_account && memcg) {
-		swap_cgroup_record(ent, memcg);
+		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
 	if (memcg)
@@ -1477,15 +1514,22 @@ void mem_cgroup_uncharge_swapcache(struc
 void mem_cgroup_uncharge_swap(swp_entry_t ent)
 {
 	struct mem_cgroup *memcg;
+	unsigned short id;
 
 	if (!do_swap_account)
 		return;
 
-	memcg = swap_cgroup_record(ent, NULL);
+	id = swap_cgroup_record(ent, 0);
+	rcu_read_lock();
+	memcg = mem_cgroup_lookup(id);
 	if (memcg) {
+		/*
+		 * This memcg can be obsolete one. We avoid calling css_tryget
+		 */
 		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
 		mem_cgroup_put(memcg);
 	}
+	rcu_read_unlock();
 }
 #endif
 
Index: mmotm-2.6.29-Feb24/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.29-Feb24.orig/mm/page_cgroup.c
+++ mmotm-2.6.29-Feb24/mm/page_cgroup.c
@@ -290,7 +290,7 @@ struct swap_cgroup_ctrl swap_cgroup_ctrl
  * cgroup rather than pointer.
  */
 struct swap_cgroup {
-	struct mem_cgroup	*val;
+	unsigned short		id;
 };
 #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
 #define SC_POS_MASK	(SC_PER_PAGE - 1)
@@ -342,10 +342,10 @@ not_enough_page:
  * @ent: swap entry to be recorded into
  * @mem: mem_cgroup to be recorded
  *
- * Returns old value at success, NULL at failure.
- * (Of course, old value can be NULL.)
+ * Returns old value at success, 0 at failure.
+ * (Of course, old value can be 0.)
  */
-struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 {
 	int type = swp_type(ent);
 	unsigned long offset = swp_offset(ent);
@@ -354,18 +354,18 @@ struct mem_cgroup *swap_cgroup_record(sw
 	struct swap_cgroup_ctrl *ctrl;
 	struct page *mappage;
 	struct swap_cgroup *sc;
-	struct mem_cgroup *old;
+	unsigned short old;
 
 	if (!do_swap_account)
-		return NULL;
+		return 0;
 
 	ctrl = &swap_cgroup_ctrl[type];
 
 	mappage = ctrl->map[idx];
 	sc = page_address(mappage);
 	sc += pos;
-	old = sc->val;
-	sc->val = mem;
+	old = sc->id;
+	sc->id = id;
 
 	return old;
 }
@@ -374,9 +374,9 @@ struct mem_cgroup *swap_cgroup_record(sw
  * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
  * @ent: swap entry to be looked up.
  *
- * Returns pointer to mem_cgroup at success. NULL at failure.
+ * Returns CSS ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
  */
-struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
+unsigned short lookup_swap_cgroup(swp_entry_t ent)
 {
 	int type = swp_type(ent);
 	unsigned long offset = swp_offset(ent);
@@ -385,16 +385,16 @@ struct mem_cgroup *lookup_swap_cgroup(sw
 	struct swap_cgroup_ctrl *ctrl;
 	struct page *mappage;
 	struct swap_cgroup *sc;
-	struct mem_cgroup *ret;
+	unsigned short ret;
 
 	if (!do_swap_account)
-		return NULL;
+		return 0;
 
 	ctrl = &swap_cgroup_ctrl[type];
 	mappage = ctrl->map[idx];
 	sc = page_address(mappage);
 	sc += pos;
-	ret = sc->val;
+	ret = sc->id;
 	return ret;
 }
 
@@ -432,7 +432,7 @@ int swap_cgroup_swapon(int type, unsigne
 
 	printk(KERN_INFO
 		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
-		" and %ld bytes to hold mem_cgroup pointers on swap\n",
+		" and %ld bytes to hold mem_cgroup information per swap ents\n",
 		array_size, length * PAGE_SIZE);
 	printk(KERN_INFO
 	"swap_cgroup can be disabled by noswapaccount boot option.\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
