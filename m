Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 50BBE6B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 21:17:53 -0400 (EDT)
Received: by obew15 with SMTP id w15so82059091obe.1
        for <linux-mm@kvack.org>; Sat, 30 May 2015 18:17:52 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id h184si6187307oib.70.2015.05.30.18.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 18:17:52 -0700 (PDT)
Message-ID: <1433033892.23540.100.camel@misato.fc.hp.com>
Subject: Re: [PATCH v11 6/12] x86, mm, asm-gen: Add ioremap_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Sat, 30 May 2015 18:58:12 -0600
In-Reply-To: <CAMuHMdWLMUr9ggkhbOiDSsc_eq04En3L5oX5pL=9gHuR6JDb+w@mail.gmail.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
	 <1432940350-1802-7-git-send-email-toshi.kani@hp.com>
	 <CAMuHMdWLMUr9ggkhbOiDSsc_eq04En3L5oX5pL=9gHuR6JDb+w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, Andy Lutomirski <luto@amacapital.net>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, yigal@plexistor.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Elliott@hp.com, "Luis R. Rodriguez" <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>

On Sat, 2015-05-30 at 11:18 +0200, Geert Uytterhoeven wrote:
> On Sat, May 30, 2015 at 12:59 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > --- a/include/asm-generic/io.h
> > +++ b/include/asm-generic/io.h
> > @@ -785,8 +785,17 @@ static inline void __iomem *ioremap_wc(phys_addr_t offset, size_t size)
> >  }
> >  #endif
> >
> > +#ifndef ioremap_wt
> > +#define ioremap_wt ioremap_wt
> > +static inline void __iomem *ioremap_wt(phys_addr_t offset, size_t size)
> > +{
> > +       return ioremap_nocache(offset, size);
> > +}
> > +#endif
> > +
> >  #ifndef iounmap
> >  #define iounmap iounmap
> > +
> >  static inline void iounmap(void __iomem *addr)
> >  {
> >  }
> > diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
> > index 1b41011..d8f8622 100644
> > --- a/include/asm-generic/iomap.h
> > +++ b/include/asm-generic/iomap.h
> > @@ -66,6 +66,10 @@ extern void ioport_unmap(void __iomem *);
> >  #define ioremap_wc ioremap_nocache
> >  #endif
> >
> > +#ifndef ARCH_HAS_IOREMAP_WT
> > +#define ioremap_wt ioremap_nocache
> > +#endif
> 
> Defining ioremap_wt in two different places in asm-generic looks fishy to me.
> 
> If <asm/io.h> already provides it (either through asm-generic/io.h or
> arch/<arch>/include/asm/io.h), why does asm-generic/iomap.h need to define
> its own version?
> 
> I see this pattern already exists for ioremap_wc...

Yes, this patchset follows the model of ioremap_wc.  This duplication
was introduced by 9216efafc52 "asm-generic/io.h: Reconcile I/O accessor
overrides", while the original ioremap_wc support changed
asm-generic/iomap.h (1526a756fba).  As described in patch 07, some
architectures define ioremap_xxx() locally as well.

It is too risky to do everything in one short.  I will look into the
duplication issue as a separate item after this patchset is settled.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
