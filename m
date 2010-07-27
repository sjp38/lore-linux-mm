Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D18A600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 04:07:00 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6R87DZn010769
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Jul 2010 17:07:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E21245DE57
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:07:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B81B45DE4F
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:07:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C95D31DB803C
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:07:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 861A41DB803A
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 17:07:12 +0900 (JST)
Date: Tue, 27 Jul 2010 17:02:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/7][memcg] use spin lock instead of bit_spin_lock in
 page_cgroup
Message-Id: <20100727170225.64f78b15.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch replaces page_cgroup's bit_spinlock with spinlock. In general,
spinlock has good implementation than bit_spin_lock and we should use
it if we have a room for it. In 64bit arch, we have extra 4bytes.
Let's use it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
--
Index: mmotm-0719/include/linux/page_cgroup.h
===================================================================
--- mmotm-0719.orig/include/linux/page_cgroup.h
+++ mmotm-0719/include/linux/page_cgroup.h
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
@@ -90,6 +96,16 @@ static inline enum zone_type page_cgroup
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
+#else
 static inline void lock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_lock(PCG_LOCK, &pc->flags);
@@ -99,6 +115,7 @@ static inline void unlock_page_cgroup(st
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
+#endif
 
 static inline void SetPCGFileFlag(struct page_cgroup *pc, int idx)
 {
Index: mmotm-0719/mm/page_cgroup.c
===================================================================
--- mmotm-0719.orig/mm/page_cgroup.c
+++ mmotm-0719/mm/page_cgroup.c
@@ -17,6 +17,9 @@ __init_page_cgroup(struct page_cgroup *p
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
