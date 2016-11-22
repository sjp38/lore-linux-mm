Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2E816B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:35:41 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so10171242wme.4
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:35:41 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 79si2829582wmy.132.2016.11.22.06.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:35:40 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id a197so28450001wmd.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:35:40 -0800 (PST)
Subject: Re: Softlockup during memory allocation
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
 <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
 <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
 <20161121053154.GA29816@dhcp22.suse.cz>
 <ab42c7a5-49e2-4e46-be60-e0a56704a11d@kyup.com>
 <20161122143056.GB6831@dhcp22.suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <6c33f44b-327c-d943-73da-5935136a83c9@kyup.com>
Date: Tue, 22 Nov 2016 16:35:38 +0200
MIME-Version: 1.0
In-Reply-To: <20161122143056.GB6831@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>



On 11/22/2016 04:30 PM, Michal Hocko wrote:
> On Tue 22-11-16 10:56:51, Nikolay Borisov wrote:
>>
>>
>> On 11/21/2016 07:31 AM, Michal Hocko wrote:
>>> Hi,
>>> I am sorry for a late response, but I was offline until this weekend. I
>>> will try to get to this email ASAP but it might take some time.
>>
>> No worries. I did some further digging up and here is what I got, which
>> I believe is rather strange:
>>
>> struct scan_control {
>>   nr_to_reclaim = 32,
>>   gfp_mask = 37880010,
>>   order = 0,
>>   nodemask = 0x0,
>>   target_mem_cgroup = 0xffff8823990d1400,
>>   priority = 7,
>>   may_writepage = 1,
>>   may_unmap = 1,
>>   may_swap = 0,
>>   may_thrash = 1,
>>   hibernation_mode = 0,
>>   compaction_ready = 0,
>>   nr_scanned = 0,
>>   nr_reclaimed = 0
>> }
>>
>> Parsing: 37880010
>> #define ___GFP_HIGHMEM		0x02
>> #define ___GFP_MOVABLE		0x08
>> #define ___GFP_IO		0x40
>> #define ___GFP_FS		0x80
>> #define ___GFP_HARDWALL		0x20000
>> #define ___GFP_DIRECT_RECLAIM	0x400000
>> #define ___GFP_KSWAPD_RECLAIM	0x2000000
>>
>> And initial_priority is 12 (DEF_PRIORITY). Given that nr_scanned is 0
>> and priority is 7 this means we've gone 5 times through the do {} while
>> in do_try_to_free_pages. Also total_scanned seems to be 0.  Here is the
>> zone which was being reclaimed :

This is also very strange that total_scanned is 0.


>>
>> http://sprunge.us/hQBi
> 
> LRUs on that zones seem to be empty from a quick glance. kmem -z in the
> crash can give you per zone counters much more nicely.
> 

So here are the populated zones:

NODE: 0  ZONE: 0  ADDR: ffff88207fffc000  NAME: "DMA"
  SIZE: 4095  PRESENT: 3994  MIN/LOW/HIGH: 2/2/3
  VM_STAT:
                NR_FREE_PAGES: 3626
               NR_ALLOC_BATCH: 1
             NR_INACTIVE_ANON: 0
               NR_ACTIVE_ANON: 0
             NR_INACTIVE_FILE: 0
               NR_ACTIVE_FILE: 0
               NR_UNEVICTABLE: 0
                     NR_MLOCK: 0
                NR_ANON_PAGES: 0
               NR_FILE_MAPPED: 0
                NR_FILE_PAGES: 0
                NR_FILE_DIRTY: 0
                 NR_WRITEBACK: 0
          NR_SLAB_RECLAIMABLE: 0
        NR_SLAB_UNRECLAIMABLE: 0
                 NR_PAGETABLE: 0
              NR_KERNEL_STACK: 0
              NR_UNSTABLE_NFS: 0
                    NR_BOUNCE: 0
              NR_VMSCAN_WRITE: 0
          NR_VMSCAN_IMMEDIATE: 0
            NR_WRITEBACK_TEMP: 0
             NR_ISOLATED_ANON: 0
             NR_ISOLATED_FILE: 0
                     NR_SHMEM: 0
                   NR_DIRTIED: 0
                   NR_WRITTEN: 0
             NR_PAGES_SCANNED: 0
                     NUMA_HIT: 298251
                    NUMA_MISS: 0
                 NUMA_FOREIGN: 0
          NUMA_INTERLEAVE_HIT: 0
                   NUMA_LOCAL: 264611
                   NUMA_OTHER: 33640
           WORKINGSET_REFAULT: 0
          WORKINGSET_ACTIVATE: 0
       WORKINGSET_NODERECLAIM: 0
