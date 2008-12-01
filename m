Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB1CJpvn028952
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 21:19:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 39C8A2AEA8E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:19:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A211EF081
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:19:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E774F1DB803A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:19:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F1C31DB8041
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 21:19:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 11/11] memcg: show reclaim_stat
In-Reply-To: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081201211905.1CEB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 21:19:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

added following four field to memory.stat file.

  - recent_rotated_anon
  - recent_rotated_file
  - recent_scanned_anon
  - recent_scanned_file

it is useful for memcg reclaim debugging.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memcontrol.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1799,6 +1799,31 @@ static int mem_control_stat_show(struct 
 
 	cb->fill(cb, "inactive_ratio", mem_cont->inactive_ratio);
 
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
+
 	return 0;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
