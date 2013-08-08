Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 0517D6B0034
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 22:33:46 -0400 (EDT)
Message-ID: <5203036F.9070201@huawei.com>
Date: Thu, 8 Aug 2013 10:33:19 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v5 2/5] memcg: convert to use cgroup id
References: <52030346.4050003@huawei.com>
In-Reply-To: <52030346.4050003@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Use cgroup id instead of css id. This is a preparation to kill css id.

Note, as memcg treat 0 as an invalid id, while cgroup id starts with 0,
we define memcg_id == cgroup_id + 1.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 87a2537..3189f70 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -503,6 +503,25 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
+static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
+{
+	/*
+	 * The ID of the root cgroup is 0, but memcg treat 0 as an
+	 * invalid ID, so we return (cgroup_id + 1).
+	 */
+	return memcg->css.cgroup->id + 1;
+}
+
+static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
+{
+	struct cgroup *cgrp;
+
+	cgrp = cgroup_from_id(&mem_cgroup_subsys, id - 1);
+	if (!cgrp)
+		return NULL;
+	return mem_cgroup_from_cont(cgrp);
+}
+
 /* Writing them here to avoid exposing memcg's inner layout */
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 
@@ -2754,15 +2773,10 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
  */
 static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 {
-	struct cgroup_subsys_state *css;
-
 	/* ID 0 is unused ID */
 	if (!id)
 		return NULL;
-	css = css_lookup(&mem_cgroup_subsys, id);
-	if (!css)
-		return NULL;
-	return mem_cgroup_from_css(css);
+	return mem_cgroup_from_id(id);
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
@@ -4259,7 +4273,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	 * css_get() was called in uncharge().
 	 */
 	if (do_swap_account && swapout && memcg)
-		swap_cgroup_record(ent, css_id(&memcg->css));
+		swap_cgroup_record(ent, mem_cgroup_id(memcg));
 }
 #endif
 
@@ -4311,8 +4325,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 {
 	unsigned short old_id, new_id;
 
-	old_id = css_id(&from->css);
-	new_id = css_id(&to->css);
+	old_id = mem_cgroup_id(from);
+	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
 		mem_cgroup_swap_statistics(from, false);
@@ -6359,7 +6373,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 	}
 	/* There is a swap entry and a page doesn't exist or isn't charged */
 	if (ent.val && !ret &&
-			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
+	    mem_cgroup_id(mc.from) == lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
 			target->ent = ent;
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
