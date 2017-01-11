Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8E736B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:38:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so27437620wms.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:38:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ew8si4457093wjc.240.2017.01.11.04.38.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 04:38:34 -0800 (PST)
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
Date: Wed, 11 Jan 2017 13:38:31 +0100
MIME-Version: 1.0
In-Reply-To: <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 01/11/2017 12:05 PM, Vlastimil Babka wrote:
> On 01/11/2017 11:50 AM, Ganapatrao Kulkarni wrote:
>> Hi,
>>
>> we are seeing OOM/stalls messages when we run ltp cpuset01(cpuset01 -I
>> 360) test for few minutes, even through the numa system has adequate
>> memory on both nodes.
>>
>> this we have observed same on both arm64/thunderx numa and on x86 numa system!
>>
>> using latest ltp from master branch version 20160920-197-gbc4d3db
>> and linux kernel version 4.9
>>
>> is this known bug already?
> 
> Probably not.
> 
> Is it possible that cpuset limits the process to one node, and numa
> mempolicy to the other node?

Ah, so 4.9 has commit 82e7d3abec86 ("oom: print nodemask in the oom
report"), so such state should be visible in the oom report. Can you
post it whole instead of just the header line (i.e. the last line in
your report)? Thanks.

>> below is the oops log:
>> [ 2280.275193] cgroup: new mount options do not match the existing
>> superblock, will be ignored
>> [ 2316.565940] cgroup: new mount options do not match the existing
>> superblock, will be ignored
>> [ 2393.388361] cpuset01: page allocation stalls for 10051ms, order:0,
>> mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
>> [ 2393.388371] CPU: 9 PID: 18188 Comm: cpuset01 Not tainted 4.9.0 #1
>> [ 2393.388373] Hardware name: Dell Inc. PowerEdge T630/0W9WXC, BIOS
>> 1.0.4 08/29/2014
>> [ 2393.388374]  ffffc9000c1afba8 ffffffff813c771e ffffffff81a40be8
>> 0000000000000001
>> [ 2393.388377]  ffffc9000c1afc30 ffffffff811b8c9a 024280ca00000202
>> ffffffff81a40be8
>> [ 2393.388380]  ffffc9000c1afbd0 0000000000000010 ffffc9000c1afc40
>> ffffc9000c1afbf0
>> [ 2393.388383] Call Trace:
>> [ 2393.388392]  [<ffffffff813c771e>] dump_stack+0x63/0x85
>> [ 2393.388397]  [<ffffffff811b8c9a>] warn_alloc+0x13a/0x170
>> [ 2393.388399]  [<ffffffff811b95c4>] __alloc_pages_slowpath+0x884/0xac0
>> [ 2393.388402]  [<ffffffff811b9ac5>] __alloc_pages_nodemask+0x2c5/0x310
>> [ 2393.388405]  [<ffffffff8120f663>] alloc_pages_vma+0xb3/0x260
>> [ 2393.388410]  [<ffffffff811e0534>] ? anon_vma_interval_tree_insert+0x84/0x90
>> [ 2393.388413]  [<ffffffff811ea42c>] handle_mm_fault+0x129c/0x1550
>> [ 2393.388417]  [<ffffffff813d65bb>] ? call_rwsem_wake+0x1b/0x30
>> [ 2393.388422]  [<ffffffff8106a362>] __do_page_fault+0x222/0x4b0
>> [ 2393.388424]  [<ffffffff8106a61f>] do_page_fault+0x2f/0x80
>> [ 2393.388429]  [<ffffffff817ca588>] page_fault+0x28/0x30
>> [ 2393.388431] Mem-Info:
>> [ 2393.388437] active_anon:92316 inactive_anon:21059 isolated_anon:32
>>  active_file:202031 inactive_file:137088 isolated_file:0
>>  unevictable:16 dirty:20 writeback:5883 unstable:0
>>  slab_reclaimable:40274 slab_unreclaimable:21605
>>  mapped:26819 shmem:28393 pagetables:11375 bounce:0
>>  free:5494728 free_pcp:549 free_cma:0
>> [ 2393.388446] Node 0 active_anon:310368kB inactive_anon:25684kB
>> active_file:807836kB inactive_file:548592kB unevictable:60kB
>> isolated(anon):0kB isolated(file):0kB mapped:101672kB dirty:80kB
>> writeback:148kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>> anon_thp: 25780kB writeback_tmp:0kB unstable:0kB pages_scanned:0
>> all_unreclaimable? no
>> [ 2393.388455] Node 1 active_anon:58896kB inactive_anon:58552kB
>> active_file:288kB inactive_file:0kB unevictable:4kB
>> isolated(anon):128kB isolated(file):0kB mapped:5604kB dirty:0kB
>> writeback:23384kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>> anon_thp: 87792kB writeback_tmp:0kB unstable:0kB pages_scanned:0
>> all_unreclaimable? no
>> [ 2393.388457] Node 1 Normal free:11937124kB min:45532kB low:62044kB
>> high:78556kB active_anon:58896kB inactive_anon:58552kB
>> active_file:288kB inactive_file:0kB unevictable:4kB
>> writepending:23384kB present:16777216kB managed:16512808kB mlocked:4kB
>> slab_reclaimable:37876kB slab_unreclaimable:44812kB
>> kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:2240kB
>> local_pcp:0kB free_cma:0kB
>> [ 2393.388462] lowmem_reserve[]: 0 0 0 0
>> [ 2393.388465] Node 1 Normal: 1179*4kB (UME) 1396*8kB (UME) 1193*16kB
>> (UME) 910*32kB (UME) 721*64kB (UME) 568*128kB (UME) 444*256kB (UME)
>> 328*512kB (ME) 223*1024kB (UM) 138*2048kB (ME) 2676*4096kB (M) =
>> 11936412kB
>> [ 2393.388479] Node 0 hugepages_total=4 hugepages_free=4
>> hugepages_surp=0 hugepages_size=1048576kB
>> [ 2393.388481] Node 1 hugepages_total=4 hugepages_free=4
>> hugepages_surp=0 hugepages_size=1048576kB
>> [ 2393.388481] 374277 total pagecache pages
>> [ 2393.388483] 6667 pages in swap cache
>> [ 2393.388484] Swap cache stats: add 101786, delete 95119, find 393/682
>> [ 2393.388485] Free swap  = 15979384kB
>> [ 2393.388485] Total swap = 16383996kB
>> [ 2393.388486] 8331071 pages RAM
>> [ 2393.388486] 0 pages HighMem/MovableOnly
>> [ 2393.388487] 152036 pages reserved
>> [ 2393.388487] 0 pages hwpoisoned
>> [ 2397.331098] cpuset01 invoked oom-killer:
>> gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1,
>> order=0, oom_score_adj=0
>>
>>
>> [gkulkarni@xeon-numa ltp]$ numactl --hardware
>> available: 2 nodes (0-1)
>> node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22
>> node 0 size: 15823 MB
>> node 0 free: 10211 MB
>> node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23
>> node 1 size: 16125 MB
>> node 1 free: 11628 MB
>> node distances:
>> node   0   1
>>   0:  10  21
>>   1:  21  10
>>
>>
>> thanks
>> Ganapat
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
