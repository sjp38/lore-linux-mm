Date: Fri, 19 Jan 2007 19:10:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070120031028.17491.60534.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/5] Cpuset aware writeback during reclaim
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Direct reclaim: cpuset aware writeout

During direct reclaim we traverse down a zonelist and are carefully
checking each zone if its a member of the active cpuset. But then we call
pdflush without enforcing the same restrictions. In a larger system this
may have the effect of a massive amount of pages being dirtied and then either

A. No writeout occurs because global dirty limits have not been reached

or

B. Writeout starts randomly for some dirty inode in the system. Pdflush
   may just write out data for nodes in another cpuset and miss doing
   proper dirty handling for the current cpuset.

In both cases dirty pages in the zones of interest may not be affected
and writeout may not occur as necessary.

Fix that by restricting pdflush to the active cpuset. Writeout will occur
from direct reclaim the same way as without a cpuset.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc5/mm/vmscan.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/vmscan.c	2007-01-15 21:34:43.173887398 -0600
+++ linux-2.6.20-rc5/mm/vmscan.c	2007-01-15 21:37:26.605346439 -0600
@@ -1065,7 +1065,8 @@ unsigned long try_to_free_pages(struct z
 		 */
 		if (total_scanned > sc.swap_cluster_max +
 					sc.swap_cluster_max / 2) {
-			wakeup_pdflush(laptop_mode ? 0 : total_scanned, NULL);
+			wakeup_pdflush(laptop_mode ? 0 : total_scanned,
+				&cpuset_current_mems_allowed);
 			sc.may_writepage = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
