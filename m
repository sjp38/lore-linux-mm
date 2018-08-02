Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 024DA6B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 02:22:13 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v205-v6so1019057oie.20
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 23:22:12 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id d187-v6si767208oib.199.2018.08.01.23.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 23:22:11 -0700 (PDT)
Message-ID: <5B62A30B.9000008@huawei.com>
Date: Thu, 2 Aug 2018 14:22:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question] A novel case happened when using mempool allocate
 memory.
References: <5B61D243.9050608@huawei.com> <20180801153713.GA4039@bombadil.infradead.org>
In-Reply-To: <20180801153713.GA4039@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Linux Memory
 Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/8/1 23:37, Matthew Wilcox wrote:
> On Wed, Aug 01, 2018 at 11:31:15PM +0800, zhong jiang wrote:
>> Hi,  Everyone
>>
>>  I ran across the following novel case similar to memory leak in linux-4.1 stable when allocating
>>  memory object by kmem_cache_alloc.   it rarely can be reproduced.
>>
>> I create a specific  mempool with 24k size based on the slab.  it can not be merged with
>> other kmem cache.  I  record the allocation and free usage by atomic_add/sub.    After a while,
>> I watch the specific slab consume most of total memory.   After halting the code execution.
>> The counter of allocation and free is equal.  Therefore,  I am sure that module have released
>> all meory resource.  but the statistic of specific slab is very high but stable by checking /proc/slabinfo.
> Please post the code.
>
> .
>

when module is loaded. we create the specific mempool. The code flow is as follows.

mem_pool_create() {

slab_cache = kmem_cache_create(name, item_size, 0, 0 , NULL);

mempoll_create(min_pool_size, mempool_alloc_slab, mempool_free_slab, slab_cache);   //min_pool_size is assigned to 1024
atomic_set(pool->statistics, 0);
}

we allocate memory from specific mempool , The code flow is as follows.

mem_alloc() {
mempool_alloc(pool, gfp_flags);

atomic_inc(pool->statistics);
}

we release memory to specific mempool . The code flow is as follows.
mem_free() {
mempool_free(object_ptr, pool);

atomic_dec(pool->statistics);
}


when we unregister the module,  the memory has been taken up will get back the system.
the code flow is as follows.

mem_pool_destroy() {
 mempool_destroy(pool);
kmem_cache_destroy(slab_cache);
}

>From the above information.  I assume the specific kmem_cache will not take up overmuch memory
when halting the execution and pool->statistics is equal to 0.

I have no idea about the issue. 

Thanks
zhong jiang
