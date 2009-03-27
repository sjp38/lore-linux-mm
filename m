Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EC4146B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 00:54:07 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2R512uE005157
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Mar 2009 14:01:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BAFF45DE50
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:01:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B3FF45DE55
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:01:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 55B981DB8038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:01:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7471DB8046
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 14:01:00 +0900 (JST)
Date: Fri, 27 Mar 2009 13:59:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi,

Memory cgroup's soft limit feature is a feature to tell global LRU 
"please reclaim from this memcg at memory shortage".

And Balbir's one and my one was proposed.
This is new one. (so restart from v1), this is very new-born.

While testing soft limit, my dilemma was following.

 - needs additional cost of can if implementation is naive (unavoidable?)

 - Inactive/Active rotation scheme of global LRU will be broken.

 - File/Anon reclaim ratio scheme of global LRU will be broken.
    - vm.swappiness will be ignored.

 - If using memcg's memory reclaim routine, 
    - shrink_slab() will be never called.
    - stale SwapCache has no chance to be reclaimed (stale SwapCache means
      readed but not used one.)
    - memcg can have no memory in a zone.
    - memcg can have no Anon memory
    - lumpty_reclaim() is not called.


This patch tries to avoid to use existing memcg's reclaim routine and
just tell "Hints" to global LRU. This patch is briefly tested and shows
good result to me. (But may not to you. plz brame me.)

Major characteristic is.
 - memcg will be inserted to softlimit-queue at charge() if usage excess
   soft limit.
 - softlimit-queue is a queue with priority. priority is detemined by size
   of excessing usage.
 - memcg's soft limit hooks is called by shrink_xxx_list() to show hints.
 - Behavior is affected by vm.swappiness and LRU scan rate is determined by
   global LRU's status.

I'm sorry that I'm tend not to tell enough explanation.  plz ask me.
There will be much discussion points, anyway. As usual, I'm not in hurry.


==brief test result==
On 2CPU/1.6GB bytes machine. create group A and B
  A.  soft limit=300M
  B.  no soft limit

  Run a malloc() program on B and allcoate 1G of memory. The program just
  sleeps after allocating memory and no memory refernce after it.
  Run make -j 6 and compile the kernel.

  When vm.swappiness = 60  => 60MB of memory are swapped out from B.
  When vm.swappiness = 10  => 1MB of memory are swapped out from B    

  If no soft limit, 350MB of swap out will happen from B.(swapiness=60)

I'll try much more complexed ones in the weekend.

Thanks,
-Kame































--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
