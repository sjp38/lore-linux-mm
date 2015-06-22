Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A793D6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 13:51:59 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so82859574wic.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 10:51:59 -0700 (PDT)
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id vl9si36244183wjc.156.2015.06.22.10.51.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 10:51:57 -0700 (PDT)
Received: by wgqq4 with SMTP id q4so22984942wgq.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 10:51:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150622161754.GC8240@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
	<20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com>
	<20150622161754.GC8240@lst.de>
Date: Mon, 22 Jun 2015 10:51:57 -0700
Message-ID: <CAPcyv4hweoNDZy8Q=dYbdGoY6wCNpAUFrsHvf9v1UpBqizhMHw@mail.gmail.com>
Subject: Re: [PATCH v5 6/6] arch, x86: pmem api for ensuring durability of
 persistent memory updates
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Richard Weinberger <richard@nod.at>

On Mon, Jun 22, 2015 at 9:17 AM, Christoph Hellwig <hch@lst.de> wrote:
>> +#ifdef ARCH_HAS_NOCACHE_UACCESS
>
> Seems like this is always define for x86 anyway?
>
>> +/**
>> + * arch_memcpy_to_pmem - copy data to persistent memory
>> + * @dst: destination buffer for the copy
>> + * @src: source buffer for the copy
>> + * @n: length of the copy in bytes
>> + *
>> + * Copy data to persistent memory media via non-temporal stores so that
>> + * a subsequent arch_wmb_pmem() can flush cpu and memory controller
>> + * write buffers to guarantee durability.
>> + */
> static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
>
> Too long line.  Also why not simply arch_copy_{from,to}_pmem?

I'm following the precedence set by memcpy_{from,to}_io().

>> +static inline void __pmem *arch_memremap_pmem(resource_size_t offset,
>> +     unsigned long size)
>> +{
>> +     return (void __force __pmem *) ioremap_cache(offset, size);
>> +}
>
> Now with my ioremap_flags proposal we'd just add an IOREMAP_PMEM
> flag, which architectures could implement (usually as no-op), and move
> the cast into memremap_pmem.

*nod*

>
>> + * These defaults seek to offer decent performance and minimize the
>> + * window between i/o completion and writes being durable on media.
>> + * However, it is undefined / architecture specific whether
>> + * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
>> + * making data durable relative to i/o completion.
>> + */
>> +static void default_memcpy_to_pmem(void __pmem *dst, const void *src, size_t size)
>> +{
>> +     memcpy((void __force *) dst, src, size);
>> +}
>
> This should really be in asm-generic (or at least your linux/pmem.h for now).

ok.

>> +static void __pmem *default_memremap_pmem(resource_size_t offset, unsigned long size)
>> +{
>> +     return (void __pmem *)memremap_wt(offset, size);
>> +}
>
> And this as well, unless we can get rid of it entirely with ioremap_flags().

I'll move it for now.  ioremap_flags() requires more care than can be
given in the open merge window as far as I can see.

>>       if (rw == READ) {
>> -             memcpy(mem + off, pmem->virt_addr + pmem_off, len);
>> +             memcpy_from_pmem(mem + off, pmem_addr, len);
>>               flush_dcache_page(page);
>>       } else {
>>               flush_dcache_page(page);
>> -             memcpy(pmem->virt_addr + pmem_off, mem + off, len);
>> +             if (arch_has_pmem_api())
>> +                     memcpy_to_pmem(pmem_addr, mem + off, len);
>> +             else
>> +                     default_memcpy_to_pmem(pmem_addr, mem + off, len);
>
> So memcpy_from_pmem hides the different but memcpy_to_pmem doesn't?
> That seems pretty awkward.  Please move the check into the helper.

ok

>> +     if (rw && arch_has_pmem_api())
>> +             wmb_pmem();
>
> And here again make sure wmb_pmem is always available and a no-op if
> not supported.

ok.

>
>> +     if (arch_has_pmem_api())
>> +             pmem->virt_addr = memremap_pmem(pmem->phys_addr, pmem->size);
>> +     else
>> +             pmem->virt_addr = default_memremap_pmem(pmem->phys_addr,
>> +                             pmem->size);
>
> All of this should be hidden in memremap_pmem.

done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
