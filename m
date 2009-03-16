Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B9586B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 15:15:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D748C304FFE
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 15:22:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id F8CxWvUItbGS for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 15:22:34 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 08B35305045
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 15:21:27 -0400 (EDT)
Date: Mon, 16 Mar 2009 15:12:50 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of precalculated
 values
In-Reply-To: <1237226020-14057-25-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161500280.20024@qirst.com>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie> <1237226020-14057-25-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> +int gfp_zone_table[GFP_ZONEMASK] __read_mostly;

The gfp_zone_table is compile time determinable. There is no need to
calculate it.

const int gfp_zone_table[GFP_ZONEMASK] = {
	ZONE_NORMAL,		/* 00 No flags set */
	ZONE_DMA,		/* 01 Only GFP_DMA set */
	ZONE_HIGHMEM,		/* 02 Only GFP_HIGHMEM set */
	ZONE_DMA,		/* 03 GFP_HIGHMEM and GFP_DMA set */
	ZONE_DMA32,		/* 04 Only GFP_DMA32 set */
	ZONE_DMA,		/* 05 GFP_DMA and GFP_DMA32 set */
	ZONE_DMA32,		/* 06 GFP_DMA32 and GFP_HIGHMEM set */
	ZONE_DMA,		/* 07 GFP_DMA, GFP_DMA32 and GFP_DMA32 set */
	ZONE_MOVABLE,		/* 08 Only ZONE_MOVABLE set */
	ZONE_DMA,		/* 09 MOVABLE + DMA */
	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
	ZONE_DMA,		/* 0B MOVABLE + DMA + HIGHMEM */
	ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
	ZONE_DMA,		/* 0D MOVABLE + DMA + DMA32 */
	ZONE_DMA32,		/* 0E MOVABLE + DMA32 + HIGHMEM */
	ZONE_DMA		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA
};

Hmmmm... Guess one would need to add some #ifdeffery here to setup
ZONE_NORMAL in cases there is no DMA, DMA32 and HIGHMEM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
