Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B038E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:30:25 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b9-v6so572972otl.4
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:30:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 141-v6si2446013oia.278.2018.09.13.03.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 03:30:23 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8DATKlH092639
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:30:22 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mfk6e79hc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:30:22 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 13 Sep 2018 11:30:19 +0100
Date: Thu, 13 Sep 2018 12:30:14 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
In-Reply-To: <20180913092811.894806629@infradead.org>
References: <20180913092110.817204997@infradead.org>
	<20180913092811.894806629@infradead.org>
MIME-Version: 1.0
Message-Id: <20180913123014.0d9321b8@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, 13 Sep 2018 11:21:11 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> Write a comment explaining some of this..
> 
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  include/asm-generic/tlb.h |  120 ++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 117 insertions(+), 3 deletions(-)
> 
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -22,6 +22,119 @@
> 
>  #ifdef CONFIG_MMU
> 
> +/*
> + * Generic MMU-gather implementation.
> + *
> + * The mmu_gather data structure is used by the mm code to implement the
> + * correct and efficient ordering of freeing pages and TLB invalidations.
> + *
> + * This correct ordering is:
> + *
> + *  1) unhook page
> + *  2) TLB invalidate page
> + *  3) free page
> + *
> + * That is, we must never free a page before we have ensured there are no live
> + * translations left to it. Otherwise it might be possible to observe (or
> + * worse, change) the page content after it has been reused.
> + *

This first comment already includes the reason why s390 is probably better off
with its own mmu-gather implementation. It depends on the situation if we have

1) unhook the page and do a TLB flush at the same time
2) free page

or

1) unhook page
2) free page
3) final TLB flush of the whole mm

A variant of the second order we had in the past is to do the mm TLB flush first,
then the unhooks and frees of the individual pages. The are some tricky corners
switching between the two variants, see finish_arch_post_lock_switch.

The point is: we *never* have the order 1) unhook, 2) TLB invalidate, 3) free.
If there is concurrency due to a multi-threaded application we have to do the
unhook of the page-table entry and the TLB flush with a single instruction.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
