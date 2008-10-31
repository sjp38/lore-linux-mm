Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9V2pS4V021255
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Oct 2008 11:51:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 977A653C127
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:51:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 67C3124005F
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:51:28 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F4F71DB8040
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:51:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0042A1DB8038
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 11:51:28 +0900 (JST)
Date: Fri, 31 Oct 2008 11:50:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/5] memcg : some patches related to swap.
Message-Id: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

This patch is memcg update set. (the last post was 23/Oct)

This patch is agaisnt 2.6.28-rc2-mm1. (mmotm at 30/Oct)

Major changes from previous one.
 - dropped lazy_lru related patches. It's complicated and I'd like to
   design it again. (Nishimura-san reported a bug to me.)
   Fortunately, no big Hunk.

 - added a patch for swap_cache. (cut out from mem+swap controller.)
   IMHO, this is necessary to do. But previous trial (in summer) caused tons of
   troubles. I think currrent memcg's code is better than old ones and I hope
   this trial will be much easier.
 
and fixed typos and logics.

brief patch description is here. I'd like to send [1/5] in the next week.
Review and test is welcome. [2-5/5] of patches should be tested more.
And I'd like to clean up them before sending...

[1/5] change force_empty to do move account.
  - current force_empty just drops page_cgroup reference. But this means
    leak of accounting. After this patch, remaining pages at rmdir() will be
    moved to parent group.

[2/5] account swap cache
  - when processes exceed limit of memory, swap-cache can be created.
    Now, swap-cache is not accounted and can be spread over hundreds of mega
    bytes. I don't think this is sane. This patch makes swap_cache to be accounted.

[3/5] mem+swap controller config.
  - add Kconfig for mem+swap controller.

[4/5] swap_cgroup
  - create a buffer to remember account information of swap.
    Because my x86-32 test environment is poor, x86-32 test report is welcome.
    This patch uses HIGHMEM to rememver information.

[5/5]
  - mem+swap controller.
  After this patch, a page swapped-in will be accounted against an original group
  which allocated memory swapped-out.
  This is not swap controller but mem+swap controller. This limits sum of
  pages + swaps_on_disk. By this,
  - global LRU's swap-out will not hit the limit. (page is converted to swap.)
  - a group of processes leaking memory will be effectively blocked.

TODO list:
 - more optimization
 - add "shrink_usage" file
 - remove mem_cgroup_per_zone->lock and use zone->lru_lock ?
 - consider behavior of oom-kill again.
 - need some notifier to tell memory shortage as mem_notity ?
 - dirty page accountng and throttle.
 - we have to decied how to handle HUGE_PAGE
 - kernel support for hierarchy ?
 - help bio_cgroup people.

Oh, too long ;)

Thanks,
-Kame  




  




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
