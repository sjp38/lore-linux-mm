Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 621B06B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:25:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4743C3EE0CD
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:25:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2581345DE5C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:25:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0303D45DE59
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:25:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3EDBE38005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:25:14 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9B01DB804D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:25:14 +0900 (JST)
Message-ID: <4FEC308F.4020909@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 19:23:11 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/2] memcg : remove -ENOMEM at page migration.
References: <4FEC300A.7040209@jp.fujitsu.com>
In-Reply-To: <4FEC300A.7040209@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

For handling many kinds of races, memcg adds an extra charge to
page's memcg at page migration. But this affects the page compaction
and make it fail if the memcg is under OOM.

This patch uses res_counter_charge_nofail() in page migration path
and remove -ENOMEM. By this, page migration will not fail by the
status of memcg.

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   26 +++++++-------------------
 1 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a2677e0..7424fab 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3168,6 +3168,7 @@ int mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask)
 {
 	struct mem_cgroup *memcg = NULL;
+	struct res_counter *dummy;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
 	int ret = 0;
@@ -3222,29 +3223,16 @@ int mem_cgroup_prepare_migration(struct page *page,
 	 */
 	if (!memcg)
 		return 0;
-
-	*memcgp = memcg;
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
-	css_put(&memcg->css);/* drop extra refcnt */
-	if (ret) {
-		if (PageAnon(page)) {
-			lock_page_cgroup(pc);
-			ClearPageCgroupMigration(pc);
-			unlock_page_cgroup(pc);
-			/*
-			 * The old page may be fully unmapped while we kept it.
-			 */
-			mem_cgroup_uncharge_page(page);
-		}
-		/* we'll need to revisit this error code (we have -EINTR) */
-		return -ENOMEM;
-	}
 	/*
 	 * We charge new page before it's used/mapped. So, even if unlock_page()
 	 * is called before end_migration, we can catch all events on this new
 	 * page. In the case new page is migrated but not remapped, new page's
 	 * mapcount will be finally 0 and we call uncharge in end_migration().
 	 */
+	res_counter_charge_nofail(&memcg->res, PAGE_SIZE, &dummy);
+	if (do_swap_account)
+		res_counter_charge_nofail(&memcg->memsw, PAGE_SIZE, &dummy);
+
 	if (PageAnon(page))
 		ctype = MEM_CGROUP_CHARGE_TYPE_ANON;
 	else if (page_is_file_cache(page))
@@ -3807,9 +3795,9 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 
 	if (!mem_cgroup_is_root(memcg)) {
 		if (!swap)
-			return res_counter_read_u64(&memcg->res, RES_USAGE);
+			return res_counter_usage_safe(&memcg->res);
 		else
-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
+			return res_counter_usage_safe(&memcg->memsw);
 	}
 
 	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
