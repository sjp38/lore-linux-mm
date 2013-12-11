Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 20B006B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:16:43 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so2879062eae.5
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:16:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id v6si8581046eel.49.2013.12.11.06.16.42
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:16:42 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/4] mm, memcg: allow OOM if no memcg is eligible during direct reclaim
Date: Wed, 11 Dec 2013 15:15:53 +0100
Message-Id: <1386771355-21805-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

If there is no memcg eligible for reclaim then the global direct
reclaim would end up in the endless loop because zones in the zonelists
are not considered unreclaimable (as per all_unreclaimable) and so the
OOM killer would never fire and direct reclaim would be triggered
without no chance to reclaim anything.

Memcg reclaim doesn't suffer from this because the OOM killer is
triggered after few unsuccessful attempts of the reclaim.

Fix this by checking the number of scanned pages which is obviously 0 if
nobody is eligible and also check that the whole tree hierarchy is not
eligible and tell OOM it can go ahead.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |  6 ++++++
 mm/memcontrol.c            | 10 ++++++++++
 mm/vmscan.c                |  7 +++++++
 3 files changed, 23 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6841e591718d..4ae6a9838a26 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -94,6 +94,7 @@ bool task_in_mem_cgroup(struct task_struct *task,
 
 extern bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
 		struct mem_cgroup *root);
+extern bool mem_cgroup_reclaim_no_eligible(struct mem_cgroup *root);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -297,6 +298,11 @@ static inline bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
 	return true;
 }
 
+static bool mem_cgroup_reclaim_no_eligible(struct mem_cgroup *root)
+{
+	return false;
+}
+
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a1cfee4491bf..102e2da9ec8d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2874,6 +2874,16 @@ bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
 	return true;
 }
 
+bool mem_cgroup_reclaim_no_eligible(struct mem_cgroup *root)
+{
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, root)
+		if (mem_cgroup_reclaim_eligible(iter, root))
+			return false;
+	return true;
+}
+
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	struct mem_cgroup *memcg = NULL;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1c9ce5f97872..234d1690563a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2481,6 +2481,13 @@ out:
 	if (aborted_reclaim)
 		return 1;
 
+	/*
+	 * If the target memcg is not eligible for reclaim then we have no opetion
+	 * but OOM
+	 */
+	if (!sc->nr_scanned && mem_cgroup_reclaim_no_eligible(sc->target_mem_cgroup))
+		return 0;
+
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
