Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2D26B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 12:47:35 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so62974624wid.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 09:47:34 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id hf9si26287836wib.39.2015.07.01.09.47.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 09:47:32 -0700 (PDT)
Received: by widjy10 with SMTP id jy10so62973657wid.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 09:47:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150701080915.GJ7557@n2100.arm.linux.org.uk>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161002.GB8240@lst.de>
	<CAPcyv4h5OXyRvZvLGD5ZknO-YUPn675YGv0XdtW1QOO9qmZsug@mail.gmail.com>
	<20150701062352.GA3739@lst.de>
	<CAMuHMdUO4uSWH1Qc0SfDTLuXbiG2N9fq8Tf6j+3RoqVKdPugbA@mail.gmail.com>
	<20150701080915.GJ7557@n2100.arm.linux.org.uk>
Date: Wed, 1 Jul 2015 09:47:31 -0700
Message-ID: <CAPcyv4iaf77KMffTseMbYEcK_BJTpGsY=PmeJyDGR9N2yBAKVg@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Jul 1, 2015 at 1:09 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Jul 01, 2015 at 08:55:57AM +0200, Geert Uytterhoeven wrote:
>> On Wed, Jul 1, 2015 at 8:23 AM, Christoph Hellwig <hch@lst.de> wrote:
>> >> One useful feature of the ifdef mess as implemented in the patch is
>> >> that you could test for whether ioremap_cache() is actually
>> >> implemented or falls back to default ioremap().  I think for
>> >> completeness archs should publish an ioremap type capabilities mask
>> >> for drivers that care... (I can imagine pmem caring), or default to
>> >> being permissive if something like IOREMAP_STRICT is not set.  There's
>> >> also the wrinkle of archs that can only support certain types of
>> >> mappings at a given alignment.
>> >
>> > I think doing this at runtime might be a better idea.  E.g. a
>> > ioremap_flags with the CACHED argument will return -EOPNOTSUP unless
>> > actually implemented.  On various architectures different CPUs or
>> > boards will have different capabilities in this area.
>>
>> So it would be the responsibility of the caller to fall back from
>> ioremap(..., CACHED) to ioremap(..., UNCACHED)?
>> I.e. all drivers using it should be changed...
>
> Another important point here is to define what the properties of the
> mappings are.  It's no good just saying "uncached".
>
> We've recently been around this over the PMEM driver and the broken
> addition of ioremap_wt() on ARM...
>
> By "properties" I mean stuff like whether unaligned accesses permitted,
> any kind of atomic access (eg, xchg, cmpxchg, etc).
>
> This matters: on ARM, a mapping suitable for a device does not support
> unaligned accesses or atomic accesses - only "memory-like" mappings
> support those.  However, memory-like mappings are not required to
> preserve access size, number of accesses, etc which makes them unsuitable
> for device registers.

I'm proposing that we explicitly switch "memory-like" use cases over
to a separate set of "memremap()" apis, as these are no longer
"__iomem" [1].

> The problem with ioremap_uncached() in particular is that we have LDD
> and other documentation telling people to use it to map device registers,
> so we can't define ioremap_uncached() on ARM to have memory-like
> properties, and it doesn't support unaligned accesses.
>
> I have a series of patches which fix up 32-bit ARM for the broken
> ioremap_wt() stuff that was merged during this merge window, which I
> intend to push out into linux-next at some point (possibly during the
> merge window, if not after -rc1) which also move ioremap*() out of line
> on ARM but more importantly, adds a load of documentation about the
> properties of the resulting mapping on ARM.

Sounds good, I'll look for that before proceeding on this clean up.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-June/001331.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
