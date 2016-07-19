Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1B8E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 09:52:37 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d65so43901393ith.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 06:52:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id b19si17141408oih.134.2016.07.19.06.52.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 06:52:36 -0700 (PDT)
Message-ID: <578E2FBF.2080405@huawei.com>
Date: Tue, 19 Jul 2016 21:48:47 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question]page allocation failure: order:2, mode:0x2000d1
References: <b3127e70-4fca-9e11-62e5-7a8f3da9d044@huawei.com> <5d0d3274-a893-8453-fb3d-87981dd38cfa@suse.cz>
In-Reply-To: <5d0d3274-a893-8453-fb3d-87981dd38cfa@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, minchan@kernel.org, mgorman@suse.de, iamjoonsoo.kim@lge.com, mina86@mina86.com, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, cl@linux.com, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>

On 2016/7/19 21:17, Vlastimil Babka wrote:

> On 07/19/2016 02:43 PM, Yisheng Xie wrote:
>> hi all,
>> I'm getting a 2-order page allocation failure problem on 4.1.18.
>> From the Mem-info, it seems the system have much zero order free pages which can be used for memory compaction.
>> Is it possible that the memory compacted by current process used by other process soon, which cause page allocation failure of current process ?
> 
> It's possible, but an order-2 allocation should retry compaction in such case.
> 

Hi Vlastimil,

mode:0x2000d1 means it expects to alloc from zone_dma, (on arm64 zone_dma is 0-4G)

The page cache is very small(active_file:292kB inactive_file:240kB),
so did_some_progress may be zero, and will not retry, right?

Thanks,
Xishi Qiu

