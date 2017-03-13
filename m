Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 652846B0388
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:20:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m27so47418698iti.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:20:47 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40133.outbound.protection.outlook.com. [40.107.4.133])
        by mx.google.com with ESMTPS id u131si7473731itf.72.2017.03.13.07.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:20:46 -0700 (PDT)
Subject: Re: [PATCHv6 4/5] x86/mm: check in_compat_syscall() instead
 TIF_ADDR32 for mmap(MAP_32BIT)
References: <20170306141721.9188-1-dsafonov@virtuozzo.com>
 <20170306141721.9188-5-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1703131035020.3558@nanos>
 <35a16a2c-c799-fe0c-2689-bf105b508663@virtuozzo.com>
 <alpine.DEB.2.20.1703131446410.3558@nanos>
 <4f802f8b-07a6-f8cd-71fc-943e40714d1b@virtuozzo.com>
 <alpine.DEB.2.20.1703131502240.3558@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <2a7e5737-2f5a-02c7-bf74-9371190a0370@virtuozzo.com>
Date: Mon, 13 Mar 2017 17:17:00 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1703131502240.3558@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Michael Kerrisk <mtk@man7.org>

On 03/13/2017 05:03 PM, Thomas Gleixner wrote:
> On Mon, 13 Mar 2017, Dmitry Safonov wrote:
>> On 03/13/2017 04:47 PM, Thomas Gleixner wrote:
>>> On Mon, 13 Mar 2017, Dmitry Safonov wrote:
>>>> On 03/13/2017 12:39 PM, Thomas Gleixner wrote:
>>>>> On Mon, 6 Mar 2017, Dmitry Safonov wrote:
>>>>>
>>>>>> Result of mmap() calls with MAP_32BIT flag at this moment depends
>>>>>> on thread flag TIF_ADDR32, which is set during exec() for 32-bit apps.
>>>>>> It's broken as the behavior of mmap() shouldn't depend on exec-ed
>>>>>> application's bitness. Instead, it should check the bitness of mmap()
>>>>>> syscall.
>>>>>> How it worked before:
>>>>>> o for 32-bit compatible binaries it is completely ignored. Which was
>>>>>> fine when there were one mmap_base, computed for 32-bit syscalls.
>>>>>> After introducing mmap_compat_base 64-bit syscalls do use computed
>>>>>> for 64-bit syscalls mmap_base, which means that we can allocate 64-bit
>>>>>> address with 64-bit syscall in application launched from 32-bit
>>>>>> compatible binary. And ignoring this flag is not expected behavior.
>>>>>
>>>>> Well, the real question here is, whether we should allow 32bit
>>>>> applications
>>>>> to obtain 64bit mappings at all. We can very well force 32bit
>>>>> applications
>>>>> into the 4GB address space as it was before your mmap base splitup and
>>>>> be
>>>>> done with it.
>>>>
>>>> Hmm, yes, we could restrict 32bit applications to 32bit mappings only.
>>>> But the approach which I tried to follow in the patches set, it was do
>>>> not base the logic on the bitness of launched applications
>>>> (native/compat) - only base on bitness of the performing syscall.
>>>> The idea was suggested by Andy and I made mmap() logic here independent
>>>> from original application's bitness.
>>>>
>>>> It also seems to me simpler:
>>>> if 32-bit application wants to allocate 64-bit mapping, it should
>>>> long-jump with 64-bit segment descriptor and do `syscall` instruction
>>>> for 64-bit syscall entry path. So, in my point of view after this dance
>>>> the application does not differ much from native 64-bit binary and can
>>>> have 64-bit address mapping.
>>>
>>> Works for me, but it lacks documentation .....
>>
>> Sure, could you recommend a better place for it?
>> Should it be in-code comment in x86 mmap() code or Documentation/*
>> change or a patch to man-pages?
>
> I added a comment in the code and fixed up the changelogs. man-page needs
> some care as well.

Big thanks, Thomas!
I'll make a patch for man-pages on the week.

>
> Thanks,
>
> 	tglx
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
