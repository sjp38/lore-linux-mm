Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 5ACB06B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 10:34:30 -0400 (EDT)
Message-ID: <51700475.7050102@linux.intel.com>
Date: Thu, 18 Apr 2013 07:34:29 -0700
From: Darren Hart <dvhart@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF79A40956.94F46B9C-ON48257B50.00320F73-48257B50.0036925D@zte.com.cn> <516EAF31.8000107@linux.intel.com> <516EBF23.2090600@sr71.net> <516EC508.6070200@linux.intel.com> <OF7B3DF162.973A9AD7-ON48257B51.00299512-48257B51.002C7D65@zte.com.cn>
In-Reply-To: <OF7B3DF162.973A9AD7-ON48257B51.00299512-48257B51.002C7D65@zte.com.cn>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.yi20@zte.com.cn
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>



On 04/18/2013 01:05 AM, zhang.yi20@zte.com.cn wrote:
> Darren Hart <dvhart@linux.intel.com> wrote on 2013/04/17 23:51:36:
> 
>> On 04/17/2013 08:26 AM, Dave Hansen wrote:
>>> On 04/17/2013 07:18 AM, Darren Hart wrote:
>>>>>> This also needs a comment in futex.h describing the usage of the
>>>>>> offset field in union futex_key as well as above get_futex_key
>>>>>> describing the key for shared mappings.
>>>>>>
>>>>> As far as I know , the max size of one hugepage is 1 GBytes for 
>>>>> x86 cpu. Can some other cpus support greater hugepage even more 
>>>>> than 4 GBytes? If so, we can change the type of 'offset' from int 
>>>>>  to long to avoid truncating.
>>>>
>>>> I discussed this with Dave Hansen, on CC, and he thought we needed
>>>> 9 bits, so even on x86 32b we should be covered.
>>>
>>> I think the problem is actually on 64-bit since you still only have
>>> 32-bits in an 'int' there.
>>>
>>> I guess it's remotely possible that we could have some
>>> mega-super-huge-gigantic pages show up in hardware some day, or that
>>> somebody would come up with software-only one.  I bet there's a lot
>>> more code that will break in the kernel than this futex code, though.
>>>
>>> The other option would be to start #defining some build-time constant
>>> for what the largest possible huge page size is, then BUILD_BUG_ON()
>>> it.
>>>
>>> Or you can just make it a long ;)
>>
>> If we make it a long I'd want to see futextest performance tests before
>> and after. Messing with the futex_key has been known to have bad results
>> in the past :-)
>>
>> -- 
>  
> I have run futextest/performance/futex_wait for testing, 5 times before 
> make it long:
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10215 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 9862 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10081 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10060 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10081 Kiter/s
> 
> 
> And 5 times after make it long:
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 9940 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10204 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 9901 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10152 Kiter/s
> 
> futex_wait: Measure FUTEX_WAIT operations per second
>         Arguments: iterations=100000000 threads=256
> Result: 10060 Kiter/s
> 
> 
> Seems OK, is it?
> 

Changes appear to be in the noise, no impact with this load anyway.

How many CPUs on your test machine? I presume not 256?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
