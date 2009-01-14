Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E97C26B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 22:25:12 -0500 (EST)
Message-ID: <496D5AE2.2020403@cn.fujitsu.com>
Date: Wed, 14 Jan 2009 11:24:18 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] memcg: fix a race when setting memcg.swappiness
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
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

Note we can't use hierarchy_lock here, because it doesn't protect
the create() method.

Though IMO use cgroup_lock() in simple write functions is OK,
Paul would like to avoid it. And he sugguested use a counter to
count the number of children instead of check cgrp->children list:

=================
create() does:

lock memcg_parent
memcg->swappiness = memcg->parent->swappiness;
memcg_parent->child_count++;
unlock memcg_parent

and write() does:

lock memcg
if (!memcg->child_count) {
  memcg->swappiness = swappiness;
} else {
  report error;
}
unlock memcg

destroy() does:
lock memcg_parent
memcg_parent->child_count--;
unlock memcg_parent

=================

And there is a suble differnce with checking cgrp->children,
that a cgroup is removed from parent's list in cgroup_rmdir(),
while memcg->child_count is decremented in cgroup_diput().


Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 mm/memcontrol.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2996b8..0274223 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1971,6 +1971,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 	struct mem_cgroup *parent;
+
 	if (val > 100)
 		return -EINVAL;
 
@@ -1978,15 +1979,22 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
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
