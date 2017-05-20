Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6F04280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 21:28:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id c1so3222508lfe.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 18:28:25 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id d14si3467645lfb.397.2017.05.19.18.28.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 18:28:24 -0700 (PDT)
Message-ID: <591F9A09.6010707@huawei.com>
Date: Sat, 20 May 2017 09:21:13 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1705191453040.3819@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel
 Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On 2017/5/20 6:00, Hugh Dickins wrote:

> On Fri, 19 May 2017, Xishi Qiu wrote:
>> On 2017/5/19 16:52, Xishi Qiu wrote:
>>> On 2017/5/18 17:46, Xishi Qiu wrote:
>>>
>>>> Hi, my system triggers this bug, and the vmcore shows the anon_vma seems be freed.
>>>> The kernel is RHEL 7.2, and the bug is hard to reproduce, so I don't know if it
>>>> exists in mainline, any reply is welcome!
>>>>
>>>
>>> When we alloc anon_vma, we will init the value of anon_vma->root,
>>> so can we set anon_vma->root to NULL when calling
>>> anon_vma_free -> kmem_cache_free(anon_vma_cachep, anon_vma);
>>>
>>> anon_vma_free()
>>> 	...
>>> 	anon_vma->root = NULL;
>>> 	kmem_cache_free(anon_vma_cachep, anon_vma);
>>>
>>> I find if we do this above, system boot failed, why?
>>>
>>
>> If anon_vma was freed, we should not to access the root_anon_vma, because it maybe also
>> freed(e.g. anon_vma == root_anon_vma), right?
>>
>> page_lock_anon_vma_read()
>> 	...
>> 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>> 	root_anon_vma = ACCESS_ONCE(anon_vma->root);
>> 	if (down_read_trylock(&root_anon_vma->rwsem)) {  // it's not safe
>> 	...
>> 	if (!atomic_inc_not_zero(&anon_vma->refcount)) {  // check anon_vma was not freed
>> 	...
>> 	anon_vma_lock_read(anon_vma);  // it's safe
>> 	...
> 
> You're ignoring the rcu_read_lock() on entry to page_lock_anon_vma_read(),
> and the SLAB_DESTROY_BY_RCU (recently renamed SLAB_TYPESAFE_BY_RCU) nature
> of the anon_vma_cachep kmem cache.  It is not safe to muck with anon_vma->
> root in anon_vma_free(), others could still be looking at it.
> 
> Hugh
> 

Hi Hugh,

Thanks for your reply.

SLAB_DESTROY_BY_RCU will let it call call_rcu() in free_slab(), but if the
anon_vma *reuse* by someone again, access root_anon_vma is not safe, right?

e.g. if I clean the root pointer before free it, then access root_anon_vma
in page_lock_anon_vma_read() is NULL pointer access, right?

anon_vma_free()
	...
	anon_vma->root = NULL;
	kmem_cache_free(anon_vma_cachep, anon_vma);
	...

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
