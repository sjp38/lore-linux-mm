Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B78886B0357
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:19:49 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 08/11] memcg: disable kmem code when not in use.
Date: Mon, 25 Jun 2012 18:15:25 +0400
Message-Id: <1340633728-12785-9-git-send-email-glommer@parallels.com>
In-Reply-To: <1340633728-12785-1-git-send-email-glommer@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

We can use jump labels to patch the code in or out
when not used.

Because the assignment: memcg->kmem_accounted = true
is done after the jump labels increment, we guarantee
that the root memcg will always be selected until
all call sites are patched (see mem_cgroup_kmem_enabled).
This guarantees that no mischarges are applied.

Jump label decrement happens when the last reference
count from the memcg dies. This will only happen when
the caches are all dead.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 include/linux/memcontrol.h |    4 +++-
 mm/memcontrol.c            |   28 ++++++++++++++++++++++++++--
 2 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 22479eb..4d69ff8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -22,6 +22,7 @@
 #include <linux/cgroup.h>
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
+#include <linux/jump_label.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -411,7 +412,8 @@ struct sock;
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
 
-#define mem_cgroup_kmem_on 1
+extern struct static_key mem_cgroup_kmem_enabled_key;
+#define mem_cgroup_kmem_on static_key_false(&mem_cgroup_kmem_enabled_key)
 bool __mem_cgroup_new_kmem_page(gfp_t gfp, void *handle, int order);
 void __mem_cgroup_commit_kmem_page(struct page *page, void *handle, int order);
 void __mem_cgroup_free_kmem_page(struct page *page, int order);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 27b2b6f..fe5388e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -425,6 +425,10 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
 #include <net/sock.h>
 #include <net/ip.h>
 
+struct static_key mem_cgroup_kmem_enabled_key;
+/* so modules can inline the checks */
+EXPORT_SYMBOL(mem_cgroup_kmem_enabled_key);
+
 static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, s64 delta);
 static void memcg_uncharge_kmem(struct mem_cgroup *memcg, s64 delta);
@@ -582,6 +586,16 @@ void __mem_cgroup_free_kmem_page(struct page *page, int order)
 	mem_cgroup_put(memcg);
 }
 EXPORT_SYMBOL(__mem_cgroup_free_kmem_page);
+
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+	if (memcg->kmem_accounted)
+		static_key_slow_dec(&mem_cgroup_kmem_enabled_key);
+}
+#else
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
 
 #if defined(CONFIG_INET) && defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
@@ -597,6 +611,12 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 }
 #endif
 
+static void disarm_static_keys(struct mem_cgroup *memcg)
+{
+	disarm_sock_keys(memcg);
+	disarm_kmem_keys(memcg);
+}
+
 static void drain_all_stock_async(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
@@ -4051,8 +4071,12 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			 *
 			 * But it is not worth the trouble
 			 */
-			if (!memcg->kmem_accounted && val != RESOURCE_MAX)
+			mutex_lock(&set_limit_mutex);
+			if (!memcg->kmem_accounted && val != RESOURCE_MAX) {
+				static_key_slow_inc(&mem_cgroup_kmem_enabled_key);
 				memcg->kmem_accounted = true;
+			}
+			mutex_unlock(&set_limit_mutex);
 		}
 #endif
 		else
@@ -4927,7 +4951,7 @@ static void free_work(struct work_struct *work)
 	 * to move this code around, and make sure it is outside
 	 * the cgroup_lock.
 	 */
-	disarm_sock_keys(memcg);
+	disarm_static_keys(memcg);
 	if (size < PAGE_SIZE)
 		kfree(memcg);
 	else
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
