Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 887406B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 17:10:02 -0400 (EDT)
Date: Wed, 29 Apr 2009 22:09:48 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On an x86_64 with 4GB ram, tcp_init()'s call to alloc_large_system_hash(),
to allocate tcp_hashinfo.ehash, is now triggering an mmotm WARN_ON_ONCE on
order >= MAX_ORDER - it's hoping for order 11.  alloc_large_system_hash()
had better make its own check on the order.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Should probably follow
page-allocator-do-not-sanity-check-order-in-the-fast-path-fix.patch

Cc'ed DaveM and netdev, just in case they're surprised it was asking for
so much, or disappointed it's not getting as much as it was asking for.

 mm/page_alloc.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- 2.6.30-rc3-mm1/mm/page_alloc.c	2009-04-29 21:01:08.000000000 +0100
+++ mmotm/mm/page_alloc.c	2009-04-29 21:12:04.000000000 +0100
@@ -4765,7 +4765,10 @@ void *__init alloc_large_system_hash(con
 			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
 		else {
 			unsigned long order = get_order(size);
-			table = (void*) __get_free_pages(GFP_ATOMIC, order);
+
+			if (order < MAX_ORDER)
+				table = (void *)__get_free_pages(GFP_ATOMIC,
+								order);
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
