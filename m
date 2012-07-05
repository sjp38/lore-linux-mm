Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id CC5A06B0083
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:45:45 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 08/11] mm: memcg: remove needless !mm fixup to init_mm when charging
Date: Thu,  5 Jul 2012 02:45:00 +0200
Message-Id: <1341449103-1986-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

It does not matter to __mem_cgroup_try_charge() if the passed mm is
NULL or init_mm, it will charge the root memcg in either case.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 418b47d..6fe4101 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2766,8 +2766,6 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		ret = 0;
 	return ret;
 charge_cur_mm:
-	if (unlikely(!mm))
-		mm = &init_mm;
 	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
 	if (ret == -EINTR)
 		ret = 0;
@@ -2832,9 +2830,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (PageCompound(page))
 		return 0;
 
-	if (unlikely(!mm))
-		mm = &init_mm;
-
 	if (!PageSwapCache(page))
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
 	else { /* page is swapcache/shmem */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
