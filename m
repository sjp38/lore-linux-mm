Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 828BB6B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:38:43 -0400 (EDT)
Date: Thu, 28 Apr 2011 21:38:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [patch] vmstat: account page allocation failures
Message-ID: <20110428133838.GA12573@localhost>
References: <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110428133644.GA12400@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

Just for your reference.

It seems not necessary given that page allocation failure rate is no long high.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |    2 ++
 mm/vmstat.c            |    1 +
 3 files changed, 4 insertions(+)

--- linux-next.orig/include/linux/mmzone.h	2011-04-28 21:34:30.000000000 +0800
+++ linux-next/include/linux/mmzone.h	2011-04-28 21:34:35.000000000 +0800
@@ -106,6 +106,7 @@ enum zone_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_ALLOC_FAIL,
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
--- linux-next.orig/mm/page_alloc.c	2011-04-28 21:34:34.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-04-28 21:34:35.000000000 +0800
@@ -2165,6 +2165,8 @@ rebalance:
 	}
 
 nopage:
+	inc_zone_state(preferred_zone, NR_ALLOC_FAIL);
+	/* count_zone_vm_events(PGALLOCFAIL, preferred_zone, 1 << order); */
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
 		unsigned int filter = SHOW_MEM_FILTER_NODES;
 
--- linux-next.orig/mm/vmstat.c	2011-04-28 21:34:30.000000000 +0800
+++ linux-next/mm/vmstat.c	2011-04-28 21:34:35.000000000 +0800
@@ -879,6 +879,7 @@ static const char * const vmstat_text[] 
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
+	"nr_alloc_fail",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
