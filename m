Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF2736B0267
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:34:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so158748033pav.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:34:06 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id h18si15342086pfj.14.2016.05.27.09.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 09:34:05 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id fy7so25032613pac.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:34:05 -0700 (PDT)
Subject: Re: [PATCH] arm64: kasan: instrument user memory access API
References: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
 <57482930.6020608@virtuozzo.com>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <cea39367-65b6-62df-7e4c-57ae1ce36dcc@linaro.org>
Date: Fri, 27 May 2016 09:34:03 -0700
MIME-Version: 1.0
In-Reply-To: <57482930.6020608@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/27/2016 4:02 AM, Andrey Ryabinin wrote:
>
>
> On 05/26/2016 09:43 PM, Yang Shi wrote:
>> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
>> ("x86/kasan: instrument user memory access API") added KASAN instrument to
>> x86 user memory access API, so added such instrument to ARM64 too.
>>
>> Tested by test_kasan module.
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>  arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
>>  1 file changed, 16 insertions(+), 2 deletions(-)
>
> Please, cover __copy_from_user() and __copy_to_user() too.
> Unlike x86, your patch doesn't instrument these two.

I should elaborated this in my review. Yes, I did think about it, but 
unlike x86, __copy_to/from_user are implemented by asm code on ARM64. If 
I add kasan_check_read/write into them, I have to move the registers 
around to prepare the parameters for kasan calls, then restore them 
after the call, for example the below code for __copy_to_user:

         mov     x9, x0
         mov     x10, x1
         mov     x11, x2
         mov     x0, x10
         mov     x1, x11
         bl      kasan_check_read
         mov     x0, x9
         mov     x1, x10


So, I'm wondering if it is worth or not since __copy_to/from_user are 
just called at a couple of places, i.e. sctp, a couple of drivers, etc 
and not used too much. Actually, I think some of them could be replaced 
by __copy_to/from_user_inatomic.

Any idea is appreciated.

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
