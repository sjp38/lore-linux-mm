Date: Thu, 11 Apr 2002 11:39:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre5-ac3
Message-ID: <20020411183959.GE23767@holomorphy.com>
References: <20020407164439.GA5662@debian> <20020410205947.GG21206@holomorphy.com> <20020410220842.GA14573@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020410220842.GA14573@debian>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Art Haas <ahaas@neosoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2002 at 05:08:42PM -0500, Art Haas wrote:
> Sorry to hear that. I haven't had any trouble on my machine, but
> it's an old machine (200MHz Pentium), and I run desktop stuff, so
> the load the patch is exposed to on this machine must not be enough
> to trip things up. 
> I think you've dropped an "=". Maybe this is the cause of the
> other trouble you were seeing?

No, it appears to be because all pagecache locking was removed from vmscan.c
Acquisitions and releases of pagecache_lock must be converted to the
analogous acquisitions and releases of the mapping->page_lock, with proper
movement of the points it's acquired and released for the per-mapping lock.
Testing with Cerberus on SMP machines helps find these issues.

The following hunks might need a bit more critical examination.


Cheers,
Bill


--- linux-2.4.19-pre5-ac3/mm/vmscan.c.ajh	2002-04-06 15:33:00.000000000 -0600
+++ linux-2.4.19-pre5-ac3/mm/vmscan.c	2002-04-06 15:33:45.000000000 -0600
@@ -84,11 +84,10 @@
 	int maxscan;
 
 	/*
-	 * We need to hold the pagecache_lock around all tests to make sure
-	 * reclaim_page() cannot race with find_get_page() and friends.
+	 * The pagecache_lock was removed with the addition of
+	 * the radix-tree patch.
 	 */
 	spin_lock(&pagemap_lru_lock);
-	spin_lock(&pagecache_lock);
 	maxscan = zone->inactive_clean_pages;
 	while (maxscan-- && !list_empty(&zone->inactive_clean_list)) {
 		page_lru = zone->inactive_clean_list.prev;
@@ -136,13 +135,11 @@
 		zone->inactive_clean_pages--;
 		UnlockPage(page);
 	}
-	spin_unlock(&pagecache_lock);
 	spin_unlock(&pagemap_lru_lock);
 	return NULL;
 
 found_page:
 	del_page_from_inactive_clean_list(page);
-	spin_unlock(&pagecache_lock);
 	spin_unlock(&pagemap_lru_lock);
 	if (entry.val)
 		swap_free(entry);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
