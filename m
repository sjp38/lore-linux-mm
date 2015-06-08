Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 33B606B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 14:25:32 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so110050492wgb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 11:25:31 -0700 (PDT)
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id v5si6828602wjr.212.2015.06.08.11.25.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 11:25:30 -0700 (PDT)
Received: by wgme6 with SMTP id e6so109920526wgm.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 11:25:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHp75Vc7CJSkFvnyHwONd0w50oxvf+rtb6_a4kqhtxe8dmzDWQ@mail.gmail.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150603213440.13749.1981.stgit@dwillia2-desk3.amr.corp.intel.com>
	<CAHp75Vc7CJSkFvnyHwONd0w50oxvf+rtb6_a4kqhtxe8dmzDWQ@mail.gmail.com>
Date: Mon, 8 Jun 2015 11:25:28 -0700
Message-ID: <CAPcyv4gVuPUFJatsqia3ie-+iHDhEp5DTssDdz7bdWPO0on4Gw@mail.gmail.com>
Subject: Re: [PATCH v3 5/6] arch: introduce memremap_cache() and memremap_wt()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, mpe@ellerman.id.au, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 8, 2015 at 9:27 AM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Thu, Jun 4, 2015 at 12:34 AM, Dan Williams <dan.j.williams@intel.com> wrote:
>> Existing users of ioremap_cache() are mapping memory that is known in
>> advance to not have i/o side effects.  These users are forced to cast
>> away the __iomem annotation, or otherwise neglect to fix the sparse
>> errors thrown when dereferencing pointers to this memory.  Provide
>> memremap_*() as a non __iomem annotated ioremap_*().
>>
>> The ARCH_HAS_MEMREMAP kconfig symbol is introduced for archs to assert
>> that it is safe to recast / reuse the return value from ioremap as a
>> normal pointer to memory.  In other words, archs that mandate specific
>> accessors for __iomem are not memremap() capable and drivers that care,
>> like pmem, can add a dependency to disable themselves on these archs.
>
> One minor comment. Otherwise looks good for me.
>
> []
>
>> --- a/kernel/resource.c
>> +++ b/kernel/resource.c
>
>> @@ -528,6 +528,45 @@ int region_is_ram(resource_size_t start, unsigned long size)
>>         return ret;
>>  }
>>
>> +#ifdef CONFIG_ARCH_HAS_MEMREMAP
>> +/*
>> + * memremap() is "ioremap" for cases where it is known that the resource
>> + * being mapped does not have i/o side effects and the __iomem
>> + * annotation is not applicable.
>> + */
>> +static bool memremap_valid(resource_size_t offset, size_t size)
>> +{
>> +       if (region_is_ram(offset, size) != 0) {
>> +               WARN_ONCE(1, "memremap attempted on ram %pa size: %zd\n",
>
> %zu

Sure, thanks for taking a look Andy!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
