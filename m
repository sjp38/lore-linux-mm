Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB3564G4021918
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:06:04 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BA8045DE54
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:06:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A4F245DE53
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:06:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 398B51DB803C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:06:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E171DB803B
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:06:00 +0900 (JST)
Date: Wed, 3 Dec 2008 14:05:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  15/21] memcg-show-reclaim-stat.patch
Message-Id: <20081203140512.85695b25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

added following four field to memory.stat file.
  - inactive_ratio
  - recent_rotated_anon
  - recent_rotated_file
  - recent_scanned_anon
  - recent_scanned_file

Changelog:
  - unified inactive_ratio patch and recent_rotate patch.
  - added documentation.
  - put under CONFIG_DEBUG_VM.

Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 Documentation/controllers/memory.txt |   25 +++++++++++++++++++++++++
 mm/memcontrol.c                      |   30 ++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -1810,6 +1810,36 @@ static int mem_control_stat_show(struct 
 		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
 
 	}
+
+#ifdef CONFIG_DEBUG_VM
+	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
+
+	{
+		int nid, zid;
+		struct mem_cgroup_per_zone *mz;
+		unsigned long recent_rotated[2] = {0, 0};
+		unsigned long recent_scanned[2] = {0, 0};
+
+		for_each_online_node(nid)
+			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+
+				recent_rotated[0] +=
+					mz->reclaim_stat.recent_rotated[0];
+				recent_rotated[1] +=
+					mz->reclaim_stat.recent_rotated[1];
+				recent_scanned[0] +=
+					mz->reclaim_stat.recent_scanned[0];
+				recent_scanned[1] +=
+					mz->reclaim_stat.recent_scanned[1];
+			}
+		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
+		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
+		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
+		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
+	}
+#endif
+
 	return 0;
 }
 
Index: mmotm-2.6.28-Dec02/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-Dec02.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-Dec02/Documentation/controllers/memory.txt
@@ -289,6 +289,31 @@ will be charged as a new owner of it.
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
   moved to the parent. If you want to avoid that, force_empty will be useful.
 
+5.2 stat file
+  memory.stat file includes following statistics (now)
+	cache			- # of pages from page-cache and shmem.
+	rss			- # of pages from anonymous memory.
+	pgpgin			- # of event of charging
+	pgpgout			- # of event of uncharging
+	active_anon		- # of pages on active lru of anon, shmem.
+	inactive_anon 		- # of pages on active lru of anon, shmem
+	active_file		- # of pages on active lru of file-cache
+	inactive_file		- # of pages on inactive lru of file cache
+	unevictable		- # of pages cannot be reclaimed.(mlocked etc)
+
+	Below is depend on CONFIG_DEBUG_VM.
+	inactive_ratio		- VM inernal parameter. (see mm/page_alloc.c)
+	recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
+	recent_rotated_file	- VM internal parameter. (see mm/vmscan.c)
+	recent_scanned_anon 	- VM internal parameter. (see mm/vmscan.c)
+	recent_scanned_file 	- VM internal parameter. (see mm/vmscan.c)
+
+  Memo:
+	recent_rotated means recent frequency of lru rotation.
+	recent_scanned means recent # of scans to lru.
+	showing for better debug please see the code for meanings.
+
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
