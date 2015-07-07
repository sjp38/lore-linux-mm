Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 751F89003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 05:50:20 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so162740798wgj.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 02:50:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si35165924wjz.93.2015.07.07.02.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jul 2015 02:50:18 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:50:12 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150707095012.GQ7021@wotan.suse.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
 <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
 <20150622161002.GB8240@lst.de>
 <CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
 <20150701062352.GA3739@lst.de>
 <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
 <20150701065948.GA4355@lst.de>
 <CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
 <20150701072828.GA4881@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701072828.GA4881@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@amacapital.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Julia Lawall <julia.lawall@lip6.fr>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, mcgrof@do-not-panic.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 01, 2015 at 09:28:28AM +0200, Christoph Hellwig wrote:
> On Wed, Jul 01, 2015 at 09:19:29AM +0200, Geert Uytterhoeven wrote:
> > >> So it would be the responsibility of the caller to fall back from
> > >> ioremap(..., CACHED) to ioremap(..., UNCACHED)?
> > >> I.e. all drivers using it should be changed...
> > >
> > > All of the zero users we currently have will need to be changed, yes.
> > 
> > Good. Less work to convert all of these ;-)
> 
> And I didn't have enough coffee yet.  We of course have a few users of
> ioremap_cache(), and two implememantions but no users of ioremap_cached().
> Looks like the implementations can't even agree on the name.

Yies, that naming is icky... we also have quite a bit of ioremap_nocache() users:

mcgrof@ergon ~/linux-next (git::kill-mtrr)$ git grep ioremap_nocache drivers/| wc -l
359

On x86 the default ioremap() happens to map to ioremap_nocache() anyway as well.

This is on purpose, there is an ongoing effort to streamline ioremap_nocache()
for registers on the x86 front with the long term goal then of making PAT
strong UC the default preference for both ioremap() and ioremap_nocache() for
PAT enabled systems. This would prevent things like write-combining modifiers
from having any effect on the area. This comes with a small architectural
driver cost, it means all write-combining desired areas must be split out in
drivers properly.  This is part of the work I've been doing lately. The
eventual goal once we have the write-combing areas properly split with
ioremap_wc() and using the new proper preferred architecture agnostic modifier
(arch_phys_wc_add()) is to change the default ioremap behaviour on x86 to use
strong UC for PAT enabled systems for *both* ioremap() and ioremap_nocache().

This was aleady done once but reverted later due to the regression issues on
video drivers not haveing the right ioremap_wc() calls. I'm finishing this
effort and am about a few patches away...

Once done and once things cool down we should go back and may consider flipping
the switch again to make strong UC default. For details refer to commit
de33c442ed2a465 ("x86 PAT: fix performance drop for glx, use UC minus
for ioremap(), ioremap_nocache() and pci_mmap_page_range()").

All this is fine in theory -- but Benjamin Herrenschmidt recently also
noted that on powerpc the write-combining may end up requiring each
register read/write with its own specific API. That is, we'd lose the
magic of having things being done behind the scenes, and that would
also mean tons of reads/writes may need to be converted over to be
explicit about write-combining preferences...

I will note that upon discussions it seems that the above requirement
may have been a slight mishap on not being explicit about our semantics
and requirements on ioremap() variants, technically it may be possible
that effectively PowerPC may not get any write-combining effects on
infiniband / networking / anything not doing write-combining on
userspace such as framebuffer... from what I gather that needs to
be fixed. Because of these grammatical issues and the issues with
unaligned access with ARM I think its important we put some effort
to care a bit more about defining clear semantics through grammar
for new APIs or as we rewrite APIs. We have tools to do this these
days, best make use of them.

While we're at it and reconsidering all this, a few items I wish for
us to address as well then, most of them related to grammar, some
procedural clarification:

  * Document it as not supported to have overlapping ioremap() calls.
    No one seems to have a clue if this should work, but clearly this
    is just a bad idea. I don't see why we should support the complexity
    of having this. It seems we can write grammar rules to prevent this.

  * We seem to care about device drivers / kernel code doing unaligned
    accesses with certain ioremap() variants. At least for ARM you should
    not do unaligned accesses on ioremap_nocache() areas. I am not sure
    if we can come up with grammar to vet for / warn for unaligned access
    type of code in driver code on some memory area when some ioremap()
    variant is used, but this could be looked into. I believe we may
    want rules for unaligned access maybe in general, and not attached
    to certain calls due to performance considerations, so this work
    may be welcomed regardless (refer to
    Documentation/unaligned-memory-access.txt)
    
  * We seem to want to be pedantic about adding new ioremap() variants, the
    unaligned issue on ARM is one reason, do we ideally then want *all*
    architecture maintainers to provide an Acked-by for any new ioremap
    variants ? Are we going to have to sit and wait for a kumbaya every time
    a helper comes along to see how it all fits well for all architectures?
    The asm-generic io.h seemed to have set in place the ability to let
    architectures define things *when* they get to it, that seems like a much
    more fair approach *if* and *when possible*.  Can we not have and define
    a *safe* ioremap() call to fall under ?  The unaligned access concerns seem
    fair but.. again it seems we generally care about unaligned access anyway,
    so the concern really should be to fix all driver code to not do unaligned
    access, if possible no?

  * There are helpers such as set_memory_wc() which should not be used
    on IO memory, we should define grammar rules for these.

  * There are ioremap() variants which may require helpers for architectures.
    The only example I am aware of is ioremap_wc() requires arch_phys_wc_add()
    so that on x86 PAT enabled systems this does nothing, but on x86 non-PAT
    systems this will use MTRRs. The arch_phys_wc_add() API can be re-purposed
    for other architectures if needed, maybe benh can look at this for powerpc?
    But it seems those helpers were added mostly with a bias towards x86
    requirements, do we again expect all architecture maintainers to provide
    an Acked-by for ioremap() variants helpers ?

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
