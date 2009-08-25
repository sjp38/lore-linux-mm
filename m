Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BD0516B0099
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:52:10 -0400 (EDT)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P2SEGa019691
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 11:28:14 +0900
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P2Rcfw006121
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 11:27:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 937BD45DE50
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:27:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AA3B45DE4D
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:27:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53348E08005
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:27:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E296A1DB803C
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 11:27:37 +0900 (JST)
Date: Tue, 25 Aug 2009 11:25:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][preview] memcg: reduce lock contention at uncharge by
 batching
Message-Id: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

This is a preview of a patch for reduce lock contention for memcg->res_counter.
This makes series of uncharge in batch and reduce critical lock contention in
res_counter. This is still under developement and based on 2.6.31-rc7.
I'll rebase this onto mmotm if I'm ready.

I have only 8cpu(4core/2socket) system now. no significant speed up but good lock_stat.

resutlt of kernel-make // time make -j 8
[Before]
real    2m46.491s
user    4m47.008s
sys     3m32.954s


lock_stat version 0.3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                          &counter->lock:       1167034        1196935           0.52       16291.34      829793.69       18742433       45050576           0.42       30788.81     9490908.36
                          --------------
                          &counter->lock         638151          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
                          &counter->lock         558784          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60
                          --------------
                          &counter->lock         679567          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
                          &counter->lock         517368          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60

[After]
real    2m45.423s
user    4m48.522s
sys     3m29.183s
lock_stat version 0.3
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                          &counter->lock:        494955         500859           0.53        9601.11      293501.54       16311201       27502048           0.43       25483.56     6934715.75
                          --------------
                          &counter->lock         427024          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0
                          &counter->lock          73835          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60
                          --------------
                          &counter->lock         435369          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0
                          &counter->lock          65490          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
