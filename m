Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DCE946B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 11:35:12 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090616111535.05b5e4b0@binnacle.cx>
Date: Tue, 16 Jun 2009 11:25:29 -0400
From: starlight@binnacle.cx
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced
  by tuning?
In-Reply-To: <20090616091932.GB14241@csn.ul.ie>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
 <20090527131437.5870e342.akpm@linux-foundation.org>
 <20090527231949.GB30002@elte.hu>
 <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx>
 <20090616091932.GB14241@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

At 10:19 AM 6/16/2009 +0100, Mel Gorman wrote:

>Can you give an example of an allocation failure? Specifically, I want to
>see what sort of allocation it was and what order.

I think it's just the basic buffer allocation for
Ethernet frames arriving in the 'ixgbe' driver.  Seems
like it's one allocation per frame.  Per the original
message the allocations are made with the 'netdev_alloc_skb()'
kernel call.  The function where this code appears is
named 'ixgbe_alloc_rx_buffers()' and the comment is
"Replace used receive buffers."

The code path in question does not generate an error.  It just
increments the 'alloc_rx_buff_failed' counter for the ethX
device.  In addition it appears that the frame is dropped
only if the PCIe hardware ring-queue associated with each
interface is full.  So on the next interrupt the allocation
is retried and appears to be successful 99% of the time.

>For reliable protocols, an allocation failure should recover and the
>data get through but obviously there is a drop in network performance
>when this happens.

This is for a specialized high-volume UDP multicast application
where data loss of any kind is unacceptable.

>If the allocations are high-order and atomic, increasing min_free_kbytes
>can help, particularly in situations where there is a burst of network
>traffic. I won't know if they are atomic until I see an error message
>though.

Doesn't the use of 'netdev_alloc_skb()' kernel primitive
imply what the nature of the allocation is?  I followed the
call graph down into "kmem" land, but it's a complex place
and so I abandoned the review.

My impression is that 'min_free_kbytes' relates mainly to systems
where significant paging pressure exists.  The servers have zero
paging pressure and lots of free memory, though mostly in the
form of instantly discardable file data cache pages.  In the
past disabling the program that generates the cache pressure
has had no effect on data loss, though I haven't tried it in
relation this specific issue.

Tried increasing a few /proc/slabinfo tuneable parameters today
and this appears to have fixed the issue so far today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
