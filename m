Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B523E6B0462
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 08:45:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so212623966pgi.4
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 05:45:25 -0800 (PST)
Received: from smtpbg11.qq.com (SMTPBG11.QQ.COM. [183.60.61.232])
        by mx.google.com with ESMTPS id l1si12913748plb.136.2017.03.11.05.45.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 11 Mar 2017 05:45:24 -0800 (PST)
From: Yisheng Xie <ysxie@foxmail.com>
Subject: [PATCH v2 RFC] mm/vmscan: more restrictive condition for retry in do_try_to_free_pages
Date: Sat, 11 Mar 2017 21:36:42 +0800
Message-Id: <1489239402-957-1-git-send-email-ysxie@foxmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, shakeelb@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, hanjunguo@huawei.com, qiuxishi@huawei.com

From: Yisheng Xie <xieyisheng1@huawei.com>

When we enter do_try_to_free_pages, the may_thrash is always clear, and
it will retry shrink zones to tap cgroup's reserves memory by setting
may_thrash when the former shrink_zones reclaim nothing.

However, when memcg is disabled or on legacy hierarchy, it should not do
this useless retry at all, for we do not have any cgroup's reserves
memory to tap, and we have already done hard work but made no progress.

To avoid this time costly and useless retrying, add a stub function
may_thrash and return true when memcg is disabled or on legacy
hierarchy.

Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Suggested-by: Shakeel Butt <shakeelb@google.com>
---
v2:
 - more restrictive condition for retry of shrink_zones (restricting
   cgroup_disabled=memory boot option and cgroup legacy hierarchy) - Shakeel

 - add a stub function may_thrash() to avoid compile error or warning.

 - rename subject from "donot retry shrink zones when memcg is disable"
   to "more restrictive condition for retry in do_try_to_free_pages"

Any comment is more than welcome!

Thanks
Yisheng Xie

 mm/vmscan.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031e..415f800 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -184,6 +184,19 @@ static bool sane_reclaim(struct scan_control *sc)
 #endif
 	return false;
 }
+
+static bool may_thrash(struct scan_control *sc)
+{
+	/*
+	 * When memcg is disabled or on legacy hierarchy, there is no cgroup
+	 * reserves memory to tap.
+	 */
+	if (!cgroup_subsys_enabled(memory_cgrp_subsys) ||
+	    !cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return true;
+
+	return sc->may_thrash;
+}
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
@@ -194,6 +207,11 @@ static bool sane_reclaim(struct scan_control *sc)
 {
 	return true;
 }
+
+static bool may_thrash(struct scan_control *sc)
+{
+	return true;
+}
 #endif
 
 /*
@@ -2808,7 +2826,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		return 1;
 
 	/* Untapped cgroup reserves?  Don't OOM, retry. */
-	if (!sc->may_thrash) {
+	if (!may_thrash(sc)) {
 		sc->priority = initial_priority;
 		sc->may_thrash = 1;
 		goto retry;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
