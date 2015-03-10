Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 51932900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 09:28:16 -0400 (EDT)
Received: by pdjp10 with SMTP id p10so1694991pdj.10
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 06:28:16 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id g12si1059084pat.50.2015.03.10.06.28.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 10 Mar 2015 06:28:15 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NL0008WU09L1N80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Mar 2015 13:32:09 +0000 (GMT)
Message-id: <54FEF163.6000602@partner.samsung.com>
Date: Tue, 10 Mar 2015 16:28:03 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA
 buffers to debugfs
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
 <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
 <87pp8qa1ab.fsf@linux.vnet.ibm.com>
In-reply-to: <87pp8qa1ab.fsf@linux.vnet.ibm.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hi Aneesh,

On 03/03/15 12:16, Aneesh Kumar K.V wrote:
> Stefan Strogin <s.strogin@partner.samsung.com> writes:
> 
>> When CONFIG_CMA_BUFFER_LIST is configured a file is added to debugfs:
>> /sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently allocated
>> CMA buffers for each CMA region (N stands for number of CMA region).
>>
>> Format is:
>> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)
>>
>> When CONFIG_CMA_ALLOC_STACKTRACE is configured then stack traces are saved when
>> the allocations are made. The stack traces are added to cma/cma-<N>/buffers
>> for each buffer list entry.
>>
>> Example:
>>
>> root@debian:/sys/kernel/debug/cma# cat cma-0/buffers
>> 0x2f400000 - 0x2f417000 (92 kB), allocated by pid 1 (swapper/0)
>>  [<c1142c4b>] cma_alloc+0x1bb/0x200
>>  [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
>>  [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
>>  [<c14456ce>] dmam_alloc_coherent+0xbe/0x100
>>  [<c1487312>] ahci_port_start+0xe2/0x210
>>  [<c146e0e0>] ata_host_start.part.28+0xc0/0x1a0
>>  [<c1473650>] ata_host_activate+0xd0/0x110
>>  [<c14881bf>] ahci_host_activate+0x3f/0x170
>>  [<c14854e4>] ahci_init_one+0x764/0xab0
>>  [<c12e415f>] pci_device_probe+0x6f/0xd0
>>  [<c14378a8>] driver_probe_device+0x68/0x210
>>  [<c1437b09>] __driver_attach+0x79/0x80
>>  [<c1435eef>] bus_for_each_dev+0x4f/0x80
>>  [<c143749e>] driver_attach+0x1e/0x20
>>  [<c1437197>] bus_add_driver+0x157/0x200
>>  [<c14381bd>] driver_register+0x5d/0xf0
>> <...>
> 
> A perf record -g will also give this information right ? To use this
> feature, one need to recompile the kernel anyway. So why not assume that
> user can always rerun the test with perf record -g and find the cma
> allocation point stack trace ?
> 
> -aneesh
> 

Excuse me for the delay.
I thought that 'perf record <command>' gathers data only for a command
that it runs, does it? But we want to have information about all the
allocations and releases from the boot time. IMHO it would be more
reasonable to use ftrace for that. But after all the patch enables to
see not a history of allocations and deallocations but a current state
of CMA region.
As to recompilation, for example in our division this feature is enabled
by default among other CONFIG_*_DEBUG features in debug versions of kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
