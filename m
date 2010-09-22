Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3B8F26B007B
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 01:13:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8M5DSSa029881
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Sep 2010 14:13:28 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 786F345DE7B
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:13:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E53C45DE5D
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:13:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34D2D1DB8051
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:13:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BFF881DB8053
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:13:27 +0900 (JST)
Date: Wed, 22 Sep 2010 14:08:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][-mm] memcg: generic filestat update interface.
Message-Id: <20100922140817.a7ac57c2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


based on mmotm and other memory cgroup patches in -mm queue.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch extracts core logic of mem_cgroup_update_file_mapped() as
mem_cgroup_update_file_stat() and add a skin.

As a planned future update, memory cgroup has to count dirty pages to implement
dirty_ratio/limit. And more, the number of dirty pages is required to kick flusher
thread to start writeback. (Now, no kick.)

This patch is preparation for it and makes other statistics implementation
clearer. Just a clean up.

Note:
In previous patch series, I wrote a more complicated patch to make the
more generic and wanted to avoid using switch(). But now, we found page_mapped()
check is necessary for updage_file_mapepd().We can't avoid to add some conditions.
I hope this style is enough easy to read and to maintainance.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

Index: mmotm-0915/mm/memcontrol.c
===================================================================
--- mmotm-0915.orig/mm/memcontrol.c
+++ mmotm-0915/mm/memcontrol.c
@@ -1575,7 +1575,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * small, we check MEM_CGROUP_ON_MOVE percpu value and detect there are
  * possibility of race condition. If there is, we take a lock.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+
+static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -1597,13 +1598,18 @@ void mem_cgroup_update_file_mapped(struc
 		if (!mem || !PageCgroupUsed(pc))
 			goto out;
 	}
-	if (val > 0) {
-		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		SetPageCgroupFileMapped(pc);
-	} else {
-		this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		if (!page_mapped(page)) /* for race between dec->inc counter */
+
+	this_cpu_add(mem->stat->count[idx], val);
+
+	switch (idx) {
+	case MEM_CGROUP_STAT_FILE_MAPPED:
+		if (val > 0)
+			SetPageCgroupFileMapped(pc);
+		else if (!page_mapped(page))
 			ClearPageCgroupFileMapped(pc);
+		break;
+	default:
+		BUG();
 	}
 
 out:
@@ -1613,6 +1619,11 @@ out:
 	return;
 }
 
+void mem_cgroup_update_file_mapped(struct page *page, int val)
+{
+	mem_cgroup_update_file_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, val);
+}
+
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
