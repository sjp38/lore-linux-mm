Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 798016B0055
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 11:58:18 -0400 (EDT)
Date: Wed, 19 Aug 2009 00:57:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
In-Reply-To: <20090816050902.GR5087@balbir.in.ibm.com>
References: <20090815054524.GB11387@localhost> <20090816050902.GR5087@balbir.in.ibm.com>
Message-Id: <20090818223951.A645.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> * Wu Fengguang <fengguang.wu@intel.com> [2009-08-15 13:45:24]:
> 
> > On Fri, Aug 14, 2009 at 09:19:35PM +0800, Rik van Riel wrote:
> > > Wu Fengguang wrote:
> > > > On Fri, Aug 14, 2009 at 05:10:55PM +0800, Johannes Weiner wrote:
> > > 
> > > >> So even with the active list being a FIFO, we keep usage information
> > > >> gathered from the inactive list.  If we deactivate pages in arbitrary
> > > >> list intervals, we throw this away.
> > > > 
> > > > We do have the danger of FIFO, if inactive list is small enough, so
> > > > that (unconditionally) deactivated pages quickly get reclaimed and
> > > > their life window in inactive list is too small to be useful.
> > > 
> > > This one of the reasons why we unconditionally deactivate
> > > the active anon pages, and do background scanning of the
> > > active anon list when reclaiming page cache pages.
> > > 
> > > We want to always move some pages to the inactive anon
> > > list, so it does not get too small.
> > 
> > Right, the current code tries to pull inactive list out of
> > smallish-size state as long as there are vmscan activities.
> > 
> > However there is a possible (and tricky) hole: mem cgroups
> > don't do batched vmscan. shrink_zone() may call shrink_list()
> > with nr_to_scan=1, in which case shrink_list() _still_ calls
> > isolate_pages() with the much larger SWAP_CLUSTER_MAX.
> > 
> > It effectively scales up the inactive list scan rate by 10 times when
> > it is still small, and may thus prevent it from growing up for ever.
> > 
> 
> I think we need to possibly export some scanning data under DEBUG_VM
> to cross verify.

Sorry for the delay.
How about this?

=======================================
Subject: [PATCH] vmscan: show recent_scanned/rotated stat

On recent discussion, Balbir Singh pointed out VM developer shold be
able to see recent_scanned/rotated statistics.

This patch does it.

output example
--------------------
% cat /proc/zoneinfo
Node 0, zone    DMA32
  pages free     347590
        min      613
        low      766
        high     919
(snip)
  inactive_ratio:    3
  recent_rotated_anon: 127305
  recent_rotated_file: 67439
  recent_scanned_anon: 135591
  recent_scanned_file: 180399



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmstat.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c	2009-08-08 14:16:53.000000000 +0900
+++ b/mm/vmstat.c	2009-08-18 22:07:25.000000000 +0900
@@ -762,6 +762,20 @@ static void zoneinfo_show_print(struct s
 		   zone->prev_priority,
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
+
+#ifdef CONFIG_DEBUG_VM
+	seq_printf(m,
+		   "\n  recent_rotated_anon: %lu"
+		   "\n  recent_rotated_file: %lu"
+		   "\n  recent_scanned_anon: %lu"
+		   "\n  recent_scanned_file: %lu",
+		   zone->reclaim_stat.recent_rotated[0],
+		   zone->reclaim_stat.recent_rotated[1],
+		   zone->reclaim_stat.recent_scanned[0],
+		   zone->reclaim_stat.recent_scanned[1]
+		);
+#endif
+
 	seq_putc(m, '\n');
 }
 





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
