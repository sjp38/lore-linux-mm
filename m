Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 210356B0033
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 17:38:07 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f72so12722835ioj.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 14:38:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor1050110oig.98.2017.09.21.14.38.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 14:38:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170921200543.GH4311@tassilo.jf.intel.com>
References: <20170921074519.9333-1-nefelim4ag@gmail.com> <8760ccdpwm.fsf@linux.intel.com>
 <CAGqmi74Qi0VRKG87N4txEZRaZ3JHYW8622E0KhKynRYuD56J=g@mail.gmail.com> <20170921200543.GH4311@tassilo.jf.intel.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Fri, 22 Sep 2017 00:37:25 +0300
Message-ID: <CAGqmi76=ntcE5tvYGKOQynpTfUfUotwXZQuU4iUC+H_6rua7Yw@mail.gmail.com>
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org

2017-09-21 23:05 GMT+03:00 Andi Kleen <ak@linux.intel.com>:
>> > Which CPU is that?
>>
>> Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
>> ---
>> I've access to some VM (Not KVM) with:
>> Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
>> PAGE_SIZE: 4096, loop count: 1048576
>> jhash2:   0x15433d14            time: 3661 ms,  th: 1173.144082 MiB/s
>> xxhash32: 0x3df3de36            time: 1163 ms,  th: 3691.581922 MiB/s
>> xxhash64: 0x5d9e67755d3c9a6a    time: 715 ms,   th: 6006.628034 MiB/s
>>
>> As additional info, xxhash work with ~ same as jhash2 speed at 32 byte
>> input data.
>> For input smaller than 32 byte, jhash2 win, for input bigger, xxhash win.
>
> Please put that information into the changelog when you repost.
>
>>
>>
>> >> So replace jhash with xxhash,
>> >> and use fastest version for current target ARCH.
>> >
>> > Can you do some macro-benchmarking too? Something that uses
>> > KSM and show how the performance changes.
>> >
>> > You could manually increase the scan rate to make it easier
>> > to see.
>>
>> Try use that patch with my patch to allow process all VMA on system [1].
>> I switch sleep_millisecs 20 -> 1
>>
>> (I use htop to see CPU load of ksmd)
>>
>> CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
>> For jhash2: ~18%
>> For xxhash64: ~11%
>
> Ok that's a great result. Is a speedup also visible with the default
> sleep_millisecs value?

With defaults:
jhash2: ~4.7%
xxhash64: ~3.3%

3.3/4.7 ~= 0.7 -> Profit: ~30%
11/18   ~= 0.6 -> Profit: ~40%
(if i calculate correctly of course)

>> >> @@ -51,6 +52,12 @@
>> >>  #define DO_NUMA(x)   do { } while (0)
>> >>  #endif
>> >>
>> >> +#if BITS_PER_LONG == 64
>> >> +typedef      u64     xxhash;
>> >> +#else
>> >> +typedef      u32     xxhash;
>> >> +#endif
>> >
>> > This should be in xxhash.h ?
>>
>> This is a "hack", for compile time chose appropriate hash function.
>> xxhash ported from upstream code,
>> upstream version don't do that (IMHO), as this useless in most cases.
>> That only can be useful for memory only hashes.
>> Because for persistent data it's obvious to always use one hash type 32/64.
>
> I don't think it's a hack. It makes sense. Just should be done centrally
> in Linux, not in a specific user.

So, i must add separate patch for xxhash.h?
If yes, may be you can suggest which list must be in copy?
(i can't find any info about maintainers of ./lib/ in MAINTAINERS)

>>
>> > xxhash_t would seem to be a better name.
>> >
>> >> -     u32 checksum;
>> >> +     xxhash checksum;
>> >>       void *addr = kmap_atomic(page);
>> >> -     checksum = jhash2(addr, PAGE_SIZE / 4, 17);
>> >> +#if BITS_PER_LONG == 64
>> >> +     checksum = xxh64(addr, PAGE_SIZE, 0);
>> >> +#else
>> >> +     checksum = xxh32(addr, PAGE_SIZE, 0);
>> >> +#endif
>> >
>> > This should also be generic in xxhash.h
>>
>> This *can* be generic in xxhash.h, when that solution will be used
>> somewhere in the kernel code, not in the KSM only, not?
>
> Yes.

If we decide to patch xxhash.h,
may be that will be better to wrap above if-else by something like:
/*
 * Only for in memory use
 */
xxhash_t xxhash(const void *input, size_t length, uint64_t seed);

>>
>> Because for now i didn't find other places with "big enough" input
>> data, to replace jhash2 with xxhash.
>
> Right, but we may get them.
>
> -Andi
>

Thanks.
-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
