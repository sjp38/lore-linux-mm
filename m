Date: Mon, 8 Jan 2001 19:52:00 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <20010108181028.F9321@redhat.com>
Message-ID: <Pine.LNX.4.21.0101081824480.6087-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001, Stephen C. Tweedie wrote:

> > _really_ well on many loads, but this one we do badly on. And from what
> > I've been able to see so far, it's because we're just too damn good at
> > waiting on page_launder() and doing refill_inactive_scan().
> 
> do_try_to_free_pages() is trying to
> 
> 	/*
> 	 * If needed, we move pages from the active list
> 	 * to the inactive list. We also "eat" pages from
> 	 * the inode and dentry cache whenever we do this.
> 	 */
> 	if (free_shortage() || inactive_shortage()) {
> 		shrink_dcache_memory(6, gfp_mask);
> 		shrink_icache_memory(6, gfp_mask);
> 		ret += refill_inactive(gfp_mask, user);
> 	} else {
> 
> So we're refilling the inactive list regardless of its current size
> whenever free_shortage() is true.  In the situation you describe,
> there's no point refilling the inactive list too far beyond the
> ability of the swapper to launder it, regardless of whether
> free_shortage() is set.

Agreed.

After some fights me and Rik agreed on doing a per-zone inactive shortage
check in inactive_shortage().

This allow us to check _only_ for inactive_shortage()  before calling
refill_inactive().

> 
> refill_inactive contains exactly the opposite logic: it breaks out if
> 
> 		/*
> 		 * If we either have enough free memory, or if
> 		 * page_launder() will be able to make enough
> 		 * free memory, then stop.
> 		 */
> 		if (!inactive_shortage() || !free_shortage())
> 			goto done;
> 
> but that still means that we're doing unnecessary inactive list
> refilling whenever free_shortage() is true: this test only occurs
> after we've tried at least one swap_out().  We're calling
> refill_inactive if either condition is true, but we're staying inside
> it only if both conditions are true.
> 
> Shouldn't we really just be making the refill_inactive() here depend
> on inactive_shortage() alone, not free_shortage()?  By refilling the
> inactive list too agressively we actually end up discarding aging
> information which might be of use to us.

Yes.

I've removed the free_shortage() of refill_inactive() in the patch.

Comments are welcome.


--- linux.orig/mm/vmscan.c	Thu Jan  4 02:45:26 2001
+++ linux/mm/vmscan.c	Mon Jan  8 20:43:59 2001
@@ -808,6 +808,9 @@
 int inactive_shortage(void)
 {
 	int shortage = 0;
+	pg_data_t *pgdat = pgdat_list;
+
+	/* Is the inactive dirty list too small? */
 
 	shortage += freepages.high;
 	shortage += inactive_target;
@@ -818,7 +821,27 @@
 	if (shortage > 0)
 		return shortage;
 
-	return 0;
+	/* If not, do we have enough per-zone pages on the inactive list? */
+
+	shortage = 0;
+
+	do {
+		int i;
+		for(i = 0; i < MAX_NR_ZONES; i++) {
+			int zone_shortage;
+			zone_t *zone = pgdat->node_zones+ i;
+
+			zone_shortage = zone->pages_high;
+			zone_shortage -= zone->inactive_dirty_pages;
+			zone_shortage -= zone->inactive_clean_pages;
+			zone_shortage -= zone->free_pages;
+			if (zone_shortage > 0)
+				shortage += zone_shortage;
+		}
+		pgdat = pgdat->node_next;
+	} while (pgdat);
+
+	return shortage;
 }
 
 /*
@@ -861,12 +884,13 @@
 		}
 
 		/*
-		 * don't be too light against the d/i cache since
-	   	 * refill_inactive() almost never fail when there's
-	   	 * really plenty of memory free. 
+		 * Only free memory from i/d caches if we have 
+		 * are under low memory.
 		 */
-		shrink_dcache_memory(priority, gfp_mask);
-		shrink_icache_memory(priority, gfp_mask);
+		if(free_shortage()) {
+			shrink_dcache_memory(priority, gfp_mask);
+			shrink_icache_memory(priority, gfp_mask);
+		}
 
 		/*
 		 * Then, try to page stuff out..
@@ -878,11 +902,10 @@
 		}
 
 		/*
-		 * If we either have enough free memory, or if
-		 * page_launder() will be able to make enough
+		 * If page_launder() will be able to make enough
 		 * free memory, then stop.
 		 */
-		if (!inactive_shortage() || !free_shortage())
+		if (!inactive_shortage())
 			goto done;
 
 		/*
@@ -922,14 +945,20 @@
 
 	/*
 	 * If needed, we move pages from the active list
-	 * to the inactive list. We also "eat" pages from
-	 * the inode and dentry cache whenever we do this.
+	 * to the inactive list.
+	 */
+	if (inactive_shortage())
+		ret += refill_inactive(gfp_mask, user);
+
+	/* 	
+	 * Delete pages from the inode and dentry cache 
+	 * if memory is low. 
 	 */
-	if (free_shortage() || inactive_shortage()) {
+	if (free_shortage()) {
 		shrink_dcache_memory(6, gfp_mask);
 		shrink_icache_memory(6, gfp_mask);
-		ret += refill_inactive(gfp_mask, user);
-	} else {
+	} else { 
+
 		/*
 		 * Reclaim unused slab cache memory.
 		 */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
