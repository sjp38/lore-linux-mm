Received: (from arjanv@localhost)
	by devserv.devel.redhat.com (8.11.0/8.11.0) id f6NAFDL21908
	for linux-mm@kvack.org; Mon, 23 Jul 2001 06:15:13 -0400
Date: Mon, 23 Jul 2001 06:15:12 -0400
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Swap progress accounting
Message-ID: <20010723061512.A21588@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Currently, calling swap_out() on a zone doesn't count progress, and the
result can be that you swap_out() a lot of pages, and still return "no
progress possible" to try_to_free_pages(), which in turn makes a GFP_KERNEL
allocation fail (and that can kill init).

The patch below makes it count as progress, so at least the page allocator
will keep trying harder in this case (and more importantly, will start the
io on the swappage if needed etc) 

Comments? 

Greetings,
   Arjan van de Ven



--- linux/mm/vmscan.c.org	Sun Jul 22 21:06:21 2001
+++ linux/mm/vmscan.c	Sun Jul 22 21:16:41 2001
@@ -288,7 +288,7 @@
 	return nr;
 }
 
-static void swap_out(zone_t *zone, unsigned int priority, int gfp_mask)
+static int swap_out(zone_t *zone, unsigned int priority, int gfp_mask)
 {
 	int counter;
 	int retval = 0;
@@ -321,10 +321,11 @@
 		retval |= swap_out_mm(zone, mm, swap_amount(mm));
 		mmput(mm);
 	} while (--counter >= 0);
-	return;
+	return retval;
 
 empty:
 	spin_unlock(&mmlist_lock);
+	return retval;
 }
 
 
@@ -949,7 +950,8 @@
 		}
 
 		/* Walk the VM space for a bit.. */
-		swap_out(NULL, DEF_PRIORITY, gfp_mask);
+		if (swap_out(NULL, DEF_PRIORITY, gfp_mask))
+			count--; /* count swap progress as progress */
 
 		count -= refill_inactive_scan(NULL, DEF_PRIORITY, count);
 		if (count <= 0)
@@ -973,7 +975,8 @@
 	maxtry = (1 << DEF_PRIORITY);
 
 	do {
-		swap_out(zone, DEF_PRIORITY, gfp_mask);
+		if (swap_out(zone, DEF_PRIORITY, gfp_mask))
+			count--; /* count swap progress as progress */
 
 		count -= refill_inactive_scan(zone, DEF_PRIORITY, count);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
