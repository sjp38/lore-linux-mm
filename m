Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id D6C376B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 17:43:36 -0400 (EDT)
Received: by obcid8 with SMTP id id8so5092468obc.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 14:43:36 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id ly15si4938503oeb.24.2015.08.28.14.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 14:43:36 -0700 (PDT)
Message-ID: <1440798084.14237.106.camel@hp.com>
Subject: Re: [PATCH v2 5/9] x86, pmem: push fallback handling to arch code
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 28 Aug 2015 15:41:24 -0600
In-Reply-To: <1440624859.31365.17.camel@intel.com>
References: 
	<20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20150826012751.8851.78564.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20150826124124.GA7613@lst.de> <1440624859.31365.17.camel@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@lst.de" <hch@lst.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "hpa@zytor.com" <hpa@zytor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "mingo@redhat.com" <mingo@redhat.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, 2015-08-26 at 21:34 +0000, Williams, Dan J wrote:
> On Wed, 2015-08-26 at 14:41 +0200, Christoph Hellwig wrote:
> > I like the intent behind this, but not the implementation.
> > 
> > I think the right approach is to keep the defaults in linux/pmem.h
> > and simply not set CONFIG_ARCH_HAS_PMEM_API for x86-32.
> 
> Yes, that makes things much cleaner.  Revised patch and changelog below:
> 
> 8<----
> Subject: x86, pmem: clarify that ARCH_HAS_PMEM_API implies PMEM mapped WB
> 
> From: Dan Williams <dan.j.williams@intel.com>
> 
> Given that a write-back (WB) mapping plus non-temporal stores is
> expected to be the most efficient way to access PMEM, update the
> definition of ARCH_HAS_PMEM_API to imply arch support for
> WB-mapped-PMEM.  This is needed as a pre-requisite for adding PMEM to
> the direct map and mapping it with struct page.
> 
> The above clarification for X86_64 means that memcpy_to_pmem() is
> permitted to use the non-temporal arch_memcpy_to_pmem() rather than
> needlessly fall back to default_memcpy_to_pmem() when the pcommit
> instruction is not available.  When arch_memcpy_to_pmem() is not
> guaranteed to flush writes out of cache, i.e. on older X86_32
> implementations where non-temporal stores may just dirty cache,
> ARCH_HAS_PMEM_API is simply disabled.
> 
> The default fall back for persistent memory handling remains.  Namely,
> map it with the WT (write-through) cache-type and hope for the best.
> 
> arch_has_pmem_api() is updated to only indicate whether the arch
> provides the proper helpers to meet the minimum "writes are visible
> outside the cache hierarchy after memcpy_to_pmem() + wmb_pmem()".  Code
> that cares whether wmb_pmem() actually flushes writes to pmem must now
> call arch_has_wmb_pmem() directly.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Toshi Kani <toshi.kani@hp.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Christoph Hellwig <hch@lst.de>
> [hch: set ARCH_HAS_PMEM_API=n on X86_32]
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Thanks for making this change!  It looks good.

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

I have one minor comment below:

> ---
>  arch/x86/Kconfig            |    2 +-
>  arch/x86/include/asm/io.h   |    2 --
>  arch/x86/include/asm/pmem.h |    8 ++------
>  drivers/acpi/nfit.c         |    2 +-
>  drivers/nvdimm/pmem.c       |    2 +-
>  include/linux/pmem.h        |   28 +++++++++++++++++-----------
>  6 files changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 76c61154ed50..5912859df533 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -27,7 +27,7 @@ config X86
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FAST_MULTIPLIER
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_PMEM_API
> +	select ARCH_HAS_PMEM_API		if X86_64
>  	select ARCH_HAS_SG_CHAIN
>  	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>  	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index d241fbd5c87b..83ec9b1d77cc 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -248,8 +248,6 @@ static inline void flush_write_buffers(void)
>  #endif
>  }
>  
> -#define ARCH_MEMREMAP_PMEM MEMREMAP_WB

Should it be better to do:

#else	/* !CONFIG_ARCH_HAS_PMEM_API */
#define ARCH_MEMREMAP_PMEM MEMREMAP_WT

so that you can remove all '#ifdef ARCH_MEMREMAP_PMEM' stuff?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
