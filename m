Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id BBE0E6B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 18:57:19 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so21906282wgq.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:57:18 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id v19si82388346wju.8.2015.06.30.15.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 15:57:17 -0700 (PDT)
Received: by wicgi11 with SMTP id gi11so29947575wic.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 15:57:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150622161002.GB8240@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161002.GB8240@lst.de>
Date: Tue, 30 Jun 2015 15:57:16 -0700
Message-ID: <CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Jun 22, 2015 at 9:10 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Jun 22, 2015 at 04:24:27AM -0400, Dan Williams wrote:
>> Some archs define the first parameter to ioremap() as unsigned long,
>> while the balance define it as resource_size_t.  Unify on
>> resource_size_t to enable passing ioremap function pointers.  Also, some
>> archs use function-like macros for defining ioremap aliases, but
>> asm-generic/io.h expects object-like macros, unify on the latter.
>>
>> Move all handling of ioremap aliasing (i.e. ioremap_wt => ioremap) to
>> include/linux/io.h.  Add a check to include/linux/io.h to warn at
>> compile time if an arch violates expectations.
>>
>> Kill ARCH_HAS_IOREMAP_WC and ARCH_HAS_IOREMAP_WT in favor of just
>> testing for ioremap_wc, and ioremap_wt being defined.  This arrangement
>> allows drivers to know when ioremap_<foo> are being re-directed to plain
>> ioremap.
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Hmm, this is quite a bit of churn, and doesn't make the interface lot
> more obvious.
>
> I guess it's enough to get the pmem related bits going, but I'd really
> prefer defining the ioremap* prototype in linux/io.h and requiring
> and out of line implementation in the architectures, it's not like
> it's a fast path.  And to avoid the ifdef mess make it something like:
>
> void __iomem *ioremap_flags(resource_size_t offset, unsigned long size,
>                         unsigned long prot_val, unsigned flags);

Doesn't 'flags' imply a specific 'prot_val'?

> static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, 0);
> }
>
> static inline void __iomem *ioremap_prot(resource_size_t offset,
>                 unsigned long size, unsigned long prot_val)
> {
>         return ioremap_flags(offset, size, prot_val, 0);
> }
>
> static inline void __iomem *ioremap_nocache(resource_size_t offset,
>                 unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, IOREMAP_NOCACHE);
> }
>
> static inline void __iomem *ioremap_cache(resource_size_t offset,
>                 unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, IOREMAP_CACHE);
> }
>
> static inline void __iomem *ioremap_uc(resource_size_t offset,
>                 unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, IOREMAP_UC);
> }
>
> static inline void __iomem *ioremap_wc(resource_size_t offset,
>                 unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, IOREMAP_WC);
> }
>
> static inline void __iomem *ioremap_wt(resource_size_t offset,
>                 unsigned long size)
> {
>         return ioremap_flags(offset, size, 0, IOREMAP_WT);
> }
>
> With all wrappers but ioremap() itself deprecated in the long run.
>
> Besides following the one API one prototype guideline this gives
> us one proper entry point for all the variants.  Additionally
> it can reject non-supported caching modes at run time, e.g. because
> different hardware may or may not support it.  Additionally it
> avoids the need for all these HAVE_IOREMAP_FOO defines, which need
> constant updating.

One useful feature of the ifdef mess as implemented in the patch is
that you could test for whether ioremap_cache() is actually
implemented or falls back to default ioremap().  I think for
completeness archs should publish an ioremap type capabilities mask
for drivers that care... (I can imagine pmem caring), or default to
being permissive if something like IOREMAP_STRICT is not set.  There's
also the wrinkle of archs that can only support certain types of
mappings at a given alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
