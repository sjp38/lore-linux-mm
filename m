Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5138E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:48:45 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m207-v6so9633235itg.5
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:48:45 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 134-v6si3436270ity.41.2018.09.13.11.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 11:48:44 -0700 (PDT)
Date: Thu, 13 Sep 2018 20:48:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 03/11] x86/mm: Page size aware flush_tlb_mm_range()
Message-ID: <20180913184836.GN24142@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.012757318@infradead.org>
 <f89e61a3-0eb0-3d00-fbaa-f30c2cf60be3@linux.intel.com>
 <20180913184230.GD24124@hirez.programming.kicks-ass.net>
 <20180913184632.GM24142@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913184632.GM24142@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 08:46:32PM +0200, Peter Zijlstra wrote:
> On Thu, Sep 13, 2018 at 08:42:30PM +0200, Peter Zijlstra wrote:
> > > > +#define flush_tlb_range(vma, start, end)			\
> > > > +		flush_tlb_mm_range((vma)->vm_mm, start, end,	\
> > > > +				(vma)->vm_flags & VM_HUGETLB ? PMD_SHIFT : PAGE_SHIFT)
> > > 
> > > This is safe.  But, Couldn't this PMD_SHIFT also be PUD_SHIFT for a 1G
> > > hugetlb page?
> > 
> > It could be, but can we tell at that point?
> 
> I had me a look in higetlb.h, would something like so work?
> 
> #define flush_tlb_range(vma, start, end)			\
> 	flush_tlb_mm_range((vma)->vm_mm, start, end,		\
> 			   huge_page_shift(hstate_vma(vma)))
> 

D'uh

#define flush_tlb_range(vma, start, end)			\
	flush_tlb_mm_range((vma)->vm_mm, start, end,		\
	   (vma)->vm_flags & VM_HUGETLB ? huge_page_shift(hstate_vma(vma)) : PAGE_SHIFT)
