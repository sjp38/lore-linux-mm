Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0477D6B028F
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:01:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so4797675pgt.11
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:01:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92-v6sor29779535pli.10.2018.11.05.16.01.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 16:01:09 -0800 (PST)
Message-ID: <1541462466.196084.163.camel@acm.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Bart Van Assche <bvanassche@acm.org>
Date: Mon, 05 Nov 2018 16:01:06 -0800
In-Reply-To: <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
References: <20181105204000.129023-1-bvanassche@acm.org>
	 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
	 <1541454489.196084.157.camel@acm.org>
	 <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
	 <1541457654.196084.159.camel@acm.org>
	 <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Mon, 2018-11-05 at 14:48 -0800, Alexander Duyck wrote:
+AD4 On Mon, Nov 5, 2018 at 2:41 PM Bart Van Assche +ADw-bvanassche+AEA-acm.org+AD4 wrote:
+AD4 +AD4 How about this version, still untested? My compiler is able to evaluate
+AD4 +AD4 the switch expression if the argument is constant.
+AD4 +AD4 
+AD4 +AD4  static +AF8AXw-always+AF8-inline enum kmalloc+AF8-cache+AF8-type kmalloc+AF8-type(gfp+AF8-t flags)
+AD4 +AD4  +AHs
+AD4 +AD4 -       int is+AF8-dma +AD0 0+ADs
+AD4 +AD4 -       int type+AF8-dma +AD0 0+ADs
+AD4 +AD4 -       int is+AF8-reclaimable+ADs
+AD4 +AD4 +-       unsigned int dr +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
+AD4 +AD4 
+AD4 +AD4  +ACM-ifdef CONFIG+AF8-ZONE+AF8-DMA
+AD4 +AD4 -       is+AF8-dma +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA)+ADs
+AD4 +AD4 -       type+AF8-dma +AD0 is+AF8-dma +ACo KMALLOC+AF8-DMA+ADs
+AD4 +AD4 +-       dr +AHwAPQ +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-DMA) +ADwAPA 1+ADs
+AD4 +AD4  +ACM-endif
+AD4 +AD4 
+AD4 +AD4 -       is+AF8-reclaimable +AD0 +ACEAIQ(flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE)+ADs
+AD4 +AD4 -
+AD4 +AD4         /+ACo
+AD4 +AD4          +ACo If an allocation is both +AF8AXw-GFP+AF8-DMA and +AF8AXw-GFP+AF8-RECLAIMABLE, return
+AD4 +AD4          +ACo KMALLOC+AF8-DMA and effectively ignore +AF8AXw-GFP+AF8-RECLAIMABLE
+AD4 +AD4          +ACo-/
+AD4 +AD4 -       return type+AF8-dma +- (is+AF8-reclaimable +ACY +ACE-is+AF8-dma) +ACo KMALLOC+AF8-RECLAIM+ADs
+AD4 +AD4 +-       switch (dr) +AHs
+AD4 +AD4 +-       default:
+AD4 +AD4 +-       case 0:
+AD4 +AD4 +-               return 0+ADs
+AD4 +AD4 +-       case 1:
+AD4 +AD4 +-               return KMALLOC+AF8-RECLAIM+ADs
+AD4 +AD4 +-       case 2:
+AD4 +AD4 +-       case 3:
+AD4 +AD4 +-               return KMALLOC+AF8-DMA+ADs
+AD4 +AD4 +-       +AH0
+AD4 +AD4  +AH0
+AD4
+AD4 Doesn't this defeat the whole point of the code which I thought was to
+AD4 avoid conditional jumps and branches? Also why would you bother with
+AD4 the +ACI-dr+ACI value when you could just mask the flags value and switch on
+AD4 that directly?

Storing the relevant bits of 'flags' in the 'dr' variable avoids that the
bit selection expressions have to be repeated and allows to use a switch
statement instead of multiple if / else statements.

Most kmalloc() calls pass a constant to the gfp argument. That allows the
compiler to evaluate kmalloc+AF8-type() at compile time. So the conditional jumps
and branches only appear when the gfp argument is not a constant. What makes
you think it is important to optimize for that case?

Bart.
