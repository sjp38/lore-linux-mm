Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B7BC98D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:56:49 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A5F53EE0C0
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07A0E45DE6B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2AED45DE61
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D17A91DB8042
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 992D71DB8040
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:46 +0900 (JST)
Date: Thu, 21 Apr 2011 12:50:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3/] fix mem_cgroup_watemark_ok (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
Message-Id: <20110421125005.eb2be43c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org


Ying, I noticed this at test. please fix the code in your set.
==
if low_wmark_distance = 0, mem_cgroup_watermark_ok() returns
false when usage hits limit.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    3 +++
 1 file changed, 3 insertions(+)

Index: mmotm-Apr14/mm/memcontrol.c
===================================================================
--- mmotm-Apr14.orig/mm/memcontrol.c
+++ mmotm-Apr14/mm/memcontrol.c
@@ -5062,6 +5062,9 @@ int mem_cgroup_watermark_ok(struct mem_c
 	long ret = 0;
 	int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
 
+	if (!mem->low_wmark_distance)
+		return 1;
+
 	VM_BUG_ON((charge_flags & flags) == flags);
 
 	if (charge_flags & CHARGE_WMARK_LOW)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
