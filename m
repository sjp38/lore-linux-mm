Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E01E6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 22:41:59 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so8100318pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:41:59 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id wz8si6993849pab.119.2015.09.22.19.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 19:41:58 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so26469668pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:41:58 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: remove pcp_counter_lock
Date: Tue, 22 Sep 2015 19:41:46 -0700
Message-Id: <1442976106-49685-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

Commit 733a572e66d2 ("memcg: make mem_cgroup_read_{stat|event}() iterate
possible cpus instead of online") removed the last use of the per memcg
pcp_counter_lock but forgot to remove the variable.

Kill the vestigial variable.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h | 1 -
 mm/memcontrol.c            | 1 -
 2 files changed, 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ad800e62cb7a..6452ff4c463f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -242,7 +242,6 @@ struct mem_cgroup {
 	 * percpu counter.
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
-	spinlock_t pcp_counter_lock;
 
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
 	struct cg_proto tcp_mem;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6ddaeba34e09..da21143550c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4179,7 +4179,6 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
 		goto out_free_stat;
 
-	spin_lock_init(&memcg->pcp_counter_lock);
 	return memcg;
 
 out_free_stat:
-- 
2.6.0.rc0.131.gf624c3d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
