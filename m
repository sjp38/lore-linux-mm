Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8C56B0037
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 04:15:42 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so1356238pdb.23
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 01:15:41 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id pq7si16042132pac.440.2014.04.30.01.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 01:15:38 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Wed, 30 Apr 2014 13:45:34 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 28E93E0057
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:45:51 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3U8FcMR5112156
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:45:38 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3U8FMTl021455
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:45:23 +0530
Message-ID: <5360B119.2090007@linux.vnet.ibm.com>
Date: Wed, 30 Apr 2014 13:45:21 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/2] powerpc/pseries: init fault_around_order for pseries
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com> <1398675690-16186-3-git-send-email-maddy@linux.vnet.ibm.com> <20140429070632.GB27951@gmail.com> <87d2fz47tg.fsf@rustcorp.com.au>
In-Reply-To: <87d2fz47tg.fsf@rustcorp.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, dave.hansen@intel.com, Linus Torvalds <torvalds@linux-foundation.org>

On Wednesday 30 April 2014 12:34 PM, Rusty Russell wrote:
> Ingo Molnar <mingo@kernel.org> writes:
>> * Madhavan Srinivasan <maddy@linux.vnet.ibm.com> wrote:
>>
>>> Performance data for different FAULT_AROUND_ORDER values from 4 socket
>>> Power7 system (128 Threads and 128GB memory). perf stat with repeat of 5
>>> is used to get the stddev values. Test ran in v3.14 kernel (Baseline) and
>>> v3.15-rc1 for different fault around order values.
>>>
>>> FAULT_AROUND_ORDER      Baseline        1               3               4               5               8
>>>
>>> Linux build (make -j64)
>>> minor-faults            47,437,359      35,279,286      25,425,347      23,461,275      22,002,189      21,435,836
>>> times in seconds        347.302528420   344.061588460   340.974022391   348.193508116   348.673900158   350.986543618
>>>  stddev for time        ( +-  1.50% )   ( +-  0.73% )   ( +-  1.13% )   ( +-  1.01% )   ( +-  1.89% )   ( +-  1.55% )
>>>  %chg time to baseline                  -0.9%           -1.8%           0.2%            0.39%           1.06%
>>
>> Probably too noisy.
> 
> A little, but 3 still looks like the winner.
> 
>>> Linux rebuild (make -j64)
>>> minor-faults            941,552         718,319         486,625         440,124         410,510         397,416
>>> times in seconds        30.569834718    31.219637539    31.319370649    31.434285472    31.972367174    31.443043580
>>>  stddev for time        ( +-  1.07% )   ( +-  0.13% )   ( +-  0.43% )   ( +-  0.18% )   ( +-  0.95% )   ( +-  0.58% )
>>>  %chg time to baseline                  2.1%            2.4%            2.8%            4.58%           2.85%
>>
>> Here it looks like a speedup. Optimal value: 5+.
> 
> No, lower time is better.  Baseline (no faultaround) wins.
> 
> 
> etc.
> 
> It's not a huge surprise that a 64k page arch wants a smaller value than
> a 4k system.  But I agree: I don't see much upside for FAO > 0, but I do
> see downside.
> 
> Most extreme results:
> Order 1: 2% loss on recompile.  10% win 4% loss on seq.  9% loss random.
> Order 3: 2% loss on recompile.  6% win 5% loss on seq.  14% loss on random.
> Order 4: 2.8% loss on recompile. 10% win 7% loss on seq.  9% loss on random.
> 
>> I'm starting to suspect that maybe workloads ought to be given a 
>> choice in this matter, via madvise() or such.
> 
> I really don't think they'll be able to use it; it'll change far too
> much with machine and kernel updates.  I think we should apply patch #1
> (with fixes) to make it a variable, then set it to 0 for PPC.
> 

Ok. Will do.

Thanks for review
With regards
Maddy


> Cheers,
> Rusty.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
