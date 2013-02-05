Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BA4D66B000A
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:24:16 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/3] memcg: cleanup mem_cgroup_init comment
Date: Tue,  5 Feb 2013 17:24:01 +0100
Message-Id: <1360081441-1960-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

We should encourage all memcg controller initialization independent on
a specific mem_cgroup to be done here rather than exploit css_alloc
callback and assume that nothing happens before root cgroup is created.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9c1690..b97008c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -7007,10 +7007,12 @@ static void __init enable_swap_cgroup(void)
 #endif
 
 /*
- * The rest of init is performed during ->css_alloc() for root css which
- * happens before initcalls.  hotcpu_notifier() can't be done together as
- * it would introduce circular locking by adding cgroup_lock -> cpu hotplug
- * dependency.  Do it from a subsys_initcall().
+ * subsys_initcall() for memory controller.
+ *
+ * Some parts like hotcpu_notifier() have to be initialized from this context
+ * because of lock dependencies (cgroup_lock -> cpu hotplug) but basically
+ * everything that doesn't depend on a specific mem_cgroup structure should
+ * be initialized from here.
  */
 static int __init mem_cgroup_init(void)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
