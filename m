Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id B89036B008A
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:33:55 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so930647lbv.26
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:33:55 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dl8si2882910lad.68.2014.10.23.07.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:33:54 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: don't pass a NULL memcg to mem_cgroup_end_move()
Date: Thu, 23 Oct 2014 10:33:50 -0400
Message-Id: <1414074830-14623-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mem_cgroup_end_move() checks if the passed memcg is NULL, along with a
lengthy comment to explain why this seemingly non-sensical situation
is even possible.

Check in cancel_attach() itself whether can_attach() set up the move
context or not, it's a lot more obvious from there.  Then remove the
check and comment in mem_cgroup_end_move().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a5c9aa4688e8..3cd4f1e0bfb3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1469,12 +1469,7 @@ static void mem_cgroup_start_move(struct mem_cgroup *memcg)
 
 static void mem_cgroup_end_move(struct mem_cgroup *memcg)
 {
-	/*
-	 * Now, mem_cgroup_clear_mc() may call this function with NULL.
-	 * We check NULL in callee rather than caller.
-	 */
-	if (memcg)
-		atomic_dec(&memcg->moving_account);
+	atomic_dec(&memcg->moving_account);
 }
 
 /*
@@ -5489,7 +5484,8 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
-	mem_cgroup_clear_mc();
+	if (mc.to)
+		mem_cgroup_clear_mc();
 }
 
 static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
