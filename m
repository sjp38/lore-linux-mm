Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id CB68C6B007E
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 12:38:11 -0400 (EDT)
Received: by eeit10 with SMTP id t10so332407eei.2
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 09:38:10 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3 2/2] memcg: set soft_limit_in_bytes to 0 by default
Date: Tue, 17 Apr 2012 09:38:09 -0700
Message-Id: <1334680689-12506-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This idea is based on discussion with Michal and Johannes from LSF.

1. If soft_limit are all set to MAX, it wastes first three priority iterations
without scanning anything.

2. By default every memcg is eligible for softlimit reclaim, and we can also
set the value to MAX for special memcg which is immune to soft limit reclaim.

Note, there are behavior changes after this patch and here I steal example from
Johannes's comment:

               A-unconfigured          B-below-softlimit
old:            reclaim(MAX)           reclaim
new:            reclaim(0)             no reclaim (if possible)

a) both A and B are under their softlimit in the old case, and it will be
detected after first round of iteration. Then both A and B will be targeted
to recalim.
b) only A is targeted to reclaim since it is above its softlimit, and we
won't reclaim from B before DEF_PRIORITY - 3.

               A-unconfigured          B-above-softlimit
old:            reclaim                 reclaim twice
new:            reclaim                 reclaim

a) If we can not get enough pages on B before DEF_PRIORITY - 3, we will reclaim
from both A and B afterwards.
b) Both A and B will be reclaimed from DEF_PRIORITY.

Signed-off-by: Ying Han <yinghan@google.com>
---
 kernel/res_counter.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d508363..8017d01 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,6 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
-	counter->soft_limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
