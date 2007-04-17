Date: Tue, 17 Apr 2007 16:56:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
In-Reply-To: <46255446.6060204@google.com>
Message-ID: <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
References: <46255446.6060204@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Ethan Solomita wrote:

>      Note that File Pages is 62040kB when MemUsed is only 4824kB. We do
> __(dec|inc)_zone_page_state(page, NR_FILE_PAGES) whenever doing a
> radix_tree_(delete|insert) from/to mapping->page_tree. Except we missed one:

Right. Sigh. Does this fix it?

Fix NR_FILE_PAGES and NR_ANON_PAGES accounting.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/migrate.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/migrate.c	2007-04-17 14:15:45.000000000 -0700
+++ linux-2.6.21-rc6/mm/migrate.c	2007-04-17 14:34:09.000000000 -0700
@@ -579,9 +579,21 @@ static int move_to_new_page(struct page 
 	else
 		rc = fallback_migrate_page(mapping, newpage, page);
 
-	if (!rc)
+	if (!rc) {
+		/*
+		 * If moved to a different zone then also account
+		 * the page for that zone. Other VM counters will be
+		 * taken care of when we establish references to the
+		 * new page and drop references to the old page.
+		 */
+		if (page_zone(newpage) != page_zone(page)) {
+			int counter = PageAnon(page) ? NR_ANON_PAGES : NR_FILE_PAGES;
+
+			dec_zone_page_state(page, counter);
+			inc_zone_page_state(newpage, counter);
+		}
 		remove_migration_ptes(page, newpage);
-	else
+	} else
 		newpage->mapping = NULL;
 
 	unlock_page(newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
