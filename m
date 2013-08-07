Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 06BCE6B00CB
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 07:28:37 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/3] memcg: limit the number of thresholds per-memcg
Date: Wed,  7 Aug 2013 13:28:25 +0200
Message-Id: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

There is no limit for the maximum number of threshold events registered
per memcg. This might lead to an user triggered memory depletion if a
regular user is allowed to register on memory.[memsw.]usage_in_bytes
eventfd interface.

Let's be more strict and cap the number of events that might be
registered. MAX_THRESHOLD_EVENTS value is more or less random. The
expectation is that it should be high enough to cover reasonable
usecases while not too high to allow excessive resources consumption.
1024 events consume something like 16KB which shouldn't be a big deal
and it should be good enough.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e4330cd..8247db3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5401,6 +5401,9 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
 		mem_cgroup_oom_notify_cb(iter);
 }
 
+/* Maximum number of treshold events registered per memcg. */
+#define MAX_THRESHOLD_EVENTS	1024
+
 static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
@@ -5424,6 +5427,11 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	else
 		BUG();
 
+	if (thresholds->primary->size == MAX_THRESHOLD_EVENTS) {
+		ret = -ENOSPC;
+		goto unlock;
+	}
+
 	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
 	/* Check if a threshold crossed before adding a new one */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
