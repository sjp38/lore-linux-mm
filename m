Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id AAE6F6B0038
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 18:01:22 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id z11so8350446lbi.35
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:01:21 -0800 (PST)
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com. [209.85.217.180])
        by mx.google.com with ESMTPS id jw6si34499967lbc.101.2014.11.03.15.01.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 15:01:21 -0800 (PST)
Received: by mail-lb0-f180.google.com with SMTP id u10so1729320lbd.25
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:01:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1411032352161.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
 <1414450545-14028-5-git-send-email-toshi.kani@hp.com> <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net>
 <1415052905.10958.39.camel@misato.fc.hp.com> <alpine.DEB.2.11.1411032352161.5308@nanos>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 3 Nov 2014 15:01:00 -0800
Message-ID: <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>

On Mon, Nov 3, 2014 at 2:53 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Mon, 3 Nov 2014, Toshi Kani wrote:
>> On Mon, 2014-11-03 at 22:10 +0000, Elliott, Robert (Server Storage)
>> wrote:
>>  :
>> > > Subject: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for
>> > > WT
>> > >
>> > > This patch adds pgprot_writethrough() for setting WT to a given
>> > > pgprot_t.
>> > >
>> > > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
>> > > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> > ...
>> > > diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
>> > > index a214f5a..a0264d3 100644
>> > > --- a/arch/x86/mm/pat.c
>> > > +++ b/arch/x86/mm/pat.c
>> > > @@ -896,6 +896,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
>> > >  }
>> > >  EXPORT_SYMBOL_GPL(pgprot_writecombine);
>> > >
>> > > +pgprot_t pgprot_writethrough(pgprot_t prot)
>> > > +{
>> > > + if (pat_enabled)
>> > > +         return __pgprot(pgprot_val(prot) |
>> > > +                         cachemode2protval(_PAGE_CACHE_MODE_WT));
>> > > + else
>> > > +         return pgprot_noncached(prot);
>> > > +}
>> > > +EXPORT_SYMBOL_GPL(pgprot_writethrough);
>> > ...
>> >
>> > Would you be willing to use EXPORT_SYMBOL for the new
>> > pgprot_writethrough function to provide more flexibility
>> > for modules to utilize the new feature?  In x86/mm, 18 of 60
>> > current exports are GPL and 42 are not GPL.
>>
>> I simply used EXPORT_SYMBOL_GPL() since pgprot_writecombine() used
>> it. :-)  This interface is intended to be used along with
>> remap_pfn_range() and ioremap_prot(), which are both exported with
>> EXPORT_SYMBOL().  So, it seems reasonable to export it with
>> EXPORT_SYMBOL() as well.  I will make this change.
>
> NAK.
>
> This is new functionality and we really have no reason to give the GPL
> circumventors access to it.

I have mixed feelings about this.

On the one hand, I agree with your sentiment.

On the other hand, I thought that _GPL was supposed to be more about
whether the thing using it is inherently a derived work of the Linux
kernel.  Since WT is an Intel concept, not a Linux concept, then I
think that this is a hard argument to make.

Not that I mind encouraging HP to GPL everything.  Although my
experiences so far with HP servers have been so uniformly negative
that I really just want to stay far away from anything storage-related
by HP for several years, so I'm very unlikely to own an affected piece
of hardware any time soon.  (Sorry, HP.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
