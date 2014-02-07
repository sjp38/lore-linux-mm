Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCA16B003A
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:39 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id d17so1649721eek.37
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:39 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q43si9392773eeo.96.2014.02.07.09.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:38 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/8] memcg: remove unnecessary !mm check from try_get_mem_cgroup_from_mm()
Date: Fri,  7 Feb 2014 12:04:22 -0500
Message-Id: <1391792665-21678-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Users pass either a mm that has been established under task lock, or
use a verified current->mm, which means the task can't be exiting.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e1d7f33227e4..689fffdee471 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1075,13 +1075,6 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
 
-	if (!mm)
-		return NULL;
-	/*
-	 * Because we have no locks, mm->owner's may be being moved to other
-	 * cgroup. We use css_tryget() here even if this looks
-	 * pessimistic (rather than adding locks here).
-	 */
 	rcu_read_lock();
 	do {
 		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
