Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 714776B00C1
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:43:48 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1854882C31C
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:48:19 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AGTSvImLs26U for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 10:48:19 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4BE9282C336
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:48:16 -0500 (EST)
Date: Mon, 23 Feb 2009 10:34:58 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocato
In-Reply-To: <87prhauiry.fsf@basil.nowhere.org>
Message-ID: <alpine.DEB.1.10.0902231032150.7298@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <87prhauiry.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Feb 2009, Andi Kleen wrote:

> > Counters are surprising expensive, we spent a good chuck of our time in
> > functions like __dec_zone_page_state and __dec_zone_state. In a profiled
> > run of kernbench, the time spent in __dec_zone_state was roughly equal to
> > the combined cost of the rest of the page free path. A quick check showed
> > that almost half of the time in that function is spent on line 233 alone
> > which for me is;
> >
> > 	(*p)--;
> >
> > That's worth a separate investigation but it might be a case that
> > manipulating int8_t on the machine I was using for profiling is unusually
> > expensive.
>
> What machine was that?
>
> In general I wouldn't expect even on a system with slow char
> operations to be that expensive. It sounds more like a cache miss or a
> cache line bounce. You could possibly confirm by using appropiate
> performance counters.

I have seen similar things occur with some processors. 16 bit or 8 bit
arithmetic can be a problem.

> > Converting this to an int might be faster but the increased
> > memory consumption and cache footprint might be a problem. Opinions?
>
> One possibility would be to move the zone statistics to allocated
> per cpu data. Or perhaps just stop counting per zone at all and
> only count per cpu.

Statistics are in a structure allocated and dedicated for a certain cpu.
It cannot be per cpu data as long as the per cpu allocator has not been
merged. Cache line footprint is reduced with the per cpu allocator.

> > So, by and large it's an improvement of some sort.
>
> That seems like an understatement.

Ack. There is certainly more work to be done on the page allocator. Looks
like a good start to me though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
