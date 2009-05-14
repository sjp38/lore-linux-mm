Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 66F416B01A4
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:47:45 -0400 (EDT)
Date: Thu, 14 May 2009 06:48:27 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <20090514114827.GN7601@sgi.com>
References: <20090513120729.5885.A69D9226@jp.fujitsu.com> <4A0ADD88.9080705@redhat.com> <20090514170721.9B75.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090514170721.9B75.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

> Unfortunately no.
> zone reclaim has two weakness by design.
> 
> 1.
> zone reclaim don't works well when workingset size > local node size.
> but it can happen easily on small machine.
> if it happen, zone reclaim drop own process's memory.
> 
> Plus, zone reclaim also doesn't fit DB server. its process has large
> workingset.

Large DB server is not your typical desktop application either.

> 2.
> zone reclaim have inter zone balancing issue.
> 
> example: x86_64 2node 8G machine has following zone assignment
> 
>    zone 0 (DMA32):  3GB
>    zone 0 (Normal): 1GB
>    zone 1 (Normal): 4GB
> 
> if the page is allocated from DMA32, you are lucky. DMA32 isn't reclaimed
> so freqently. but if from zone0 Normal, you are unlucky.
> it is very frequent reclaimed although it is small than other zone.

I have seen that behavior on some of our mismatched large systems as well,
although never had one so imbalanced because ia64 only has Normal.

> I know my patch change large server default. but I believe linux
> default kernel parameter adapt to desktop and entry machine.

If this imbalance is an x86_64 only problem, then we could do something
simple like the following untested patch.  This leaves the default
for everyone except x86_64.

Robin

------------------------------------------------------------------------

Even if there is a great node distance on x86_64, disable zone reclaim
by default.  This was done to handle the imbalanced zone sizes where a
majority of the memory in zone 0 is DMA32 with a small remaining Normal
which will be aggressively reclaimed.

For other architectures, we leave the default behavior.

Signed-off-by: Robin Holt <holt@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>

---
 arch/x86/include/asm/topology.h |    2 ++
 include/linux/topology.h        |    5 +++++
 mm/page_alloc.c                 |    2 +-
 3 files changed, 8 insertions(+), 1 deletion(-)
Index: page_reclaim_mode/arch/x86/include/asm/topology.h
===================================================================
--- page_reclaim_mode.orig/arch/x86/include/asm/topology.h	2009-05-14 06:44:20.118925713 -0500
+++ page_reclaim_mode/arch/x86/include/asm/topology.h	2009-05-14 06:44:21.251067716 -0500
@@ -128,6 +128,8 @@ extern unsigned long node_remap_size[];
 
 #endif
 
+#define DEFAULT_ZONE_RECLAIM_MODE	0
+
 /* sched_domains SD_NODE_INIT for NUMA machines */
 #define SD_NODE_INIT (struct sched_domain) {		\
 	.min_interval		= 8,			\
Index: page_reclaim_mode/include/linux/topology.h
===================================================================
--- page_reclaim_mode.orig/include/linux/topology.h	2009-05-14 06:44:20.070919619 -0500
+++ page_reclaim_mode/include/linux/topology.h	2009-05-14 06:44:21.279071382 -0500
@@ -61,6 +61,11 @@ int arch_update_cpu_topology(void);
  */
 #define RECLAIM_DISTANCE 20
 #endif
+
+#ifndef DEFAULT_ZONE_RECLAIM_MODE
+#define DEFAULT_ZONE_RECLAIM_MODE	1
+#endif
+
 #ifndef PENALTY_FOR_NODE_WITH_CPUS
 #define PENALTY_FOR_NODE_WITH_CPUS	(1)
 #endif
Index: page_reclaim_mode/mm/page_alloc.c
===================================================================
--- page_reclaim_mode.orig/mm/page_alloc.c	2009-05-14 06:44:20.138928363 -0500
+++ page_reclaim_mode/mm/page_alloc.c	2009-05-14 06:44:21.311075244 -0500
@@ -2331,7 +2331,7 @@ static void build_zonelists(pg_data_t *p
 		 * to reclaim pages in a zone before going off node.
 		 */
 		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode = 1;
+			zone_reclaim_mode = DEFAULT_ZONE_RECLAIM_MODE;
 
 		/*
 		 * We don't want to pressure a particular node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
