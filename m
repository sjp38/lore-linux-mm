Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6A56B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:48:35 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p78so19886004lfd.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:48:35 -0700 (PDT)
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id 12si2196965ljb.290.2017.03.15.23.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:48:32 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox> <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox> <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
Date: Thu, 16 Mar 2017 07:38:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170302071721.GA32632@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 02.03.2017 08:17, Minchan Kim wrote:
> Hi Michal,
>
> On Tue, Feb 28, 2017 at 09:12:24AM +0100, Michal Hocko wrote:
>> On Tue 28-02-17 14:17:23, Minchan Kim wrote:
>>> On Mon, Feb 27, 2017 at 10:44:49AM +0100, Michal Hocko wrote:
>>>> On Mon 27-02-17 18:02:36, Minchan Kim wrote:
>>>> [...]
>>>>> >From 9779a1c5d32e2edb64da5cdfcd6f9737b94a247a Mon Sep 17 00:00:00 2001
>>>>> From: Minchan Kim <minchan@kernel.org>
>>>>> Date: Mon, 27 Feb 2017 17:39:06 +0900
>>>>> Subject: [PATCH] mm: use up highatomic before OOM kill
>>>>>
>>>>> Not-Yet-Signed-off-by: Minchan Kim <minchan@kernel.org>
>>>>> ---
>>>>>   mm/page_alloc.c | 14 ++++----------
>>>>>   1 file changed, 4 insertions(+), 10 deletions(-)
>>>>>
>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>> index 614cd0397ce3..e073cca4969e 100644
>>>>> --- a/mm/page_alloc.c
>>>>> +++ b/mm/page_alloc.c
>>>>> @@ -3549,16 +3549,6 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>>>>>   		*no_progress_loops = 0;
>>>>>   	else
>>>>>   		(*no_progress_loops)++;
>>>>> -
>>>>> -	/*
>>>>> -	 * Make sure we converge to OOM if we cannot make any progress
>>>>> -	 * several times in the row.
>>>>> -	 */
>>>>> -	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
>>>>> -		/* Before OOM, exhaust highatomic_reserve */
>>>>> -		return unreserve_highatomic_pageblock(ac, true);
>>>>> -	}
>>>>> -
>>>>>   	/*
>>>>>   	 * Keep reclaiming pages while there is a chance this will lead
>>>>>   	 * somewhere.  If none of the target zones can satisfy our allocation
>>>>> @@ -3821,6 +3811,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>>>   	if (read_mems_allowed_retry(cpuset_mems_cookie))
>>>>>   		goto retry_cpuset;
>>>>>   
>>>>> +	/* Before OOM, exhaust highatomic_reserve */
>>>>> +	if (unreserve_highatomic_pageblock(ac, true))
>>>>> +		goto retry;
>>>>> +
>>>> OK, this can help for higher order requests when we do not exhaust all
>>>> the retries and fail on compaction but I fail to see how can this help
>>>> for order-0 requets which was what happened in this case. I am not
>>>> saying this is wrong, though.
>>> The should_reclaim_retry can return false although no_progress_loop is less
>>> than MAX_RECLAIM_RETRIES unless eligible zones has enough reclaimable pages
>>> by the progress_loop.
>> Yes, sorry I should have been more clear. I was talking about this
>> particular case where we had a lot of reclaimable pages (a lot of
>> anonymous with the swap available).
> This reports shows two problems. Why we see OOM 1) enough *free* pages and
> 2) enough *freeable* pages.
>
> I just pointed out 1) and sent the patch to solve it.
>
> About 2), one of my imaginary scenario is inactive anon list is full of
> pinned pages so VM can unmap them successfully in shrink_page_list but fail
> to free due to increased page refcount. In that case, the page will be added
> to inactive anonymous LRU list again without activating so inactive_list_is_low
> on anonymous LRU is always false. IOW, there is no deactivation from active list.
>
> It's just my picture without no clue. ;-)

With latest kernels (4.11.0-0.rc2.git0.2.fc26.x86_64) I'm having the 
issue that swapping is active all the time after some runtime (~1day).

top - 07:30:17 up 1 day, 19:42,  1 user,  load average: 13.71, 16.98, 15.36
Tasks: 130 total,   2 running, 128 sleeping,   0 stopped, 0 zombie
%Cpu(s): 15.8 us, 33.5 sy,  0.0 ni,  3.9 id, 34.5 wa,  4.9 hi,  1.0 si,  
6.4 st
KiB Mem :   369700 total,     5484 free,   311556 used, 52660 buff/cache
KiB Swap:  2064380 total,  1187684 free,   876696 used. 20340 avail Mem

[root@smtp ~]# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- 
------cpu-----
  r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy 
id wa st
  3  1 876280   7132  16536  64840  238  226  1027   258 80   97  2  3 
83 11  1
  0  4 876140   3812  10520  64552 3676  168 11840  1100 2255 2582  7 
13  8 70  3
  0  3 875372   3628   4024  56160 5424   64 10004   476 2157 2580  2 
14  0 83  2
  0  4 875560  24056   2208  56296 9032 2180 39928  2388 4111 4549 10 
32  0 55  3
  2  2 875660   7540   5256  58220 5536 1604 48756  1864 4505 4196 12 
23  5 58  3
  0  3 875264   3664   2120  57596 2304  116 17904   560 2223 1825 15 
15  0 67  3
  0  2 875564   3800    588  57856 1340 1068 14780  1184 1390 1364 12 
10  0 77  3
  1  2 875724   3740    372  53988 3104  928 16884  1068 1560 1527  3 
12  0 83  3
  0  3 881096   3708    532  52220 4604 5872 21004  6104 2752 2259  7 
18  5 67  2

