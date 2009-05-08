Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 353556B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 01:06:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n48571ua007364
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 May 2009 14:07:01 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D673C45DD74
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:07:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1DE945DD72
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:07:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B25BC1DB8013
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:07:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B82A1DB8012
	for <linux-mm@kvack.org>; Fri,  8 May 2009 14:07:00 +0900 (JST)
Date: Fri, 8 May 2009 14:05:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] fix stale swap cache account leak  in memcg v6
Message-Id: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

As Nishimura reported, there is a race at handling swap cache.

Typical cases are following (from Nishimura's mail)


== Type-1 ==
  If some pages of processA has been swapped out, it calls free_swap_and_cache().
  And if at the same time, processB is calling read_swap_cache_async() about
  a swap entry *that is used by processA*, a race like below can happen.

            processA                   |           processB
  -------------------------------------+-------------------------------------
    (free_swap_and_cache())            |  (read_swap_cache_async())
                                       |    swap_duplicate()
                                       |    __set_page_locked()
                                       |    add_to_swap_cache()
      swap_entry_free() == 0           |
      find_get_page() -> found         |
      try_lock_page() -> fail & return |
                                       |    lru_cache_add_anon()
                                       |      doesn't link this page to memcg's
                                       |      LRU, because of !PageCgroupUsed.

  This type of leak can be avoided by setting /proc/sys/vm/page-cluster to 0.


== Type-2 ==
    Assume processA is exiting and pte points to a page(!PageSwapCache).
    And processB is trying reclaim the page.

              processA                   |           processB
    -------------------------------------+-------------------------------------
      (page_remove_rmap())               |  (shrink_page_list())
         mem_cgroup_uncharge_page()      |
            ->uncharged because it's not |
              PageSwapCache yet.         |
              So, both mem/memsw.usage   |
              are decremented.           |
                                         |    add_to_swap() -> added to swap cache.

    If this page goes thorough without being freed for some reason, this page
    doesn't goes back to memcg's LRU because of !PageCgroupUsed.


Considering Type-1, it's better to avoid swapin-readahead when memcg is used.
swapin-readahead just read swp_entries which are near to requested entry. So,
pages not to be used can be on memory (on global LRU). When memcg is used,
this is not good behavior anyway.

Considering Type-2, the page should be freed from SwapCache right after WriteBack.
Free swapped out pages as soon as possible is a good nature to memcg, anyway.

The patch set includes followng
 [1/2] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
 [2/2] fix swap cache handling.


Test result is good under my test. Nishimura, could you try ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
