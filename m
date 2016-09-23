Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72E3B6B026E
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:12:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 21so198963990pfy.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:12:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e124si4781806pfg.102.2016.09.22.19.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 19:12:55 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160922225608.GA3898@kernel.org>
Date: Fri, 23 Sep 2016 10:12:52 +0800
In-Reply-To: <20160922225608.GA3898@kernel.org> (Shaohua Li's message of "Thu,
	22 Sep 2016 15:56:08 -0700")
Message-ID: <87lgyjuzx7.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi, Shaohua,

Thanks for comments!

Shaohua Li <shli@kernel.org> writes:

> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
>> 
>> The advantages of the THP swap support include:

Sorry for confusing.  This is the advantages of the final goal, that is,
avoid splitting/collapsing the THP during swap out/in, not the
advantages of this patchset.  This patchset is just the first step of
the final goal.  So some advantages of the final goal is not reflected
in this patchset.

>> - Batch the swap operations for the THP to reduce lock
>>   acquiring/releasing, including allocating/freeing the swap space,
>>   adding/deleting to/from the swap cache, and writing/reading the swap
>>   space, etc.  This will help improve the performance of the THP swap.
>> 
>> - The THP swap space read/write will be 2M sequential IO.  It is
>>   particularly helpful for the swap read, which usually are 4k random
>>   IO.  This will improve the performance of the THP swap too.
>
> I think this is not a problem. Even with current early split, we are allocating
> swap entry sequentially, after IO is dispatched, block layer will merge IO to
> big size.

Yes.  For swap out, the original implementation can merge IO to big size
already.  But for the THP swap out, instead of allocating one bio for
each 4k page in a THP, we can allocate one bio for each THP.  This will
avoid many useless CPU cycles to split then merge.  I think this will
help performance for the fast storage device.

>> - It will help the memory fragmentation, especially when the THP is
>>   heavily used by the applications.  The 2M continuous pages will be
>>   free up after THP swapping out.
>
> So this is impossible without THP swapin. While 2M swapout makes a lot of
> sense, I doubt 2M swapin is really useful. What kind of application is
> 'optimized' to do sequential memory access?

Although applications usually don't do much sequential memory access,
they still have space locality.  And after 2M swap in, the THP before
swapped out is kept to be a THP after swapped in.  It can be mapped into
the PMD of the application.  This will help reduce the TLB contention.

> One advantage of THP swapout is to reduce TLB flush. Eg, when we split 2m to 4k
> pages, we set swap entry for the 4k pages since your patch already allocates
> swap entry before the split, so we only do tlb flush once in the split. Without
> the delay THP split, we do twice tlb flush (split and unmap of swapout). I
> don't see this in the patches, do I misread the code?

Combining THP splitting with unmapping?  That sounds like a good idea.
It is not implemented in this patchset because I have not thought about
that before :).

In the next step of THP swap support, I will further delay THP splitting
after swapping out finished.  At that time, we will avoid calling
split_huge_page_to_list() during swapping out.  So the TLB flush only
need to be done once for unmap.

Best Regards,
Huang, Ying

> Thanks,
> Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
