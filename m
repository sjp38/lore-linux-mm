Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 144826B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:33:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b20so28332447wma.11
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:33:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si14948107wra.196.2017.05.23.02.33.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 02:33:28 -0700 (PDT)
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com>
 <591EBE71.7080402@huawei.com>
 <alpine.LSU.2.11.1705191453040.3819@eggly.anvils>
 <591F9A09.6010707@huawei.com>
 <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
 <591FA78E.9050307@huawei.com>
 <alpine.LSU.2.11.1705191935220.11750@eggly.anvils>
 <591FB173.4020409@huawei.com> <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
 <5923FF31.5020801@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <aea91199-2b40-85fd-8c93-2d807ed726bd@suse.cz>
Date: Tue, 23 May 2017 11:33:23 +0200
MIME-Version: 1.0
In-Reply-To: <5923FF31.5020801@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/23/2017 11:21 AM, zhong jiang wrote:
> On 2017/5/23 0:51, Vlastimil Babka wrote:
>> On 05/20/2017 05:01 AM, zhong jiang wrote:
>>> On 2017/5/20 10:40, Hugh Dickins wrote:
>>>> On Sat, 20 May 2017, Xishi Qiu wrote:
>>>>> Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
>>>>> And I meet the bug too. However it is hard to reproduce, and 
>>>>> 624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.
>>>>>
>>>>> From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
>>>>> and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
>>>>> but anon_vma has been corrupted.
>>>>>
>>>>> Any ideas?
>>>> Sorry, no.  I assume that _mapcount has been misaccounted, for example
>>>> a pte mapped in on top of another pte; but cannot begin tell you where
>>>> in Red Hat's kernel-3.10.0-229.4.2.el7 that might happen.
>>>>
>>>> Hugh
>>>>
>>>> .
>>>>
>>> Hi, Hugh
>>>
>>> I find the following message from the dmesg.
>>>
>>> [26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1
>>>
>>> I can prove that the __mapcount is misaccount.  when task is exited. the rmap
>>> still exist.
>> Check if the kernel in question contains this commit: ad33bb04b2a6 ("mm:
>> thp: fix SMP race condition between THP page fault and MADV_DONTNEED")
>   HI, Vlastimil
>  
>   I miss the patch.

Try applying it then, there's good chance the error and crash will go
away. Even if your workload doesn't actually run any madvise(MADV_DONTNEED).

> when I read the patch. I find the following issue. but I am sure it is right.
> 
>       if (unlikely(pmd_trans_unstable(pmd)))
>         return 0;
>     /*
>      * A regular pmd is established and it can't morph into a huge pmd
>      * from under us anymore at this point because we hold the mmap_sem
>      * read mode and khugepaged takes it in write mode. So now it's
>      * safe to run pte_offset_map().
>      */
>     pte = pte_offset_map(pmd, address);
> 
>   after pmd_trans_unstable call,  without any protect method.  by the comments,
>   it think the pte_offset_map is safe.    before pte_offset_map call, it still may be
>   unstable. it is possible?

IIRC it's "unstable" wrt possible none->huge->none transition. But once
we've seen it's a regular pmd via pmd_trans_unstable(), we're safe as a
transition from regular pmd can't happen.

>   Thanks
> zhongjiang
>>> Thanks
>>> zhongjiang
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>> .
>>
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
