Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DEB76B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 06:06:36 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9QA6X5H020038
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 Oct 2010 19:06:33 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8219145DE54
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:06:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EFE045DE53
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:06:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 479021DB803F
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:06:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 015CC1DB805D
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 19:06:29 +0900 (JST)
Date: Tue, 26 Oct 2010 19:00:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/3] big chunk memory allocator v2
Message-Id: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

Hi, here is version 2.

I only did small test and it seems to work (but I think there will be bug...)
I post this now just because I'll be out of office 10/31-11/15 with ksummit and
a private trip.

Any comments are welcome but please see the interface is enough for use cases or
not.  For example) If MAX_ORDER alignment is too bad, I need to rewrite almost
all code.

Now interface is:


struct page *__alloc_contig_pages(unsigned long base, unsigned long end,
                        unsigned long nr_pages, int align_order,
                        int node, gfp_t gfpflag, nodemask_t *mask)

 * @base: the lowest pfn which caller wants.
 * @end:  the highest pfn which caller wants.
 * @nr_pages: the length of a chunk of pages to be allocated.
 * @align_order: alignment of start address of returned chunk in order.
 *   Returned' page's order will be aligned to (1 << align_order).If smaller
 *   than MAX_ORDER, it's raised to MAX_ORDER.
 * @node: allocate near memory to the node, If -1, current node is used.
 * @gfpflag: see include/linux/gfp.h
 * @nodemask: allocate memory within the nodemask.

If the caller wants a FIXED address, set end - base == nr_pages.

The patch is based onto the latest mmotm + Bob's 3 patches for fixing
memory_hotplug.c (they are queued.)

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
