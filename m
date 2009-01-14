Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BFF836B0055
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:11:40 -0500 (EST)
Message-ID: <496D9E0C.4060806@cn.fujitsu.com>
Date: Wed, 14 Jan 2009 16:10:52 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: fix return value of mem_cgroup_hierarchy_write()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When there are sub-dirs, writing to memory.use_hierarchy returns -EBUSY,
this doesn't seem to fit the meaning of EBUSY, and is inconsistent with
memory.swappiness, which returns -EINVAL in this case.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 mm/memcontrol.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bc8f101..2497f7d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1760,6 +1760,9 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	struct cgroup *parent = cont->parent;
 	struct mem_cgroup *parent_mem = NULL;
 
+	if (val != 0 && val != 1)
+		return -EINVAL;
+
 	if (parent)
 		parent_mem = mem_cgroup_from_cont(parent);
 
@@ -1773,12 +1776,9 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	 * set if there are no children.
 	 */
 	if ((!parent_mem || !parent_mem->use_hierarchy) &&
-				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+	    list_empty(&cont->children))
 			mem->use_hierarchy = val;
-		else
-			retval = -EBUSY;
-	} else
+	else
 		retval = -EINVAL;
 	cgroup_unlock();
 
-- 
1.5.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
