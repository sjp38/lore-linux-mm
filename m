Date: Mon, 12 Jun 2006 16:48:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 19/21] swap_prefetch: Conversion of nr_unstable to ZVC
In-Reply-To: <200606130940.16956.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.64.0606121647090.22052@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
 <20060612211423.20862.41488.sendpatchset@schroedinger.engr.sgi.com>
 <200606130940.16956.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2006, Con Kolivas wrote:

> Nack. You're changing some other code unintentionally.

Is this okay?

Subject: swap_prefetch: conversion of nr_unstable to per zone counter
From: Christoph Lameter <clameter@sgi.com>

The determination of the vm state is now not that expensive
anymore after we remove the use of the page state.
Remove the logic to avoid the expensive checks.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-rc6-cl/mm/swap_prefetch.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/mm/swap_prefetch.c	2006-06-12 13:37:47.283159568 -0700
+++ linux-2.6.17-rc6-cl/mm/swap_prefetch.c	2006-06-12 16:46:48.504626417 -0700
@@ -357,7 +357,6 @@ static int prefetch_suitable(void)
 	 */
 	for_each_node_mask(node, sp_stat.prefetch_nodes) {
 		struct node_stats *ns = &sp_stat.node[node];
-		struct page_state ps;
 
 		/*
 		 * We check to see that pages are not being allocated
@@ -375,11 +374,6 @@ static int prefetch_suitable(void)
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
@@ -394,7 +388,8 @@ static int prefetch_suitable(void)
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
