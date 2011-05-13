Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 959FA6B0024
	for <linux-mm@kvack.org>; Thu, 12 May 2011 23:17:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 296303EE0AE
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:17:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E85945DE69
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:17:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E708645DE55
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:17:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D0808E08003
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:17:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91DB1E08001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:17:13 +0900 (JST)
Date: Fri, 13 May 2011 12:10:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>


ZONE_CONGESTED should be a state of global memory reclaim.
If not, a busy memcg sets this and give unnecessary throttoling in
wait_iff_congested() against memory recalim in other contexts. This makes
system performance bad.

I'll think about "memcg is congested!" flag is required or not, later.
But this fix is required 1st.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: mmotm-May11/mm/vmscan.c
===================================================================
--- mmotm-May11.orig/mm/vmscan.c
+++ mmotm-May11/mm/vmscan.c
@@ -941,7 +941,8 @@ keep_lumpy:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty == nr_congested && nr_dirty != 0)
+	if (scanning_global_lru(sc) &&
+	    nr_dirty == nr_congested && nr_dirty != 0)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
