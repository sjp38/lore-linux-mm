Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DA9946B00EA
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:01:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6DFD13EE0B6
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 563F145DE55
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 313C945DE51
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 217671DB803F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C08861DB8037
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:01:15 +0900 (JST)
Message-ID: <4F72EF10.3060209@jp.fujitsu.com>
Date: Wed, 28 Mar 2012 19:59:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][[PATCH 4/6] memcg: remove mem_cgroup pointer from page_cgroup
References: <4F72EB84.7080000@jp.fujitsu.com>
In-Reply-To: <4F72EB84.7080000@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Suleiman Souhlal <suleiman@google.com>


This patch removes pc->mem_cgroup and merge the pointer into flags as

63                           4     0
  | pointer to memcg..........|flags|

After this, memory cgroup's overhead is 8(4)bytes per a page.

Changelog:
 - added BUILD_BUG_ON()
 - update comments in Kconfig

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   21 +++++++++------------
 init/Kconfig                |    2 +-
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 3f3b4ff..7e3a3c7 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -3,6 +3,10 @@
 
 #include <linux/smp.h>
 
+/*
+ * These flags are encoded into low bits of unsigned long,
+ * ORed with a pointer to mem_cgroup.
+ */
 enum {
 	/* flags for mem_cgroup */
 	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
@@ -12,6 +16,8 @@ enum {
 	__NR_PCG_FLAGS,
 };
 
+#define PCG_FLAGS_MASK	((1 << __NR_PCG_FLAGS) - 1)
+
 #ifndef __GENERATING_BOUNDS_H
 #include <generated/bounds.h>
 
@@ -27,7 +33,6 @@ enum {
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -93,7 +98,7 @@ extern struct mem_cgroup*  root_mem_cgroup;
 static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
 {
 	if (likely(!PageCgroupReset(pc)))
-		return pc->mem_cgroup;
+		return (struct mem_cgroup*)(pc->flags & ~PCG_FLAGS_MASK);
 	return root_mem_cgroup;
 }
 
@@ -101,16 +106,8 @@ static inline void
 pc_set_mem_cgroup_and_flags(struct page_cgroup *pc, struct mem_cgroup *memcg,
 			unsigned long flags)
 {
-	pc->mem_cgroup = memcg;
-	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc's mem_cgroup
-	 * is accessed after testing USED bit. To make pc's mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
-	 */
-	smp_wmb();
-	pc->flags = flags;
+	BUILD_BUG_ON(__NR_PCG_FLAGS > 5); /* assume 32byte alignment. */
+	pc->flags = (unsigned long)memcg | flags;
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
diff --git a/init/Kconfig b/init/Kconfig
index 6cfd71d..e0bfe92 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -651,7 +651,7 @@ config CGROUP_MEM_RES_CTLR
 
 	  Note that setting this option increases fixed memory overhead
 	  associated with each page of memory in the system. By this,
-	  20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
+	  4(8)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
 	  usage tracking struct at boot. Total amount of this is printed out
 	  at boot.
 
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
