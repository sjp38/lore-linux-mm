Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D330C600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:26:16 -0500 (EST)
From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: [RFC,PATCH 0/2] dmapool: allocation gfp changes
Date: Wed, 2 Dec 2009 15:18:35 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200912021518.35877.roger.oksanen@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Roger Oksanen <roger.oksanen@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi,
When introducing dma pools to the e100 driver, it was noticed that allocation
failure warnings were being generated to dmesg when allocations were being
retried (in dma_pool_alloc). Patch #1 changes the allocator to suppress most
warnings (a warning every 10th retry).

Patch #2, which applies on top of patch #1, changes the GFP_ATOMIC
allocation, which allows emergency pool usage, to use the callers GFP_*
flags. This is a scary change that can cause delays in the allocation path,
but is still imho the correct way. Discussion about this approach is welcome!

Additionally, I'm wondering if dma_pool_alloc(..) should be allowed to
fail after a while even when using __GFP_WAIT. Currently it loops forever
if it can't find the requested memory. A quick grep reveals that memory
allocation failures are handled in most drivers using (pci|dma)_pool_alloc.

PATCH 1/2
Don't warn when allowed to retry allocation.

PATCH 2/2
Honor GFP_* flags.

 mm/dmapool.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