>>
>> --- dmesg messages ---
>> 07-13 08:41:51.341 <4>[309805.658142s][pid:1361,cpu5,sManagerService]sManagerService: page allocation failure: order:2, mode:0x2000d1
> 
> Geez, these old kernels that can't print the mode human-readably...
> #define ___GFP_DMA              0x01
> #define ___GFP_WAIT             0x10
> #define ___GFP_IO               0x40
> #define ___GFP_FS               0x80
> #define ___GFP_NOTRACK          0x200000
> 
> Compaction indeed should be possible. And it's a non-costly allocation. It shouldn't even be allowed to fail, unless the process was killed?
> 
>> 07-13 08:41:51.346 <4>[309805.658142s][pid:1361,cpu5,sManagerService]CPU: 5 PID: 1361 Comm: sManagerService Tainted: G        W       4.1.18-g09f547b #1
> 
> There's a W taint flag so there should have been a WARN message/backtrace preceding it. What is it? It could be related.
> 
>> 07-13 08:41:51.347 <4>[309805.658142s][pid:1361,cpu5,sManagerService]TGID: 981 Comm: system_server
>> 07-13 08:41:51.347 <4>[309805.658172s][pid:1361,cpu5,sManagerService]Hardware name: hi3650 (DT)
>> 07-13 08:41:51.347 <0>[309805.658172s][pid:1361,cpu5,sManagerService]Call trace:
>> 07-13 08:41:51.347 <4>[309805.658203s][pid:1361,cpu5,sManagerService][<ffffffc00008a0a4>] dump_backtrace+0x0/0x150
>> 07-13 08:41:51.347 <4>[309805.658203s][pid:1361,cpu5,sManagerService][<ffffffc00008a214>] show_stack+0x20/0x28
>> 07-13 08:41:51.347 <4>[309805.658203s][pid:1361,cpu5,sManagerService][<ffffffc000fc4034>] dump_stack+0x84/0xa8
>> 07-13 08:41:51.347 <4>[309805.658203s][pid:1361,cpu5,sManagerService][<ffffffc00018af54>] warn_alloc_failed+0x10c/0x164
>> 07-13 08:41:51.347 <4>[309805.658233s][pid:1361,cpu5,sManagerService][<ffffffc00018e778>] __alloc_pages_nodemask+0x5b4/0x888
>> 07-13 08:41:51.347 <4>[309805.658233s][pid:1361,cpu5,sManagerService][<ffffffc00018eb84>] alloc_kmem_pages_node+0x44/0x50
>> 07-13 08:41:51.347 <4>[309805.658233s][pid:1361,cpu5,sManagerService][<ffffffc00009fa78>] copy_process.part.46+0x140/0x15ac
>> 07-13 08:41:51.347 <4>[309805.658233s][pid:1361,cpu5,sManagerService][<ffffffc0000a10a0>] do_fork+0xe8/0x444
>> 07-13 08:41:51.347 <4>[309805.658264s][pid:1361,cpu5,sManagerService][<ffffffc0000a14e8>] SyS_clone+0x3c/0x48
>> 07-13 08:41:51.347 <4>[309805.658264s][pid:1361,cpu5,sManagerService]Mem-Info:
>> 07-13 08:41:51.347 <4>[309805.658264s][pid:1361,cpu5,sManagerService]active_anon:491074 inactive_anon:118072 isolated_anon:0
>> 07-13 08:41:51.347 <4>[309805.658264s] active_file:19087 inactive_file:9843 isolated_file:0
>> 07-13 08:41:51.347 <4>[309805.658264s] unevictable:322 dirty:20 writeback:0 unstable:0
>> 07-13 08:41:51.347 <4>[309805.658264s] slab_reclaimable:11788 slab_unreclaimable:28068
>> 07-13 08:41:51.347 <4>[309805.658264s] mapped:20633 shmem:4038 pagetables:10865 bounce:72
>> 07-13 08:41:51.347 <4>[309805.658264s] free:118678 free_pcp:58 free_cma:0
>> 07-13 08:41:51.347 <4>[309805.658294s][pid:1361,cpu5,sManagerService]DMA free:470628kB min:6800kB low:29116kB high:30816kB active_anon:1868540kB inactive_anon:376100kB active_file:292kB inactive_file:240kB unevictable:1080kB isolated(anon):0kB isolated(file):0kB present:3446780kB managed:3307056kB mlocked:1080kB dirty:80kB writeback:0kB mapped:7604kB shmem:14380kB slab_reclaimable:47152kB slab_unreclaimable:112268kB kernel_stack:28224kB pagetables:43460kB unstable:0kB bounce:288kB free_pcp:204kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>> 07-13 08:41:51.347 <4>[309805.658294s][pid:1361,cpu5,sManagerService]lowmem_reserve[]: 0 415 415
>> 07-13 08:41:51.347 <4>[309805.658294s][pid:1361,cpu5,sManagerService]Normal free:4084kB min:872kB low:3740kB high:3960kB active_anon:95756kB inactive_anon:96188kB active_file:76056kB inactive_file:39132kB unevictable:208kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:425480kB mlocked:208kB dirty:0kB writeback:0kB mapped:74928kB shmem:1772kB slab_reclaimable:0kB slab_unreclaimable:4kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:28kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>> 07-13 08:41:51.347 <4>[309805.658294s][pid:1361,cpu5,sManagerService]lowmem_reserve[]: 0 0 0
>> 07-13 08:41:51.347 <4>[309805.658325s][pid:1361,cpu5,sManagerService]DMA: 68324*4kB (UEM) 24706*8kB (UER) 2*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 470976kB
> 
> Indeed compaction should be doing something with this...
> 
>> 07-13 08:41:51.347 <4>[309805.658355s][pid:1361,cpu5,sManagerService]Normal: 270*4kB (UMR) 82*8kB (UMR) 48*16kB (MR) 25*32kB (R) 12*64kB (R) 2*128kB (R) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4584kB
>> 07-13 08:41:51.347 <4>[309805.658386s][pid:1361,cpu5,sManagerService]38319 total pagecache pages
>> 07-13 08:41:51.347 <4>[309805.658386s][pid:1361,cpu5,sManagerService]5384 pages in swap cache
>> 07-13 08:41:51.347 <4>[309805.658386s][pid:1361,cpu5,sManagerService]Swap cache stats: add 628084, delete 622700, find 2187699/2264909
>> 07-13 08:41:51.347 <4>[309805.658386s][pid:1361,cpu5,sManagerService]Free swap  = 0kB
>> 07-13 08:41:51.348 <4>[309805.658416s][pid:1361,cpu5,sManagerService]Total swap = 524284kB
>> 07-13 08:41:51.348 <4>[309805.658416s][pid:1361,cpu5,sManagerService]992767 pages RAM
>> 07-13 08:41:51.348 <4>[309805.658416s][pid:1361,cpu5,sManagerService]0 pages HighMem/MovableOnly
>> 07-13 08:41:51.348 <4>[309805.658416s][pid:1361,cpu5,sManagerService]51441 pages reserved
>> 07-13 08:41:51.348 <4>[309805.658416s][pid:1361,cpu5,sManagerService]8192 pages cma reserved
>> 07-13 08:41:51.767 <6>[309806.068298s][pid:2247,cpu6,notification-sq][I/sensorhub] shb_release ok
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
