Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9501C6B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:54:57 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so17389309pdb.24
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 07:54:57 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fc3si54312318pad.15.2014.12.29.07.54.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Dec 2014 07:54:56 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] memcg: fix destination cgroup leak on task charges migration
Date: Mon, 29 Dec 2014 18:54:43 +0300
Message-ID: <1419868483-30612-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We are supposed to take one css reference per each memory page and per
each swap entry accounted to a memory cgroup. However, during task
charges migration we take a reference to the destination cgroup twice
per each swap entry: first in mem_cgroup_do_precharge()->try_charge()
and then in mem_cgroup_move_swap_account(), permanently leaking the
destination cgroup.

The hunk taking the second reference seems to be a leftover from the
pre-00501b531c472 ("mm: memcontrol: rewrite charge API") era. Remove it
to fix the leak.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e856c7e4..d62c335dfef4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3043,18 +3043,6 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
 		mem_cgroup_swap_statistics(from, false);
 		mem_cgroup_swap_statistics(to, true);
-		/*
-		 * This function is only called from task migration context now.
-		 * It postpones page_counter and refcount handling till the end
-		 * of task migration(mem_cgroup_clear_mc()) for performance
-		 * improvement. But we cannot postpone css_get(to)  because if
-		 * the process that has been moved to @to does swap-in, the
-		 * refcount of @to might be decreased to 0.
-		 *
-		 * We are in attach() phase, so the cgroup is guaranteed to be
-		 * alive, so we can just call css_get().
-		 */
-		css_get(&to->css);
 		return 0;
 	}
 	return -EINVAL;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
