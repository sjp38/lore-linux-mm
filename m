Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E71E6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:40:01 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so1074922wib.15
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:40:00 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id i1si1446837wiy.105.2014.10.22.04.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 04:39:57 -0700 (PDT)
Date: Wed, 22 Oct 2014 13:39:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 3/6] mm: VMA sequence count
Message-ID: <20141022113951.GB21513@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.361741939@infradead.org>
 <20141022112657.GG30588@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022112657.GG30588@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 22, 2014 at 02:26:57PM +0300, Kirill A. Shutemov wrote:
> On Mon, Oct 20, 2014 at 11:56:36PM +0200, Peter Zijlstra wrote:
> > Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
> > counts such that we can easily test if a VMA is changed.
> > 
> > The unmap_page_range() one allows us to make assumptions about
> > page-tables; when we find the seqcount hasn't changed we can assume
> > page-tables are still valid.
> > 
> > The flip side is that we cannot distinguish between a vma_adjust() and
> > the unmap_page_range() -- where with the former we could have
> > re-checked the vma bounds against the address.
> 
> You only took care about changing size of VMA or unmap. What about other
> aspects of VMA. How would you care about race with mprotect(2)?
> 
> 		CPU0						CPU1
>  mprotect()
>    mprotect_fixup()
>      vma_merge()
>        [ maybe update vm_sequence ]
>     						[ page fault kicks in ]
> 						  do_anonymous_page()
> 						    entry = mk_pte(page, fe->vma->vm_page_prot);
>      vma_set_page_prot(vma)
>        [ update vma->vm_page_prot ]
>      change_protection()
> 						    pte_map_lock()
> 						      [ vm_sequence is ok ]
> 						    set_pte_at(entry) // With old vm_page_prot!!!
> 

This won't happen, this is be serialized by the PTL and the fault
validates that the PTE is the 'same' it started out with after acquiring
the PTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