The following commit is included in that version:
commit 710531320af876192d76b2c1f68190a1df941b02
Author: Michal Hocko <mhocko@suse.com>
Date:   Wed Feb 22 15:45:58 2017 -0800

     mm, vmscan: cleanup lru size claculations

     commit fd538803731e50367b7c59ce4ad3454426a3d671 upstream.

But still OOMs:
[157048.030760] clamscan: page allocation stalls for 19405ms, order:0, 
mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
[157048.031985] clamscan cpuset=/ mems_allowed=0
[157048.031993] CPU: 1 PID: 9597 Comm: clamscan Not tainted 
4.11.0-0.rc2.git0.2.fc26.x86_64 #1
[157048.033197] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3 04/01/2014
[157048.034382] Call Trace:
[157048.035532]  dump_stack+0x63/0x84
[157048.036735]  warn_alloc+0x10c/0x1b0
[157048.037768]  __alloc_pages_slowpath+0x93d/0xe60
[157048.038873]  ? dd_dispatch_request+0x2b/0x1a0
[157048.041033]  ? get_page_from_freelist+0x122/0xbf0
[157048.042435]  __alloc_pages_nodemask+0x290/0x2b0
[157048.043662]  alloc_pages_vma+0xa0/0x2b0
[157048.044796]  __read_swap_cache_async+0x146/0x210
[157048.045841]  read_swap_cache_async+0x26/0x60
[157048.046858]  swapin_readahead+0x186/0x230
[157048.047854]  ? radix_tree_lookup_slot+0x22/0x50
[157048.049006]  ? find_get_entry+0x20/0x140
[157048.053109]  ? pagecache_get_page+0x2c/0x2e0
[157048.054179]  do_swap_page+0x276/0x7b0
[157048.055138]  __handle_mm_fault+0x6fd/0x1160
[157048.057571]  ? pick_next_task_fair+0x48c/0x560
[157048.058608]  handle_mm_fault+0xb3/0x250
[157048.059622]  __do_page_fault+0x23f/0x4c0
[157048.068926]  trace_do_page_fault+0x41/0x120
[157048.070143]  do_async_page_fault+0x51/0xa0
[157048.071254]  async_page_fault+0x28/0x30
[157048.072606] RIP: 0033:0x7f78659eb675
[157048.073858] RSP: 002b:00007ffcaba111b8 EFLAGS: 00010202
[157048.075192] RAX: 0000000000000941 RBX: 00007f785957e8d0 RCX: 
00007f784e968b48
[157048.076609] RDX: 00007f784f87bce8 RSI: 00007f7851fdb0cb RDI: 
00007f7866726000
[157048.077809] RBP: 00007f785957e910 R08: 0000000000040000 R09: 
0000000000000000
[157048.078935] R10: ffffffffffffff48 R11: 0000000000000246 R12: 
00007f78600c81c0
[157048.080028] R13: 00007f785957e970 R14: 00007f78594ffba8 R15: 
0000000003406237
[157048.081827] Mem-Info:
[157048.083005] active_anon:19902 inactive_anon:19920 isolated_anon:383
                  active_file:816 inactive_file:529 isolated_file:0
                  unevictable:0 dirty:0 writeback:19 unstable:0
                  slab_reclaimable:4225 slab_unreclaimable:6483
                  mapped:942 shmem:3 pagetables:3553 bounce:0
                  free:944 free_pcp:87 free_cma:0
[157048.089470] Node 0 active_anon:79552kB inactive_anon:79588kB 
active_file:3108kB inactive_file:2144kB unevictable:0kB 
isolated(anon):1624kB isolated(file):0kB mapped:3612kB dirty:0kB 
writeback:76kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
12kB writeback_tmp:0kB unstable:0kB pages_scanned:247 all_unreclaimable? no
[157048.092318] Node 0 DMA free:1408kB min:104kB low:128kB high:152kB 
active_anon:664kB inactive_anon:3124kB active_file:48kB 
inactive_file:40kB unevictable:0kB writepending:0kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:564kB 
slab_unreclaimable:2148kB kernel_stack:92kB pagetables:1328kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
[157048.096008] lowmem_reserve[]: 0 327 327 327 327
[157048.097234] Node 0 DMA32 free:2576kB min:2264kB low:2828kB 
high:3392kB active_anon:78844kB inactive_anon:76612kB active_file:2840kB 
inactive_file:1896kB unevictable:0kB writepending:76kB present:376688kB 
managed:353792kB mlocked:0kB slab_reclaimable:16336kB 
slab_unreclaimable:23784kB kernel_stack:2388kB pagetables:12884kB 
bounce:0kB free_pcp:644kB local_pcp:312kB free_cma:0kB
[157048.101118] lowmem_reserve[]: 0 0 0 0 0
[157048.102190] Node 0 DMA: 37*4kB (UEH) 12*8kB (H) 13*16kB (H) 10*32kB 
(H) 4*64kB (H) 3*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
1412kB
[157048.104989] Node 0 DMA32: 79*4kB (UMEH) 199*8kB (UMEH) 18*16kB (UMH) 
5*32kB (H) 2*64kB (H) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 
= 2484kB
[157048.107789] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[157048.107790] 2027 total pagecache pages
[157048.109125] 710 pages in swap cache
[157048.115088] Swap cache stats: add 36179491, delete 36179123, find 
86964755/101977142
[157048.116934] Free swap  = 808064kB
[157048.118466] Total swap = 2064380kB
[157048.122828] 98170 pages RAM
[157048.124039] 0 pages HighMem/MovableOnly
[157048.125051] 5745 pages reserved
[157048.125997] 0 pages cma reserved
[157048.127008] 0 pages hwpoisoned


Thnx.

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
