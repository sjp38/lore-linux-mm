Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45FD0280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 22:24:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u187so72494002pgb.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:24:25 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id a90si9891915plc.67.2017.05.19.19.24.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 19:24:24 -0700 (PDT)
Message-ID: <591FA78E.9050307@huawei.com>
Date: Sat, 20 May 2017 10:18:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1705191852360.11060@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/20 10:02, Hugh Dickins wrote:

> On Sat, 20 May 2017, Xishi Qiu wrote:
>> On 2017/5/20 6:00, Hugh Dickins wrote:
>>>
>>> You're ignoring the rcu_read_lock() on entry to page_lock_anon_vma_read(),
>>> and the SLAB_DESTROY_BY_RCU (recently renamed SLAB_TYPESAFE_BY_RCU) nature
>>> of the anon_vma_cachep kmem cache.  It is not safe to muck with anon_vma->
>>> root in anon_vma_free(), others could still be looking at it.
>>>
>>> Hugh
>>>
>>
>> Hi Hugh,
>>
>> Thanks for your reply.
>>
>> SLAB_DESTROY_BY_RCU will let it call call_rcu() in free_slab(), but if the
>> anon_vma *reuse* by someone again, access root_anon_vma is not safe, right?
> 
> That is safe, on reuse it is still a struct anon_vma; then the test for
> !page_mapped(page) will show that it's no longer a reliable anon_vma for
> this page, so page_lock_anon_vma_read() returns NULL.
> 
> But of course, if page->_mapcount has been corrupted or misaccounted,
> it may think page_mapped(page) when actually page is not mapped,
> and the anon_vma is not good for it.
> 

Hi Hugh,

Here is a bug report form redhat: https://bugzilla.redhat.com/show_bug.cgi?id=1305620
And I meet the bug too. However it is hard to reproduce, and 
624483f3ea82598("mm: rmap: fix use-after-free in __put_anon_vma") is not help.

>From the vmcore, it seems that the page is still mapped(_mapcount=0 and _count=2),
and the value of mapping is a valid address(mapping = 0xffff8801b3e2a101),
but anon_vma has been corrupted.

Any ideas?

Thanks,
Xishi Qiu

>>
>> e.g. if I clean the root pointer before free it, then access root_anon_vma
>> in page_lock_anon_vma_read() is NULL pointer access, right?
> 
> Yes, cleaning root pointer before free may result in NULL pointer access.
> 
> Hugh
> 
>>
>> anon_vma_free()
>> 	...
>> 	anon_vma->root = NULL;
>> 	kmem_cache_free(anon_vma_cachep, anon_vma);
>> 	...
>>
>> Thanks,
>> Xishi Qiu
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
