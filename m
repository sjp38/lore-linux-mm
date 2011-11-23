Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 294AF6B00CE
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 10:43:03 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/8] mm: memcg: lookup_page_cgroup (almost) never returns NULL
Date: Wed, 23 Nov 2011 16:42:27 +0100
Message-Id: <1322062951-1756-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

Pages have their corresponding page_cgroup descriptors set up before
they are used in userspace, and thus managed by a memory cgroup.

The only time where lookup_page_cgroup() can return NULL is in the
page sanity checking code that executes while feeding pages into the
page allocator for the first time.

Remove the NULL checks against lookup_page_cgroup() results from all
callsites where we know that corresponding page_cgroup descriptors
must be allocated.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d825af9..d4d139a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1894,9 +1894,6 @@ void mem_cgroup_update_page_stat(struct page *page,
 	bool need_unlock = false;
 	unsigned long uninitialized_var(flags);
 
-	if (unlikely(!pc))
-		return;
-
 	rcu_read_lock();
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
@@ -2669,8 +2666,6 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	}
 
 	pc = lookup_page_cgroup(page);
-	BUG_ON(!pc); /* XXX: remove this and move pc lookup into commit */
-
 	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
 	if (ret || !memcg)
 		return ret;
@@ -2942,7 +2937,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 * Check if our page_cgroup is valid
 	 */
 	pc = lookup_page_cgroup(page);
-	if (unlikely(!pc || !PageCgroupUsed(pc)))
+	if (unlikely(!PageCgroupUsed(pc)))
 		return NULL;
 
 	lock_page_cgroup(pc);
@@ -3326,6 +3321,7 @@ static struct page_cgroup *lookup_page_cgroup_used(struct page *page)
 	struct page_cgroup *pc;
 
 	pc = lookup_page_cgroup(page);
+	/* Can be NULL while bootstrapping the page allocator */
 	if (likely(pc) && PageCgroupUsed(pc))
 		return pc;
 	return NULL;
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
