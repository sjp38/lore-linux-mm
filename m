Date: Tue, 17 Apr 2007 22:12:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
In-Reply-To: <46259945.8040504@google.com>
Message-ID: <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com>
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
 <46259945.8040504@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2007, Ethan Solomita wrote:

> > Fix NR_FILE_PAGES and NR_ANON_PAGES accounting.
> >   
> 
>    I don't think that there's a problem with NR_ANON_PAGES. unmap_and_move(),
> the caller of move_to_new_page(), calls try_to_unmap() which calls
> try_to_unmap_anon() which calls try_to_unmap_one() which calls
> page_remove_rmap() which in turn makes the call to __dec_zone_page_state. i.e.
> the rmap() code is handling NR_ANON_PAGES and NR_FILE_MAPPED pages correctly.

Hmmmm...... Ok I see that NR_ANON_PAGES is decremented. But where does 
NR_ANON_PAGES get incremented for the new zone? Ahh in page_add_anon_rmap. 
So that is fine the same way as NR_FILE_MAPPED.

> It's just the NR_FILE_PAGES which are tied to the mapping's page tree, where
> the problem lies.

Ah. I see.

However, anonymous pages may also have a mapping (swap). So we need to 
check first that it is not an anonymous page and then eventually shift 
the count between zones.

Do you think this is right?


Index: linux-2.6.21-rc6/mm/migrate.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/migrate.c	2007-04-17 17:01:58.000000000 -0700
+++ linux-2.6.21-rc6/mm/migrate.c	2007-04-17 22:08:22.000000000 -0700
@@ -333,6 +333,17 @@ static int migrate_page_move_mapping(str
 	 */
 	__put_page(page);
 
+	/*
+	 * If moved to a different zone then also account
+	 * the page for that zone. Other VM counters will be
+	 * taken care of when we establish references to the
+	 * new page and drop references to the old page.
+	 */
+	if (page_zone(newpage) != page_zone(page) && !PageAnon(page)) {
+		__dec_zone_page_state(page, NR_FILE_PAGES);
+		__inc_zone_page_state(newpage, NR_FILE_PAGES);
+	}
+
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
