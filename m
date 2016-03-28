Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 301476B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 07:14:53 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 127so19686186wmu.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 04:14:53 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id jf9si27989385wjb.86.2016.03.28.04.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 04:14:51 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id 191so11738762wmq.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 04:14:51 -0700 (PDT)
Subject: Re: memory fragmentation issues on 4.4
References: <56F8F5DA.6040206@kyup.com> <56F90D94.9000604@I-love.SAKURA.ne.jp>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56F91229.8050704@kyup.com>
Date: Mon, 28 Mar 2016 14:14:49 +0300
MIME-Version: 1.0
In-Reply-To: <56F90D94.9000604@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Linux MM <linux-mm@kvack.org>, vbabka@suse.cz, mgorman@techsingularity.net



On 03/28/2016 01:55 PM, Tetsuo Handa wrote:
> On 2016/03/28 18:14, Nikolay Borisov wrote:
>> Hello,
>>
>> On kernel 4.4 I observe that the memory gets really fragmented fairly
>> quickly. E.g. there are no order  > 4 pages even after 2 days of uptime.
>> This leads to certain data structures on XFS (in my case order 4/order 5
>> allocations)  not being allocated and causes the server to stall. When
>> this happens either someone has to log on the server and manually invoke
>> the memory compaction or plain reboot the server. Before that the server
>> was running with the exact same workload but with 3.12.52 kernel and no
>> such issue were observed. That is - memory was fragmented but allocation
>> didn't fail, maybe alloc_pages_direct_compact was doing a better job?
> 
> I'm not a mm person. But currently the page allocator does not give up
> unless there is no reclaimable zones. That would be the reason the allocation
> did not fail but caused the system to stall. It is interesting for mm people
> if you can try, apart from your fragmentation issue, running linux-next kernel
> which includes OOM detection rework ( https://lwn.net/Articles/667939/ ).

I don't think that this would have helped since the machine didn't run
out of memory rather memory was so fragmented that an order 5 allocation
could not be satisfied. Which I think means no OOM logic would have been
triggered.

Actually the allocation did fail but was infinitely retried by merit of
the logic in kmem_alloc. So in this case kmalloc was returning a NULL-ptr.


> 
>>
>> FYI the allocation is performed with GFP_KERNEL | GFP_NOFS
> 
> Excuse me, but GFP_KERNEL is GFP_NOFS | __GFP_FS, and therefore
> GFP_KERNEL | GFP_NOFS is GFP_KERNEL. What did you mean?

Right, so it's : (GFP_KERNEL | __GFP_NOWARN) &= ~__GFP_FS

> 
>>
>>
>> Manual compaction usually does the job, however I'm wondering why isn't
>> invoking __alloc_pages_direct_compact from within __alloc_pages_nodemask
>> satisfying the request if manual compaction would do the job. Is there a
>> difference in the efficiency of manually invoking memory compaction and
>> the one invoked from the page allocator path?
>>
>>
>> Another question for my own satisfaction - I created a kernel module
>> which allocate pages of very high order - 8/9) then later when those
>> pages are returned I see the number of unmovable pages increase by the
>> amount of pages returned. So should freed pages go to the unmovable
>> category?
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
