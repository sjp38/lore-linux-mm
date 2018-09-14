Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4CE8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:07:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l14-v6so9661854oii.9
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:07:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k91-v6si1519498otc.259.2018.09.14.07.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 07:07:22 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EE49jQ048822
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:07:21 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgdsvt4xd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:07:21 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 14 Sep 2018 15:07:19 +0100
Date: Fri, 14 Sep 2018 16:07:14 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
In-Reply-To: <20180914130207.GD24106@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
	<20180913092811.894806629@infradead.org>
	<20180913123014.0d9321b8@mschwideX1>
	<20180913105738.GW24124@hirez.programming.kicks-ass.net>
	<20180913141827.1776985e@mschwideX1>
	<20180913123937.GX24124@hirez.programming.kicks-ass.net>
	<20180914122824.181d9778@mschwideX1>
	<20180914130207.GD24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Message-Id: <20180914160714.45a11f13@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, 14 Sep 2018 15:02:07 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, Sep 14, 2018 at 12:28:24PM +0200, Martin Schwidefsky wrote:
> 
> > I spent some time to get s390 converted to the common mmu_gather code.
> > There is one thing I would like to request, namely the ability to
> > disable the page gather part of mmu_gather. For my prototype patch
> > see below, it defines the negative HAVE_RCU_NO_GATHER_PAGES Kconfig
> > symbol that if defined will remove some parts from common code.
> > Ugly but good enough for the prototype to convey the idea.
> > For the final solution we better use a positive Kconfig symbol and
> > add that to all arch Kconfig files except for s390.  
> 
> In a private thread ealier Linus raised the point that the batching and
> freeing of lots of pages at once is probably better for I$.

That would be something to try. For now I would like to do a conversion
that more or less preserves the old behavior. You know these pesky TLB
related bugs..

> > +config HAVE_RCU_NO_GATHER_PAGES
> > +	bool  
> 
> I have a problem with the name more than anything else; this name
> suggests it is the RCU table freeing that should not batch, which is not
> the case, you want the regular page gather gone, but very much require
> the RCU table gather to batch.
> 
> So I would like to propose calling it:
> 
> config HAVE_MMU_GATHER_NO_GATHER
> 
> Or something along those lines.
 
Imho a positive config option like HAVE_MMU_GATHER_PAGES would make the
most sense. It has the downside that it needs to be added to all
arch/*/Kconfig files except for s390. 

But I am not hung-up on a name, whatever does not sound to awful will do
for me. HAVE_MMU_GATHER_NO_GATHER would be ok.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
