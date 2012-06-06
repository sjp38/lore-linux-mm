Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D04966B00AF
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 14:23:44 -0400 (EDT)
Received: by yenl11 with SMTP id l11so746315yen.2
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 11:23:44 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/5] mm: memcg set soft_limit_in_bytes to 0 by default
Date: Wed,  6 Jun 2012 11:23:43 -0700
Message-Id: <1339007023-10467-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This idea is based on discussion with Michal and Johannes from LSF.

1. If soft_limit are all set to MAX, it wastes first three priority iterations
without scanning anything.

2. By default every memcg is eligible for softlimit reclaim, and we can also
set the value to MAX for special memcg which is immune to soft limit reclaim.

There is a behavior change after this patch: (N == DEF_PRIORITY - 2)

        A: usage > softlimit        B: usage <= softlimit        U: softlimit unset
old:    reclaim at each priority    reclaim when priority < N    reclaim when priority < N
new:    reclaim at each priority    reclaim when priority < N    reclaim at each priority

Note: I can leave the counter->soft_limit uninitialized, at least all the
caller of res_counter_init() have the memcg as pre-zeroed structure. However, I
might be better not rely on that.

Signed-off-by: Ying Han <yinghan@google.com>
---
 kernel/res_counter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index d508363..231c7ef 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -18,7 +18,7 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
-	counter->soft_limit = RESOURCE_MAX;
+	counter->soft_limit = 0;
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
