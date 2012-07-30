Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 89E6D6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 10:13:32 -0400 (EDT)
Date: Mon, 30 Jul 2012 16:13:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: page allocation failure
Message-ID: <20120730141329.GC9981@tiehlicka.suse.cz>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B900@HKMAIL02.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B900@HKMAIL02.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi@firstfloor.org" <andi@firstfloor.org>

On Mon 30-07-12 21:25:40, Shawn Joo wrote:
> Dear experts,
> 
> I have question about memory allocation failure on kernel 3.1. (simply
> it seems there is available free memory, however "page allocation
> failure" happened)
>
> While big data transfer, there is page allocation failure (please
> check attached log) It happens on __alloc_skb().  Inside function, it
> allocates memory from "skbuff_head_cache" and "size-xxxxxxx" caches.
>
> Here is my understanding, please correct me and advise.  From the
> kernel log, it failed when it tried to get 2^3*4K(=32KB) memory. (e.g.
> swapper: page allocation failure: order:3, mode:0x20)

You are actually short on free memory (7M out of 700M). Although you
have some order-3 pages the Normal zone is not balanced for that order
most probably (see __zone_watermark_ok). Your allocation is GFP_ATOMIC
and that's why the process cannot sleep and wait for reclaim to free
enough pages to satisfy this allocation.

> From slabinfo, upper size-32768 does not have available slab, however
> buddy still has available memory. so when 32KB(order:3) was required,
> slab(size-32768) should request memory from buddy. e.g. "2" will be
> decreased to "1" on buddyinfo and "size-32768" cache will get 32K
> memory from buddy.  So I can not understand why page alloc failure
> happened even if there are many available memory on buddy.  Please
> advise on it.
>
> Here is dump info(page_allocation_failure_last_dump.txt), right after
> issue happens.
> (FYI at alloc failure, order:3)
> cat /proc/buddyinfo
> Node 0, zone   Normal    949      0      0      2      3      3      0      0      1      1      0
> 
> root@android:/sdcard/modem_CoreDump # cat /proc/meminfo
> cat /proc/meminfo
> MemTotal:         747864 kB
> MemFree:            7000 kB
> Buffers:            5596 kB
> Cached:           361884 kB
> SwapCached:            0 kB
> Active:           147068 kB
> Inactive:         333448 kB
> Active(anon):     113212 kB
> Inactive(anon):      296 kB
> Active(file):      33856 kB
> Inactive(file):   333152 kB
> Unevictable:          96 kB
> Mlocked:               0 kB
> HighTotal:             0 kB
> HighFree:              0 kB
> LowTotal:         747864 kB
> LowFree:            7000 kB
> SwapTotal:             0 kB
> SwapFree:              0 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:        113172 kB
> Mapped:            44288 kB
> Shmem:               376 kB
> Slab:              15280 kB
> SReclaimable:       7976 kB
> SUnreclaim:         7304 kB
> KernelStack:        3712 kB
> PageTables:         5628 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      373932 kB
> Committed_AS:    2894244 kB
> VmallocTotal:     131072 kB
> VmallocUsed:       39136 kB
> VmallocChunk:      76676 kB
> DirectMap4k:      399364 kB
> DirectMap2M:      370688 kB
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
