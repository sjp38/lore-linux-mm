Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3436B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 07:48:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g138so20607379itb.4
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 04:48:33 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id s80si2752294ioi.211.2017.03.15.04.48.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 04:48:32 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v4] mm/vmscan: more restrictive condition for retry in do_try_to_free_pages
Date: Wed, 15 Mar 2017 19:36:48 +0800
Message-ID: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, shakeelb@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

By reviewing code, I find that when enter do_try_to_free_pages, the
may_thrash is always clear, and it will retry shrink zones to tap
cgroup's reserves memory by setting may_thrash when the former
shrink_zones reclaim nothing.

However, when memcg is disabled or on legacy hierarchy, or there do not
have any memcg protected by low limit, it should not do this useless retry
at all, for we do not have any cgroup's reserves memory to tap, and we
have already done hard work but made no progress.

To avoid this unneeded retrying, add a new field in scan_control named
memcg_low_protection, set it if there is any memcg protected by low limit
and only do the retry when memcg_low_protection is set while may_thrash
is clear.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Suggested-by: Shakeel Butt <shakeelb@google.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
---
v4:
 - add a new field in scan_control named memcg_low_protection to check whether
   there have any memcg protected by low limit. - Michal

v3:
 - rename function may_thrash() to mem_cgroup_thrashed() to avoid confusing.

v2:
 - more restrictive condition for retry of shrink_zones (restricting
   cgroup_disabled=memory boot option and cgroup legacy hierarchy) - Shakeel

 - add a stub function may_thrash() to avoid compile error or warning.

 - rename subject from "donot retry shrink zones when memcg is disable"
   to "more restrictive condition for retry in do_try_to_free_pages"

Any comment is more than welcome!

Thanks
Yisheng Xie

 mm/vmscan.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031e..c4fa3d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -100,6 +100,9 @@ struct scan_control {
 	/* Can cgroups be reclaimed below their normal consumption range? */
 	unsigned int may_thrash:1;
 
+	/* Did we have any memcg protected by the low limit */
+	unsigned int memcg_low_protection:1;
+
 	unsigned int hibernation_mode:1;
 
 	/* One of the zones is ready for compaction */
@@ -2557,6 +2560,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			unsigned long scanned;
 
 			if (mem_cgroup_low(root, memcg)) {
+				sc->memcg_low_protection = 1;
+
 				if (!sc->may_thrash)
 					continue;
 				mem_cgroup_events(memcg, MEMCG_LOW, 1);
@@ -2808,7 +2813,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		return 1;
 
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
-	if (!sc->may_thrash) {
+	if (sc->memcg_low_protection && !sc->may_thrash) {
 		sc->priority = initial_priority;
 		sc->may_thrash = 1;
 		goto retry;
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
