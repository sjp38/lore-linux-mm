Subject: [PATCH] balance inactive_dirty list
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 03 Jun 2001 00:01:34 +0200
Message-ID: <87pucma6dd.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

For a long time I've been thinking that inactive list is too small,
while observing lots of different workloads (all I/O bound). Finally,
I decided to take a look and try to improve things. In mm/vmscan.c I
found this overly complicated piece of heuristics:

if (!target) {
        int inactive = nr_free_pages() + nr_inactive_clean_pages() +
                                        nr_inactive_dirty_pages;
        int active = MAX(nr_active_pages, num_physpages / 2);
        if (active > 10 * inactive)
                maxscan = nr_active_pages >> 4;
        else if (active > 3 * inactive)
                maxscan = nr_active_pages >> 8;
        else
                return 0;
}

We're trying to be too clever there, and that eventually hurts
performance because inactive_dirty list is too small for typical
scenarios. Especially that 'return 0' is hurting us, as it effectively
stops background scan, so too many pages stay active without the real
need.

With patch below performance is much better under lots of workloads I
have tested. The patch simplifies code a lot and removes unnecessary
complex calculation. Code is now completely autotuning. I have a
modified xmem utility that shows the state of the lists in a graphical
manner, so it's easy to see what's going on. Things look much more
smooth now.

I think I've seen Mike Galbraith (on the list) trying to solve almost
the same problem, although in a slightly different way. Mike, could
you give this patch a try.

All comments welcome, of course. :)

Index: 5.2/mm/vmscan.c
--- 5.2/mm/vmscan.c Sat, 26 May 2001 20:44:49 +0200 zcalusic (linux24/j/9_vmscan.c 1.1.7.1.1.1.2.1.1.1 644)
+++ 5.2(w)/mm/vmscan.c Sat, 02 Jun 2001 23:25:40 +0200 zcalusic (linux24/j/9_vmscan.c 1.1.7.1.1.1.2.1.1.1 644)
@@ -655,24 +655,10 @@
 
 	/*
 	 * When we are background aging, we try to increase the page aging
-	 * information in the system. When we have too many inactive pages
-	 * we don't do background aging since having all pages on the
-	 * inactive list decreases aging information.
-	 *
-	 * Since not all active pages have to be on the active list, we round
-	 * nr_active_pages up to num_physpages/2, if needed.
+	 * information in the system.
 	 */
-	if (!target) {
-		int inactive = nr_free_pages() + nr_inactive_clean_pages() +
-						nr_inactive_dirty_pages;
-		int active = MAX(nr_active_pages, num_physpages / 2);
-		if (active > 10 * inactive)
-			maxscan = nr_active_pages >> 4;
-		else if (active > 3 * inactive)
-			maxscan = nr_active_pages >> 8;
-		else
-			return 0;
-	}
+	if (!target)
+		maxscan = nr_active_pages >> 4;
 
 	/* Take the lock while messing with the list... */
 	spin_lock(&pagemap_lru_lock);

-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
