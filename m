Date: Thu, 16 Mar 2006 01:31:41 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page migration reorg patch
Message-Id: <20060316013141.16c28224.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603151828001.30650@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
	<20060315175544.6f9adc59.akpm@osdl.org>
	<Pine.LNX.4.64.0603151828001.30650@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, marcelo.tosatti@cyclades.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> This patch centralizes the page migration functions in anticipation of
>  additional tinkering. Creates a new file mm/migrate.c


mm/migrate.c: In function `migrate_page_remove_references':
mm/migrate.c:200: warning: implicit declaration of function `__put_page'
mm/migrate.c: In function `isolate_lru_page':
mm/migrate.c:482: warning: implicit declaration of function `TestClearPageLRU'


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/migrate.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN mm/migrate.c~page-migration-reorg-fixes mm/migrate.c
--- devel/mm/migrate.c~page-migration-reorg-fixes	2006-03-16 01:28:18.000000000 -0800
+++ devel-akpm/mm/migrate.c	2006-03-16 01:28:18.000000000 -0800
@@ -26,6 +26,8 @@
 #include <linux/cpuset.h>
 #include <linux/swapops.h>
 
+#include "internal.h"
+
 /* The maximum number of pages to take off the LRU for migration */
 #define MIGRATE_CHUNK_SIZE 256
 
@@ -479,9 +481,10 @@ int isolate_lru_page(struct page *page)
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
 		spin_lock_irq(&zone->lru_lock);
-		if (TestClearPageLRU(page)) {
+		if (PageLRU(page)) {
 			ret = 1;
 			get_page(page);
+			ClearPageLRU(page);
 			if (PageActive(page))
 				del_page_from_active_list(zone, page);
 			else
_


This wasn't compile tested and it wasn't runtime tested.  But the worrisome
part is that the patch failed to bring over changes which were made by
earlier patches.  So it possibly reverts important changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
