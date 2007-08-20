Message-Id: <20070820215317.441134723@sgi.com>
References: <20070820215040.937296148@sgi.com>
Date: Mon, 20 Aug 2007 14:50:47 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 7/7] Switch of PF_MEMALLOC during writeout
Content-Disposition: inline; filename=nopfmemalloc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Switch off PF_MEMALLOC during both direct and kswapd reclaim.

This works because we are not holding any locks at that point because
reclaim is essentially complete. The write occurs when the memory on
the zones is at the high water mark so it is unlikely that writeout
will get into trouble. If so then reclaim can be called recursively to
reclaim more pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-19 23:53:47.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-19 23:55:29.000000000 -0700
@@ -1227,8 +1227,16 @@ out:
 
 		zone->prev_priority = priority;
 	}
+
+	/*
+	 * Trigger writeout. Drop PF_MEMALLOC for writeback
+	 * since we are holding no locks. Callbacks into
+	 * reclaim should be fine
+	 */
+	current->flags &= ~PF_MEMALLOC;
 	nr_reclaimed += shrink_page_list(&laundry, &sc, NULL);
 	release_lru_pages(&laundry);
+	current->flags |= PF_MEMALLOC;
 	return ret;
 }
 
@@ -1406,8 +1414,10 @@ out:
 
 		goto loop_again;
 	}
+	current->flags &= ~PF_MEMALLOC;
 	nr_reclaimed += shrink_page_list(&laundry, &sc, NULL);
 	release_lru_pages(&laundry);
+	current->flags |= PF_MEMALLOC;
 	return nr_reclaimed;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
