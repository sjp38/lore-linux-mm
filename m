Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF2CF6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 06:40:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q124so360800wmb.23
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 03:40:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y14sor158208wmh.20.2017.09.28.03.40.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 03:40:08 -0700 (PDT)
Date: Thu, 28 Sep 2017 12:40:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 09/19] x86/mm: Make MAX_PHYSADDR_BITS and
 MAX_PHYSMEM_BITS dynamic
Message-ID: <20170928104005.j23dwfkuycf2qqrk@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-10-kirill.shutemov@linux.intel.com>
 <20170928082514.tl6tuigmx6oleus6@gmail.com>
 <20170928101736.oqbgmcbi2yp446hc@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928101736.oqbgmcbi2yp446hc@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Thu, Sep 28, 2017 at 10:25:14AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > For boot-time switching between paging modes, we need to be able to
> > > adjust size of physical address space at runtime.
> > > 
> > > As part of making physical address space size variable, we have to make
> > > X86_5LEVEL dependent on SPARSEMEM_VMEMMAP. !SPARSEMEM_VMEMMAP
> > > configuration doesn't work well with variable MAX_PHYSMEM_BITS.
> > > 
> > > Affect on kernel image size:
> > > 
> > >    text    data     bss     dec     hex filename
> > > 10710340        4880000  860160 16450500         fb03c4 vmlinux.before
> > > 10710666        4880000  860160 16450826         fb050a vmlinux.after
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > ---
> > >  arch/x86/Kconfig                        | 1 +
> > >  arch/x86/include/asm/pgtable_64_types.h | 2 +-
> > >  arch/x86/include/asm/sparsemem.h        | 9 ++-------
> > >  arch/x86/kernel/setup.c                 | 5 ++---
> > >  4 files changed, 6 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > > index 6a15297140ff..f75723d62c25 100644
> > > --- a/arch/x86/Kconfig
> > > +++ b/arch/x86/Kconfig
> > > @@ -1403,6 +1403,7 @@ config X86_PAE
> > >  config X86_5LEVEL
> > >  	bool "Enable 5-level page tables support"
> > >  	depends on X86_64
> > > +	depends on SPARSEMEM_VMEMMAP
> > 
> > Adding a 'depends on' to random kernel internal implementational details, to 
> > support new hardware, sucks as an UI, as it will just randomly hide/show the new 
> > hardware option if certain magic Kconfig combinations are set.
> > 
> > Please check how other architectures are doing it. (Hint: they are using select.)
> > 
> > Also, what is the real dependency here? Why don't the other memory models work, 
> > what's the failure mode - won't build, won't boot, or misbehaves in some other 
> > way?
> 
> I won't build.
> 
> For !SPARSEMEM_VMEMMAP SECTIONS_WIDTH depends on MAX_PHYSMEM_BITS:
> 
> SECTIONS_WIDTH
>   SECTIONS_SHIFT
>     MAX_PHYSMEM_BITS
> 
> And SECTIONS_WIDTH is used on per-processor stage, it doesn't work if it's
> dyncamic. See include/linux/page-flags-layout.h.

Ok, this would be a good addition to the changelog.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
