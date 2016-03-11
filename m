Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 36F846B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:11:51 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id z76so139475080iof.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:11:51 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o64si589841pfj.112.2016.03.11.02.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 02:11:33 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: zap oom_info_lock
Date: Fri, 11 Mar 2016 13:11:23 +0300
Message-ID: <1457691083-22655-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_print_oom_info is always called under oom_lock, so
oom_info_lock is redundant.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa7bf354ae32..36db05fa8acb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1150,12 +1150,9 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
  */
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
-	/* oom_info_lock ensures that parallel ooms do not interleave */
-	static DEFINE_MUTEX(oom_info_lock);
 	struct mem_cgroup *iter;
 	unsigned int i;
 
-	mutex_lock(&oom_info_lock);
 	rcu_read_lock();
 
 	if (p) {
@@ -1199,7 +1196,6 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 		pr_cont("\n");
 	}
-	mutex_unlock(&oom_info_lock);
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
