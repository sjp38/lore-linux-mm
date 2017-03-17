Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24EAB6B038F
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:08:58 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h89so46691688lfi.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:08:58 -0700 (PDT)
Received: from vps01.wiesinger.com ([2a02:25b0:aaaa:57a::affe:bade])
        by mx.google.com with ESMTPS id i13si5004571ljb.108.2017.03.17.13.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 13:08:56 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz> <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
Date: Fri, 17 Mar 2017 21:08:31 +0100
MIME-Version: 1.0
In-Reply-To: <20170317171339.GA23957@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 17.03.2017 18:13, Michal Hocko wrote:
> On Fri 17-03-17 17:37:48, Gerhard Wiesinger wrote:
> [...]
>> Why does the kernel prefer to swapin/out and not use
>>
>> a.) the free memory?
> It will use all the free memory up to min watermark which is set up
> based on min_free_kbytes.

Makes sense, how is /proc/sys/vm/min_free_kbytes default value calculated?

>
>> b.) the buffer/cache?
> the memory reclaim is strongly biased towards page cache and we try to
> avoid swapout as much as possible (see get_scan_count).

If I understand it correctly, swapping is preferred over dropping the 
cache, right. Can this behaviour be changed to prefer dropping the cache 
to some minimum amount?
Is this also configurable in a way?
(As far as I remember e.g. kernel 2.4 dropped the caches well).

>   
>> There is ~100M memory available but kernel swaps all the time ...
>>
>> Any ideas?
>>
>> Kernel: 4.9.14-200.fc25.x86_64
>>
>> top - 17:33:43 up 28 min,  3 users,  load average: 3.58, 1.67, 0.89
>> Tasks: 145 total,   4 running, 141 sleeping,   0 stopped,   0 zombie
>> %Cpu(s): 19.1 us, 56.2 sy,  0.0 ni,  4.3 id, 13.4 wa, 2.0 hi,  0.3 si,  4.7
>> st
>> KiB Mem :   230076 total,    61508 free,   123472 used,    45096 buff/cache
>>
>> procs -----------memory---------- ---swap-- -----io---- -system--
>> ------cpu-----
>>   r  b   swpd   free   buff  cache   si   so    bi    bo in   cs us sy id wa st
>>   3  5 303916  60372    328  43864 27828  200 41420   236 6984 11138 11 47  6 23 14
> I am really surprised to see any reclaim at all. 26% of free memory
> doesn't sound as if we should do a reclaim at all. Do you have an
> unusual configuration of /proc/sys/vm/min_free_kbytes ? Or is there
> anything running inside a memory cgroup with a small limit?

nothing special set regarding /proc/sys/vm/min_free_kbytes (default 
values), detailed config below. Regarding cgroups, none of I know. How 
to check (I guess nothing is set because cg* commands are not available)?

cat /etc/sysctl.d/* | grep "^vm"
vm.dirty_background_ratio = 3
vm.dirty_ratio = 15
vm.overcommit_memory = 2
vm.overcommit_ratio = 80
vm.swappiness=10

find /proc/sys/vm -type f -exec echo {} \; -exec cat {} \;
/proc/sys/vm/admin_reserve_kbytes
8192
/proc/sys/vm/block_dump
0
/proc/sys/vm/compact_memory
cat: /proc/sys/vm/compact_memory: Permission denied
/proc/sys/vm/compact_unevictable_allowed
1
/proc/sys/vm/dirty_background_bytes
0
/proc/sys/vm/dirty_background_ratio
3
/proc/sys/vm/dirty_bytes
0
/proc/sys/vm/dirty_expire_centisecs
3000
/proc/sys/vm/dirty_ratio
15
/proc/sys/vm/dirty_writeback_centisecs
500
/proc/sys/vm/dirtytime_expire_seconds
43200
/proc/sys/vm/drop_caches
0
/proc/sys/vm/extfrag_threshold
500
/proc/sys/vm/hugepages_treat_as_movable
0
/proc/sys/vm/hugetlb_shm_group
0
/proc/sys/vm/laptop_mode
0
/proc/sys/vm/legacy_va_layout
0
/proc/sys/vm/lowmem_reserve_ratio
256     256     32      1
/proc/sys/vm/max_map_count
65530
/proc/sys/vm/memory_failure_early_kill
0
/proc/sys/vm/memory_failure_recovery
1
/proc/sys/vm/min_free_kbytes
45056
/proc/sys/vm/min_slab_ratio
5
/proc/sys/vm/min_unmapped_ratio
1
/proc/sys/vm/mmap_min_addr
65536
/proc/sys/vm/mmap_rnd_bits
28
/proc/sys/vm/mmap_rnd_compat_bits
8
/proc/sys/vm/nr_hugepages
0
/proc/sys/vm/nr_hugepages_mempolicy
0
/proc/sys/vm/nr_overcommit_hugepages
0
/proc/sys/vm/nr_pdflush_threads
0
/proc/sys/vm/numa_zonelist_order
default
/proc/sys/vm/oom_dump_tasks
1
/proc/sys/vm/oom_kill_allocating_task
0
/proc/sys/vm/overcommit_kbytes
0
/proc/sys/vm/overcommit_memory
2
/proc/sys/vm/overcommit_ratio
80
/proc/sys/vm/page-cluster
3
/proc/sys/vm/panic_on_oom
0
/proc/sys/vm/percpu_pagelist_fraction
0
/proc/sys/vm/stat_interval
1
/proc/sys/vm/stat_refresh
/proc/sys/vm/swappiness
10
/proc/sys/vm/user_reserve_kbytes
31036
/proc/sys/vm/vfs_cache_pressure
100
/proc/sys/vm/watermark_scale_factor
10
/proc/sys/vm/zone_reclaim_mode
0

Thnx.


Ciao,

Gerhard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
