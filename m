Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 47C376B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 19:44:30 -0400 (EDT)
Received: by obbgp5 with SMTP id gp5so69317011obb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 16:44:30 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id k7si5183570oes.103.2015.07.09.16.44.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 16:44:29 -0700 (PDT)
Message-ID: <1436485405.3214.99.camel@hp.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 09 Jul 2015 17:43:25 -0600
In-Reply-To: <20150709014020.GA7021@wotan.suse.de>
References: 
	<CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	 <20150701062352.GA3739@lst.de>
	 <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
	 <20150701065948.GA4355@lst.de>
	 <CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
	 <20150701072828.GA4881@lst.de> <20150707095012.GQ7021@wotan.suse.de>
	 <20150707101330.GJ7557@n2100.arm.linux.org.uk>
	 <20150707160703.GR7021@wotan.suse.de> <1436310658.3214.85.camel@hp.com>
	 <20150709014020.GA7021@wotan.suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@amacapital.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Julia Lawall <julia.lawall@lip6.fr>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, mcgrof@do-not-panic.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, 2015-07-09 at 03:40 +0200, Luis R. Rodriguez wrote:
> On Tue, Jul 07, 2015 at 05:10:58PM -0600, Toshi Kani wrote:
> > On Tue, 2015-07-07 at 18:07 +0200, Luis R. Rodriguez wrote:
> > > On Tue, Jul 07, 2015 at 11:13:30AM +0100, Russell King - ARM 
> > > Linux 
> > > wrote:
> >   :
> > > > On ARM, we (probably) have a lot of cases where ioremap() is 
> > > > used 
> > > > multiple
> > > > times for the same physical address space, so we shouldn't rule 
> > > > out 
> > > > having
> > > > multiple mappings of the same type.
> > > 
> > > Why is that done? Don't worry if you are not sure why but only 
> > > speculate of the
> > > practice's existence (sloppy drivers or lazy driver developers). 
> > > FWIW 
> > > for x86
> > > IIRC I ended up concluding that overlapping ioremap() calls with 
> > > the 
> > > same type
> > > would work but not if they differ in type.  Although I haven't 
> > > written a
> > > grammer rule to hunt down overlapping ioremap() I suspected its 
> > > use 
> > > was likely
> > > odd and likely should be reconsidered. Would this be true for ARM 
> > > too 
> > > ? Or are
> > > you saying this should be a feature ? I don't expect an answer 
> > > now 
> > > but I'm
> > > saying we *should* all together decide on this, and if you're 
> > > inclined to
> > > believe that this should ideally be avoided I'd like to hear 
> > > that. If 
> > > you feel
> > > strongly though this should be a feature I would like to know 
> > > why.
> > 
> > There are multiple mapping interfaces, and overlapping can happen 
> > among
> > them as well.  For instance, remap_pfn_range() (and 
> > io_remap_pfn_range(), which is the same as remap_pfn_range() on 
> > x86)
> > creates a mapping to user space. The same physical ranges may be
> > mapped to kernel and user spaces.  /dev/mem is one example that may
> > create a user space mapping to a physical address that is already
> > mapped with ioremap() by other module.
> 
> Thanks for the feedback. The restriction seems to be differing cache 
> types
> requirements, other than this, are there any other concerns ? For 
> instance are
> we completley happy with aliasing so long as cache types match 
> everywhere?  I'd
> expect no architecture would want cache types to differ when 
> aliasing, what
> should differ then I think would just be how to verify this and it 
> doesn't seem
> we may be doing this for all architectures.
> 
> Even for userspace we seem to be covered -- we enable userspace 
> mmap() calls to
> get their mapped space with a cache type, on the kernel we'd say use
> pgprot_writecombine() on the vma->vm_page_prot prior to the
> io_remap_pfn_range() -- that maps to remap_pfn_range() on x86 and as 
> you note
> that checks cache type via reserve_memtype() -- but only on x86...
> 
> Other than this differing cache type concern are we OK with aliasing 
> in
> userspace all the time ?
> 
> If we want to restrict aliasing either for the kernel or userspace 
> mapping
> we might be able to do it, I just want to know if we want to or not 
> care
> at all.

Yes, we allow to create multiple mappings to a same physical page as
long as their cache type is the same.  There are multiple use-cases
that depend on this ability.

> > pmem and DAX also create mappings to the same NVDIMM ranges.  DAX 
> > calls
> > vm_insert_mixed(), which is particularly a problematic since
> > vm_insert_mixed() does not verify aliasing.  ioremap() and 
> > remap_pfn_range()
> > call reserve_memtype() to verify aliasing on x86. 
> >  reserve_memtype() is
> > x86-specific and there is no arch-generic wrapper for such check.
> 
> As clarified by Matthew Wilcox via commit d92576f1167cacf7844 ("dax: 
> does not
> work correctly with virtual aliasing caches") caches are virtually 
> mapped for
> some architectures, it seems it should be possible to fix this for 
> DAX somehow
> though.

I simply described this DAX case as an example of how two modules might
request different cache types.  Yes, we should be able to fix this
case.

> > I think DAX could get a cache type from pmem to keep them in sync, 
> > though.
> 
> pmem is x86 specific right now, are other folks going to expose 
> something
> similar ? Otherwise we seem to only be addressing these deep concerns 
> for
> x86 so far.

pmem is a generic driver and is not x86-specific. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
