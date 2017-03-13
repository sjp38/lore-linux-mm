Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E47E6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:30:15 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u81so124741233uau.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:30:15 -0700 (PDT)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id g30si226978uab.157.2017.03.13.08.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 08:30:14 -0700 (PDT)
Received: by mail-vk0-x234.google.com with SMTP id d188so36926532vka.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:30:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1703131446410.3558@nanos>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com> <20170306141721.9188-5-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1703131035020.3558@nanos> <35a16a2c-c799-fe0c-2689-bf105b508663@virtuozzo.com>
 <alpine.DEB.2.20.1703131446410.3558@nanos>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 13 Mar 2017 08:29:53 -0700
Message-ID: <CALCETrXzUXa9i_9ZoMMhH27U+V2pQZE4cM7L7n0wNsTzmWHW3Q@mail.gmail.com>
Subject: Re: [PATCHv6 4/5] x86/mm: check in_compat_syscall() instead
 TIF_ADDR32 for mmap(MAP_32BIT)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Mar 13, 2017 at 6:47 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Mon, 13 Mar 2017, Dmitry Safonov wrote:
>> On 03/13/2017 12:39 PM, Thomas Gleixner wrote:
>> > On Mon, 6 Mar 2017, Dmitry Safonov wrote:
>> >
>> > > Result of mmap() calls with MAP_32BIT flag at this moment depends
>> > > on thread flag TIF_ADDR32, which is set during exec() for 32-bit apps.
>> > > It's broken as the behavior of mmap() shouldn't depend on exec-ed
>> > > application's bitness. Instead, it should check the bitness of mmap()
>> > > syscall.
>> > > How it worked before:
>> > > o for 32-bit compatible binaries it is completely ignored. Which was
>> > > fine when there were one mmap_base, computed for 32-bit syscalls.
>> > > After introducing mmap_compat_base 64-bit syscalls do use computed
>> > > for 64-bit syscalls mmap_base, which means that we can allocate 64-bit
>> > > address with 64-bit syscall in application launched from 32-bit
>> > > compatible binary. And ignoring this flag is not expected behavior.
>> >
>> > Well, the real question here is, whether we should allow 32bit applications
>> > to obtain 64bit mappings at all. We can very well force 32bit applications
>> > into the 4GB address space as it was before your mmap base splitup and be
>> > done with it.
>>
>> Hmm, yes, we could restrict 32bit applications to 32bit mappings only.
>> But the approach which I tried to follow in the patches set, it was do
>> not base the logic on the bitness of launched applications
>> (native/compat) - only base on bitness of the performing syscall.
>> The idea was suggested by Andy and I made mmap() logic here independent
>> from original application's bitness.
>>
>> It also seems to me simpler:
>> if 32-bit application wants to allocate 64-bit mapping, it should
>> long-jump with 64-bit segment descriptor and do `syscall` instruction
>> for 64-bit syscall entry path. So, in my point of view after this dance
>> the application does not differ much from native 64-bit binary and can
>> have 64-bit address mapping.

I agree.

>
> Works for me, but it lacks documentation .....
>
> Thanks,
>
>         tglx



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
