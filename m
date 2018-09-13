Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B76598E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:46:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4-v6so3074374plk.7
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:46:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i186-v6si4420061pge.414.2018.09.13.11.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 11:46:43 -0700 (PDT)
Date: Thu, 13 Sep 2018 20:46:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 03/11] x86/mm: Page size aware flush_tlb_mm_range()
Message-ID: <20180913184632.GM24142@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.012757318@infradead.org>
 <f89e61a3-0eb0-3d00-fbaa-f30c2cf60be3@linux.intel.com>
 <20180913184230.GD24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913184230.GD24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 08:42:30PM +0200, Peter Zijlstra wrote:
> > > +#define flush_tlb_range(vma, start, end)			\
> > > +		flush_tlb_mm_range((vma)->vm_mm, start, end,	\
> > > +				(vma)->vm_flags & VM_HUGETLB ? PMD_SHIFT : PAGE_SHIFT)
> > 
> > This is safe.  But, Couldn't this PMD_SHIFT also be PUD_SHIFT for a 1G
> > hugetlb page?
> 
> It could be, but can we tell at that point?

I had me a look in higetlb.h, would something like so work?

#define flush_tlb_range(vma, start, end)			\
	flush_tlb_mm_range((vma)->vm_mm, start, end,		\
			   huge_page_shift(hstate_vma(vma)))
