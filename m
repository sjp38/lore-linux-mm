Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4206B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 17:16:31 -0400 (EDT)
Received: by wizo1 with SMTP id o1so61797907wiz.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 14:16:31 -0700 (PDT)
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id g4si16747938wjs.106.2015.05.30.14.16.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 14:16:29 -0700 (PDT)
Received: by wgme6 with SMTP id e6so86782943wgm.2
        for <linux-mm@kvack.org>; Sat, 30 May 2015 14:16:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201505302252.19647.arnd@arndb.de>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150530185929.32590.22873.stgit@dwillia2-desk3.amr.corp.intel.com>
	<201505302252.19647.arnd@arndb.de>
Date: Sat, 30 May 2015 14:16:28 -0700
Message-ID: <CAPcyv4g30QqO2+vmhfFi6Mw3pku=BkEmvUbzxMme4nm8SkHyrQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] devm: fix ioremap_cache() usage
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Sat, May 30, 2015 at 1:52 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Saturday 30 May 2015, Dan Williams wrote:
>> @@ -154,7 +148,7 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res)
>>         }
>>
>>         if (res->flags & IORESOURCE_CACHEABLE)
>> -               dest_ptr = devm_ioremap(dev, res->start, size);
>> +               dest_ptr = devm_ioremap_cache(dev, res->start, size);
>>         else
>>                 dest_ptr = devm_ioremap_nocache(dev, res->start, size);
>
> I think the existing uses of IORESOURCE_CACHEABLE are mostly bugs, so changing
> the behavior here may cause more problems than it solves.
>

Ok, but that effectively makes devm_ioremap_resource() unusable for
the cached case.  How about introducing devm_ioremap_cache_resource(),
and cleaning up devm_ioremap_resource() to stop pretending that it is
honoring the memory type of the resource?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
