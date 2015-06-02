Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id A982A6B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 04:38:49 -0400 (EDT)
Received: by oifu123 with SMTP id u123so120493108oif.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 01:38:49 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id q62si1170226oia.65.2015.06.02.01.38.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 01:38:48 -0700 (PDT)
Received: by oihb142 with SMTP id b142so120352960oih.3
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 01:38:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1825055.kiMypDskUT@wuerfel>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150530185923.32590.98598.stgit@dwillia2-desk3.amr.corp.intel.com>
	<1433198166.23540.128.camel@misato.fc.hp.com>
	<1825055.kiMypDskUT@wuerfel>
Date: Tue, 2 Jun 2015 10:38:48 +0200
Message-ID: <CAMuHMdXXXEqaGf1zT0iL=K-LA3qcnx9aCJLZnC6W3ijY4dRipQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] arch/*/asm/io.h: add ioremap_cache() to all architectures
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Toshi Kani <toshi.kani@hp.com>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, ross.zwisler@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, jgross@suse.com, the arch/x86 maintainers <x86@kernel.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, stefan.bader@canonical.com, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>, David Howells <dhowells@redhat.com>

On Tue, Jun 2, 2015 at 10:20 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > --- a/arch/mn10300/include/asm/io.h
>> > +++ b/arch/mn10300/include/asm/io.h
>> > @@ -283,6 +283,7 @@ static inline void __iomem *ioremap_nocache(unsigned long offset, unsigned long
>> >
>> >  #define ioremap_wc ioremap_nocache
>> >  #define ioremap_wt ioremap_nocache
>> > +#define ioremap_cache ioremap_nocache
>>
>> From the comment in ioremap_nocache(), ioremap() may be cacheable in
>> this arch.
>
> Right, and I guess that would be a bug. ;-)
>
> mn10300 decides caching on the address, so presumably all arguments passed into

Aha, like MIPS...

> ioremap here already have that bit set. I've checked all the resource
> definitions for mn10300, and they are all between 0xA0000000 and 0xBFFFFFFF,
> which is non-cacheable.

But ioremap() clears that bit again:

static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
{
        return (void __iomem *)(offset & ~0x20000000);
}

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
