Date: Mon, 12 Jun 2006 17:08:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 19/21] swap_prefetch: Conversion of nr_unstable to ZVC
In-Reply-To: <200606130959.48006.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.64.0606121707130.22052@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0606121647090.22052@schroedinger.engr.sgi.com>
 <200606130957.28414.kernel@kolivas.org> <200606130959.48006.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2006, Con Kolivas wrote:

> The comment should read something like:

If we need another round then maybe it would be best if you would do that 
patch.

This?

Subject: swap_prefetch: conversion of nr_unstable to per zone counter
From: Christoph Lameter <clameter@sgi.com>

The determination of the vm state is now not that expensive
anymore after we remove the use of the page state.
Change the logic to avoid the expensive checks.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Con Kolivas <kernel@kolivas.org>

Index: linux-2.6.17-rc6-cl/mm/swap_prefetch.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/mm/swap_prefetch.c	2006-06-12 13:37:47.283159568 -0700
+++ linux-2.6.17-rc6-cl/mm/swap_prefetch.c	2006-06-12 17:06:44.875945042 -0700
@@ -298,7 +298,7 @@ static int prefetch_suitable(void)
 {
 	unsigned long limit;
 	struct zone *z;
-	int node, ret = 0, test_pagestate = 0;
+	int node, ret = 0;
 
 	/* Purposefully racy */
 	if (test_bit(0, &swapped.busy)) {
@@ -307,17 +307,15 @@ static int prefetch_suitable(void)
 	}
 
 	/*
-	 * get_page_state and above_background_load are expensive so we only
-	 * perform them every SWAP_CLUSTER_MAX prefetched_pages.
+	 * above_background_load() is expensive so we only perform
+	 * it every SWAP_CLUSTER_MAX prefetched_pages.
 	 * We test to see if we're above_background_load as disk activity
 	 * even at low priority can cause interrupt induced scheduling
 	 * latencies.
 	 */
-	if (!(sp_stat.prefetched_pages % SWAP_CLUSTER_MAX)) {
-		if (above_background_load())
+	if ((!(sp_stat.prefetched_pages % SWAP_CLUSTER_MAX)) &&
+		above_background_load())
 			goto out;
-		test_pagestate = 1;
-	}
 
 	clear_current_prefetch_free();
 
@@ -357,7 +355,6 @@ static int prefetch_suitable(void)
 	 */
 	for_each_node_mask(node, sp_stat.prefetch_nodes) {
 		struct node_stats *ns = &sp_stat.node[node];
-		struct page_state ps;
 
 		/*
 		 * We check to see that pages are not being allocated
@@ -375,11 +372,6 @@ static int prefetch_suitable(void)
 		} else
 			ns->last_free = ns->current_free;
 
-		if (!test_pagestate)
-			continue;
-
-		get_page_state_node(&ps, node);
-
 		/* We shouldn't prefetch when we are doing writeback */
 		if (node_page_state(node, NR_WRITEBACK)) {
 			node_clear(node, sp_stat.prefetch_nodes);
@@ -394,7 +386,8 @@ static int prefetch_suitable(void)
 			node_page_state(node, NR_ANON) +
 			node_page_state(node, NR_SLAB) +
 			node_page_state(node, NR_DIRTY) +
-			ps.nr_unstable + total_swapcache_pages;
+			node_page_state(node, NR_UNSTABLE) +
+			total_swapcache_pages;
 		if (limit > ns->prefetch_watermark) {
 			node_clear(node, sp_stat.prefetch_nodes);
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
