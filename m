Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 28E626B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:11:29 -0500 (EST)
Message-ID: <496D9DFA.1050602@cn.fujitsu.com>
Date: Wed, 14 Jan 2009 16:10:34 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: fix a race when setting memory.swappiness
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(suppose: memcg->use_hierarchy == 0 and memcg->swappiness == 60)

echo 10 > /memcg/0/swappiness   |
  mem_cgroup_swappiness_write() |
    ...                         | echo 1 > /memcg/0/use_hierarchy
                                | mkdir /mnt/0/1
                                |   sub_memcg->swappiness = 60;
    memcg->swappiness = 10;     |

In the above scenario, we end up having 2 different swappiness
values in a single hierarchy.

We should hold cgroup_lock() when cheking cgrp->children list.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb62b43..bc8f101 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1992,6 +1992,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup *parent;
+
 	if (val > 100)
 		return -EINVAL;
 
@@ -1999,15 +2000,22 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 		return -EINVAL;
 
 	parent = mem_cgroup_from_cont(cgrp->parent);
+
+	cgroup_lock();
+
 	/* If under hierarchy, only empty-root can set this value */
 	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children)))
+	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+		cgroup_unlock();
 		return -EINVAL;
+	}
 
 	spin_lock(&memcg->reclaim_param_lock);
 	memcg->swappiness = val;
 	spin_unlock(&memcg->reclaim_param_lock);
 
+	cgroup_unlock();
+
 	return 0;
 }
 
-- 
1.5.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
