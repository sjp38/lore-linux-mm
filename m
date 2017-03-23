Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 782DB6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 09:31:06 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id a12so369653553ota.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:31:06 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id o88si2293582ota.292.2017.03.23.06.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 06:31:05 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id f81so5587066oih.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:31:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aL-X8VbFC0kfHG8tKVSanhkY9a_hNrEcAHGUyQk1WtSA@mail.gmail.com>
References: <20170322111022.85745-1-dvyukov@google.com> <CAK8P3a2pm2EsxOxxf7SsEObxcNFJP60JOY_78a19g2kD4pL6Rw@mail.gmail.com>
 <CAK8P3a2DskgumXx5XuzN8J-T0jmhXgD5dPZ4QWBtDA3WvMCyoQ@mail.gmail.com> <CACT4Y+aL-X8VbFC0kfHG8tKVSanhkY9a_hNrEcAHGUyQk1WtSA@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 23 Mar 2017 14:31:04 +0100
Message-ID: <CAK8P3a0v1_hb_BLmnbz-hcgvCi=-B8mKvhhkX-FpXJM5z+TQgA@mail.gmail.com>
Subject: Re: [PATCH] asm-generic: fix compilation failure in cmpxchg_double()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Mar 23, 2017 at 9:49 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Mar 22, 2017 at 10:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Wed, Mar 22, 2017 at 12:27 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> On Wed, Mar 22, 2017 at 12:10 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> Arnd reported that the new code leads to compilation failures
>>>> with some versions of gcc. I've filed gcc issue 72873,
>>>> but we need a kernel fix as well.
>>>>
>>>> Remove instrumentation from cmpxchg_double() for now.
>>>
>>> Thanks, I also checked that fixes the build error for me.
>>
>> I got a new variant of the bug in
>> arch/x86/include/asm/cmpxchg_32.h:set_64bit() now.
>>
>> In file included from /git/arm-soc/arch/x86/include/asm/cmpxchg.h:142:0,
>>                  from /git/arm-soc/arch/x86/include/asm/atomic.h:7,
>>                  from /git/arm-soc/arch/x86/include/asm/msr.h:66,
>>                  from /git/arm-soc/arch/x86/include/asm/processor.h:20,
>>                  from /git/arm-soc/arch/x86/include/asm/cpufeature.h:4,
>>                  from /git/arm-soc/arch/x86/include/asm/thread_info.h:52,
>>                  from /git/arm-soc/include/linux/thread_info.h:25,
>>                  from /git/arm-soc/arch/x86/include/asm/preempt.h:6,
>>                  from /git/arm-soc/include/linux/preempt.h:80,
>>                  from /git/arm-soc/include/linux/spinlock.h:50,
>>                  from /git/arm-soc/include/linux/mmzone.h:7,
>>                  from /git/arm-soc/include/linux/gfp.h:5,
>>                  from /git/arm-soc/include/linux/mm.h:9,
>>                  from /git/arm-soc/mm/khugepaged.c:3:
>> /git/arm-soc/mm/khugepaged.c: In function 'khugepaged':
>> /git/arm-soc/arch/x86/include/asm/cmpxchg_32.h:29:2: error: 'asm'
>> operand has impossible constraints
>>   asm volatile("\n1:\t"
>>
>> Defconfig is at http://pastebin.com/raw/Pthhv5iU
>
>
> I can't reproduce it with gcc 4.8.4, 7.0.0, 7.0.1.
>
> Are you sure it's related to my recent change? I did not touch set_64bit.

You are right, this is different, it just appeared on the same day with
almost exactly the same symptom as the other one, so I mistakenly
assumed it was the same root cause.

Reverting your patches doesn't fix it, and I only see it with the
latest gcc-7.0.1 snapshot, not with one from a few weeks ago.
I'll open a gcc bug for it.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
