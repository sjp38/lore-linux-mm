Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2122A6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 03:11:26 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kq14so1533901pab.18
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 00:11:25 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id rb6si15869831pab.67.2014.04.30.00.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Apr 2014 00:11:24 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V3 2/2] powerpc/pseries: init fault_around_order for pseries
In-Reply-To: <20140429070632.GB27951@gmail.com>
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com> <1398675690-16186-3-git-send-email-maddy@linux.vnet.ibm.com> <20140429070632.GB27951@gmail.com>
Date: Wed, 30 Apr 2014 16:34:11 +0930
Message-ID: <87d2fz47tg.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, dave.hansen@intel.com, Linus Torvalds <torvalds@linux-foundation.org>

Ingo Molnar <mingo@kernel.org> writes:
> * Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:
>
>> Performance data for different FAULT_AROUND_ORDER values from 4 socket
>> Power7 system (128 Threads and 128GB memory). perf stat with repeat of 5
>> is used to get the stddev values. Test ran in v3.14 kernel (Baseline) and
>> v3.15-rc1 for different fault around order values.
>> 
>> FAULT_AROUND_ORDER      Baseline        1               3               4               5               8
>> 
>> Linux build (make -j64)
>> minor-faults            47,437,359      35,279,286      25,425,347      23,461,275      22,002,189      21,435,836
>> times in seconds        347.302528420   344.061588460   340.974022391   348.193508116   348.673900158   350.986543618
>>  stddev for time        ( +-  1.50% )   ( +-  0.73% )   ( +-  1.13% )   ( +-  1.01% )   ( +-  1.89% )   ( +-  1.55% )
>>  %chg time to baseline                  -0.9%           -1.8%           0.2%            0.39%           1.06%
>
> Probably too noisy.

A little, but 3 still looks like the winner.

>> Linux rebuild (make -j64)
>> minor-faults            941,552         718,319         486,625         440,124         410,510         397,416
>> times in seconds        30.569834718    31.219637539    31.319370649    31.434285472    31.972367174    31.443043580
>>  stddev for time        ( +-  1.07% )   ( +-  0.13% )   ( +-  0.43% )   ( +-  0.18% )   ( +-  0.95% )   ( +-  0.58% )
>>  %chg time to baseline                  2.1%            2.4%            2.8%            4.58%           2.85%
>
> Here it looks like a speedup. Optimal value: 5+.

No, lower time is better.  Baseline (no faultaround) wins.


etc.

It's not a huge surprise that a 64k page arch wants a smaller value than
a 4k system.  But I agree: I don't see much upside for FAO > 0, but I do
see downside.

Most extreme results:
Order 1: 2% loss on recompile.  10% win 4% loss on seq.  9% loss random.
Order 3: 2% loss on recompile.  6% win 5% loss on seq.  14% loss on random.
Order 4: 2.8% loss on recompile. 10% win 7% loss on seq.  9% loss on random.

> I'm starting to suspect that maybe workloads ought to be given a 
> choice in this matter, via madvise() or such.

I really don't think they'll be able to use it; it'll change far too
much with machine and kernel updates.  I think we should apply patch #1
(with fixes) to make it a variable, then set it to 0 for PPC.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
