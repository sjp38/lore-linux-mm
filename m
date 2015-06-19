Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id DDDC46B009C
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 17:29:24 -0400 (EDT)
Received: by obbkn5 with SMTP id kn5so53797553obb.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:29:24 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id pk8si546751oeb.91.2015.06.19.14.29.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jun 2015 14:29:24 -0700 (PDT)
Message-ID: <1434749332.11808.113.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 5/6] arch: introduce memremap_cache() and
 memremap_wt()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 19 Jun 2015 15:28:52 -0600
In-Reply-To: <20150611211941.10271.10513.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20150611211941.10271.10513.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, konrad.wilk@oracle.com, benh@kernel.crashing.org, mcgrof@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, Andy Shevchenko <andy.shevchenko@gmail.com>, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

On Thu, 2015-06-11 at 17:19 -0400, Dan Williams wrote:
> Existing users of ioremap_cache() are mapping memory that is known in
> advance to not have i/o side effects.  These users are forced to cast
> away the __iomem annotation, or otherwise neglect to fix the sparse
> errors thrown when dereferencing pointers to this memory.  Provide
> memremap_*() as a non __iomem annotated ioremap_*().
> 
> The ARCH_HAS_MEMREMAP kconfig symbol is introduced for archs to assert
> that it is safe to recast / reuse the return value from ioremap as a
> normal pointer to memory.  In other words, archs that mandate specific
> accessors for __iomem are not memremap() capable and drivers that care,
> like pmem, can add a dependency to disable themselves on these archs.
  : 
> +#ifdef CONFIG_ARCH_HAS_MEMREMAP
> +/*
> + * memremap() is "ioremap" for cases where it is known that the resource
> + * being mapped does not have i/o side effects and the __iomem
> + * annotation is not applicable.
> + */
> +static bool memremap_valid(resource_size_t offset, size_t size)
> +{
> +	if (region_is_ram(offset, size) != 0) {

I noticed that region_is_ram() is buggy and always returns -1.  I will
submit the fix shortly.

Thanks,
-Toshi


> +		WARN_ONCE(1, "memremap attempted on ram %pa size: %zu\n",
> +				&offset, size);
> +		return false;
> +	}
> +	return true;
> +}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
