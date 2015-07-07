Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 852616B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 19:12:06 -0400 (EDT)
Received: by ykeo3 with SMTP id o3so71771356yke.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 16:12:06 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id w5si124472ywf.213.2015.07.07.16.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 16:12:05 -0700 (PDT)
Message-ID: <1436310658.3214.85.camel@hp.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 07 Jul 2015 17:10:58 -0600
In-Reply-To: <20150707160703.GR7021@wotan.suse.de>
References: <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	 <20150622161002.GB8240@lst.de>
	 <CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	 <20150701062352.GA3739@lst.de>
	 <CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
	 <20150701065948.GA4355@lst.de>
	 <CAMuHMdXqjmo2T3V=msZySVSu2j4YjyE7FnVXWTjySEyfYLSg1A@mail.gmail.com>
	 <20150701072828.GA4881@lst.de> <20150707095012.GQ7021@wotan.suse.de>
	 <20150707101330.GJ7557@n2100.arm.linux.org.uk>
	 <20150707160703.GR7021@wotan.suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, Andy Lutomirski <luto@amacapital.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Julia Lawall <julia.lawall@lip6.fr>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, mcgrof@do-not-panic.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, 2015-07-07 at 18:07 +0200, Luis R. Rodriguez wrote:
> On Tue, Jul 07, 2015 at 11:13:30AM +0100, Russell King - ARM Linux 
> wrote:
  :
> > On ARM, we (probably) have a lot of cases where ioremap() is used 
> > multiple
> > times for the same physical address space, so we shouldn't rule out 
> > having
> > multiple mappings of the same type.
> 
> Why is that done? Don't worry if you are not sure why but only 
> speculate of the
> practice's existence (sloppy drivers or lazy driver developers). FWIW 
> for x86
> IIRC I ended up concluding that overlapping ioremap() calls with the 
> same type
> would work but not if they differ in type.  Although I haven't 
> written a
> grammer rule to hunt down overlapping ioremap() I suspected its use 
> was likely
> odd and likely should be reconsidered. Would this be true for ARM too 
> ? Or are
> you saying this should be a feature ? I don't expect an answer now 
> but I'm
> saying we *should* all together decide on this, and if you're 
> inclined to
> believe that this should ideally be avoided I'd like to hear that. If 
> you feel
> strongly though this should be a feature I would like to know why.

There are multiple mapping interfaces, and overlapping can happen among
them as well.  For instance, remap_pfn_range() (and 
io_remap_pfn_range(), which is the same as remap_pfn_range() on x86)
creates a mapping to user space.  The same physical ranges may be
mapped to kernel and user spaces.  /dev/mem is one example that may
create a user space mapping to a physical address that is already
mapped with ioremap() by other module.  pmem and DAX also create
mappings to the same NVDIMM ranges.  DAX calls vm_insert_mixed(), which
is particularly a problematic since vm_insert_mixed() does not verify
aliasing.  ioremap() and remap_pfn_range() call reserve_memtype() to
verify aliasing on x86.  reserve_memtype() is x86-specific and there is
no arch-generic wrapper for such check.  I think DAX could get a cache
type from pmem to keep them in sync, though.

Thanks,
-Toshi


 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
