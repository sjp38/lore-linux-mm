Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E95786B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 04:41:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n898f6WY027790
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Sep 2009 17:41:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A79145DE51
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:41:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13ACE45DE5D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:41:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 109251DB8042
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:41:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DD44A1DB8048
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 17:41:03 +0900 (JST)
Date: Wed, 9 Sep 2009 17:39:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/4][mmotm] memcg: reduce lock contention v3
Message-Id: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch series is for reducing memcg's lock contention on res_counter, v3.
(sending today just for reporting current status in my stack.)

It's reported that memcg's res_counter can cause heavy false sharing / lock
conention and scalability is not good. This is for relaxing that.
No terrible bugs are found, I'll maintain/update this until the end of next
merge window. Tests on big-smp and new-good-idea are welcome.

This patch is on to mmotm+Nishimura's fix + Hugh's get_user_pages() patch.
But can be applied directly against mmotm, I think.

numbers:

I used 8cpu x86-64 box and run make -j 12 kernel.
Before make, make clean and drop_caches.

[Before patch(mmotm)] 3 runs
real    3m1.127s
user    4m42.143s
sys     6m22.588s

real    3m0.942s
user    4m42.377s
sys     6m24.463s

real    2m53.982s
user    4m42.635s
sys     6m23.124s

[After patch] 3 runs.
real    2m53.052s
user    4m48.095s
sys     5m43.042s

real    2m54.367s
user    4m43.738s
sys     5m40.626s

real    2m55.108s
user    4m43.367s
sys     5m40.265s


you can see 'sys' is reduced.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
