Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCFFE6B026D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:25:56 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f66-v6so382162ywa.0
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:25:56 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y125-v6si2221442ybf.68.2018.10.09.00.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 00:25:55 -0700 (PDT)
Subject: Re: [PATCH] x86/mm: In the PTE swapout page reclaim case clear the
 accessed bit instead of flushing the TLB
References: <1539059570-9043-1-git-send-email-amhetre@nvidia.com>
 <20181009071637.GF5663@hirez.programming.kicks-ass.net>
From: Ashish Mhetre <amhetre@nvidia.com>
Message-ID: <d717553c-bdd4-7183-7424-19341bada57b@nvidia.com>
Date: Tue, 9 Oct 2018 12:55:51 +0530
MIME-Version: 1.0
In-Reply-To: <20181009071637.GF5663@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, nadav.amit@gmail.com
Cc: Snikam@nvidia.com, vdumpa@nvidia.com, Shaohua Li <shli@kernel.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

I am really sorry for sending this patch out to unintended audience.
This patch is already present in kernel.
We were referencing this patch for internal use and by mistake the
people in review got added in CC.
I apologize for that. Please ignore this patch.

Thanks,
Ashish Mhetre


On Tuesday 09 October 2018 12:46 PM, Peter Zijlstra wrote:
> On Tue, Oct 09, 2018 at 10:02:50AM +0530, Ashish Mhetre wrote:
>> From: Shaohua Li <shli@kernel.org>
>>
>> We use the accessed bit to age a page at page reclaim time,
>> and currently we also flush the TLB when doing so.
>>
>> But in some workloads TLB flush overhead is very heavy. In my
>> simple multithreaded app with a lot of swap to several pcie
>> SSDs, removing the tlb flush gives about 20% ~ 30% swapout
>> speedup.
>>
>> Fortunately just removing the TLB flush is a valid optimization:
>> on x86 CPUs, clearing the accessed bit without a TLB flush
>> doesn't cause data corruption.
>>
>> It could cause incorrect page aging and the (mistaken) reclaim of
>> hot pages, but the chance of that should be relatively low.
>>
>> So as a performance optimization don't flush the TLB when
>> clearing the accessed bit, it will eventually be flushed by
>> a context switch or a VM operation anyway. [ In the rare
>> event of it not getting flushed for a long time the delay
>> shouldn't really matter because there's no real memory
>> pressure for swapout to react to. ]
> Note that context switches (and here I'm talking about switch_mm(), not
> the cheaper switch_to()) do not unconditionally imply a TLB invalidation
> these days (on PCID enabled hardware).
>
> So in that regards, the Changelog (and the comment) is a little
> misleading.
>
> I don't see anything fundamentally wrong with the patch though; just the
> wording.
