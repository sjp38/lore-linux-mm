Message-ID: <4020BE45.10007@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:41:25 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 3/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------070601050309000904020602"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070601050309000904020602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> 3/5: vm-lru-info.patch
>     Keep more referenced info in the active list. Should also improve
>     system time in some cases. Helps swapping loads significantly.
>



--------------070601050309000904020602
Content-Type: text/plain;
 name="vm-lru-info.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-lru-info.patch"


When refill_inactive_list is running !reclaim_mapped, it clears a mapped
pages referenced bits then puts them back to the head of the active list.
Referenced and non referenced mapped pages are treated the same, so you
lose the "referenced" information.

This patch causes the referenced bits to not be cleared during !reclaim_mapped.

It improves heavy swapping performance significantly.


 linux-2.6-npiggin/mm/vmscan.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff -puN mm/vmscan.c~vm-lru-info mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-lru-info	2004-02-04 14:09:45.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-02-04 14:09:45.000000000 +1100
@@ -711,6 +711,16 @@ refill_inactive_zone(struct zone *zone, 
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
+
+			/*
+			 * Don't clear page referenced if we're not going
+			 * to use it.
+			 */
+			if (!reclaim_mapped) {
+				list_add(&page->lru, &l_ignore);
+				continue;
+			}
+
 			/*
 			 * probably it would be useful to transfer dirty bit
 			 * from pte to the @page here.
@@ -722,10 +732,6 @@ refill_inactive_zone(struct zone *zone, 
 				continue;
 			}
 			pte_chain_unlock(page);
-			if (!reclaim_mapped) {
-				list_add(&page->lru, &l_ignore);
-				continue;
-			}
 		}
 		/*
 		 * FIXME: need to consider page_count(page) here if/when we

_

--------------070601050309000904020602--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
