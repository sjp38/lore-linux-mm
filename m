Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E2906B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 03:58:14 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M7x3Hx017254
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 16:59:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C8845DE5F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 16:59:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 047C545DE5C
	for <linux-mm@kvack.org>; Fri, 22 May 2009 16:59:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF7FF1DB803E
	for <linux-mm@kvack.org>; Fri, 22 May 2009 16:59:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BA1C1DB8037
	for <linux-mm@kvack.org>; Fri, 22 May 2009 16:59:02 +0900 (JST)
Date: Fri, 22 May 2009 16:57:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] fix memcg to do swap account in right way (avoid
 swap account leak)
Message-Id: <20090522165730.8791c2dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Thank you all for comments to previous patches. This is new one.
(Please see when you have free time, I don't want to annoy anyone ;)

Major difference of this version to old ones is
 - old ones tries to fix swap handling itself...
 - this one tries to fix memcg's swap accounting.

I like ideas in this patch set. (But I may need more tests.)

Major concept of this patch set for fixing mis-accounting of memcg is
"ignore a ref from swapcache when we uncharge swap."

Consists of following 3 patches. Maybe patch 1/3 can be a concern for people who
don't use memcg.

 [1/3] Adding SWAP_HAS_CACHE flag to swap_map[] array.
 Add an flag to indicate "there is swap cache" instead of "refcnt from swapcache"
 By this, we'll be able to know refcnt to swap without find_get_page(swapper_space).

 [2/3] fix memcg to handle refcnt to swap.
 There is an issue that "all swap references gone but it can't be freed/uncharged
 because its swapcache is not on memcg's LRU".
 To fix this, this patch tries to unaccount swap even if there is swap-cache.
 Need careful tests (and some fix) but I think this is a good way to go.

 This patch uncharge swap account but swp_entry is still used by swap-cache.
 So, some more work to reclaim unnecesary swap-cache will be required (at vm_swap_full())

 [3/3] count # of swap caches with "unused swp_entries".
 This patch just counts # of swap caches whose swp_entry has no reference.
 This counter + vm_swap_full() will allow us to write a function to reclaim
 swp_entry which is unused.

Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
