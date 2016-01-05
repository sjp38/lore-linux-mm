Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5C06B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 08:59:06 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id u188so24157015wmu.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:59:06 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id k67si5441397wmc.99.2016.01.05.05.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 05:59:05 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id b14so30305696wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:59:05 -0800 (PST)
Date: Tue, 5 Jan 2016 14:59:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] free_pages stuff
Message-ID: <20160105135903.GA15594@dhcp22.suse.cz>
References: <20151221234615.GW20997@ZenIV.linux.org.uk>
 <CA+55aFwp4iy4rtX2gE2WjBGFL=NxMVnoFeHqYa2j1dYOMMGqxg@mail.gmail.com>
 <20151222010403.GX20997@ZenIV.linux.org.uk>
 <CA+55aFy9NrV_RnziN9z3p5O6rv1A0mirhLD0hL7Wrb77+YyBeg@mail.gmail.com>
 <20151222022226.GY20997@ZenIV.linux.org.uk>
 <CAMuHMdUGkVcUOH4VUXiuoa6eGVQEA+QRDEop3GrEOEWz8GeNig@mail.gmail.com>
 <20151222210435.GB20997@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151222210435.GB20997@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

[CCing linux-mm]

On Tue 22-12-15 21:04:35, Al Viro wrote:
[...]
> Documentation/which-allocator-should-I-use might be a good idea...  Notes
> below are just a skeleton - a lot of details need to be added; in particular,
> there should be a part on "I have this kind of address and I want that;
> when and how should that be done?", completely missing here.  And there
> should be a big scary warning along the lines of "this is NOT an invitation
> for a flood of checkpatch-inspired patches"...
> 
> Comments, corrections and additions would be very welcome.

FWIW I think this is a very good idea. The current form is good enough
IMHO.

> 1) Most of the time kmalloc() is the right thing to use.
> Limitations: alignment is no better than word, not available very early in
> bootstrap, allocated memory is physically contiguous, so large allocations
> are best avoided.
> 
> 2) kmem_cache_alloc() allows to specify the alignment at cache creation
> time.  Otherwise it's similar to kmalloc().  Normally it's used for
> situations where we have a lot of instances of some type and want dynamic
> allocation of those.
> 
> 3) vmalloc() is for large allocations.  They will be page-aligned,
> but *not* physically contiguous.  OTOH, large physically contiguous
> allocations are generally a bad idea.  Unlike other allocators, there's
> no variant that could be used in interrupt; freeing is possible there,
> but allocation is not.  Note that non-blocking variant *does* exist -
> __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL) can be used in atomic
> contexts; it's the interrupt ones that are no-go.

It is also hardcoded GFP_KERNEL context so a usage from NOFS context
needs a special treatment.

> 4) if it's very early in bootstrap, alloc_bootmem() and friends
> may be the only option.  Rule of the thumb: if it's already printed
> Memory: ...../..... available.....
> you shouldn't be using that one.  Allocations are physically contiguous
> and at that point large physically contiguous allocations are still OK.
> 
> 5) if you need to allocate memory for DMA, use dma_alloc_coherent()
> and friends.  They'll give you both the virtual address for your use
> and DMA address refering to the same memory for use by device; do *NOT*
> try to derive the latter from the former; use of virt_to_bus() et.al.
> is a Bloody Bad Idea(tm).
> 
> 6) if you need a reference to struct page, use alloc_page/alloc_pages.
> 
> 7) in some cases (page tables, for the most obvious example), __get_free_page()
> and friends might be the right answer.  In principle, it's case (6), but
> it returns page_address(page) instead of the page itself.  Historically that
> was the first API introduced, so a _lot_ of places that should've been using
> something else ended up using that.  Do not assume that being lower level
> makes it faster than e.g. kmalloc() - this is simply not true.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
