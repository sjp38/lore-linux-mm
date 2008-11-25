Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAP9YDAg025634
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Nov 2008 18:34:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C7745DD74
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 18:34:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34A2345DD72
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 18:34:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FB8F1DB803F
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 18:34:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6321DB803A
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 18:34:12 +0900 (JST)
Date: Tue, 25 Nov 2008 18:33:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: force_emtpy fix to confirm cgroup has no
 tasks.
Message-Id: <20081125183326.21f2067d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

This is a fix to memcg-new-force_empty-to-free-pages-under-group.patch

Thanks,
-Kame
==
Now, force_empty can be called and do reclaim pages
while there are tasks. fix it.
(reclaim occurs but move doesn't occur in this case.)

And, we have interface to count # of tasks under cgroup.
Using it is better.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
 mm/memcontrol.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: mmotm-2.6.28-Nov24/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov24.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov24/mm/memcontrol.c
@@ -1481,6 +1481,7 @@ static int mem_cgroup_force_empty(struct
 	int ret;
 	int node, zid, shrink;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct cgroup *cgrp = mem->css.cgroup;
 
 	css_get(&mem->css);
 
@@ -1491,7 +1492,7 @@ static int mem_cgroup_force_empty(struct
 move_account:
 	while (mem->res.usage > 0) {
 		ret = -EBUSY;
-		if (atomic_read(&mem->css.cgroup->count) > 0)
+		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
 		ret = -EINTR;
 		if (signal_pending(current))
@@ -1523,8 +1524,10 @@ out:
 	return ret;
 
 try_to_free:
-	/* returns EBUSY if we come here twice. */
-	if (shrink) {
+	/* returns EBUSY if there is a task or if we come here twice. */
+	if (cgroup_task_count(cgrp)
+	    || !list_empty(&cgrp->children)
+	    || shrink) {
 		ret = -EBUSY;
 		goto out;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
