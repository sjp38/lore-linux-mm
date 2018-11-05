Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B10476B0289
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 17:40:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id j2-v6so10845975pfi.18
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 14:40:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j10-v6sor31407405pfh.21.2018.11.05.14.40.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 14:40:58 -0800 (PST)
Message-ID: <1541457654.196084.159.camel@acm.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 05 Nov 2018 14:40:54 -0800
In-Reply-To: <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
References: <20181105204000.129023-1-bvanassche@acm.org>
	 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
	 <1541454489.196084.157.camel@acm.org>
	 <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Mon, 2018-11-05 at 23:14 +-0100, Rasmus Villemoes wrote:
+AD4 Won't that pessimize the cases where gfp is a constant to actually do
+AD4 the table lookup, and add 16 bytes to every translation unit?
+AD4 
+AD4 Another option is to add a fake KMALLOC+AF8-DMA+AF8-RECLAIM so the
+AD4 kmalloc+AF8-caches+AFsAXQ array has size 4, then assign the same dma
+AD4 kmalloc+AF8-cache pointer to +AFs-2+AF0AWw-i+AF0 and +AFs-3+AF0AWw-i+AF0 (so that costs perhaps a
+AD4 dozen pointers in .data), and then just compute kmalloc+AF8-type() as
+AD4 
+AD4 ((flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE) +AD4APg someshift) +AHw ((flags +ACY +AF8AXw-GFP+AF8-DMA) +AD4APg
+AD4 someothershift).
+AD4 
+AD4 Perhaps one could even shuffle the GFP flags so the two shifts are the same.

How about this version, still untested? My compiler is able to evaluate
the switch expression if the argument is constant.

 static +AF8AXw-always+AF8-inline enum kmalloc+AF8-cache+AF8-type kmalloc+AF8-type(gfp+AF8-t flags)
 +AHs
-	int is+AF8-dma +AD0 0+ADs
-	int type+AF8-dma +AD0 0+ADs
-	int is+AF8-reclaimable+ADs
+-	unsigned int dr +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
 
 +ACM-ifdef CONFIG+AF8-ZONE+AF8-DMA
-	is+AF8-dma +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA)+ADs
-	type+AF8-dma +AD0 is+AF8-dma +ACo KMALLOC+AF8-DMA+ADs
+-	dr +AHwAPQ +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA) +ADwAPA 1+ADs
 +ACM-endif
 
-	is+AF8-reclaimable +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
-
 	/+ACo
 	 +ACo If an allocation is both +AF8AXw-GFP+AF8-DMA and +AF8AXw-GFP+AF8-RECLAIMABLE, return
 	 +ACo KMALLOC+AF8-DMA and effectively ignore +AF8AXw-GFP+AF8-RECLAIMABLE
 	 +ACo-/
-	return type+AF8-dma +- (is+AF8-reclaimable +ACY +ACE-is+AF8-dma) +ACo KMALLOC+AF8-RECLAIM+ADs
+-	switch (dr) +AHs
+-	default:
+-	case 0:
+-		return 0+ADs
+-	case 1:
+-		return KMALLOC+AF8-RECLAIM+ADs
+-	case 2:
+-	case 3:
+-		return KMALLOC+AF8-DMA+ADs
+-	+AH0
 +AH0
 
Bart.
