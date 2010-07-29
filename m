Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E3D36B02AA
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 05:54:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T9sINq023843
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Jul 2010 18:54:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E42D45DE52
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:54:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62CBD45DE4F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:54:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 446001DB8043
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:54:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DBD351DB803F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 18:54:17 +0900 (JST)
Date: Thu, 29 Jul 2010 18:49:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/5] memcg : use spinlock in pcg instad of bit_spinlock
Message-Id: <20100729184927.9a3e214d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100729184250.acdff587.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100729184250.acdff587.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch replaces bit_spinlock with spinlock. In general,
spinlock has good functinality than bit_spin_lock and we should use
it if we have a room for it. In 64bit arch, we have extra 4bytes.
Let's use it.
expected effects:
 - use better codes.
 - ticket lock on x86-64
 - para-vitualization aware lock
etc..

Chagelog: 20090729
 - fixed page_cgroup_locked().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
--
---
 include/linux/page_cgroup.h |   35 +++++++++++++++++++++++++++++++++--
 mm/page_cgroup.c            |    3 +++
 2 files changed, 36 insertions(+), 2 deletions(-)

Index: mmotm-0727/include/linux/page_cgroup.h
===================================================================
--- mmotm-0727.orig/include/linux/page_cgroup.h
+++ mmotm-0727/include/linux/page_cgroup.h
@@ -10,8 +10,14 @@
  * All page cgroups are allocated at boot or memory hotplug event,
  * then the page cgroup for pfn always exists.
  */
+#ifdef CONFIG_64BIT
+#define PCG_HAS_SPINLOCK
+#endif
 struct page_cgroup {
 	unsigned long flags;
+#ifdef PCG_HAS_SPINLOCK
+	spinlock_t	lock;
+#endif
 	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
 	unsigned short blk_cgroup;	/* Not Used..but will be. */
 	struct page *page;
@@ -36,7 +42,9 @@ struct page_cgroup *lookup_page_cgroup(s
 
 enum {
 	/* flags for mem_cgroup */
-	PCG_LOCK,  /* page cgroup is locked */
+#ifndef PCG_HAS_SPINLOCK
+	PCG_LOCK,  /* page cgroup is locked (see below also.)*/
+#endif
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
@@ -60,7 +68,7 @@ static inline void ClearPageCgroup##unam
 static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
 	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
 
-TESTPCGFLAG(Locked, LOCK)
+
 
 /* Cache flag is set only once (at allocation) */
 TESTPCGFLAG(Cache, CACHE)
@@ -90,6 +98,22 @@ static inline enum zone_type page_cgroup
 	return page_zonenum(pc->page);
 }
 
+#ifdef PCG_HAS_SPINLOCK
+static inline void lock_page_cgroup(struct page_cgroup *pc)
+{
+	spin_lock(&pc->lock);
+}
+static inline void unlock_page_cgroup(struct page_cgroup *pc)
+{
+	spin_unlock(&pc->lock);
+}
+
+static inline bool page_cgroup_locked(struct page_cgroup *pc)
+{
+	return spin_is_locked(&pc->lock);
+}
+
+#else
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
@@ -100,6 +124,13 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline bool page_cgroup_locked(struct page_cgroup *pc)
+{
+	return test_bit(PCG_LOCK, &pc->flags);
+}
+
+#endif
+
 static inline void SetPCGFileFlag(struct page_cgroup *pc, int idx)
 {
 	set_bit(PCG_FILE_FLAGS + idx, &pc->flags);
Index: mmotm-0727/mm/page_cgroup.c
===================================================================
--- mmotm-0727.orig/mm/page_cgroup.c
+++ mmotm-0727/mm/page_cgroup.c
@@ -18,6 +18,9 @@ __init_page_cgroup(struct page_cgroup *p
 	pc->mem_cgroup = 0;
 	pc->page = pfn_to_page(pfn);
 	INIT_LIST_HEAD(&pc->lru);
+#ifdef PCG_HAS_SPINLOCK
+	spin_lock_init(&pc->lock);
+#endif
 }
 static unsigned long total_usage;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
