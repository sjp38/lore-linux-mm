Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 81E146B017D
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 04:11:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9F8BpG9013926
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 15 Oct 2010 17:11:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CC5745DE51
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:11:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDA0E45DE53
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:11:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B5D5E1DB8049
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:11:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 578231DB804B
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:11:50 +0900 (JST)
Date: Fri, 15 Oct 2010 17:06:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/2] memcg: some updates to move_account and file_stat
 races
Message-Id: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


At implementing dirty page accounting support, one of problem is that
PG_writeback update can be called in IRQ context. So, following kind of dead-lock
can be considered.

  lock_page_cgroup()
	<--------------- IRQ
			  try to update Writeback state of memcg
		          lock_page_cgroup()
			  DEAD LOCK

To avoid this, one idea is IRQ disabling in lock_page_cgroup() but our concern is
it's too heavy. 

Considering more, there are facts
  -  why update_file_stat() has to take lock_page_cgroup() is just for avoiding
     race with move_account(). There are no race with charge/uncharge.

So, this series adds a new lock for mutual exection of move_account() and
update_file_stat(). This lock is always taken under IRQ disable.
This adds new lock to move_account()....so this makes move_account() slow.
It's a trade-off to be considered.


This series contains 2 patches. One is a trial to performance improvement,
next one is adding a new lock.
They are independent from each other.
All are onto mmotm-1014 + removing memcg-reduce-lock-hold-time-during-charge-moving.patch

Scores on my box at moving 8GB anon process.

== mmotm ==
root@bluextal kamezawa]# time echo 2530 > /cgroup/B/tasks

real    0m0.792s
user    0m0.000s
sys     0m0.780s

== After patch 1==
[root@bluextal kamezawa]# time echo 2257 > /cgroup/B/tasks

real    0m0.694s
user    0m0.000s
sys     0m0.683s

[After Patch #2]
[root@bluextal kamezawa]# time echo 2238 > /cgroup/B/tasks

real    0m0.741s
user    0m0.000s
sys     0m0.730s

Any comments/advices are welcome.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
