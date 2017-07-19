Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 028B36B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 21:47:53 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c14so39436067pgn.11
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 18:47:52 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id q7si2940279pgc.397.2017.07.18.18.47.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Jul 2017 18:47:51 -0700 (PDT)
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
Date: Wed, 19 Jul 2017 09:46:10 +0800
MIME-Version: 1.0
In-Reply-To: <20170718153816.GA3135@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal
 Hocko <mhocko@kernel.org>

On 2017/7/18 23:38, Jerome Glisse wrote:
> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>> On 2017/7/14 5:15, Jerome Glisse wrote:
>>> Sorry i made horrible mistake on names in v4, i completly miss-
>>> understood the suggestion. So here i repost with proper naming.
>>> This is the only change since v3. Again sorry about the noise
>>> with v4.
>>>
>>> Changes since v4:
>>>   - s/DEVICE_HOST/DEVICE_PUBLIC
>>>
>>> Git tree:
>>> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5
>>>
>>>
>>> Cache coherent device memory apply to architecture with system bus
>>> like CAPI or CCIX. Device connected to such system bus can expose
>>> their memory to the system and allow cache coherent access to it
>>> from the CPU.
>>>
>>> Even if for all intent and purposes device memory behave like regular
>>> memory, we still want to manage it in isolation from regular memory.
>>> Several reasons for that, first and foremost this memory is less
>>> reliable than regular memory if the device hangs because of invalid
>>> commands we can loose access to device memory. Second CPU access to
>>> this memory is expected to be slower than to regular memory. Third
>>> having random memory into device means that some of the bus bandwith
>>> wouldn't be available to the device but would be use by CPU access.
>>>
>>> This is why we want to manage such memory in isolation from regular
>>> memory. Kernel should not try to use this memory even as last resort
>>> when running out of memory, at least for now.
>>>
>>
>> I think set a very large node distance for "Cache Coherent Device Memory"
>> may be a easier way to address these concerns.
> 
> Such approach was discuss at length in the past see links below. Outcome
> of discussion:
>   - CPU less node are bad
>   - device memory can be unreliable (device hang) no way for application
>     to understand that

Device memory can also be more reliable if using high quality and expensive memory.

>   - application and driver NUMA madvise/mbind/mempolicy ... can conflict
>     with each other and no way the kernel can figure out which should
>     apply
>   - NUMA as it is now would not work as we need further isolation that
>     what a large node distance would provide
> 

Agree, that's where we need spend time on.

One drawback of HMM-CDM I'm worry about is one more extra copy.
In the cache coherent case, CPU can write data to device memory directly then start fpga/GPU/other accelerators.

Thanks,
Bob Liu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
