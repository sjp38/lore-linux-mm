Date: Wed, 18 Apr 2007 12:36:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
In-Reply-To: <4625B711.8060400@google.com>
Message-ID: <Pine.LNX.4.64.0704181235090.7234@schroedinger.engr.sgi.com>
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
 <46259945.8040504@google.com> <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com>
 <4625AD3C.8010709@google.com> <Pine.LNX.4.64.0704172236140.4205@schroedinger.engr.sgi.com>
 <4625B711.8060400@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Ethan Solomita wrote:

>    While you're busy correcting me, look in swap_state.c at
> __add_to_swap_cache(). Note how, when it inserts a page into
> swapper_space.page_tree, it then does an __inc_zone_page_state(NR_FILE_PAGES).

Correct. So a page is accounted for both as anonymous and a file pages. 
That is surprising. So this patch should indeed work. Added some comments
to clarify the situation.

Index: linux-2.6.21-rc6/mm/migrate.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/migrate.c	2007-04-17 22:10:33.000000000 -0700
+++ linux-2.6.21-rc6/mm/migrate.c	2007-04-18 12:34:19.000000000 -0700
@@ -297,7 +297,7 @@ static int migrate_page_move_mapping(str
 	void **pslot;
 
 	if (!mapping) {
-		/* Anonymous page */
+		/* Anonymous page without mapping */
 		if (page_count(page) != 1)
 			return -EAGAIN;
 		return 0;
@@ -333,6 +333,19 @@ static int migrate_page_move_mapping(str
 	 */
 	__put_page(page);
 
+	/*
+	 * If moved to a different zone then also account
+	 * the page for that zone. Other VM counters will be
+	 * taken care of when we establish references to the
+	 * new page and drop references to the old page.
+	 *
+	 * Note that anonymous pages are accounted for
+	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
+	 * are mapped to swap space.
+	 */
+	__dec_zone_page_state(page, NR_FILE_PAGES);
+	__inc_zone_page_state(newpage, NR_FILE_PAGES);
+
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
