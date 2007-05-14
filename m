From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/2] Two patches to address bug report in relation to high-order atomic allocations
Date: Mon, 14 May 2007 18:32:18 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nicolas.mailhot@laposte.net, apw@shadowen.org, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The following two patches should address a problem reported at
http://lkml.org/lkml/2007/5/10/550 . The issue was that atomic high-order
allocations were failing even though free memory was available at the
requested order.

The first patch addresses an observation in the logs that the majority of
free memory was at lower orders even though it was known that high-order
allocations were regularly required. This patch informs kswapd that there
is a known high-order that allocation will regularly request, triggering
watermark reclaim at that order. Arguably, this minimum value that kswapd
reclaims at should be PAGE_ALLOC_COSTLY_ORDER.

The second patch addresses an issue where the callers ability to enter
direct reclaim is not taken into account when checking watermarks. The
patch alters zone_watermarks_ok() so that it only checks the watermarks at
order-0 when the caller is flagged ALLOC_HIGH or ALLOC_HARDER.

Nicolas, I would appreciate if you would test 2.6.21-mm2 with both of these
patches applied. They have changed in a number of respects from what what I
sent you over the weekend and I'd like to be sure the fix still works. Thanks
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
