Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDA76B0264
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 18:09:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i130so15737125wmg.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 15:09:35 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id hm2si23849298wjb.83.2016.10.07.15.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 15:09:34 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id f193so4793713wmg.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 15:09:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <001f01d1ee06$00b484e0$021d8ea0$@alibaba-inc.com>
References: <001e01d1ee04$c7f77be0$57e673a0$@alibaba-inc.com> <001f01d1ee06$00b484e0$021d8ea0$@alibaba-inc.com>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Sat, 8 Oct 2016 00:09:33 +0200
Message-ID: <CAOMGZ=E0U980xbHbCkms89rR3ykQmum0d+E=XEGG_xw0+=CwNg@mail.gmail.com>
Subject: Re: [PATCH 04/10] fault injection: prevent recursive fault injection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>

On 4 August 2016 at 06:09, Hillf Danton <hillf.zj@alibaba-inc.com> wrote:
>>
>> If something we call in the fail_dump() code path tries to acquire a
>> resource that might fail (due to fault injection), then we should not
>> try to recurse back into the fault injection code.
>>
>> I've seen this happen with the console semaphore in the upcoming
>> semaphore trylock fault injection code.
>>
>> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
>> ---
>>  lib/fault-inject.c | 34 ++++++++++++++++++++++++++++------
>>  1 file changed, 28 insertions(+), 6 deletions(-)
>>
>> diff --git a/lib/fault-inject.c b/lib/fault-inject.c
>> index 6a823a5..adba7c9 100644
>> --- a/lib/fault-inject.c
>> +++ b/lib/fault-inject.c
>> @@ -100,6 +100,33 @@ static inline bool fail_stacktrace(struct fault_attr *attr)
>>
>>  #endif /* CONFIG_FAULT_INJECTION_STACKTRACE_FILTER */
>>
>> +static DEFINE_PER_CPU(int, fault_active);
>> +
>> +static bool __fail(struct fault_attr *attr)
>> +{
>> +     bool ret = false;
>> +
>> +     /*
>> +      * Prevent recursive fault injection (this could happen if for
>> +      * example printing the fault would itself run some code that
>> +      * could fail)
>> +      */
>> +     preempt_disable();
>> +     if (unlikely(__this_cpu_inc_return(fault_active) != 1))
>> +             goto out;
>> +
>> +     ret = true;
>> +     fail_dump(attr);
>> +
>> +     if (atomic_read(&attr->times) != -1)
>> +             atomic_dec_not_zero(&attr->times);
>> +
>> +out:
>> +     __this_cpu_dec(fault_active);
>> +     preempt_enable();
>
> Well schedule entry point is add in paths like
>         rt_mutex_trylock
>         __alloc_pages_nodemask
> and please add one or two sentences in log
> message for it.

I'm sorry, but I don't really get what you are saying or what you want
me to add.

Are you saying that because I'm adding a fail_dump() call to
mutex_trylock() that we can now end up calling schedule() from a weird
context?

This patch is just to prevent __fail() from looping on itself, I don't
see what the connection is to rt_mutex_trylock(),
__alloc_pages_nodemask(), or schedule().

Could you please clarify? Thanks,


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
