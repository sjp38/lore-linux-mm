Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B03776B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 18:32:41 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id z12so12157589wgg.23
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:32:41 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id pg2si325077wjb.162.2014.11.03.15.32.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 15:32:40 -0800 (PST)
Date: Tue, 4 Nov 2014 00:32:32 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
In-Reply-To: <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1411040007210.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com> <1414450545-14028-5-git-send-email-toshi.kani@hp.com> <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net> <1415052905.10958.39.camel@misato.fc.hp.com>
 <alpine.DEB.2.11.1411032352161.5308@nanos> <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Toshi Kani <toshi.kani@hp.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>Andrew Morton <akpm@linux-foundation.org>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Bdale Garbee <bdale@gag.com>

On Mon, 3 Nov 2014, Andy Lutomirski wrote:
> On Mon, Nov 3, 2014 at 2:53 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Mon, 3 Nov 2014, Toshi Kani wrote:
> >> On Mon, 2014-11-03 at 22:10 +0000, Elliott, Robert (Server Storage)
> >> wrote:
> >> > > +EXPORT_SYMBOL_GPL(pgprot_writethrough);
> >> > ...
> >> >
> >> > Would you be willing to use EXPORT_SYMBOL for the new
> >> > pgprot_writethrough function to provide more flexibility
> >> > for modules to utilize the new feature?  In x86/mm, 18 of 60
> >> > current exports are GPL and 42 are not GPL.
> >>
> >> I simply used EXPORT_SYMBOL_GPL() since pgprot_writecombine() used
> >> it. :-)  This interface is intended to be used along with
> >> remap_pfn_range() and ioremap_prot(), which are both exported with
> >> EXPORT_SYMBOL().  So, it seems reasonable to export it with
> >> EXPORT_SYMBOL() as well.  I will make this change.
> >
> > NAK.
> >
> > This is new functionality and we really have no reason to give the GPL
> > circumventors access to it.
> 
> I have mixed feelings about this.
> 
> On the one hand, I agree with your sentiment.
> 
> On the other hand, I thought that _GPL was supposed to be more about
> whether the thing using it is inherently a derived work of the Linux
> kernel.  Since WT is an Intel concept, not a Linux concept, then I
> think that this is a hard argument to make.

If your argument stands then almost nothing in Linux which is related
to hardware can stand on its own as it is always dependent on the
underlying hardware. But that's not true. The software support for
that particular hardware feature is always Linux specific.

The point about derived work, which Linus made, is that the GPL might
not necessarily apply to something which was developed completely
independent of Linux in the first place and then adopted via a wrapper
layer. This applies pretty much to the odd binary graphics drivers
which got retrofitted with a Linux interface by wrapping the existing
binary blob.

We have always accomodated with this by not changing the replacement
interfaces for something with was EXPORT_SYMBOL to
EXPORT_SYMBOL_GPL. Though we have forced binary blobs away from
abusing stuff by removing such exports; google for the removal of the
init_mm export.

But that does not mean that we are obliged to expose new Linux
infrastucture which supports existing Intel hardware properties to
drivers which prefer to be closed for whatever reason.

Quite the contrary. We want to expose these new features to the fair
players. The HP driver can live with the less performant modes and if
it wants to use WT, that's none of our problems at all.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
