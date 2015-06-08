Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 34B9B6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 12:27:14 -0400 (EDT)
Received: by yhpn97 with SMTP id n97so42216103yhp.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 09:27:14 -0700 (PDT)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com. [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id r4si1414883yhg.164.2015.06.08.09.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 09:27:13 -0700 (PDT)
Received: by yhan67 with SMTP id n67so42254849yha.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 09:27:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150603213440.13749.1981.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150603213440.13749.1981.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Mon, 8 Jun 2015 19:27:12 +0300
Message-ID: <CAHp75Vc7CJSkFvnyHwONd0w50oxvf+rtb6_a4kqhtxe8dmzDWQ@mail.gmail.com>
Subject: Re: [PATCH v3 5/6] arch: introduce memremap_cache() and memremap_wt()
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, bp@alien8.de, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, jgross@suse.com, "x86@kernel.org" <x86@kernel.org>, toshi.kani@hp.com, linux-nvdimm@lists.01.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, mcgrof@suse.com, konrad.wilk@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, hmh@hmh.eng.br, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, paulus@samba.org, hch@lst.de

On Thu, Jun 4, 2015 at 12:34 AM, Dan Williams <dan.j.williams@intel.com> wrote:
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

One minor comment. Otherwise looks good for me.

[]

> --- a/kernel/resource.c
> +++ b/kernel/resource.c

> @@ -528,6 +528,45 @@ int region_is_ram(resource_size_t start, unsigned long size)
>         return ret;
>  }
>
> +#ifdef CONFIG_ARCH_HAS_MEMREMAP
> +/*
> + * memremap() is "ioremap" for cases where it is known that the resource
> + * being mapped does not have i/o side effects and the __iomem
> + * annotation is not applicable.
> + */
> +static bool memremap_valid(resource_size_t offset, size_t size)
> +{
> +       if (region_is_ram(offset, size) != 0) {
> +               WARN_ONCE(1, "memremap attempted on ram %pa size: %zd\n",

%zu

> +                               &offset, size);
> +               return false;
> +       }
> +       return true;
> +}


-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
