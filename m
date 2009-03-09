Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A0A006B00C1
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:39:09 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297d5kX028306
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:39:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 888CD45DE4D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:39:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62D8F45DE3E
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:39:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D1B3E08006
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:39:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C0821DB8013
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:39:05 +0900 (JST)
Date: Mon, 9 Mar 2009 16:37:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg: softlimit (Another one) v3
Message-Id: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Still RFC but maybe much better than v2.
(Reduced CC:s)

This patch implemetns softlimit for memcg.
Totally re-designed from v2.

[1/4] patch for softlimit_in_bytes.
[2/4] patch for softlimit_priority and victim scheduler.
[3/4] hooks to kswapd
[4/4] Documentation

Softlimit works when kswapd() runs and select victim cgroup to be reclaimed.

Details of calculation of parameters are not fixed yet but this version will
not be very bad. This patch uses static-priority-round-robin scheduling.
If you have better idea for implemnting dynamic-priority one, it's welcome.

I consider following usage in this patch.

Assume  softlimit supports priority 0...8 (0 is the lowest, 8 is the highest)
Example)
   /group_A/      softlimit=1G, priority=8
           /01    priority=0
           /02    prinrity=1

kswapd() will reclaim memory from 01->02->group_A if cgroup contains memory
in zone.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
