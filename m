Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 834526B0009
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 13:50:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q22so5370744pfh.20
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 10:50:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f19sor235981pfn.18.2018.04.09.10.50.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 10:50:15 -0700 (PDT)
Subject: Re: Free swap negative?
References: <4a181da3-8ce4-dc3c-60de-e6ad6f2a296a@redhat.com>
 <alpine.LSU.2.11.1804081132360.1977@eggly.anvils>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b0d8b880-b4f2-47b9-d32e-2b5100978831@redhat.com>
Date: Mon, 9 Apr 2018 10:50:10 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1804081132360.1977@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-MM <linux-mm@kvack.org>

On 04/08/2018 11:53 AM, Hugh Dickins wrote:
> On Tue, 27 Mar 2018, Laura Abbott wrote:
> 
>> Hi,
>>
>> Fedora got a bug report of an OOM which listed a negative number of swap
>> pages on 4.16-rc4
>>
>> [ 2201.781891] localhost-live kernel: Free swap  = -245804kB
>> [ 2201.781892] localhost-live kernel: Total swap = 0kB
>> [ 2201.781894] localhost-live kernel: 458615 pages RAM
>>
>> The setup itself was unusual, virt with 1792M RAM + 2G swap.
>> This apparently used to work but the test case was installation
>> media which is a bit painful to bisect. Full oom output is below:
>>
>>   anaconda invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE),
>> nodemask=(null), order=0, oom_score_adj=0
>>   anaconda cpuset=/ mems_allowed=0
>>   CPU: 1 PID: 4928 Comm: anaconda Not tainted 4.16.0-0.rc4.git0.1.fc28.x86_64
>> #1
>>   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-2.fc27
>> 04/01/2014
>>   Call Trace:
>>    dump_stack+0x5c/0x85
>>    dump_header+0x6e/0x275
>>    oom_kill_process.cold.28+0xb/0x3c9
>>    oom_badness+0xe1/0x160
>>    ? out_of_memory+0x1ca/0x4c0
>>    ? __alloc_pages_slowpath+0xca5/0xd80
>>    ? __alloc_pages_nodemask+0x28e/0x2b0
>>    ? alloc_pages_vma+0x74/0x1e0
>>    ? __read_swap_cache_async+0x14c/0x220
>>    ? read_swap_cache_async+0x28/0x60
>>    ? try_to_unuse+0x135/0x760
>>    ? swapcache_free_entries+0x11d/0x180
>>    ? drain_slots_cache_cpu.constprop.1+0x8a/0xd0
>>    ? SyS_swapoff+0x1d6/0x6b0
>>    ? do_syscall_64+0x74/0x180
>>    ? entry_SYSCALL_64_after_hwframe+0x3d/0xa2
>>   Mem-Info:
>>   active_anon:98024 inactive_anon:167006 isolated_anon:0
>>              active_file:138 inactive_file:226 isolated_file:0
>>              unevictable:118208 dirty:0 writeback:0 unstable:0
>>              slab_reclaimable:7506 slab_unreclaimable:18839
>>              mapped:1889 shmem:2744 pagetables:10605 bounce:0
>>              free:12856 free_pcp:235 free_cma:0
>>   Node 0 active_anon:392096kB inactive_anon:668024kB active_file:552kB
>> inactive_file:904kB unevictable:472832kB isolated(anon):0kB
>> isolated(file):0kB mapped:7556kB dirty:0kB writeback:0kB shmem:10976kB
>> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB
>> unstable:0kB all_unreclaimable? no
>>   Node 0 DMA free:7088kB min:412kB low:512kB high:612kB active_anon:2428kB
>> inactive_anon:3120kB active_file:0kB inactive_file:0kB unevictable:2428kB
>> writepending:0kB present:15992kB managed:15908kB mlocked:0kB kernel_stack:0kB
>> pagetables:40kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>>   lowmem_reserve[]: 0 1670 1670 1670 1670
>>   Node 0 DMA32 free:44336kB min:44640kB low:55800kB high:66960kB
>> active_anon:389668kB inactive_anon:664904kB active_file:552kB
>> inactive_file:984kB unevictable:470404kB writepending:0kB present:1818468kB
>> managed:1766292kB mlocked:16kB kernel_stack:7840kB pagetables:42380kB
>> bounce:0kB free_pcp:940kB local_pcp:736kB free_cma:0kB
>>   lowmem_reserve[]: 0 0 0 0 0
>>   Node 0 DMA: 6*4kB (UME) 19*8kB (UME) 12*16kB (UE) 4*32kB (UE) 29*64kB (ME)
>> 11*128kB (UME) 3*256kB (ME) 3*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB =
>> 7088kB
>>   Node 0 DMA32: 986*4kB (UMEH) 815*8kB (UMEH) 359*16kB (UMEH) 113*32kB (UMEH)
>> 229*64kB (UMEH) 51*128kB (UMEH) 7*256kB (UMEH) 3*512kB (ME) 0*1024kB 0*2048kB
>> 0*4096kB = 44336kB
>>   Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
>> hugepages_size=2048kB
>>   122508 total pagecache pages
>>   1176 pages in swap cache
>>   Swap cache stats: add 222119, delete 220943, find 18522/25378
>>   Free swap  = -245804kB
>>   Total swap = 0kB
>>   458615 pages RAM
>>   0 pages HighMem/MovableOnly
>>   13065 pages reserved
>>   0 pages cma reserved
>>   0 pages hwpoisoned
>>
>> Any suggestions?
> 
> Negative "Free swap" is entirely normal in such output, while swapoff
> is in progress: and the stale address "? try_to_unuse+0x135/0x760" in
> the backtrace implies that swapoff is in progress.
> 
> swapoff subtracts total size first, then as swap is freed the number
> goes back up to 0.  /proc/meminfo hides that negativity as 0, but in
> a low-level message like this, we prefer to see the unmassaged info.
> 
> Mind you, swapoff uses set_current_oom_origin() to volunteer to be
> the first thing killed when OOM comes into play.  Perhaps it's already
> marked to be killed, but too busy in its loop looking for swap entries,
> to have noticed the kill yet.
> 
> Hugh
> 

Thanks for the explanation. I think this is now a question for
the application about why swap off was even being called.

Thanks,
Laura
