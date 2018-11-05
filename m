Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C04956B0283
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:48:13 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 190-v6so2227175pfd.7
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:48:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o34-v6sor43322874pgm.39.2018.11.05.13.48.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 13:48:12 -0800 (PST)
Message-ID: <1541454489.196084.157.camel@acm.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 05 Nov 2018 13:48:09 -0800
In-Reply-To: <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
References: <20181105204000.129023-1-bvanassche@acm.org>
	 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Mon, 2018-11-05 at 13:13 -0800, Andrew Morton wrote:
+AD4 On Mon,  5 Nov 2018 12:40:00 -0800 Bart Van Assche +ADw-bvanassche+AEA-acm.org+AD4 wrote:
+AD4 
+AD4 +AD4 This patch suppresses the following sparse warning:
+AD4 +AD4 
+AD4 +AD4 ./include/linux/slab.h:332:43: warning: dubious: x +ACY +ACE-y
+AD4 +AD4 
+AD4 +AD4 ...
+AD4 +AD4 
+AD4 +AD4 --- a/include/linux/slab.h
+AD4 +AD4 +-+-+- b/include/linux/slab.h
+AD4 +AD4 +AEAAQA -329,7 +-329,7 +AEAAQA static +AF8AXw-always+AF8-inline enum kmalloc+AF8-cache+AF8-type kmalloc+AF8-type(gfp+AF8-t flags)
+AD4 +AD4  	 +ACo If an allocation is both +AF8AXw-GFP+AF8-DMA and +AF8AXw-GFP+AF8-RECLAIMABLE, return
+AD4 +AD4  	 +ACo KMALLOC+AF8-DMA and effectively ignore +AF8AXw-GFP+AF8-RECLAIMABLE
+AD4 +AD4  	 +ACo-/
+AD4 +AD4 -	return type+AF8-dma +- (is+AF8-reclaimable +ACY +ACE-is+AF8-dma) +ACo KMALLOC+AF8-RECLAIM+ADs
+AD4 +AD4 +-	return type+AF8-dma +- is+AF8-reclaimable +ACo +ACE-is+AF8-dma +ACo KMALLOC+AF8-RECLAIM+ADs
+AD4 +AD4  +AH0
+AD4 +AD4  
+AD4 +AD4  /+ACo
+AD4 
+AD4 I suppose so.
+AD4 
+AD4 That function seems too clever for its own good :(.  I wonder if these
+AD4 branch-avoiding tricks are really worthwhile.

>From what I have seen in gcc disassembly it seems to me like gcc uses the
cmov instruction to implement e.g. the ternary operator (?:). So I think none
of the cleverness in kmalloc+AF8-type() is really necessary to avoid conditional
branches. I think this function would become much more readable when using a
switch statement or when rewriting it as follows (untested):

 static +AF8AXw-always+AF8-inline enum kmalloc+AF8-cache+AF8-type kmalloc+AF8-type(gfp+AF8-t flags)
 +AHs
-	int is+AF8-dma +AD0 0+ADs
-	int type+AF8-dma +AD0 0+ADs
-	int is+AF8-reclaimable+ADs
-
-+ACM-ifdef CONFIG+AF8-ZONE+AF8-DMA
-	is+AF8-dma +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA)+ADs
-	type+AF8-dma +AD0 is+AF8-dma +ACo KMALLOC+AF8-DMA+ADs
-+ACM-endif
-
-	is+AF8-reclaimable +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
-
 	/+ACo
 	 +ACo If an allocation is both +AF8AXw-GFP+AF8-DMA and +AF8AXw-GFP+AF8-RECLAIMABLE, return
 	 +ACo KMALLOC+AF8-DMA and effectively ignore +AF8AXw-GFP+AF8-RECLAIMABLE
 	 +ACo-/
-	return type+AF8-dma +- (is+AF8-reclaimable +ACY +ACE-is+AF8-dma) +ACo KMALLOC+AF8-RECLAIM+ADs
+-	static const enum kmalloc+AF8-cache+AF8-type flags+AF8-to+AF8-type+AFs-2+AF0AWw-2+AF0 +AD0 +AHs
+-		+AHs 0,		KMALLOC+AF8-RECLAIM +AH0,
+-		+AHs KMALLOC+AF8-DMA,	KMALLOC+AF8-DMA +AH0,
+-	+AH0AOw
+-+ACM-ifdef CONFIG+AF8-ZONE+AF8-DMA
+-	bool is+AF8-dma +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA)+ADs
+-+ACM-endif
+-	bool is+AF8-reclaimable +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
+-
+-	return flags+AF8-to+AF8-type+AFs-is+AF8-dma+AF0AWw-is+AF8-reclaimable+AF0AOw
 +AH0
