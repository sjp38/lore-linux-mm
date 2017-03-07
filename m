Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 055066B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:00:19 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w37so1381307wrc.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:00:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i21si847599wmc.94.2017.03.07.07.00.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 07:00:17 -0800 (PST)
Date: Tue, 7 Mar 2017 15:59:54 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 08/32] x86: Use PAGE_KERNEL protection for ioremap
 of memory page
Message-ID: <20170307145954.l2fqy5s5h65wbtyz@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846761276.2349.4899767672892365544.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846761276.2349.4899767672892365544.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:13:32AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> In order for memory pages to be properly mapped when SEV is active, we
> need to use the PAGE_KERNEL protection attribute as the base protection.
> This will insure that memory mapping of, e.g. ACPI tables, receives the
> proper mapping attributes.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---

> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index c400ab5..481c999 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -151,7 +151,15 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
>                 pcm = new_pcm;
>         }
> 
> +       /*
> +        * If the page being mapped is in memory and SEV is active then
> +        * make sure the memory encryption attribute is enabled in the
> +        * resulting mapping.
> +        */
>         prot = PAGE_KERNEL_IO;
> +       if (sev_active() && page_is_mem(pfn))

Hmm, a resource tree walk per ioremap call. This could get expensive for
ioremap-heavy workloads.

__ioremap_caller() gets called here during boot 55 times so not a whole
lot but I wouldn't be surprised if there were some nasty use cases which
ioremap a lot.

...

> diff --git a/kernel/resource.c b/kernel/resource.c
> index 9b5f044..db56ba3 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -518,6 +518,46 @@ int __weak page_is_ram(unsigned long pfn)
>  }
>  EXPORT_SYMBOL_GPL(page_is_ram);
>  
> +/*
> + * This function returns true if the target memory is marked as
> + * IORESOURCE_MEM and IORESOUCE_BUSY and described as other than
> + * IORES_DESC_NONE (e.g. IORES_DESC_ACPI_TABLES).
> + */
> +static int walk_mem_range(unsigned long start_pfn, unsigned long nr_pages)
> +{
> +	struct resource res;
> +	unsigned long pfn, end_pfn;
> +	u64 orig_end;
> +	int ret = -1;
> +
> +	res.start = (u64) start_pfn << PAGE_SHIFT;
> +	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> +	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	orig_end = res.end;
> +	while ((res.start < res.end) &&
> +		(find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
> +		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		end_pfn = (res.end + 1) >> PAGE_SHIFT;
> +		if (end_pfn > pfn)
> +			ret = (res.desc != IORES_DESC_NONE) ? 1 : 0;
> +		if (ret)
> +			break;
> +		res.start = res.end + 1;
> +		res.end = orig_end;
> +	}
> +	return ret;
> +}

So the relevant difference between this one and walk_system_ram_range()
is this:

-			ret = (*func)(pfn, end_pfn - pfn, arg);
+			ret = (res.desc != IORES_DESC_NONE) ? 1 : 0;

so it seems to me you can have your own *func() pointer which does that
IORES_DESC_NONE comparison. And then you can define your own workhorse
__walk_memory_range() which gets called by both walk_mem_range() and
walk_system_ram_range() instead of almost duplicating them.

And looking at walk_system_ram_res(), that one looks similar too except
the pfn computation. But AFAICT the pfn/end_pfn things are computed from
res.start and res.end so it looks to me like all those three functions
are crying for unification...

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
