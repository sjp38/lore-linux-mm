Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AED2F6B004F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 00:55:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S4uSXu031514
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 13:56:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B897345DD80
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:56:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 954E745DD7E
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:56:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 753831DB803E
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:56:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AFAEE08005
	for <linux-mm@kvack.org>; Thu, 28 May 2009 13:56:28 +0900 (JST)
Date: Thu, 28 May 2009 13:54:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] memcg fix swap accounting (28/May)
Message-Id: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Removed "RFC"

This patch series is restructured as following. some bugs are fixed.
Thank you for all your helps.

[1/4] ....change interface of swap_duplicate()/swap_free()
    Adds an function swapcache_prepare() and swapcache_free().

[2/4] ....add SWAP_HAS_CACHE flag and modify reference counting in swap_map
    Add SWAP_HAS_CACHE flag to swap_map array for knowing an information that
    "there is an only swap cache and swap has no reference" 
    without extra call of find_get_page().

[3/4] ....reclaim swap-cache-only swap_entry when get_swap_page() find it.
    Now, swap_map can tell "there is no reference other than cache", we
    can reclaim it if necessary.
    This code reclaim swap entries if
    - vm_swap_full()==ture
    && there is no free swap cluster
    && get_swap_page() finds unused swap entry.

[4/4].... fix memcg's swap accounting
    This is for fixing memcg's swap account leak. like this
==
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
==
    This patch tries to fix this by uncharging account when swap's refcnt goes
    to 0 even if there is an unused swap-cache.

    Works quite well in my test.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
