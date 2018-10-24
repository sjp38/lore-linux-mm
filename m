Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF1A6B0285
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 08:44:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b27-v6so3246250pfm.15
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 05:44:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g129-v6sor4114479pgc.52.2018.10.24.05.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 05:44:50 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:44:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181024124443.husnnxgligsncm5t@kshutemo-mobl1>
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
 <20181023163157.41441-2-kirill.shutemov@linux.intel.com>
 <20181024115447.GE25444@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024115447.GE25444@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 24, 2018 at 04:54:47AM -0700, Matthew Wilcox wrote:
> On Tue, Oct 23, 2018 at 07:31:56PM +0300, Kirill A. Shutemov wrote:
> > -ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
> > +ffff888000000000 - ffff887fffffffff (=39 bits) LDT remap for PTI
> 
> I'm a little bit cross-eyed at this point, but I think the above '888'
> should be '880'.
> 
> > @@ -14,7 +15,6 @@ ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
> >  ... unused hole ...
> >  				    vaddr_end for KASLR
> >  fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
> > -fffffe8000000000 - fffffeffffffffff (=39 bits) LDT remap for PTI
> 
> ... and the line above this one should be adjusted to finish at
> fffffeffffffffff (also it's now 40 bits).  Or should there be something
> else here?
> 
> >  ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
> >  ... unused hole ...
> >  ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
> > @@ -30,8 +30,8 @@ Virtual memory map with 5 level page tables:
> >  0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
> >  hole caused by [56:63] sign extension
> >  ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
> > -ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
> > -ff90000000000000 - ff9fffffffffffff (=52 bits) LDT remap for PTI
> > +ff10000000000000 - ff10ffffffffffff (=48 bits) LDT remap for PTI
> > +ff11000000000000 - ff90ffffffffffff (=55 bits) direct mapping of all phys. memory
> 
> What's at ff910..0 to ff9f..f ?
> 
> Is there any way we can generate this part of this file to prevent human
> error from creeping in over time?  ;-)

In current Linus' tree this part of the documentation was re-written. I've
rebased to it and rewrote the documenation for the change.

I believe I've fixed all mistakes you've noticied. Please check out v2. I
will post it soon.

-- 
 Kirill A. Shutemov
