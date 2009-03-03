Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E437E6B00AD
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:42:40 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3149630556C
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:48:01 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7cu64Yy+Sh0S for <linux-mm@kvack.org>;
	Tue,  3 Mar 2009 11:48:01 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 53530305571
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:47:56 -0500 (EST)
Date: Tue, 3 Mar 2009 11:31:46 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
In-Reply-To: <20090302112122.GC21145@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903031130550.26454@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235639427.11390.11.camel@minggr> <20090226110336.GC32756@csn.ul.ie> <1235647139.16552.34.camel@penberg-laptop> <20090226112232.GE32756@csn.ul.ie> <1235724283.11610.212.camel@minggr>
 <20090302112122.GC21145@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lin Ming <ming.m.lin@intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009, Mel Gorman wrote:

> Going by the vanilla kernel, a *large* amount of time is spent doing
> high-order allocations. Over 25% of the cost of buffered_rmqueue() is in
> the branch dealing with high-order allocations. Does UDP-U-4K mean that 8K
> pages are required for the packets? That means high-order allocations and
> high contention on the zone-list. That is bad obviously and has implications
> for the SLUB-passthru patch because whether 8K allocations are handled by
> SL*B or the page allocator has a big impact on locking.
>
> Next, a little over 50% of the cost get_page_from_freelist() is being spent
> acquiring the zone spinlock. The implication is that the SL*B allocators
> passing in order-1 allocations to the page allocator are currently going to
> hit scalability problems in a big way. The solution may be to extend the
> per-cpu allocator to handle magazines up to PAGE_ALLOC_COSTLY_ORDER. I'll
> check it out.

Then we are increasing the number of queues dramatically in the page
allocator. More of a memory sink. Less cache hotness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
