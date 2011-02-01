Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 465EE8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:18:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 379BA3EE0B3
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 09:18:10 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BD1345DE59
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 09:18:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F183A45DE4D
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 09:18:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E10CD1DB803F
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 09:18:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A93DF1DB8038
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 09:18:09 +0900 (JST)
Date: Tue, 1 Feb 2011 09:12:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix event counting breakage by recent THP update
Message-Id: <20110201091208.b2088800.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Thanks to Johannes for catching this.
And sorry for my patch, I'd like to consinder some debug check..
=
Changes in commit e401f1761c0b01966e36e41e2c385d455a7b44ee
adds nr_pages to support multiple page size in memory_cgroup_charge_statistics.

But counting the number of event nees abs(nr_pages) for increasing
counters. This patch fixes event counting.

Reported-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: mmotm-0125/mm/memcontrol.c
===================================================================
--- mmotm-0125.orig/mm/memcontrol.c
+++ mmotm-0125/mm/memcontrol.c
@@ -612,8 +612,10 @@ static void mem_cgroup_charge_statistics
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
-	else
+	else {
 		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
+		nr_pages = -nr_pages; /* for event */
+	}
 
 	__this_cpu_add(mem->stat->count[MEM_CGROUP_EVENTS], nr_pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
