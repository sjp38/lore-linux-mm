Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5486B006E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 12:17:57 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so145876969wgb.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:17:57 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d13si35832694wjs.32.2015.06.22.09.17.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 09:17:55 -0700 (PDT)
Date: Mon, 22 Jun 2015 18:17:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 6/6] arch, x86: pmem api for ensuring durability of
	persistent memory updates
Message-ID: <20150622161754.GC8240@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, Richard Weinberger <richard@nod.at>

> +#ifdef ARCH_HAS_NOCACHE_UACCESS

Seems like this is always define for x86 anyway?

> +/**
> + * arch_memcpy_to_pmem - copy data to persistent memory
> + * @dst: destination buffer for the copy
> + * @src: source buffer for the copy
> + * @n: length of the copy in bytes
> + *
> + * Copy data to persistent memory media via non-temporal stores so that
> + * a subsequent arch_wmb_pmem() can flush cpu and memory controller
> + * write buffers to guarantee durability.
> + */
static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)

Too long line.  Also why not simply arch_copy_{from,to}_pmem?

> +#else /* ARCH_HAS_NOCACHE_UACCESS i.e. ARCH=um */

Oh, UM.  I'd rather see UM fixed to provide these.

Richard, any chance you could look into it?

> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index 97ae3b748d9e..0d3e43f679aa 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -249,6 +249,12 @@ static inline void flush_write_buffers(void)
>  #endif
>  }
>  
> +static inline void __pmem *arch_memremap_pmem(resource_size_t offset,
> +	unsigned long size)
> +{
> +	return (void __force __pmem *) ioremap_cache(offset, size);
> +}

Now with my ioremap_flags proposal we'd just add an IOREMAP_PMEM
flag, which architectures could implement (usually as no-op), and move
the cast into memremap_pmem.

> + * These defaults seek to offer decent performance and minimize the
> + * window between i/o completion and writes being durable on media.
> + * However, it is undefined / architecture specific whether
> + * default_memremap_pmem + default_memcpy_to_pmem is sufficient for
> + * making data durable relative to i/o completion.
> + */
> +static void default_memcpy_to_pmem(void __pmem *dst, const void *src, size_t size)
> +{
> +	memcpy((void __force *) dst, src, size);
> +}

This should really be in asm-generic (or at least your linux/pmem.h for now).

> +static void __pmem *default_memremap_pmem(resource_size_t offset, unsigned long size)
> +{
> +	return (void __pmem *)memremap_wt(offset, size);
> +}

And this as well, unless we can get rid of it entirely with ioremap_flags().

>  	if (rw == READ) {
> -		memcpy(mem + off, pmem->virt_addr + pmem_off, len);
> +		memcpy_from_pmem(mem + off, pmem_addr, len);
>  		flush_dcache_page(page);
>  	} else {
>  		flush_dcache_page(page);
> -		memcpy(pmem->virt_addr + pmem_off, mem + off, len);
> +		if (arch_has_pmem_api())
> +			memcpy_to_pmem(pmem_addr, mem + off, len);
> +		else
> +			default_memcpy_to_pmem(pmem_addr, mem + off, len);

So memcpy_from_pmem hides the different but memcpy_to_pmem doesn't?
That seems pretty awkward.  Please move the check into the helper.

> +	if (rw && arch_has_pmem_api())
> +		wmb_pmem();

And here again make sure wmb_pmem is always available and a no-op if
not supported.

> +	if (arch_has_pmem_api())
> +		pmem->virt_addr = memremap_pmem(pmem->phys_addr, pmem->size);
> +	else
> +		pmem->virt_addr = default_memremap_pmem(pmem->phys_addr,
> +				pmem->size);

All of this should be hidden in memremap_pmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
