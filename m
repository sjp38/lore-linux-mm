Date: Fri, 2 Nov 2007 16:58:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: start_isolate_page_range() question/offline_pages() bug ?
Message-Id: <20071102165825.73d15c5b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1193944769.26106.34.camel@dyn9047017100.beaverton.ibm.com>
References: <1193944769.26106.34.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Badari, and Andrew

This is bugfix for memory hotremove.

But we'll need x86_64 memory hotremove patch set to test this easily.

Then, I'd like to schedule this with Goto's ioresource patch and
Badari's fix and this one and x86_64 memory hotremove support patch
against the next -mm.

This is quick fix. Thank you, Badari.

Regards,
-Kame
==

We should unset migrate type "ISOLATE" when we successfully removed
memory. But current code has BUG and cannot works well.

This patch also includes bugfix? to change get_pageblock_flags to
get_pageblock_migratetype().

Tested with x86_64 memory hotremove (private) patch and works well.
(It will be posted if things settled.)

Thanks to Badari Pulavarty for finding this.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memory_hotplug.c |    4 ++--
 mm/page_isolation.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: devel-2.6.23-mm1/mm/memory_hotplug.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memory_hotplug.c
+++ devel-2.6.23-mm1/mm/memory_hotplug.c
@@ -536,8 +536,8 @@ repeat:
 	/* Ok, all of our target is islaoted.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
-	/* reset pagetype flags */
-	start_isolate_page_range(start_pfn, end_pfn);
+	/* reset pagetype flags and makes migrate type to be MOVABLE */
+	undo_isolate_page_range(start_pfn, end_pfn);
 	/* removal success */
 	zone = page_zone(pfn_to_page(start_pfn));
 	zone->present_pages -= offlined_pages;
Index: devel-2.6.23-mm1/mm/page_isolation.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/page_isolation.c
+++ devel-2.6.23-mm1/mm/page_isolation.c
@@ -55,7 +55,7 @@ start_isolate_page_range(unsigned long s
 	return 0;
 undo:
 	for (pfn = start_pfn;
-	     pfn <= undo_pfn;
+	     pfn < undo_pfn;
 	     pfn += pageblock_nr_pages)
 		unset_migratetype_isolate(pfn_to_page(pfn));
 
@@ -76,7 +76,7 @@ undo_isolate_page_range(unsigned long st
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (!page || get_pageblock_flags(page) != MIGRATE_ISOLATE)
+		if (!page || get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 			continue;
 		unset_migratetype_isolate(page);
 	}
@@ -126,7 +126,7 @@ int test_pages_isolated(unsigned long st
 	 */
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page && get_pageblock_flags(page) != MIGRATE_ISOLATE)
+		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 			break;
 	}
 	if (pfn < end_pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
