Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3330A6B006C
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 06:56:02 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so8977005ghr.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 03:56:01 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: return -EBUSY when oom-kill-disable modified and memcg use_hierarchy, has children
Date: Thu,  5 Jul 2012 18:55:08 +0800
Message-Id: <1341485708-14221-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

When oom-kill-disable modified by the user and current memcg use_hierarchy,
the change can occur, provided the current memcg has no children. If it
has children, return -EBUSY is enough.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 63e36e7..4b64fe0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4521,11 +4521,14 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 
 	cgroup_lock();
 	/* oom-kill-disable is a flag for subhierarchy. */
-	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+	if (parent->use_hierarchy) {
 		cgroup_unlock();
 		return -EINVAL;
+	} else if (memcg->use_hierarchy && !list_empty(&cgrp->children)) {
+		cgroup_unlock();
+		return -EBUSY;
 	}
+
 	memcg->oom_kill_disable = val;
 	if (!val)
 		memcg_oom_recover(memcg);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
