Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id DC4966B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:49:56 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so2642907lbv.12
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:49:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y9si7193884lbr.1.2014.10.24.06.49.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 06:49:55 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memcontrol: pull the NULL check from __mem_cgroup_same_or_subtree()
Date: Fri, 24 Oct 2014 09:49:48 -0400
Message-Id: <1414158589-26094-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
References: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The NULL in mm_match_cgroup() comes from a possibly exiting mm->owner.
It makes a lot more sense to check where it's looked up, rather than
check for it in __mem_cgroup_same_or_subtree() where it's unexpected.

No other callsite passes NULL to __mem_cgroup_same_or_subtree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 5 +++--
 mm/memcontrol.c            | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ea007615e8f9..e32ab948f589 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -83,11 +83,12 @@ static inline
 bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *task_memcg;
-	bool match;
+	bool match = false;
 
 	rcu_read_lock();
 	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	match = __mem_cgroup_same_or_subtree(memcg, task_memcg);
+	if (task_memcg)
+		match = __mem_cgroup_same_or_subtree(memcg, task_memcg);
 	rcu_read_unlock();
 	return match;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdf8520979cf..15b1c5110a8f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1316,7 +1316,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 {
 	if (root_memcg == memcg)
 		return true;
-	if (!root_memcg->use_hierarchy || !memcg)
+	if (!root_memcg->use_hierarchy)
 		return false;
 	return cgroup_is_descendant(memcg->css.cgroup, root_memcg->css.cgroup);
 }
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
