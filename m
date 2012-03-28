Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 93E606B00EF
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:08:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 32CC63EE0AE
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:08:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 18EF345DE51
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:08:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F3C4245DE4F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:08:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E54931DB803E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:08:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 954E31DB8037
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:08:11 +0900 (JST)
Message-ID: <4F72F0AF.4080208@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 20:06:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 6/6] memcg: config for integrate page_cgroup into memmap
References: <4F72EB84.7080000@jp.fujitsu.com>
In-Reply-To: <4F72EB84.7080000@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>

This patch is an experimental patch.
Considering 32bit archs, I think this should be CONFIG option...
==
Now, struct page_cgroup is 8byte object and allocated per a page.
This patch adds a config option to allocate page_cgroup in struct page.

By this
Pros.
  - lookup_page_cgroup() is almost 0 cost.
  - implementation seems very natural...
Cons.
  - size of 'struct page' will be increased  (to 64bytes in typical case)
  - cgroup_disable=memory will not allow user to avoid 8bytes of overhead.

Tested 'kernel make' on tmpfs.

Config=n
 Performance counter stats for 'make -j 8':

 1,180,857,100,495 instructions              #    0.00  insns per cycle
       923,084,678 cache-misses

      71.346377273 seconds time elapsed

Config=y
Performance counter stats for 'make -j 8':

 1,178,404,304,530 instructions              #    0.00  insns per cycle
       911,098,615 cache-misses

      71.607477840 seconds time elapsed

seems instructions and cache-misses decreased to some extent.
But no visible change in total execution time...

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h    |    4 +++-
 include/linux/page_cgroup.h |   33 ++++++++++++++++++++++++++++++++-
 init/Kconfig                |   14 ++++++++++++++
 mm/memcontrol.c             |    3 ++-
 mm/page_alloc.c             |    1 +
 mm/page_cgroup.c            |    3 ++-
 6 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 76bbdaf..2beda78 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -141,7 +141,9 @@ struct page {
 #ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
 	unsigned long debug_flags;	/* Use atomic bitops on this */
 #endif
-
+#ifdef CONFIG_INTEGRATED_PAGE_CGROUP
+	unsigned long page_cgroup;	/* see page_cgroup.h */
+#endif
 #ifdef CONFIG_KMEMCHECK
 	/*
 	 * kmemcheck wants to track the status of each byte in a page; this
diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 7e3a3c7..0e02632 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -35,8 +35,9 @@ struct page_cgroup {
 	unsigned long flags;
 };
 
-void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 
+#ifndef CONFIG_INTEGRATED_PAGE_CGROUP
+void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 #ifdef CONFIG_SPARSEMEM
 static inline void __init page_cgroup_init_flatmem(void)
 {
@@ -51,6 +52,36 @@ static inline void __init page_cgroup_init(void)
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 struct page *lookup_cgroup_page(struct page_cgroup *pc);
+static inline void memmap_init_cgroup(struct page *page)
+{
+}
+#else
+static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
+{
+	return (struct page_cgroup*)&page->page_cgroup;
+}
+
+static inline struct page *lookup_cgroup_page(struct page_cgroup *pc)
+{
+	return container_of((unsigned long*)pc, struct page, page_cgroup);
+}
+
+static inline void memmap_init_cgroup(struct page *page)
+{
+	page->page_cgroup = 0;
+}
+
+static inline void __init page_cgroup_init_flatmem(void)
+{
+}
+static inline void __init page_cgroup_init(void)
+{
+}
+
+static inline void pgdat_page_cgroup_init(struct pglist_data *pgdat)
+{
+}
+#endif
 
 #define TESTPCGFLAG(uname, lname)			\
 static inline int PageCgroup##uname(struct page_cgroup *pc)	\
diff --git a/init/Kconfig b/init/Kconfig
index e0bfe92..99514c2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -694,6 +694,20 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
 	  For those who want to have the feature enabled by default should
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
+
+config INTEGRATED_PAGE_CGROUP
+	bool "record memory cgroup information into struct page"
+	depends on CGROUP_MEM_RES_CTLR
+	default n
+	help
+	  Memory Resource Controller consumes 4/(8 if 64bit)bytes per page.
+	  It's independent of 'struct page'. If you say Y here, memory cgroup
+	  information is recorded into struct page and increase size of it
+	  4/8 bytes. With this, cpu overheads in runtime will be reduced
+	  but you cannot avoid above overheads of 4/8 bytes per page by boot
+	  option. If unsure, say N.
+
+
 config CGROUP_MEM_RES_CTLR_KMEM
 	bool "Memory Resource Controller Kernel Memory accounting (EXPERIMENTAL)"
 	depends on CGROUP_MEM_RES_CTLR && EXPERIMENTAL
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 767bef3..0c5b15c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2557,7 +2557,8 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	if (!PageCgroupUsed(head_pc))
 		return;
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
-		pc = head_pc + i;
+		/* page struct is contiguous in hugepage. */
+		pc = lookup_page_cgroup(head + i);
 		pc_set_mem_cgroup_and_flags(pc, memcg, BIT(PCG_USED));
 	}
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b37873..9be94df 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3682,6 +3682,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (!is_highmem_idx(zone))
 			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
+		memmap_init_cgroup(page);
 	}
 }
 
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 1ccbd71..036c8ea 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -11,6 +11,7 @@
 #include <linux/swapops.h>
 #include <linux/kmemleak.h>
 
+#ifndef CONFIG_INTEGRATED_PAGE_CGROUP
 static unsigned long total_usage;
 
 #if !defined(CONFIG_SPARSEMEM)
@@ -315,7 +316,7 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
 }
 
 #endif
-
+#endif
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 
-- 
1.7.4.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
