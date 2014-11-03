Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 155556B0096
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 13:15:32 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id h11so7278476wiw.3
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 10:15:32 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id p17si9289563wie.48.2014.11.03.10.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 10:15:32 -0800 (PST)
Date: Mon, 3 Nov 2014 19:15:17 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/7] x86, mm, pat: Set WT to PA7 slot of PAT MSR
In-Reply-To: <CALCETrWwEsaz8j2ajqqxS4mupO48tv0e_wbrODsmJfZeON2ptA@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1411031913140.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com> <1414450545-14028-2-git-send-email-toshi.kani@hp.com> <alpine.DEB.2.11.1411031812390.5308@nanos> <1415036879.29109.26.camel@misato.fc.hp.com>
 <CALCETrWwEsaz8j2ajqqxS4mupO48tv0e_wbrODsmJfZeON2ptA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Mon, 3 Nov 2014, Andy Lutomirski wrote:
> On Mon, Nov 3, 2014 at 9:47 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Mon, 2014-11-03 at 18:14 +0100, Thomas Gleixner wrote:
> >> On Mon, 27 Oct 2014, Toshi Kani wrote:
> >> > +   } else {
> >> > +           /*
> >> > +            * PAT full support. WT is set to slot 7, which minimizes
> >> > +            * the risk of using the PAT bit as slot 3 is UC and is
> >> > +            * currently unused. Slot 4 should remain as reserved.
> >>
> >> This comment makes no sense. What minimizes which risk and what has
> >> this to do with slot 3 and slot 4?
> >
> > This is for precaution.  Since the patch enables the PAT bit the first
> > time, it was suggested that we keep slot 4 reserved and set it to WB.
> > The PAT bit still has no effect to slot 0/1/2 (WB/WC/UC-) after this
> > patch.  Slot 7 is the safest slot since slot 3 (UC) is unused today.
> >
> > https://lkml.org/lkml/2014/9/4/691
> > https://lkml.org/lkml/2014/9/5/394
> >
> 
> I would clarify the comment, since this really has nothing to do with
> slot 3 being unused.  How about:
> 
> We put WT in slot 7 to improve robustness in the presence of errata
> that might cause the high PAT bit to be ignored.  This way a buggy
> slot 7 access will hit slot 3, and slot 3 is UC, so at worst we lose
> performance without causing a correctness issue.  Pentium 4 erratum
> N46 is an example of such an erratum, although we try not to use PAT
> at all on affected CPUs.

Indeed. That makes a lot more sense.
 
> >> > +            *
> >> > +            *  PTE encoding used in Linux:
> >> > +            *      PAT
> >> > +            *      |PCD
> >> > +            *      ||PWT  PAT
> >> > +            *      |||    slot
> >> > +            *      000    0    WB : _PAGE_CACHE_MODE_WB
> >> > +            *      001    1    WC : _PAGE_CACHE_MODE_WC
> >> > +            *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
> >> > +            *      011    3    UC : _PAGE_CACHE_MODE_UC
> >> > +            *      100    4    <reserved>
> >> > +            *      101    5    <reserved>
> >> > +            *      110    6    <reserved>
> >>
> >> Well, they are still mapped to WB/WC/UC_MINUS ....
> >
> > Right, the reserved slots are also initialized with their safe values.
> > However, the macros _PAGE_CACHE_MODE_XXX only refer to the slots
> > specified above.

Then the table should reflect this, i.e.: reserved, but mapped to XX

And a comment below that explaining WHY we map the reserved slots.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
