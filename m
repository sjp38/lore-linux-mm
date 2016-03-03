Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id C904E6B0256
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:14 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id rt7so12808178obb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:14 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id k194si17804726oig.27.2016.03.02.23.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:13 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id r187so9693279oih.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D79284.3030009@redhat.com>
References: <56D6F008.1050600@huawei.com>
	<56D79284.3030009@redhat.com>
Date: Thu, 3 Mar 2016 16:42:13 +0900
Message-ID: <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
Subject: Re: Suspicious error for CMA stress test
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
> (cc -mm and Joonsoo Kim)
>
>
> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>
>> Hi,
>>
>> I came across a suspicious error for CMA stress test:
>>
>> Before the test, I got:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:          195044 kB
>>
>>
>> After running the test:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:         6602584 kB
>>
>> So the freed CMA memory is more than total..
>>
>> Also the the MemFree is more than mem total:
>>
>> -bash-4.3# cat /proc/meminfo
>> MemTotal:       16342016 kB
>> MemFree:        22367268 kB
>> MemAvailable:   22370528 kB
>>
>> Here is the kernel module doing the stress test below (if the test case
>> is wrong, correct me), any help would be great appreciated.
>>
>> The test is running on ARM64 platform (hisilicon D02) with 4.4 kernel, I
>> think
>> the 4.5-rc is the same as I didn't notice the updates for it.
>>
>> int malloc_dma(void *data)
>> {
>>      void *vaddr;
>>      struct platform_device * pdev=(struct platform_device*)data;
>>      dma_addr_t dma_handle;
>>      int i;
>>
>>      for(i=0; i<1000; i++) {
>>          vaddr=dma_alloc_coherent(&pdev->dev, malloc_size, &dma_handle,
>> GFP_KERNEL);
>>          if (!vaddr)
>>              pr_err("alloc cma memory failed!\n");
>>
>>          mdelay(1);
>>
>>          if (vaddr)
>>                  dma_free_coherent(&pdev->dev,malloc_size,vaddr,
>> dma_handle);
>>      }
>>      pr_info("alloc free cma memory success return!\n");
>>      return 0;
>> }
>>
>> static int dma_alloc_coherent_init(struct platform_device *pdev)
>> {
>>      int i;
>>
>>      for(i=0; i<100; i++)   {
>>          task[i] = kthread_create(malloc_dma,pdev,"malloc_dma_%d",i);
>>          if(!task[i]) {
>>              printk("kthread_create faile %d\n",i);
>>              continue;
>>          }
>>          wake_up_process(task[i]);
>>      }
>>      return 0;
>> }
>>
>> Thanks
>> Hanjun
>>
>> The whole /proc/meminfo:
>>
>> -bash-4.3# cat /proc/meminfo
>> MemTotal:       16342016 kB
>> MemFree:        22367268 kB
>> MemAvailable:   22370528 kB
>> Buffers:            4292 kB
>> Cached:            36444 kB
>> SwapCached:            0 kB
>> Active:            23564 kB
>> Inactive:          25360 kB
>> Active(anon):       8424 kB
>> Inactive(anon):       64 kB
>> Active(file):      15140 kB
>> Inactive(file):    25296 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> SwapTotal:             0 kB
>> SwapFree:              0 kB
>> Dirty:                 0 kB
>> Writeback:             0 kB
>> AnonPages:          8196 kB
>> Mapped:            16448 kB
>> Shmem:               296 kB
>> Slab:              26832 kB
>> SReclaimable:       6300 kB
>> SUnreclaim:        20532 kB
>> KernelStack:        3088 kB
>> PageTables:          404 kB
>> NFS_Unstable:          0 kB
>> Bounce:                0 kB
>> WritebackTmp:          0 kB
>> CommitLimit:     8171008 kB
>> Committed_AS:      34336 kB
>> VmallocTotal:   258998208 kB
>> VmallocUsed:           0 kB
>> VmallocChunk:          0 kB
>> AnonHugePages:         0 kB
>> CmaTotal:         204800 kB
>> CmaFree:         6602584 kB
>> HugePages_Total:       0
>> HugePages_Free:        0
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:       2048 kB
>>
>
>
> I played with this a bit and can see the same problem. The sanity
> check of CmaFree < CmaTotal generally triggers in
> __move_zone_freepage_state in unset_migratetype_isolate.
> This also seems to be present as far back as v4.0 which was the
> first version to have the updated accounting from Joonsoo.
> Were there known limitations with the new freepage accounting,
> Joonsoo?

I don't know. I also played with this and looks like there is
accounting problem, however, for my case, number of free page is slightly less
than total. I will take a look.

Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
look like your case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
