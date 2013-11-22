Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC726B0036
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:18:01 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so925255bkz.28
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:18:00 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id np3si5994722bkb.93.2013.11.22.09.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 09:18:00 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL allocations
Date: Fri, 22 Nov 2013 12:17:56 -0500
Message-Id: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

84235de394d9 ("fs: buffer: move allocation failure loop into the
allocator") started recognizing __GFP_NOFAIL in memory cgroups but
forgot to disable the OOM killer.

Any task that does not fail allocation will also not enter the OOM
completion path.  So don't declare an OOM state in this case or it'll
be leaked and the task be able to bypass the limit until the next
userspace-triggered page fault cleans up the OOM state.

Reported-by: William Dauchy <wdauchy@gmail.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@kernel.org # 3.12
---
 mm/memcontrol.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13b9d0f..cc4f9cb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2677,6 +2677,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	if (unlikely(task_in_memcg_oom(current)))
 		goto bypass;
 
+	if (gfp_mask & __GFP_NOFAIL)
+		oom = false;
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
