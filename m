Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F75A6B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 03:41:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L7gXvE010718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 May 2009 16:42:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8EB45DD76
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:42:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ABBD45DD72
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:42:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A82A1DB8013
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:42:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F06891DB8014
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:42:32 +0900 (JST)
Date: Thu, 21 May 2009 16:41:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] synchrouns swap freeing at zapping vmas
Message-Id: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


In these 6-7 weeks, we tried to fix memcg's swap-leak race by checking
swap is valid or not after I/O. But Andrew Morton pointed out that
"trylock in free_swap_and_cache() is not good"
Oh, yes. it's not good.

Then, this patch series is a trial to remove trylock for swapcache AMAP.
Patches are more complex and larger than expected but the behavior itself is
much appreciate than prevoius my posts for memcg...
 
This series contains 2 patches.
  1. change refcounting in swap_map.
     This is for allowing swap_map to indicate there is swap reference/cache.
  2. synchronous freeing of swap entries.
     For avoiding race, free swap_entries in appropriate way with lock_page().
     After this patch, race between swapin-readahead v.s. zap_page_range()
     will go away.
     Note: the whole code for zap_page_range() will not work until the system
     or cgroup is very swappy. So, no influence in typical case.

There are used trylocks more than this patch treats. But IIUC, they are not
racy with memcg and I don't care them.
(And....I have no idea to remove trylock() in free_pages_and_swapcache(),
 which is called via tlb_flush_mmu()....preemption disabled and using percpu.)

These patches + Nishimura-san's writeback fix will do complete work, I think.
But test is not enough.

Any comments are welcome. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
