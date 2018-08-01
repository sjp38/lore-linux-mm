Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA436B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:31:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r20-v6so11147776pgv.20
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:31:25 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id o8-v6si11511551pgo.2.2018.08.01.08.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 08:31:22 -0700 (PDT)
Message-ID: <5B61D243.9050608@huawei.com>
Date: Wed, 1 Aug 2018 23:31:15 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: [Question] A novel case happened when using mempool allocate memory.
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,  Everyone

 I ran across the following novel case similar to memory leak in linux-4.1 stable when allocating
 memory object by kmem_cache_alloc.   it rarely can be reproduced.

I create a specific  mempool with 24k size based on the slab.  it can not be merged with
other kmem cache.  I  record the allocation and free usage by atomic_add/sub.    After a while,
I watch the specific slab consume most of total memory.   After halting the code execution.
The counter of allocation and free is equal.  Therefore,  I am sure that module have released
all meory resource.  but the statistic of specific slab is very high but stable by checking /proc/slabinfo.

but It is strange that the specific slab will free get back all memory when unregister the module.
I got the following information from specific slab data structure when halt the module execution.


kmem_cache_node                                                          kmem_cache

nr_partial = 1,                                                             min_partial = 7
partial = {                                                                    cpu_partial = 2
        next = 0xffff7c00085cae20                             object_size = 24576
        prev = 0xffff7c00085cae20
},

nr_slabs = {
    counter = 365610
 },

total_objects = {
 counter = 365610
},

full = {
      next =  0xffff8013e44f75f0,
     prev =  0xffff8013e44f75f0
},

>From the above restricted information , we can know that the node full list is empty.  and partial list only
have a  slab.   A slab contain a object.  I think that most of slab stay in the cpu_partial
list even though it seems to be impossible theoretically.  because I come to the conclusion based on the case
that slab take up the memory will be release when unregister the moudle.

but I check the code(mm/slub.c) carefully . I can not find any clue to prove my assumption.
I will be appreciate if anyone have any idea about the case. 


Thanks
zhong jiang
