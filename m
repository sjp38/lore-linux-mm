Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id F2B9B6B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 06:37:22 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so155531381wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:37:22 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id nf19si12957329wic.83.2015.10.27.03.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 03:37:21 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so152945349wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:37:21 -0700 (PDT)
From: mhocko@kernel.org
Subject: [PATCH] memcg: Fix thresholds for 32b architectures.
Date: Tue, 27 Oct 2015 11:37:14 +0100
Message-Id: <1445942234-11175-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, Ben Hutchings <ben@decadent.org.uk>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

424cdc141380 ("memcg: convert threshold to bytes") has fixed a
regression introduced by 3e32cb2e0a12 ("mm: memcontrol: lockless page
counters") where thresholds were silently converted to use page units
rather than bytes when interpreting the user input.

The fix is not complete, though, as properly pointed out by Ben
Hutchings during stable backport review. The page count is converted
to bytes but unsigned long is used to hold the value which would
be obviously not sufficient for 32b systems with more than 4G
thresholds. The same applies to usage as taken from mem_cgroup_usage
which might overflow.

Let's remove this bytes vs. pages internal tracking differences and
handle thresholds in page units internally. Chage mem_cgroup_usage()
to return the value in page units and revert 424cdc141380 because this
should be sufficient for the consistent handling.
mem_cgroup_read_u64 as the only users of mem_cgroup_usage outside of
the threshold handling code is converted to give the proper in bytes
result. It is doing that already for page_counter output so this is
more consistent as well.

The value presented to the userspace is still in bytes units.

Fixes: 424cdc141380 ("memcg: convert threshold to bytes")
Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
CC: stable@vger.kernel.org
Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f3cc594ffa2d..2823cafc269e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2802,7 +2802,7 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
 	return val;
 }
 
-static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
+static inline unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
 
@@ -2817,7 +2817,7 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 		else
 			val = page_counter_read(&memcg->memsw);
 	}
-	return val << PAGE_SHIFT;
+	return val;
 }
 
 enum {
@@ -2851,9 +2851,9 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	switch (MEMFILE_ATTR(cft->private)) {
 	case RES_USAGE:
 		if (counter == &memcg->memory)
-			return mem_cgroup_usage(memcg, false);
+			return (u64)mem_cgroup_usage(memcg, false) * PAGE_SIZE;
 		if (counter == &memcg->memsw)
-			return mem_cgroup_usage(memcg, true);
+			return (u64)mem_cgroup_usage(memcg, true) * PAGE_SIZE;
 		return (u64)page_counter_read(counter) * PAGE_SIZE;
 	case RES_LIMIT:
 		return (u64)counter->limit * PAGE_SIZE;
@@ -3353,7 +3353,6 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	ret = page_counter_memparse(args, "-1", &threshold);
 	if (ret)
 		return ret;
-	threshold <<= PAGE_SHIFT;
 
 	mutex_lock(&memcg->thresholds_lock);
 
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
