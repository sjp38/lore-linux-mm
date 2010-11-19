Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D9B46B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 03:16:18 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAJ8GDem014390
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Nov 2010 17:16:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EA23445DE4F
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:16:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BE09745DE4E
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:16:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EEC9CE08003
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:16:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 72B73E08007
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:16:11 +0900 (JST)
Date: Fri, 19 Nov 2010 17:10:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] big chunk memory allocator v4
Message-Id: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minchan.kim@gmail.com, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this is an updated version. 

No major changes from the last one except for page allocation function.
removed RFC.

Order of patches is

[1/4] move some functions from memory_hotplug.c to page_isolation.c
[2/4] search physically contiguous range suitable for big chunk alloc.
[3/4] allocate big chunk memory based on memory hotplug(migration) technique
[4/4] modify page allocation function.

For what:

  I hear there is requirements to allocate a chunk of page which is larger than
  MAX_ORDER. Now, some (embeded) device use a big memory chunk. To use memory,
  they hide some memory range by boot option (mem=) and use hidden memory
  for its own purpose. But this seems a lack of feature in memory management.

  This patch adds 
	alloc_contig_pages(start, end, nr_pages, gfp_mask)
  to allocate a chunk of page whose length is nr_pages from [start, end)
  phys address. This uses similar logic of memory-unplug, which tries to
  offline [start, end) pages. By this, drivers can allocate 30M or 128M or
  much bigger memory chunk on demand. (I allocated 1G chunk in my test).

  But yes, because of fragmentation, this cannot guarantee 100% alloc.
  If alloc_contig_pages() is called in system boot up or movable_zone is used,
  this allocation succeeds at high rate.

  I tested this on x86-64, and it seems to work as expected. But feedback from
  embeded guys are appreciated because I think they are main user of this
  function.

Thanks,
-Kame


  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
