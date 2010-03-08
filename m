Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 495056B0095
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 04:21:13 -0500 (EST)
Date: Mon, 8 Mar 2010 10:21:04 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
Message-ID: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

__zone_pcp_update() iterates over NR_CPUS instead of limiting the
access to the possible cpus. This might result in access to
uninitialized areas as the per cpu allocator only populates the per
cpu memory for possible cpus.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
 	int cpu;
 	unsigned long batch = zone_batchsize(zone), flags;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_cpu(cpu) {
 		struct per_cpu_pageset *pset;
 		struct per_cpu_pages *pcp;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
