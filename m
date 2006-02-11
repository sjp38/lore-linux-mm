Date: Sat, 11 Feb 2006 11:01:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Get rid of scan_control
In-Reply-To: <20060211013255.20832152.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602111054520.24060@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
 <20060211045355.GA3318@dmt.cnet> <20060211013255.20832152.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Feb 2006, Andrew Morton wrote:

> > But refill_inactive_list() is not used for swapping only. All evicted 
> > pages go through that path - it can be _very_ hot.
> 
> A bit hot.  I guess it's worth fixing.

There is another issue of the anon_vma lock getting very hot during 
zone_reclaim() because refill_inactive_list calls page_referenced(). So 
does shrink_list(). zone_reclaim is only interested in unmapped pages and 
thus checking for references is useless.

> scan_control was modelled on writeback_control.  But writeback_control
> works, and scan_control doesn't.  I think this is because a)
> writeback_control instances are always initialised at the declaration site
> and b) writeback_control is just a lot simpler.

The zoned counter patchset eliminates at least the wbs structure.

Patch to fix the calling of page_referenced() follows. This is against 
2.6.16-rc2. We probably need another patch for current mm. In the case
of VMSCAN_MAY_SWAP not set, we may just want to bypass the whole 
calculation thing for reclaim_mapped.





Do not check references to a page during zone reclaim

Shrink_list and refill_inactive() check all ptes pointing to a page
for reference bits in order to decide if the page should be put on
the active list. This is not necessary for zone_reclaim since we
are only interested in removing unmapped pages. Skip the checks in both
functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2006-02-10 12:15:37.293298891 -0800
+++ linux/mm/vmscan.c	2006-02-10 12:26:19.453541327 -0800
@@ -443,6 +443,10 @@ static int shrink_list(struct list_head 
 		BUG_ON(PageActive(page));
 
 		sc->nr_scanned++;
+
+		if (!sc->may_swap && page_mapped(page))
+			goto keep_locked;
+
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
@@ -983,7 +987,7 @@ refill_inactive_zone(struct zone *zone, 
 	 * Now use this metric to decide whether to start moving mapped memory
 	 * onto the inactive list.
 	 */
-	if (swap_tendency >= 100)
+	if (swap_tendency >= 100 && sc->may_swap)
 		reclaim_mapped = 1;
 
 	while (!list_empty(&l_hold)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
