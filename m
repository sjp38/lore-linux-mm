Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2940D8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:02:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h4-v6so4327049pls.17
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:02:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j124-v6si7701625pfb.191.2018.09.14.06.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Sep 2018 06:02:14 -0700 (PDT)
Date: Fri, 14 Sep 2018 15:02:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180914130207.GD24106@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180913123014.0d9321b8@mschwideX1>
 <20180913105738.GW24124@hirez.programming.kicks-ass.net>
 <20180913141827.1776985e@mschwideX1>
 <20180913123937.GX24124@hirez.programming.kicks-ass.net>
 <20180914122824.181d9778@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180914122824.181d9778@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Sep 14, 2018 at 12:28:24PM +0200, Martin Schwidefsky wrote:

> I spent some time to get s390 converted to the common mmu_gather code.
> There is one thing I would like to request, namely the ability to
> disable the page gather part of mmu_gather. For my prototype patch
> see below, it defines the negative HAVE_RCU_NO_GATHER_PAGES Kconfig
> symbol that if defined will remove some parts from common code.
> Ugly but good enough for the prototype to convey the idea.
> For the final solution we better use a positive Kconfig symbol and
> add that to all arch Kconfig files except for s390.

In a private thread ealier Linus raised the point that the batching and
freeing of lots of pages at once is probably better for I$.

> +config HAVE_RCU_NO_GATHER_PAGES
> +	bool

I have a problem with the name more than anything else; this name
suggests it is the RCU table freeing that should not batch, which is not
the case, you want the regular page gather gone, but very much require
the RCU table gather to batch.

So I would like to propose calling it:

config HAVE_MMU_GATHER_NO_GATHER

Or something along those lines.
