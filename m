Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id F34906B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 10:29:37 -0400 (EDT)
Received: by wizo1 with SMTP id o1so107587624wiz.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 07:29:37 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id b14si19381348wjz.87.2015.06.01.07.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 07:29:36 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 2/4] devm: fix ioremap_cache() usage
Date: Mon, 01 Jun 2015 16:26:57 +0200
Message-ID: <1620292.L8s1FmNDhT@wuerfel>
In-Reply-To: <CAPcyv4g30QqO2+vmhfFi6Mw3pku=BkEmvUbzxMme4nm8SkHyrQ@mail.gmail.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com> <201505302252.19647.arnd@arndb.de> <CAPcyv4g30QqO2+vmhfFi6Mw3pku=BkEmvUbzxMme4nm8SkHyrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Saturday 30 May 2015 14:16:28 Dan Williams wrote:
> On Sat, May 30, 2015 at 1:52 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Saturday 30 May 2015, Dan Williams wrote:
> >> @@ -154,7 +148,7 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res)
> >>         }
> >>
> >>         if (res->flags & IORESOURCE_CACHEABLE)
> >> -               dest_ptr = devm_ioremap(dev, res->start, size);
> >> +               dest_ptr = devm_ioremap_cache(dev, res->start, size);
> >>         else
> >>                 dest_ptr = devm_ioremap_nocache(dev, res->start, size);
> >
> > I think the existing uses of IORESOURCE_CACHEABLE are mostly bugs, so changing
> > the behavior here may cause more problems than it solves.
> >
> 
> Ok, but that effectively makes devm_ioremap_resource() unusable for
> the cached case.  How about introducing devm_ioremap_cache_resource(),
> and cleaning up devm_ioremap_resource() to stop pretending that it is
> honoring the memory type of the resource?

I was thinking the opposite approach and basically removing all uses
of IORESOURCE_CACHEABLE from the kernel. There are only a handful of
them.and we can probably replace them all with hardcoded ioremap_cached()
calls in the cases they are actually useful

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
