Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4036B0005
	for <linux-mm@kvack.org>; Fri, 27 May 2016 14:05:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id di3so49529867pab.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:05:25 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id sq4si29751089pab.243.2016.05.27.11.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 11:05:24 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id eu11so33015788pad.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:05:24 -0700 (PDT)
Subject: Re: [PATCH] arm64: kasan: instrument user memory access API
References: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
 <57482930.6020608@virtuozzo.com>
 <cea39367-65b6-62df-7e4c-57ae1ce36dcc@linaro.org>
 <20160527174635.GL24469@leverpostej>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <9980d1db-abde-8c27-a581-17d72567903f@linaro.org>
Date: Fri, 27 May 2016 11:05:22 -0700
MIME-Version: 1.0
In-Reply-To: <20160527174635.GL24469@leverpostej>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, will.deacon@arm.com, catalin.marinas@arm.com, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 5/27/2016 10:46 AM, Mark Rutland wrote:
> On Fri, May 27, 2016 at 09:34:03AM -0700, Shi, Yang wrote:
>> On 5/27/2016 4:02 AM, Andrey Ryabinin wrote:
>>>
>>>
>>> On 05/26/2016 09:43 PM, Yang Shi wrote:
>>>> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
>>>> ("x86/kasan: instrument user memory access API") added KASAN instrument to
>>>> x86 user memory access API, so added such instrument to ARM64 too.
>>>>
>>>> Tested by test_kasan module.
>>>>
>>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>>>> ---
>>>> arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
>>>> 1 file changed, 16 insertions(+), 2 deletions(-)
>>>
>>> Please, cover __copy_from_user() and __copy_to_user() too.
>>> Unlike x86, your patch doesn't instrument these two.
>
> Argh, I missed those when reviewing. My bad.
>
>> I should elaborated this in my review. Yes, I did think about it,
>> but unlike x86, __copy_to/from_user are implemented by asm code on
>> ARM64. If I add kasan_check_read/write into them, I have to move the
>> registers around to prepare the parameters for kasan calls, then
>> restore them after the call, for example the below code for
>> __copy_to_user:
>>
>>         mov     x9, x0
>>         mov     x10, x1
>>         mov     x11, x2
>>         mov     x0, x10
>>         mov     x1, x11
>>         bl      kasan_check_read
>>         mov     x0, x9
>>         mov     x1, x10
>
> There's no need to alter the assembly.
>
> Rename the functions (e.g. have __arch_raw_copy_from_user), and add
> static inline wrappers in uaccess.h that do the kasan calls before
> calling the assembly functions.
>
> That gives the compiler the freedom to do the right thing, and avoids
> horrible ifdeffery in the assembly code.

Thanks for the suggestion, will address in v2.

Yang

>
>> So, I'm wondering if it is worth or not since __copy_to/from_user
>> are just called at a couple of places, i.e. sctp, a couple of
>> drivers, etc and not used too much.
>
> [mark@leverpostej:~/src/linux]% git grep -w __copy_to_user -- ^arch | wc -l
> 63
> [mark@leverpostej:~/src/linux]% git grep -w __copy_from_user -- ^arch | wc -l
> 47
>
> That's a reasonable number of callsites.
>
> If we're going to bother adding this, it should be complete. So please
> do update __copy_from_user and __copy_to_user.
>
>> Actually, I think some of them
>> could be replaced by __copy_to/from_user_inatomic.
>
> Given the number of existing callers outside of arch code, I think we'll
> get far more traction reworking the arm64 parts for now.
>
> Thanks,
> Mark.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
