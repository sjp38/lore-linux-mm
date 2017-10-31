Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0426B0069
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:04:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n8so7654773wmg.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:04:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a79sor440539wma.11.2017.10.31.05.04.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 05:04:33 -0700 (PDT)
Date: Tue, 31 Oct 2017 15:04:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171031120429.ehaqy2iciewcij35@node.shutemov.name>
References: <20171023122159.wyztmsbgt5k2d4tb@node.shutemov.name>
 <20171023124014.mtklgmydspnvfcvg@gmail.com>
 <20171023124811.4i73242s5dotnn5k@node.shutemov.name>
 <20171024094039.4lonzocjt5kras7m@gmail.com>
 <20171024113819.pli7ifesp2u2rexi@node.shutemov.name>
 <20171024124741.ux74rtbu2vqaf6zt@gmail.com>
 <20171024131227.nchrzazuk4c6r75i@node.shutemov.name>
 <20171026073752.fl4eicn4x7wudpop@gmail.com>
 <20171026144040.hjm45civpm74gafx@node.shutemov.name>
 <20171031094727.cvipkxzo2zhrxst3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031094727.cvipkxzo2zhrxst3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 31, 2017 at 10:47:27AM +0100, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > I don't think this design is reasonable.
> > 
> >   - It introduces memory references where we haven't had them before.
> > 
> >     At this point all variable would fit a cache line, which is not that
> >     bad. But I don't see what would stop the list from growing in the
> >     future.
> 
> Is any of these actually in a hotpath?

Probably, no. Closest to hotpath I see so far is page_zone_id() in page
allocator.

> Also, note the context: your changes turn some of these into variables. Yes, I 
> suggest structuring them all and turning them all into variables, exactly because 
> the majority are now dynamic, yet their _naming_ suggests that they are constants.

Another way to put it would be that you suggest significant rework of kernel
machinery based on cosmetic nitpick. :)

> >   - We loose ability to optimize out change with static branches
> >     (cpu_feature_enabled() instead of pgtable_l5_enabled variable).
> > 
> >     It's probably, not that big of an issue here, but if we are going to
> >     use the same approach for other dynamic macros in the patchset, it
> >     might be.
> 
> Here too I think the (vast) majority of the uses here are for bootup/setup/init 
> purposes, where clarity and maintainability of code matters a lot.

I would argue that it makes maintainability worse.

It makes dependencies between values less obvious. For instance, checking
MAXMEM definition on x86-64 makes it obvious that it depends directly
on MAX_PHYSMEM_BITS.

If we would convert MAXMEM to variable, we would need to check where the
variable is initialized and make sure that nobody changes it afterwards.

Does it sound like a win for maintainability?

> >   - AFAICS, it requires changes to all architectures to provide such
> >     structures as we now partly in generic code.
> > 
> >     Or to introduce some kind of compatibility layer, but it would make
> >     the kernel as a whole uglier than cleaner. Especially, given that
> >     nobody beyond x86 need this.
> 
> Yes, all the uses should be harmonized (no compatibility layer) - but as you can 
> see it from the histogram I generated it's a few dozen uses, i.e. not too bad.

Without a compatibility layer, I would need to change every architecture.
It's few dozen patches easily. Not fun.

---------------------------------8<------------------------------------

Putting, my disagreement with the design aside, I try to prototype it.
And stumble an issue that I don't see how to solve.

If we are going to convert macros to variable whether they need to be
variable in the configuration we quickly put ourself into corner:

 - SECTIONS_SHIFT is dependent on MAX_PHYSMEM_BITS.

 - SECTIONS_SHIFT is used to define SECTIONS_WIDTH, but only if
   CONFIG_SPARSEMEM_VMEMMAP is not enabled. SECTIONS_WIDTH is zero
   otherwise.

At this point we can convert both SECTIONS_SHIFT and SECTIONS_WIDTH to
variables.

But SECTIONS_WIDTH used on preprocessor level to determinate NODES_WIDTH,
which used to determinate if we going to define NODE_NOT_IN_PAGE_FLAGS and
the value of LAST_CPUPID_WIDTH.

Making SECTIONS_WIDTH variable breaks the preprocessor logic. But problems
don't stop there:

  - LAST_CPUPID_WIDTH determinate if LAST_CPUPID_NOT_IN_PAGE_FLAGS is defined.

  - LAST_CPUPID_NOT_IN_PAGE_FLAGS is used define struct page and therefore
    cannot be dynamic (read variable).


In my patchset I made X86_5LEVEL select SPARSEMEM_VMEMMAP. It breaks the
chain and SECTIONS_WIDTH is never dynamic.

But how get it work with the design?

I can only think of hack like making machine.physmem.sections.shift a
constant macro if we don't want it dynamic for the configuration and leave
SECTHION_WITH as a constant in generic code.

To me it's ugly as hell.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
