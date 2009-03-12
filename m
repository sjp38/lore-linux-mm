Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7E6D06B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 20:05:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C05j4r002306
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 09:05:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C479345DD72
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:05:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A00B845DD76
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:05:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87E571DB8013
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:05:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 135641DB8015
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:05:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] memcg: softlimit caller via kswapd
In-Reply-To: <20090310190242.GG26837@balbir.in.ibm.com>
References: <20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com> <20090310190242.GG26837@balbir.in.ibm.com>
Message-Id: <20090312090311.439B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 09:05:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Balbir-san,

> Looks like a dirty hack, replacing sc-> fields this way. I've
> experimented a lot with per zone balancing and soft limits and it does
> not work well. The reasons
> 
> 1. zone watermark balancing has a different goal than soft limit. Soft
> limits are more of a mem cgroup feature rather than node/zone feature.
> IIRC, you called reclaim as hot-path for soft limit reclaim, my
> experimentation is beginning to show changed behaviour
> 
> On a system with 4 CPUs and 4 Nodes, I find all CPUs spending time
> doing reclaim, putting the hook in the reclaim path, makes the reclaim
> dependent on the number of tasks and contention.
> 
> What does your test data/experimentation show?

you pointed out mainline kernel bug, not kamezawa patch's bug ;-)
Could you please try following patch?

sorry, this is definitly my fault.


---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bfd853b..15f7737 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		int file = is_file_lru(l);
 		int scan;
 
-		scan = zone_page_state(zone, NR_LRU_BASE + l);
+		scan = zone_nr_pages(zone, sc, l);
 		if (priority) {
 			scan >>= priority;
 			scan = (scan * percent[file]) / 100;
-- 
1.6.0.6



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
