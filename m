Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8515A6B02B8
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 04:20:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o718Jwdk003822
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 1 Aug 2010 17:19:58 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 204B345DE6F
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 17:19:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2A8D45DE4D
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 17:19:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D33541DB803E
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 17:19:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 838931DB803A
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 17:19:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when reclaim is encountering dirty pages
In-Reply-To: <1280529653.12852.67.camel@heimdal.trondhjem.org>
References: <20100730150601.199c5618.akpm@linux-foundation.org> <1280529653.12852.67.camel@heimdal.trondhjem.org>
Message-Id: <20100801170115.4AFC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sun,  1 Aug 2010 17:19:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Trond,

> There is that, and then there are issues with the VM simply lying to the
> filesystems.
> 
> See https://bugzilla.kernel.org/show_bug.cgi?id=16056
> 
> Which basically boils down to the following: kswapd tells the filesystem
> that it is quite safe to do GFP_KERNEL allocations in pageouts and as
> part of try_to_release_page().
> 
> In the case of pageouts, it does set the 'WB_SYNC_NONE', 'nonblocking'
> and 'for_reclaim' flags in the writeback_control struct, and so the
> filesystem has at least some hint that it should do non-blocking i/o.
> 
> However if you trust the GFP_KERNEL flag in try_to_release_page() then
> the kernel can and will deadlock, and so I had to add in a hack
> specifically to tell the NFS client not to trust that flag if it comes
> from kswapd.

Can you please elaborate your issue more? vmscan logic is, briefly, below

	if (PageDirty(page))
		pageout(page)
	if (page_has_private(page)) {
		try_to_release_page(page, sc->gfp_mask))

So, I'm interest why nfs need to writeback at ->release_page again even
though pageout() call ->writepage and it was successfull.

In other word, an argument gfp_mask of try_to_release_page() is suspected
to pass kmalloc()/alloc_page() familiy. and page allocator have already care
PF_MEMALLOC flag.

So, My question is, What do you want additional work to VM folks?
Can you please share nfs design and what we should?


btw, Another question, Recently, Xiaotian Feng posted "swap over nfs -v21"
patch series. they have new reservation memory framework. Is this help you?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
