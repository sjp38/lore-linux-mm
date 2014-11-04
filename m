Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 239B86B0085
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 20:04:36 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so9892185obc.7
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 17:04:35 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id g5si19830107oed.11.2014.11.03.17.04.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 17:04:34 -0800 (PST)
Message-ID: <1415062233.10958.42.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 03 Nov 2014 17:50:33 -0700
In-Reply-To: <alpine.DEB.2.11.1411032352161.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
	  <1414450545-14028-5-git-send-email-toshi.kani@hp.com>
	  <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net>
	 <1415052905.10958.39.camel@misato.fc.hp.com>
	 <alpine.DEB.2.11.1411032352161.5308@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Elliott, Robert (Server Storage)" <Elliott@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "luto@amacapital.net" <luto@amacapital.net>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>

On Mon, 2014-11-03 at 23:53 +0100, Thomas Gleixner wrote:
> On Mon, 3 Nov 2014, Toshi Kani wrote:
> > On Mon, 2014-11-03 at 22:10 +0000, Elliott, Robert (Server Storage)
> > wrote:
> >  :
> > > > Subject: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for
> > > > WT
> > > > 
> > > > This patch adds pgprot_writethrough() for setting WT to a given
> > > > pgprot_t.
> > > > 
> > > > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > > > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > ...
> > > > diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> > > > index a214f5a..a0264d3 100644
> > > > --- a/arch/x86/mm/pat.c
> > > > +++ b/arch/x86/mm/pat.c
> > > > @@ -896,6 +896,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
> > > >  }
> > > >  EXPORT_SYMBOL_GPL(pgprot_writecombine);
> > > > 
> > > > +pgprot_t pgprot_writethrough(pgprot_t prot)
> > > > +{
> > > > +	if (pat_enabled)
> > > > +		return __pgprot(pgprot_val(prot) |
> > > > +				cachemode2protval(_PAGE_CACHE_MODE_WT));
> > > > +	else
> > > > +		return pgprot_noncached(prot);
> > > > +}
> > > > +EXPORT_SYMBOL_GPL(pgprot_writethrough);
> > > ...
> > > 
> > > Would you be willing to use EXPORT_SYMBOL for the new 
> > > pgprot_writethrough function to provide more flexibility
> > > for modules to utilize the new feature?  In x86/mm, 18 of 60
> > > current exports are GPL and 42 are not GPL.
> > 
> > I simply used EXPORT_SYMBOL_GPL() since pgprot_writecombine() used
> > it. :-)  This interface is intended to be used along with
> > remap_pfn_range() and ioremap_prot(), which are both exported with
> > EXPORT_SYMBOL().  So, it seems reasonable to export it with
> > EXPORT_SYMBOL() as well.  I will make this change.
> 
> NAK.
> 
> This is new functionality and we really have no reason to give the GPL
> circumventors access to it.

Thanks for the background info about EXPORT_SYMBOL.  I will keep it no
change.

-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
