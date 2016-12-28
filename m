Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA82D6B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 22:34:02 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so171492126qkf.0
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:34:02 -0800 (PST)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id c145si29167747qke.290.2016.12.27.19.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 19:34:02 -0800 (PST)
Received: by mail-qk0-x243.google.com with SMTP id u25so30308892qki.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:34:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87k2cxkwss.fsf@yhuang-dev.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
 <f399f0381db2e6d6bba804d139f5f41725137337.1477004978.git.tim.c.chen@linux.intel.com>
 <20161024103133.7c1a8f83@lwn.net> <87k2cxkwss.fsf@yhuang-dev.intel.com>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Wed, 28 Dec 2016 11:34:01 +0800
Message-ID: <CAC=cRTNTpnqOp5-G+c4dEPdADeL2m=zorvFBoY8sYaWKCwGOgg@mail.gmail.com>
Subject: Re: [PATCH v2 2/8] mm/swap: Add cluster lock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, Andi Kleen <ak@linux.intel.com>, Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hi, Jonathan,

On Tue, Oct 25, 2016 at 10:05 AM, Huang, Ying <ying.huang@intel.com> wrote:
> Hi, Jonathan,
>
> Thanks for review.
>
> Jonathan Corbet <corbet@lwn.net> writes:
>
>> On Thu, 20 Oct 2016 16:31:41 -0700
>> Tim Chen <tim.c.chen@linux.intel.com> wrote:
>>
>>> From: "Huang, Ying" <ying.huang@intel.com>
>>>
>>> This patch is to reduce the lock contention of swap_info_struct->lock
>>> via using a more fine grained lock in swap_cluster_info for some swap
>>> operations.  swap_info_struct->lock is heavily contended if multiple
>>> processes reclaim pages simultaneously.  Because there is only one lock
>>> for each swap device.  While in common configuration, there is only one
>>> or several swap devices in the system.  The lock protects almost all
>>> swap related operations.
>>
>> So I'm looking at this a bit.  Overall it seems like a good thing to do
>> (from my limited understanding of this area) but I have a probably silly
>> question...
>>
>>>  struct swap_cluster_info {
>>> -    unsigned int data:24;
>>> -    unsigned int flags:8;
>>> +    unsigned long data;
>>>  };
>>> -#define CLUSTER_FLAG_FREE 1 /* This cluster is free */
>>> -#define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
>>> +#define CLUSTER_COUNT_SHIFT         8
>>> +#define CLUSTER_FLAG_MASK           ((1UL << CLUSTER_COUNT_SHIFT) - 1)
>>> +#define CLUSTER_COUNT_MASK          (~CLUSTER_FLAG_MASK)
>>> +#define CLUSTER_FLAG_FREE           1 /* This cluster is free */
>>> +#define CLUSTER_FLAG_NEXT_NULL              2 /* This cluster has no next cluster */
>>> +/* cluster lock, protect cluster_info contents and sis->swap_map */
>>> +#define CLUSTER_FLAG_LOCK_BIT               2
>>> +#define CLUSTER_FLAG_LOCK           (1 << CLUSTER_FLAG_LOCK_BIT)
>>
>> Why the roll-your-own locking and data structures here?  To my naive
>> understanding, it seems like you could do something like:
>>
>>   struct swap_cluster_info {
>>       spinlock_t lock;
>>       atomic_t count;
>>       unsigned int flags;
>>   };
>>
>> Then you could use proper spinlock operations which, among other things,
>> would make the realtime folks happier.  That might well help with the
>> cache-line sharing issues as well.  Some of the count manipulations could
>> perhaps be done without the lock entirely; similarly, atomic bitops might
>> save you the locking for some of the flag tweaks - though I'd have to look
>> more closely to be really sure of that.
>>
>> The cost, of course, is the growth of this structure, but you've already
>> noted that the overhead isn't all that high; seems like it could be worth
>> it.
>
> Yes.  The data structure you proposed is much easier to be used than the
> current one.  The main concern is the RAM usage.  The size of the data
> structure you proposed is about 80 bytes, while that of the current one
> is about 8 bytes.  There will be one struct swap_cluster_info for every
> 1MB swap space, so for 1TB swap space, the total size will be 80M
> compared with 8M of current implementation.

Sorry, I turned on the lockdep when measure the size change, so the
previous size change data is wrong.  The size of the data structure
you proposed is 12 bytes.  While that of the current one is 8 bytes on
64 bit platform and 4 bytes on 32 bit platform.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
