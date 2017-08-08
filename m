Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9330E6B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 07:04:14 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b20so26295176itd.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 04:04:14 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n126si1055582iod.303.2017.08.08.04.04.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 04:04:13 -0700 (PDT)
Date: Tue, 8 Aug 2017 13:04:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v5 04/11] mm: VMA sequence count
Message-ID: <20170808110406.sathbzn4yxlq66ss@hirez.programming.kicks-ass.net>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <1536011f-c8ac-0c00-7018-90cf3384f048@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536011f-c8ac-0c00-7018-90cf3384f048@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Tue, Aug 08, 2017 at 04:29:32PM +0530, Anshuman Khandual wrote:
> On 06/16/2017 11:22 PM, Laurent Dufour wrote:
> > From: Peter Zijlstra <peterz@infradead.org>
> > 
> 
> First of all, please do mention that its adding a new element into the
> vm_area_struct which will act as a sequential lock element and help
> in navigating page fault without mmap_sem lock.

You're not making sense, there is no lock, and the lines below clearly
state we're adding a sequence count.

> 
> > Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
> > counts such that we can easily test if a VMA is changed
> 
> Yeah true.
> 
> > 
> > The unmap_page_range() one allows us to make assumptions about
> > page-tables; when we find the seqcount hasn't changed we can assume
> > page-tables are still valid.
> 
> Because unmap_page_range() is the only function which can tear it down ?
> Or is there any other reason for this assumption ?

Yep.

> > 
> > The flip side is that we cannot distinguish between a vma_adjust() and
> > the unmap_page_range() -- where with the former we could have
> > re-checked the vma bounds against the address.
> 
> Distinguished for what purpose ?

It states. If you know its a vma_adjust we could just check if we're
inside the new boundaries and continue. But since we cannot, we have to
assume the worst and bail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
