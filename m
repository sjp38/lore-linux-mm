Subject: Re: blk_congestion_wait racy?
Message-ID: <OF335311D8.7BCE1E48-ONC1256E51.0049DBF1-C1256E51.004AEA2A@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Mon, 8 Mar 2004 14:38:16 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




> Gad, that'll make the VM scan its guts out.
Yes, I expected something like this.

> > 2.6.4-rc2 + "fix" with 1 cpu
> > sys     0m0.880s
> >
> > 2.6.4-rc2 + "fix" with 2 cpu
> > sys     0m1.560s
>
> system time was doubled though.
That would be the additional cost for not waiting.

> Nope, something is obviously broken.   I'll take a look.
That would be very much appreciated.

> Perhaps with two CPUs you are able to get kswapd and mempig running page
> reclaim at the same time, which causes seekier swap I/O patterns than with
> one CPU, where we only run one app or the other at any time.
>
> Serialising balance_pgdat() and try_to_free_pages() with a global semaphore
> would be a way of testing that theory.

Just tried the following patch:

Index: mm/vmscan.c
===================================================================
RCS file: /home/cvs/linux-2.5/mm/vmscan.c,v
retrieving revision 1.45
diff -u -r1.45 vmscan.c
--- mm/vmscan.c   18 Feb 2004 17:45:28 -0000    1.45
+++ mm/vmscan.c   8 Mar 2004 13:30:56 -0000
@@ -848,6 +848,7 @@
  * excessive rotation of the inactive list, which is _supposed_ to be an LRU,
  * yes?
  */
+static DECLARE_MUTEX(reclaim_sem);
 int try_to_free_pages(struct zone **zones,
            unsigned int gfp_mask, unsigned int order)
 {
@@ -858,6 +859,8 @@
      struct reclaim_state *reclaim_state = current->reclaim_state;
      int i;

+     down(&reclaim_sem);
+
      inc_page_state(allocstall);

      for (i = 0; zones[i] != 0; i++)
@@ -884,7 +887,10 @@
            wakeup_bdflush(total_scanned);

            /* Take a nap, wait for some writeback to complete */
+           up(&reclaim_sem);
            blk_congestion_wait(WRITE, HZ/10);
+           down(&reclaim_sem);
+
            if (zones[0] - zones[0]->zone_pgdat->node_zones < ZONE_HIGHMEM) {
                  shrink_slab(total_scanned, gfp_mask);
                  if (reclaim_state) {
@@ -898,6 +904,9 @@
 out:
      for (i = 0; zones[i] != 0; i++)
            zones[i]->prev_priority = zones[i]->temp_priority;
+
+     up(&reclaim_sem);
+
      return ret;
 }

@@ -926,6 +935,8 @@
      int i;
      struct reclaim_state *reclaim_state = current->reclaim_state;

+     down(&reclaim_sem);
+
      inc_page_state(pageoutrun);

      for (i = 0; i < pgdat->nr_zones; i++) {
@@ -974,8 +985,11 @@
            }
            if (all_zones_ok)
                  break;
-           if (to_free > 0)
+           if (to_free > 0) {
+                 up(&reclaim_sem);
                  blk_congestion_wait(WRITE, HZ/10);
+                 down(&reclaim_sem);
+           }
      }

      for (i = 0; i < pgdat->nr_zones; i++) {
@@ -983,6 +997,9 @@

            zone->prev_priority = zone->temp_priority;
      }
+
+     up(&reclaim_sem);
+
      return nr_pages - to_free;
 }


It didn't help. Still needs almost a minute.

blue skies,
   Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
