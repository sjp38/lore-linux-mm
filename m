Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC4E56B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 20:52:18 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id q1so4272395lam.26
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 17:52:17 -0700 (PDT)
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
        by mx.google.com with ESMTPS id ei11si810397lad.2.2014.09.04.17.52.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 17:52:16 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id pn19so12933096lab.18
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 17:52:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409876991.28990.172.camel@misato.fc.hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com> <20140904201123.GA9116@khazad-dum.debian.net>
 <5408C9C4.1010705@zytor.com> <20140904231923.GA15320@khazad-dum.debian.net>
 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com> <1409876991.28990.172.camel@misato.fc.hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 4 Sep 2014 17:51:55 -0700
Message-ID: <CALCETrUhbx4hFRAkHfczLkZBYo0E7tRmdFyO7bqPd5e9JEWcMA@mail.gmail.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 4, 2014 at 5:29 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Thu, 2014-09-04 at 16:34 -0700, Andy Lutomirski wrote:
>> On Thu, Sep 4, 2014 at 4:19 PM, Henrique de Moraes Holschuh
>> <hmh@hmh.eng.br> wrote:
>> > On Thu, 04 Sep 2014, H. Peter Anvin wrote:
>> >> On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
>> >> > I am worried of uncharted territory, here.  I'd actually advocate for not
>> >> > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
>> >> > is using them as well.  Is this a real concern, or am I being overly
>> >> > cautious?
>> >>
>> >> It is extremely unlikely that we'd have PAT issues in 32-bit mode and
>> >> not in 64-bit mode on the same CPU.
>> >
>> > Sure, but is it really a good idea to enable this on the *old* non-64-bit
>> > capable processors (note: I don't mean x86-64 processors operating in 32-bit
>> > mode) ?
>> >
>> >> As far as I know, the current blacklist rule is very conservative due to
>> >> lack of testing more than anything else.
>> >
>> > I was told that much in 2009 when I asked why cpuid 0x6d8 was blacklisted
>> > from using PAT :-)
>>
>> At the very least, anyone who plugs an NV-DIMM into a 32-bit machine
>> is nuts, and not just because I'd be somewhat amazed if it even
>> physically fits into the slot. :)
>
> According to the spec, the upper four entries bug was fixed in Pentium 4
> model 0x1.  So, the remaining Intel 32-bit processors that may enable
> the upper four entries are Pentium 4 model 0x1-4.  Should we disable it
> for all Pentium 4 models?

Assuming that this is Pentium 4 erratum N46, then there may be another
option: use slot 7 instead of slot 4 for WT.  Then, even if somehow
the blacklist screws up, the worst that happens is that a WT page gets
interpreted as UC.  I suppose this could cause aliasing issues, but
can't cause problems for people who don't use the high entries in the
first place.

--Andy

>
> Thanks,
> -Toshi
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
