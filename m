Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 174A06B0038
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 10:11:08 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id et14so22298574pad.16
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 07:11:06 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id f5si4571380pat.14.2014.09.05.07.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 07:11:04 -0700 (PDT)
Message-ID: <1409925614.28990.184.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 05 Sep 2014 08:00:14 -0600
In-Reply-To: <CALCETrUhbx4hFRAkHfczLkZBYo0E7tRmdFyO7bqPd5e9JEWcMA@mail.gmail.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
	 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
	 <20140904201123.GA9116@khazad-dum.debian.net> <5408C9C4.1010705@zytor.com>
	 <20140904231923.GA15320@khazad-dum.debian.net>
	 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
	 <1409876991.28990.172.camel@misato.fc.hp.com>
	 <CALCETrUhbx4hFRAkHfczLkZBYo0E7tRmdFyO7bqPd5e9JEWcMA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, 2014-09-04 at 17:51 -0700, Andy Lutomirski wrote:
> On Thu, Sep 4, 2014 at 5:29 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Thu, 2014-09-04 at 16:34 -0700, Andy Lutomirski wrote:
> >> On Thu, Sep 4, 2014 at 4:19 PM, Henrique de Moraes Holschuh
> >> <hmh@hmh.eng.br> wrote:
> >> > On Thu, 04 Sep 2014, H. Peter Anvin wrote:
> >> >> On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
> >> >> > I am worried of uncharted territory, here.  I'd actually advocate for not
> >> >> > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
> >> >> > is using them as well.  Is this a real concern, or am I being overly
> >> >> > cautious?
> >> >>
> >> >> It is extremely unlikely that we'd have PAT issues in 32-bit mode and
> >> >> not in 64-bit mode on the same CPU.
> >> >
> >> > Sure, but is it really a good idea to enable this on the *old* non-64-bit
> >> > capable processors (note: I don't mean x86-64 processors operating in 32-bit
> >> > mode) ?
> >> >
> >> >> As far as I know, the current blacklist rule is very conservative due to
> >> >> lack of testing more than anything else.
> >> >
> >> > I was told that much in 2009 when I asked why cpuid 0x6d8 was blacklisted
> >> > from using PAT :-)
> >>
> >> At the very least, anyone who plugs an NV-DIMM into a 32-bit machine
> >> is nuts, and not just because I'd be somewhat amazed if it even
> >> physically fits into the slot. :)
> >
> > According to the spec, the upper four entries bug was fixed in Pentium 4
> > model 0x1.  So, the remaining Intel 32-bit processors that may enable
> > the upper four entries are Pentium 4 model 0x1-4.  Should we disable it
> > for all Pentium 4 models?
> 
> Assuming that this is Pentium 4 erratum N46, then there may be another
> option: use slot 7 instead of slot 4 for WT.  Then, even if somehow
> the blacklist screws up, the worst that happens is that a WT page gets
> interpreted as UC.  I suppose this could cause aliasing issues, but
> can't cause problems for people who don't use the high entries in the
> first place.

That's a fine idea, but as Ingo also suggested, I am going to disable
this feature on all Pentium 4 models.  That should give us a safety
margin.  Using slot 4 has a benefit that it keeps the PAT setup
consistent with Xen.      

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