NR_ANON_TRANSPARENT_HUGEPAGES: 0
            NR_FREE_CMA_PAGES: 0


NODE: 0  ZONE: 1  ADDR: ffff88207fffc780  NAME: "DMA32"
  SIZE: 1044480  PRESENT: 492819  MIN/LOW/HIGH: 275/343/412
  VM_STAT:
                NR_FREE_PAGES: 127277
               NR_ALLOC_BATCH: 69
             NR_INACTIVE_ANON: 104061
               NR_ACTIVE_ANON: 40297
             NR_INACTIVE_FILE: 19114
               NR_ACTIVE_FILE: 24517
               NR_UNEVICTABLE: 1027
                     NR_MLOCK: 1231
                NR_ANON_PAGES: 141688
               NR_FILE_MAPPED: 4619
                NR_FILE_PAGES: 47327
                NR_FILE_DIRTY: 1
                 NR_WRITEBACK: 0
          NR_SLAB_RECLAIMABLE: 77185
        NR_SLAB_UNRECLAIMABLE: 5064
                 NR_PAGETABLE: 2051
              NR_KERNEL_STACK: 236
              NR_UNSTABLE_NFS: 0
                    NR_BOUNCE: 0
              NR_VMSCAN_WRITE: 347044
          NR_VMSCAN_IMMEDIATE: 289451163
            NR_WRITEBACK_TEMP: 0
             NR_ISOLATED_ANON: 0
             NR_ISOLATED_FILE: 0
                     NR_SHMEM: 3062
                   NR_DIRTIED: 76625942
                   NR_WRITTEN: 63608865
             NR_PAGES_SCANNED: -9
                     NUMA_HIT: 11857097869
                    NUMA_MISS: 2808023
                 NUMA_FOREIGN: 0
          NUMA_INTERLEAVE_HIT: 0
                   NUMA_LOCAL: 11856373836
                   NUMA_OTHER: 3532056
           WORKINGSET_REFAULT: 107056373
          WORKINGSET_ACTIVATE: 88346956
       WORKINGSET_NODERECLAIM: 27254
NR_ANON_TRANSPARENT_HUGEPAGES: 10
            NR_FREE_CMA_PAGES: 0


NODE: 0  ZONE: 2  ADDR: ffff88207fffcf00  NAME: "Normal"
  SIZE: 33030144  MIN/LOW/HIGH: 22209/27761/33313
  VM_STAT:
                NR_FREE_PAGES: 62436
               NR_ALLOC_BATCH: 2024
             NR_INACTIVE_ANON: 8177867
               NR_ACTIVE_ANON: 5407176
             NR_INACTIVE_FILE: 5804642
               NR_ACTIVE_FILE: 9694170
               NR_UNEVICTABLE: 50013
                     NR_MLOCK: 59860
                NR_ANON_PAGES: 13276046
               NR_FILE_MAPPED: 969231
                NR_FILE_PAGES: 15858085
                NR_FILE_DIRTY: 683
                 NR_WRITEBACK: 530
          NR_SLAB_RECLAIMABLE: 2688882
        NR_SLAB_UNRECLAIMABLE: 255070
                 NR_PAGETABLE: 182007
              NR_KERNEL_STACK: 8419
              NR_UNSTABLE_NFS: 0
                    NR_BOUNCE: 0
              NR_VMSCAN_WRITE: 1129513
          NR_VMSCAN_IMMEDIATE: 39497899
            NR_WRITEBACK_TEMP: 0
             NR_ISOLATED_ANON: 0
             NR_ISOLATED_FILE: 462
                     NR_SHMEM: 331386
                   NR_DIRTIED: 6868276352
                   NR_WRITTEN: 5816499568
             NR_PAGES_SCANNED: -490
                     NUMA_HIT: 922019911612
                    NUMA_MISS: 2935289654
                 NUMA_FOREIGN: 1903827196
          NUMA_INTERLEAVE_HIT: 57290
                   NUMA_LOCAL: 922017951068
                   NUMA_OTHER: 2937250198
           WORKINGSET_REFAULT: 6998116360
          WORKINGSET_ACTIVATE: 6033595269
       WORKINGSET_NODERECLAIM: 2300965
