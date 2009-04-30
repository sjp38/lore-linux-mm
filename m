Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4CEDB6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:25:26 -0400 (EDT)
Date: Thu, 30 Apr 2009 14:25:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <20090430132544.GB21997@csn.ul.ie>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 10:09:48PM +0100, Hugh Dickins wrote:
> On an x86_64 with 4GB ram, tcp_init()'s call to alloc_large_system_hash(),
> to allocate tcp_hashinfo.ehash, is now triggering an mmotm WARN_ON_ONCE on
> order >= MAX_ORDER - it's hoping for order 11.  alloc_large_system_hash()
> had better make its own check on the order.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Looks good

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

As I was looking there, it seemed that alloc_large_system_hash() should be
using alloc_pages_exact() instead of having its own "give back the spare
pages at the end of the buffer" logic. If alloc_pages_exact() was used, then
the check for an order >= MAX_ORDER can be pushed down to alloc_pages_exact()
where it may catch other unwary callers.

How about adding the following patch on top of yours?

==== CUT HERE ====
Use alloc_pages_exact() in alloc_large_system_hash() to avoid duplicated logic

alloc_large_system_hash() has logic for freeing unused pages at the end
of an power-of-two-pages-aligned buffer that is a duplicate of what is in
alloc_pages_exact(). This patch converts alloc_large_system_hash() to use
alloc_pages_exact().

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   27 +++++----------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b3da0f..c94b140 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1942,6 +1942,9 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	unsigned int order = get_order(size);
 	unsigned long addr;
 
+	if (order >= MAX_ORDER)
+		return NULL;
+
 	addr = __get_free_pages(gfp_mask, order);
 	if (addr) {
 		unsigned long alloc_end = addr + (PAGE_SIZE << order);
@@ -4755,28 +4758,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 			table = alloc_bootmem_nopanic(size);
 		else if (hashdist)
 			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
-		else {
-			unsigned long order = get_order(size);
-
-			if (order < MAX_ORDER)
-				table = (void *)__get_free_pages(GFP_ATOMIC,
-								order);
-			/*
-			 * If bucketsize is not a power-of-two, we may free
-			 * some pages at the end of hash table.
-			 */
-			if (table) {
-				unsigned long alloc_end = (unsigned long)table +
-						(PAGE_SIZE << order);
-				unsigned long used = (unsigned long)table +
-						PAGE_ALIGN(size);
-				split_page(virt_to_page(table), order);
-				while (used < alloc_end) {
-					free_page(used);
-					used += PAGE_SIZE;
-				}
-			}
-		}
+		else
+			table = alloc_pages_exact(PAGE_ALIGN(size), GFP_ATOMIC);
 	} while (!table && size > PAGE_SIZE && --log2qty);
 
 	if (!table)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
