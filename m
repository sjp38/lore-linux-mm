Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 15BDA6B0072
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 13:35:44 -0400 (EDT)
Received: by yhpn97 with SMTP id n97so38926005yhp.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:35:43 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id q66si1807186ywe.191.2015.06.17.10.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 10:35:38 -0700 (PDT)
Message-ID: <1434562513.11808.100.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 1/6] arch: unify ioremap prototypes and macro aliases
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 17 Jun 2015 11:35:13 -0600
In-Reply-To: <20150611211918.10271.74243.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20150611211918.10271.74243.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, konrad.wilk@oracle.com, benh@kernel.crashing.org, mcgrof@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, kbuild test robot <fengguang.wu@intel.com>, hch@lst.de

On Thu, 2015-06-11 at 17:19 -0400, Dan Williams wrote:
> Some archs define the first parameter to ioremap() as unsigned long,
> while the balance define it as resource_size_t.  Unify on
> resource_size_t to enable passing ioremap function pointers.  Also, some
> archs use function-like macros for defining ioremap aliases, but
> asm-generic/iomap.h expects object-like macros, unify on the latter.
> 
 :
> diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
> index 80a7e34be009..8588ef767a44 100644
> --- a/arch/ia64/include/asm/io.h
> +++ b/arch/ia64/include/asm/io.h
> @@ -424,8 +424,8 @@ __writeq (unsigned long val, volatile void __iomem *addr)
>  
>  # ifdef __KERNEL__
>  
> -extern void __iomem * ioremap(unsigned long offset, unsigned long size);
> -extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
> +extern void __iomem * ioremap(resource_size_t offset, unsigned long size);
> +extern void __iomem * ioremap_nocache (resource_size_t offset, unsigned long size);
>  extern void iounmap (volatile void __iomem *addr);
>  extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
>  #define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)

This ia64 io.h also defines ioremap_cache().  Should this be also
changed to resource_size_t?

static inline void __iomem * ioremap_cache (unsigned long phys_addr,
unsigned long size)
{
	return ioremap(phys_addr, size);
}

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
