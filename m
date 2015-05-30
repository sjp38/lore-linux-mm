Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3507F6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 17:39:51 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so8990342wib.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 14:39:50 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id p2si10775726wij.21.2015.05.30.14.39.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 14:39:49 -0700 (PDT)
Received: by wizo1 with SMTP id o1so62112088wiz.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 14:39:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201505302300.10950.arnd@arndb.de>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150530185935.32590.95416.stgit@dwillia2-desk3.amr.corp.intel.com>
	<201505302300.10950.arnd@arndb.de>
Date: Sat, 30 May 2015 14:39:48 -0700
Message-ID: <CAPcyv4hqQaabcOsOZA9emT5f+UF9GgD-PiYupng4HYwymcvYmQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] arch: introduce memremap()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Sat, May 30, 2015 at 2:00 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Saturday 30 May 2015, Dan Williams wrote:
>>
>> +/*
>> + * memremap() is "ioremap" for cases where it is known that the resource
>> + * being mapped does not have i/o side effects and the __iomem
>> + * annotation is not applicable.
>> + */
>> +
>> +static inline void *memremap(resource_size_t offset, size_t size)
>> +{
>> +       return (void __force *) ioremap(offset, size);
>> +}
>> +
>> +static inline void *memremap_nocache(resource_size_t offset, size_t size)
>> +{
>> +       return (void __force *) ioremap_nocache(offset, size);
>> +}
>> +
>> +static inline void *memremap_cache(resource_size_t offset, size_t size)
>> +{
>> +       return (void __force *) ioremap_cache(offset, size);
>> +}
>> +
>
> There are architectures on which the result of ioremap is not necessarily
> a pointer, but instead indicates that the access is to be done through
> some other indirect access, or require special instructions. I think implementing
> the memremap() interfaces is generally helpful, but don't rely on the
> ioremap implementation.

Is it enough to detect the archs where ioremap() does return an
otherwise usable pointer and set ARCH_HAS_MEMREMAP, in the first take
of this introduction?  Regardless, it seems that drivers should have
Kconfig dependency checks for archs where ioremap can not be used in
this manner.

> Adding both cached an uncached versions is also dangerous, because you
> typically get either undefined behavior or a system checkstop when a
> single page is mapped both cached and uncached at the same time. This
> means that doing memremap() or memremap_nocache() on something that
> may be part of the linear kernel mapping is a bug, and we should probably
> check for that here.

Part of the reason for relying on ioremap() was to borrow its internal
checks to fail attempts that try to remap ranges that are already in
the kernel linear map.  Hmm, that's a guarantee x86 ioremap gives, but
maybe that's not universal?

> We can probably avoid having both memremap() and memremap_nocache(),
> as all architectures define ioremap() and ioremap_nocache() to be the
> same thing.
>

Ok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
