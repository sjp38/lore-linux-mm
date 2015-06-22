Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE18F6B0071
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 12:10:05 -0400 (EDT)
Received: by lagi2 with SMTP id i2so23444328lag.2
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 09:10:05 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id qg11si20548474wic.73.2015.06.22.09.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 09:10:04 -0700 (PDT)
Date: Mon, 22 Jun 2015 18:10:02 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
Message-ID: <20150622161002.GB8240@lst.de>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

On Mon, Jun 22, 2015 at 04:24:27AM -0400, Dan Williams wrote:
> Some archs define the first parameter to ioremap() as unsigned long,
> while the balance define it as resource_size_t.  Unify on
> resource_size_t to enable passing ioremap function pointers.  Also, some
> archs use function-like macros for defining ioremap aliases, but
> asm-generic/io.h expects object-like macros, unify on the latter.
> 
> Move all handling of ioremap aliasing (i.e. ioremap_wt => ioremap) to
> include/linux/io.h.  Add a check to include/linux/io.h to warn at
> compile time if an arch violates expectations.
> 
> Kill ARCH_HAS_IOREMAP_WC and ARCH_HAS_IOREMAP_WT in favor of just
> testing for ioremap_wc, and ioremap_wt being defined.  This arrangement
> allows drivers to know when ioremap_<foo> are being re-directed to plain
> ioremap.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Hmm, this is quite a bit of churn, and doesn't make the interface lot
more obvious.

I guess it's enough to get the pmem related bits going, but I'd really
prefer defining the ioremap* prototype in linux/io.h and requiring
and out of line implementation in the architectures, it's not like
it's a fast path.  And to avoid the ifdef mess make it something like:

void __iomem *ioremap_flags(resource_size_t offset, unsigned long size,
			unsigned long prot_val, unsigned flags);

static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
{
	return ioremap_flags(offset, size, 0, 0);
}

static inline void __iomem *ioremap_prot(resource_size_t offset,
		unsigned long size, unsigned long prot_val)
{
	return ioremap_flags(offset, size, prot_val, 0);
}

static inline void __iomem *ioremap_nocache(resource_size_t offset,
		unsigned long size)
{
	return ioremap_flags(offset, size, 0, IOREMAP_NOCACHE);
}

static inline void __iomem *ioremap_cache(resource_size_t offset,
		unsigned long size)
{
	return ioremap_flags(offset, size, 0, IOREMAP_CACHE);
}

static inline void __iomem *ioremap_uc(resource_size_t offset,
		unsigned long size)
{
	return ioremap_flags(offset, size, 0, IOREMAP_UC);
}

static inline void __iomem *ioremap_wc(resource_size_t offset,
		unsigned long size)
{
	return ioremap_flags(offset, size, 0, IOREMAP_WC);
}

static inline void __iomem *ioremap_wt(resource_size_t offset,
		unsigned long size)
{
	return ioremap_flags(offset, size, 0, IOREMAP_WT);
}

With all wrappers but ioremap() itself deprecated in the long run.

Besides following the one API one prototype guideline this gives
us one proper entry point for all the variants.  Additionally
it can reject non-supported caching modes at run time, e.g. because
different hardware may or may not support it.  Additionally it
avoids the need for all these HAVE_IOREMAP_FOO defines, which need
constant updating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