NR_ANON_TRANSPARENT_HUGEPAGES: 0
            NR_FREE_CMA_PAGES: 0

NODE: 1  ZONE: 2  ADDR: ffff88407fff9f00  NAME: "Normal"
  SIZE: 33554432  MIN/LOW/HIGH: 22567/28208/33850
  VM_STAT:
                NR_FREE_PAGES: 1003922
               NR_ALLOC_BATCH: 4572
             NR_INACTIVE_ANON: 7092366
               NR_ACTIVE_ANON: 6898921
             NR_INACTIVE_FILE: 4880696
               NR_ACTIVE_FILE: 8185594
               NR_UNEVICTABLE: 5311
                     NR_MLOCK: 25509
                NR_ANON_PAGES: 13644139
               NR_FILE_MAPPED: 790292
                NR_FILE_PAGES: 13418055
                NR_FILE_DIRTY: 2081
                 NR_WRITEBACK: 944
          NR_SLAB_RECLAIMABLE: 3948975
        NR_SLAB_UNRECLAIMABLE: 546053
                 NR_PAGETABLE: 207960
              NR_KERNEL_STACK: 10382
              NR_UNSTABLE_NFS: 0
                    NR_BOUNCE: 0
              NR_VMSCAN_WRITE: 213029
          NR_VMSCAN_IMMEDIATE: 28902492
            NR_WRITEBACK_TEMP: 0
             NR_ISOLATED_ANON: 0
             NR_ISOLATED_FILE: 23
                     NR_SHMEM: 327804
                   NR_DIRTIED: 12275571618
                   NR_WRITTEN: 11397580462
             NR_PAGES_SCANNED: -787
                     NUMA_HIT: 798927158945
                    NUMA_MISS: 1903827196
                 NUMA_FOREIGN: 2938097677
          NUMA_INTERLEAVE_HIT: 57726
                   NUMA_LOCAL: 798925933393
                   NUMA_OTHER: 1905052748
           WORKINGSET_REFAULT: 3461465775
          WORKINGSET_ACTIVATE: 2724000507
       WORKINGSET_NODERECLAIM: 4756016
NR_ANON_TRANSPARENT_HUGEPAGES: 70
            NR_FREE_CMA_PAGES: 0

So looking at those I see the following things:

1. There aren't that many writeback/dirty pages on the 2 nodes.
2. There aren't that many isolated pages.

Since the system doesn't have swap then the ANON allocation's cannot
possibly be reclaimed. However, this leaves the FILE allocations of
which there are plenty. Yet, still no further progress is made. Given
all of this I'm not able to map the number to a sensible behavior of the
reclamation path.

>> So what's strange is that the softlockup occurred but then the code
>> proceeded (as evident from the subsequent stack traces), yet inspecting
>> the reclaim progress it seems rather sad (no progress at all)
> 
> Unless I have misread the data above it seems something has either
> isolated all LRU pages for some time or there simply are none while the
> reclaim is desperately trying to make some progress. In any case this
> sounds less than a happy system...
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
