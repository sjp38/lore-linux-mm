Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E3CA36B003A
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 03:09:44 -0400 (EDT)
Message-ID: <51F614FE.8020401@huawei.com>
Date: Mon, 29 Jul 2013 15:08:46 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v3 5/8] memcg: convert to use cgroup id
References: <51F614B2.6010503@huawei.com>
In-Reply-To: <51F614B2.6010503@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Use cgroup id instead of css id. This is a preparation to kill css id.

Note, as memcg treat 0 as an invalid id, while cgroup id starts with 0,
we define memcg_id == cgroup_id + 1.

v3:
- add a helper mem_cgroup_from_id(), suggested by Michal.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 626c426..62541f5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -512,6 +512,25 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
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
 
@@ -2821,15 +2840,10 @@ static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
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
@@ -4328,7 +4342,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	 * css_get() was called in uncharge().
 	 */
 	if (do_swap_account && swapout && memcg)
-		swap_cgroup_record(ent, css_id(&memcg->css));
+		swap_cgroup_record(ent, mem_cgroup_id(memcg));
 }
 #endif
 
@@ -4380,8 +4394,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 {
 	unsigned short old_id, new_id;
 
-	old_id = css_id(&from->css);
-	new_id = css_id(&to->css);
+	old_id = mem_cgroup_id(from);
+	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
 		mem_cgroup_swap_statistics(from, false);
@@ -6542,7 +6556,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
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
