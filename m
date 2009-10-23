Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A630D6B0062
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 13:11:41 -0400 (EDT)
Message-Id: <20091023171051.993073846@sequoia.sous-sol.org>
Date: Fri, 23 Oct 2009 10:10:51 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: [RFC PATCH 0/2] allow bootmem to be freed to allocator late
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: David Woodhouse <dwmw2@infradead.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Currently there is no way to release bootmem once the bootmem allocator
frees all unreserved memory.  This adds the ability to free reserved
pages directly to the page allocator after the bootmem allocator metadata
is already freed.  It's limited in scope since it's still all marked
__init, and creates a new entry point free_bootmem_late rather than
trying to do this automatically in free_bootmem.  Hence the RFC...

With this we are able to do something like allocate swiotlb, and then
free it later if we discover we had a hw iommu that doesn't need swiotlb.

 include/linux/bootmem.h |    1 +
 mm/bootmem.c            |   98 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 77 insertions(+), 22 deletions(-)

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
