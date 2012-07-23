Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 6BDB66B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 23:27:55 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 08:57:51 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6N3RlOb21233798
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 08:57:48 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6N8vKY6032722
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 14:27:21 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] memcg: fix mm/memcontrol.c build error against linux-next
Date: Mon, 23 Jul 2012 11:27:34 +0800
Message-Id: <1343014054-30929-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWAHiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

As Fengguang Wu reported, linux-next failed to build with 

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
head:   37e2ad4953983527f7bdb6831bf478eedcc84082
commit: 442d53f161093de78f0aafcd3ec2a6345de42890 [164/309] memcg: add mem_cgroup_from_css() helper

mem_cgroup_from_css() is defined inside CONFIG_MEMCG_KMEM and used
outside of it, move mem_cgroup_from_css() out of the #ifdef 
CONFIG_MEMCG_KMEM can address this issue.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

---
 mm/memcontrol.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 439190b..994e353 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -405,17 +405,17 @@ enum charge_type {
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#ifdef CONFIG_MEMCG_KMEM
-#include <net/sock.h>
-#include <net/ip.h>
-
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
 	return container_of(s, struct mem_cgroup, css);
 }
 
+/* Writing them here to avoid exposing memcg's inner layout */
+#ifdef CONFIG_MEMCG_KMEM
+#include <net/sock.h>
+#include <net/ip.h>
+
 static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 void sock_update_memcg(struct sock *sk)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
