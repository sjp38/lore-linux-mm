Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68B4D6B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:36:05 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j26so11620010iod.5
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 10:36:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a66sor843314oib.136.2017.09.21.10.36.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 10:36:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8760ccdpwm.fsf@linux.intel.com>
References: <20170921074519.9333-1-nefelim4ag@gmail.com> <8760ccdpwm.fsf@linux.intel.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 21 Sep 2017 20:35:23 +0300
Message-ID: <CAGqmi74Qi0VRKG87N4txEZRaZ3JHYW8622E0KhKynRYuD56J=g@mail.gmail.com>
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org

2017-09-21 18:36 GMT+03:00 Andi Kleen <ak@linux.intel.com>:
> Timofey Titovets <nefelim4ag@gmail.com> writes:
>
>> xxhash much faster then jhash,
>> ex. for x86_64 host:
>> PAGE_SIZE: 4096, loop count: 1048576
>> jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
>> xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
>> xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s
>>
>> xxhash64 on x86_32 work with ~ same speed as jhash2.
>> xxhash32 on x86_32 work with ~ same speed as for x86_64
>
> Which CPU is that?

Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
---
I've access to some VM (Not KVM) with:
Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
PAGE_SIZE: 4096, loop count: 1048576
jhash2:   0x15433d14            time: 3661 ms,  th: 1173.144082 MiB/s
xxhash32: 0x3df3de36            time: 1163 ms,  th: 3691.581922 MiB/s
xxhash64: 0x5d9e67755d3c9a6a    time: 715 ms,   th: 6006.628034 MiB/s

As additional info, xxhash work with ~ same as jhash2 speed at 32 byte
input data.
For input smaller than 32 byte, jhash2 win, for input bigger, xxhash win.


>> So replace jhash with xxhash,
>> and use fastest version for current target ARCH.
>
> Can you do some macro-benchmarking too? Something that uses
> KSM and show how the performance changes.
>
> You could manually increase the scan rate to make it easier
> to see.

Try use that patch with my patch to allow process all VMA on system [1].
I switch sleep_millisecs 20 -> 1

(I use htop to see CPU load of ksmd)

CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
For jhash2: ~18%
For xxhash64: ~11%

(i didn't have x86_32 test machine, so by extrapolating values,
so i expect for xxhash32: (18+11)/2 = ~14.5%)

KSM Statistic:
full_scans:481
max_page_sharing:256
merge_across_nodes:1
mode:[always] normal
pages_shared:39
pages_sharing:135
pages_to_scan:100
pages_unshared:4514
pages_volatile:310
run:1
sleep_millisecs:1
stable_node_chains:0
stable_node_chains_prune_millisecs:2000
stable_node_dups:0
use_zero_pages:0

>> @@ -51,6 +52,12 @@
>>  #define DO_NUMA(x)   do { } while (0)
>>  #endif
>>
>> +#if BITS_PER_LONG == 64
>> +typedef      u64     xxhash;
>> +#else
>> +typedef      u32     xxhash;
>> +#endif
>
> This should be in xxhash.h ?

This is a "hack", for compile time chose appropriate hash function.
xxhash ported from upstream code,
upstream version don't do that (IMHO), as this useless in most cases.
That only can be useful for memory only hashes.
Because for persistent data it's obvious to always use one hash type 32/64.

> xxhash_t would seem to be a better name.
>
>> -     u32 checksum;
>> +     xxhash checksum;
>>       void *addr = kmap_atomic(page);
>> -     checksum = jhash2(addr, PAGE_SIZE / 4, 17);
>> +#if BITS_PER_LONG == 64
>> +     checksum = xxh64(addr, PAGE_SIZE, 0);
>> +#else
>> +     checksum = xxh32(addr, PAGE_SIZE, 0);
>> +#endif
>
> This should also be generic in xxhash.h

This *can* be generic in xxhash.h, when that solution will be used
somewhere in the kernel code, not in the KSM only, not?

Because for now i didn't find other places with "big enough" input
data, to replace jhash2 with xxhash.

>
>
> -Andi

Thanks.

Links:
1. https://marc.info/?l=linux-mm&m=150539825420373&w=2

-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
