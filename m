Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 97BAA6B005A
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:22:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S4MZHw013252
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 13:22:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6BB245DE52
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:22:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B405245DE50
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:22:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 90DBF1DB803F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:22:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B0E1DB803C
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:22:34 +0900 (JST)
Date: Fri, 28 Aug 2009 13:20:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/5] memcg: reduce lock conetion
Message-Id: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

Recently, memcg's res_counter->lock contention on big server is reported and
Balbir wrote a workaround for root memcg.
It's good but we need some fix for children, too.

This set is for reducing lock conetion of memcg's children cgroup based on mmotm-Aug27.

I'm sorry I have only 8cpu machine and can't reproduce very troublesome lock conention.
Here is lock_stat of make -j 12 on my 8cpu box, befre-after this patch series.

[Before] time make -j 12 (Best time in 3 test)
real    2m55.170s
user    4m38.351s
sys     6m40.694s
lock_stat version 0.3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                          &counter->lock:       1793728        1824383           0.90       16599.78     1255869.40       24879507       44909568           0.45       31183.88    19505982.15
                          --------------
                          &counter->lock         999561          [<ffffffff81099224>] res_counter_charge+0x94/0x140
                          &counter->lock         824822          [<ffffffff8109911c>] res_counter_uncharge+0x3c/0xb0
                          --------------
                          &counter->lock         835597          [<ffffffff8109911c>] res_counter_uncharge+0x3c/0xb0
                          &counter->lock         988786          [<ffffffff81099224>] res_counter_charge+0x94/0x140

you can see this by "head" ;)

[After] time make -j 12 (Best time in 3 test..but score was very stable.)
real    2m52.612s
user    4m45.450s
sys     6m4.422s

                          &counter->lock:         11159          11406           1.02          30.35        6707.74        1097940        3957860           0.47       17652.17     1534430.74
                          --------------
                          &counter->lock           2016          [<ffffffff810991bd>] res_counter_charge+0x4d/0x110
                          &counter->lock           9390          [<ffffffff81099115>] res_counter_uncharge+0x35/0x90
                          --------------
                          &counter->lock           8962          [<ffffffff81099115>] res_counter_uncharge+0x35/0x90
                          &counter->lock           2444          [<ffffffff810991bd>] res_counter_charge+0x4d/0x110

dcache-lock, zone->lru_lock etc is much heavier than this.


I expects good result on big servers.

But this patch sereis is a  "big change". I (and memcg folks) have to be careful...


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
