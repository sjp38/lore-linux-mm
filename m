Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id E53B96B009A
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:58:48 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so13177643obb.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:58:48 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id u8si12403719oie.22.2015.05.06.10.58.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 10:58:48 -0700 (PDT)
Message-ID: <554A5655.6060108@hp.com>
Date: Wed, 06 May 2015 13:58:45 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430231830-7702-1-git-send-email-mgorman@suse.de> <554030D1.8080509@hp.com> <5543F802.9090504@hp.com> <554415B1.2050702@hp.com> <20150504143046.9404c572486caf71bdef0676@linux-foundation.org> <20150505104514.GC2462@suse.de> <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org> <20150505221329.GE2462@suse.de> <20150505152549.037679566fad8c593df176ed@linux-foundation.org> <20150506071246.GF2462@suse.de> <20150506102220.GH2462@suse.de>
In-Reply-To: <20150506102220.GH2462@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/06/2015 06:22 AM, Mel Gorman wrote:
> On Wed, May 06, 2015 at 08:12:46AM +0100, Mel Gorman wrote:
>> On Tue, May 05, 2015 at 03:25:49PM -0700, Andrew Morton wrote:
>>> On Tue, 5 May 2015 23:13:29 +0100 Mel Gorman<mgorman@suse.de>  wrote:
>>>
>>>>> Alternatively, the page allocator can go off and synchronously
>>>>> initialize some pageframes itself.  Keep doing that until the
>>>>> allocation attempt succeeds.
>>>>>
>>>> That was rejected during review of earlier attempts at this feature on
>>>> the grounds that it impacted allocator fast paths.
>>> eh?  Changes are only needed on the allocation-attempt-failed path,
>>> which is slow-path.
>> We'd have to distinguish between falling back to other zones because the
>> high zone is artifically exhausted and normal ALLOC_BATCH exhaustion. We'd
>> also have to avoid falling back to remote nodes prematurely. While I have
>> not tried an implementation, I expected they would need to be in the fast
>> paths unless I used jump labels to get around it. I'm going to try altering
>> when we initialise instead so that it happens earlier.
>>
> Which looks as follows. Waiman, a test on the 24TB machine would be
> appreciated again. This patch should be applied instead of "mm: meminit:
> Take into account that large system caches scale linearly with memory"
>
> ---8<---
> mm: meminit: Finish initialisation of memory before basic setup
>
> Waiman Long reported that 24TB machines hit OOM during basic setup when
> struct page initialisation was deferred. One approach is to initialise memory
> on demand but it interferes with page allocator paths. This patch creates
> dedicated threads to initialise memory before basic setup. It then blocks
> on a rw_semaphore until completion as a wait_queue and counter is overkill.
> This may be slower to boot but it's simplier overall and also gets rid of a
> lot of section mangling which existed so kswapd could do the initialisation.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
>

This patch moves the deferred meminit from kswapd to its own kernel 
threads started after smp_init(). However, the hash table allocation was 
done earlier than that. It seems like it will still run out of memory in 
the 24TB machine that I tested on.

I will certainly try it out, but I doubt it will solve the problem on 
its own.

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
