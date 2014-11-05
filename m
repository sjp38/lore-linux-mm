Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id AB5B16B0071
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 05:23:25 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id ft15so503228pdb.7
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 02:23:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ly4si2612654pdb.174.2014.11.05.02.23.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Nov 2014 02:23:24 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: __mem_cgroup_free: remove stale disarm_static_keys comment
Date: Wed, 5 Nov 2014 13:23:14 +0300
Message-ID: <1415182994-2866-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

cpuset code stopped using cgroup_lock in favor of cpuset_mutex long ago.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9a37d99aee54..95ee47c0f0a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4610,17 +4610,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	free_percpu(memcg->stat);
 
-	/*
-	 * We need to make sure that (at least for now), the jump label
-	 * destruction code runs outside of the cgroup lock. This is because
-	 * get_online_cpus(), which is called from the static_branch update,
-	 * can't be called inside the cgroup_lock. cpusets are the ones
-	 * enforcing this dependency, so if they ever change, we might as well.
-	 *
-	 * schedule_work() will guarantee this happens. Be careful if you need
-	 * to move this code around, and make sure it is outside
-	 * the cgroup_lock.
-	 */
 	disarm_static_keys(memcg);
 	kfree(memcg);
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
