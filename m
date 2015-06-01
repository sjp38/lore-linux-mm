Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id C6FC46B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 10:32:11 -0400 (EDT)
Received: by labko7 with SMTP id ko7so99383663lab.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 07:32:11 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id kw8si24999211wjb.181.2015.06.01.07.32.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 07:32:10 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/4] arch: introduce memremap()
Date: Mon, 01 Jun 2015 16:29:55 +0200
Message-ID: <2979323.pqVEGrEfg7@wuerfel>
In-Reply-To: <CAPcyv4hqQaabcOsOZA9emT5f+UF9GgD-PiYupng4HYwymcvYmQ@mail.gmail.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com> <201505302300.10950.arnd@arndb.de> <CAPcyv4hqQaabcOsOZA9emT5f+UF9GgD-PiYupng4HYwymcvYmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Saturday 30 May 2015 14:39:48 Dan Williams wrote:
> On Sat, May 30, 2015 at 2:00 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Saturday 30 May 2015, Dan Williams wrote:
> >>
> >> +/*
> >> + * memremap() is "ioremap" for cases where it is known that the resource
> >> + * being mapped does not have i/o side effects and the __iomem
> >> + * annotation is not applicable.
> >> + */
> >> +
> >> +static inline void *memremap(resource_size_t offset, size_t size)
> >> +{
> >> +       return (void __force *) ioremap(offset, size);
> >> +}
> >> +
> >> +static inline void *memremap_nocache(resource_size_t offset, size_t size)
> >> +{
> >> +       return (void __force *) ioremap_nocache(offset, size);
> >> +}
> >> +
> >> +static inline void *memremap_cache(resource_size_t offset, size_t size)
> >> +{
> >> +       return (void __force *) ioremap_cache(offset, size);
> >> +}
> >> +
> >
> > There are architectures on which the result of ioremap is not necessarily
> > a pointer, but instead indicates that the access is to be done through
> > some other indirect access, or require special instructions. I think implementing
> > the memremap() interfaces is generally helpful, but don't rely on the
> > ioremap implementation.
> 
> Is it enough to detect the archs where ioremap() does return an
> otherwise usable pointer and set ARCH_HAS_MEMREMAP, in the first take
> of this introduction?  Regardless, it seems that drivers should have
> Kconfig dependency checks for archs where ioremap can not be used in
> this manner.

Yes, that should work.

> > Adding both cached an uncached versions is also dangerous, because you
> > typically get either undefined behavior or a system checkstop when a
> > single page is mapped both cached and uncached at the same time. This
> > means that doing memremap() or memremap_nocache() on something that
> > may be part of the linear kernel mapping is a bug, and we should probably
> > check for that here.
> 
> Part of the reason for relying on ioremap() was to borrow its internal
> checks to fail attempts that try to remap ranges that are already in
> the kernel linear map.  Hmm, that's a guarantee x86 ioremap gives, but
> maybe that's not universal?

I haven't seen that check elsewhere. IIRC what ioremap() guarantees on ARM
is that if there is an existing boot-time mapping (similar to x86 fixmap,
but more commonly used), we use the same flags in the new ioremap and
override the ones that are provided by the caller.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
