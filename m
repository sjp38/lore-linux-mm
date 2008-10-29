Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9T2ctsh011952
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 29 Oct 2008 11:38:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B641253C161
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 11:38:55 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F30D240060
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 11:38:55 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 76FAE1DB803F
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 11:38:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 3740C1DB8037
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 11:38:55 +0900 (JST)
Date: Wed, 29 Oct 2008 11:38:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [discuss][memcg] oom-kill extension
Message-Id: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Under memory resource controller(memcg), oom-killer can be invoked when it
reaches limit and no memory can be reclaimed.

In general, not under memcg, oom-kill(or panic) is an only chance to recover
the system because there is no available memory. But when oom occurs under
memcg, it just reaches limit and it seems we can do something else.

Does anyone have plan to enhance oom-kill ?

What I can think of now is
  - add an notifier to user-land.
    - receiver of notify should work in another cgroup.
    - automatically extend the limit as emergency
    - trigger fail-over process.
    - automatically create a precise report of OOM.
      - record snapshot of 'ps -elf' and so on of memcg which triggers oom.

  - freeze processes under cgroup.
    - maybe freezer cgroup should be mounted at the same time.
    - can we add memcg-oom-freezing-point in somewhere we can sleep ?
  
Is there a chance to add oom_notifier to memcg ? (netlink ?)

But the real problem is that what we can do in the kernel is limited
and we need proper userland, anyway ;)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
