Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id BD0F46B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 16:50:38 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id b17so12545518lan.22
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:50:38 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
        by mx.google.com with ESMTPS id tc3si52779lbb.103.2014.09.04.13.50.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 13:50:37 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so12464879lbd.34
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 13:50:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409862708.28990.141.camel@misato.fc.hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com> <20140904201123.GA9116@khazad-dum.debian.net>
 <1409862708.28990.141.camel@misato.fc.hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 4 Sep 2014 13:50:16 -0700
Message-ID: <CALCETrV411+dvU-CzLrSs790W2oyb5fdx_9Mp8nUBmaMygBmUw@mail.gmail.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 4, 2014 at 1:31 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> On Thu, 2014-09-04 at 17:11 -0300, Henrique de Moraes Holschuh wrote:
>> On Thu, 04 Sep 2014, Toshi Kani wrote:
>> > This patch sets WT to the PA4 slot in the PAT MSR when the processor
>> > is not affected by the PAT errata.  The upper 4 slots of the PAT MSR
>> > are continued to be unused on the following Intel processors.
>> >
>> >   errata           cpuid
>> >   --------------------------------------
>> >   Pentium 2, A52   family 0x6, model 0x5
>> >   Pentium 3, E27   family 0x6, model 0x7
>> >   Pentium M, Y26   family 0x6, model 0x9
>> >   Pentium 4, N46   family 0xf, model 0x0
>> >
>> > For these affected processors, _PAGE_CACHE_MODE_WT is redirected to UC-
>> > per the default setup in __cachemode2pte_tbl[].
>>
>> There are at least two PAT errata.  The blacklist is in
>> arch/x86/kernel/cpu/intel.c:
>>
>>         if (c->x86 == 6 && c->x86_model < 15)
>>                 clear_cpu_cap(c, X86_FEATURE_PAT);
>>
>> It covers model 13, which is not in your blacklist.
>>
>> It *is* possible that PAT would work on model 13, as I don't think it has
>> any PAT errata listed and it was blacklisted "just in case" (from memory. I
>> did not re-check), but this is untested, and unwise to enable on an aging
>> platform.
>>
>> I am worried of uncharted territory, here.  I'd actually advocate for not
>> enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
>> is using them as well.  Is this a real concern, or am I being overly
>> cautious?
>
> The blacklist you pointed out covers a different PAT errata, and is
> still effective after this change.  pat_init() will call pat_disable()
> and the PAT will continue to be disabled on these processors.  There is
> no change for them.
>
> My blacklist covers the PAT errata that makes the upper four bit
> unusable when the PAT is enabled.
>

IIRC a lot of the errata only matter if we try to use various PAT bits
in intermediate page table entries to change the caching mode of, say,
the PTE pages.  If we're doing that, something's very wrong, errata or
otherwise.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
