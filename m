Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 011318E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 16:01:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a23-v6so8858113pfo.23
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 13:01:20 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id n7-v6si15985142plk.204.2018.09.17.13.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 13:01:19 -0700 (PDT)
Subject: Re: [RFC v10 PATCH 0/3] mm: zap pages with read mmap_sem in munmap
 for large mapping
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180915101042.GD31572@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d00aea15-cf08-1980-dcdf-bf24334e6848@linux.alibaba.com>
Date: Mon, 17 Sep 2018 13:00:58 -0700
MIME-Version: 1.0
In-Reply-To: <20180915101042.GD31572@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/15/18 3:10 AM, Matthew Wilcox wrote:
> On Sat, Sep 15, 2018 at 04:34:56AM +0800, Yang Shi wrote:
>> Regression and performance data:
>> Did the below regression test with setting thresh to 4K manually in the code:
>>    * Full LTP
>>    * Trinity (munmap/all vm syscalls)
>>    * Stress-ng: mmap/mmapfork/mmapfixed/mmapaddr/mmapmany/vm
>>    * mm-tests: kernbench, phpbench, sysbench-mariadb, will-it-scale
>>    * vm-scalability
>>
>> With the patches, exclusive mmap_sem hold time when munmap a 80GB address
>> space on a machine with 32 cores of E5-2680 @ 2.70GHz dropped to us level
>> from second.
>>
>> munmap_test-15002 [008]   594.380138: funcgraph_entry: |  __vm_munmap {
>> munmap_test-15002 [008]   594.380146: funcgraph_entry:      !2485684 us |    unmap_region();
>> munmap_test-15002 [008]   596.865836: funcgraph_exit:       !2485692 us |  }
>>
>> Here the excution time of unmap_region() is used to evaluate the time of
>> holding read mmap_sem, then the remaining time is used with holding
>> exclusive lock.
> Something I've been wondering about for a while is whether we should "sort"
> the readers together.  ie if the acquirers look like this:
>
> A write
> B read
> C read
> D write
> E read
> F read
> G write
>
> then we should grant the lock to A, BCEF, D, G rather than A, BC, D, EF, G.

I'm not sure how much this can help to the real world workload.

Typically, there are multi threads to contend for one mmap_sem. So, they 
are trying to read/write the same address space. There might be 
dependency or synchronization among them. Sorting read together might 
break the dependency?

Thanks,
Yang

> A quick way to test this is in __rwsem_down_read_failed_common do
> something like:
>
> -	if (list_empty(&sem->wait_list))
> +	if (list_empty(&sem->wait_list)) {
>   		adjustment += RWSEM_WAITING_BIAS;
> +		list_add(&waiter.list, &sem->wait_list);
> +	} else {
> +		struct rwsem_waiter *first = list_first_entry(&sem->wait_list,
> +						struct rwsem_waiter, list);
> +		if (first.type == RWSEM_WAITING_FOR_READ)
> +			list_add(&waiter.list, &sem->wait_list);
> +		else
> +			list_add_tail(&waiter.list, &sem->wait_list);
> +	}
> -	list_add_tail(&waiter.list, &sem->wait_list);
>
> It'd be interesting to know if this makes any difference with your tests.
>
> (this isn't perfect, of course; it'll fail to sort readers together if there's
> a writer at the head of the queue; eg:
>
> A write
> B write
> C read
> D write
> E read
> F write
> G read
>
> but it won't do any worse than we have at the moment).
