Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0A37A6B00F3
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 04:03:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7AD5F3EE0C0
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:03:16 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A06E45DE6E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:03:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40FAC45DE6B
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:03:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2979B1DB8055
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:03:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB5EC1DB804E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:03:15 +0900 (JST)
Message-ID: <4F66E7D7.4040406@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 17:01:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/3] memcg: reduce size of struct page_cgroup.
References: <4F66E6A5.10804@jp.fujitsu.com>
In-Reply-To: <4F66E6A5.10804@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

Now, page_cgroup->flags has only 3bits. Considering alignment of
struct mem_cgroup, which is allocated by kmalloc(), we can encode
pointer to mem_cgroup and flags into a word.

After this patch, pc->flags is encoded as

 63                           2     0
  | pointer to memcg..........|flags|

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 92768cb..bca5447 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -1,6 +1,10 @@
 #ifndef __LINUX_PAGE_CGROUP_H
 #define __LINUX_PAGE_CGROUP_H
 
+/*
+ * Because these flags are encoded into ->flags with a pointer,
+ * we cannot have too much flags.
+ */
 enum {
 	/* flags for mem_cgroup */
 	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
@@ -9,6 +13,8 @@ enum {
 	__NR_PCG_FLAGS,
 };
 
+#define PCG_FLAGS_MASK	((1 << __NR_PCG_FLAGS) - 1)
+
 #ifndef __GENERATING_BOUNDS_H
 #include <generated/bounds.h>
 
@@ -21,10 +27,12 @@ enum {
  * page_cgroup helps us identify information about the cgroup
  * All page cgroups are allocated at boot or memory hotplug event,
  * then the page cgroup for pfn always exists.
+ *
+ * flags and a pointer to memory cgroup are encoded into ->flags.
+ * Lower 3bits are used for flags and others are used for a pointer to memcg.
  */
 struct page_cgroup {
 	unsigned long flags;
-	struct mem_cgroup *mem_cgroup;
 };
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
@@ -85,13 +93,14 @@ static inline void unlock_page_cgroup(struct page_cgroup *pc)
 
 static inline struct mem_cgroup* pc_to_mem_cgroup(struct page_cgroup *pc)
 {
-	return pc->mem_cgroup;
+	return (struct mem_cgroup *)(pc->flags & ~PCG_FLAGS_MASK);
 }
 
 static inline void
 pc_set_mem_cgroup(struct page_cgroup *pc, struct mem_cgroup *memcg)
 {
-	pc->mem_cgroup = memcg;
+	unsigned long bits = pc->flags & PCG_FLAGS_MASK;
+	pc->flags = (unsigned long)memcg | bits;
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
