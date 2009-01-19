Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 58E286B00AB
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 01:59:01 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0J6wwIg003177
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Jan 2009 15:58:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D7A445DD77
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:58:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D98D745DD70
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:58:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D571DB8045
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:58:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD5FF1DB803C
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 15:58:52 +0900 (JST)
Date: Mon, 19 Jan 2009 15:57:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: update document to mention swapoff should be test.
Message-Id: <20090119155748.acc60988.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Considering recently found problem:
 memcg-fix-refcnt-handling-at-swapoff.patch

It's better to mention about swapoff behavior in memcg_test document.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memcg_test.txt |   24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

Index: mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
===================================================================
--- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/memcg_test.txt
+++ mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
@@ -1,6 +1,6 @@
 Memory Resource Controller(Memcg)  Implementation Memo.
-Last Updated: 2008/12/15
-Base Kernel Version: based on 2.6.28-rc8-mm.
+Last Updated: 2009/1/19
+Base Kernel Version: based on 2.6.29-rc2.
 
 Because VM is getting complex (one of reasons is memcg...), memcg's behavior
 is complex. This is a document for memcg's internal behavior.
@@ -340,3 +340,23 @@ Under below explanation, we assume CONFI
 	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
 
 	and do task move, mkdir, rmdir etc...under this.
+
+ 9.7 swapoff.
+	Besides management of swap is one of complicated parts of memcg,
+	call path of swap-in at swapoff is not same as usual swap-in path..
+	It's worth to be tested explicitly.
+
+	For example, test like following is good.
+	(Shell-A)
+	# mount -t cgroup none /cgroup -t memory
+	# mkdir /cgroup/test
+	# echo 40M > /cgroup/test/memory.limit_in_bytes
+	# echo 0 > /cgroup/test/tasks
+	Run malloc(100M) program under this. You'll see 60M of swaps.
+	(Shell-B)
+	# move all tasks in /cgroup/test to /cgroup
+	# /sbin/swapoff -a
+	# rmdir /test/cgroup
+	# kill malloc task.
+
+	Of course, tmpfs v.s. swapoff test should be tested, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
