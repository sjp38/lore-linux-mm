Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 554726B03A5
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 03:44:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z1so10474664wrz.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:44:40 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id x130si3229620wmg.27.2017.06.23.00.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 00:44:38 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id z45so10494855wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 00:44:38 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
Date: Fri, 23 Jun 2017 10:44:36 +0300
MIME-Version: 1.0
In-Reply-To: <20170623071324.GD5308@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

IGBPI?I1I? 23/06/2017 10:13 I?I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> On Thu 22-06-17 12:37:36, Andrew Morton wrote:
> 
> What is your dirty limit configuration. Is your highmem dirtyable
> (highmem_is_dirtyable)?
> 
>>> This issue happens on systems with any 4.x kernel, i386 arch, 16+ GB RAM.
>>> It doesn't happen if we use 3.x kernels (i.e. it's a regression) or any 64bit
>>> kernels (i.e. it only affects i386).
> 
> I remember we've had some changes in the way how the dirty memory is
> throttled and 32b would be more sensitive to those changes. Anyway, I
> would _strongly_ discourage you from using 32b kernels with that much of
> memory. You are going to hit walls constantly and many of those issues
> will be inherent. Some of them less so but rather non-trivial to fix
> without regressing somewhere else. You can tune your system somehow but
> this will be fragile no mater what.
> 
> Sorry to say that but 32b systems with tons of memory are far from
> priority of most mm people. Just use 64b kernel. There are more pressing
> problems to deal with.
> 



Hi, I'm attaching below all my settings from /proc/sys/vm.

I think that the regression also affects 4 GB and 8 GB RAM i386 systems, 
but not in an exponential manner; i.e. copies there are appear only 2-3 
times slower than they used to be in 3.x kernels.

Now I don't know the kernel internals, but if disk copies show up to be 
2-3 times slower, and the regression is in memory management, wouldn't 
that mean that the memory management is *hundreds* of times slower, to 
show up in disk writing benchmarks?

I.e. I'm afraid that this regression doesn't affect 16+ GB RAM systems 
only; it just happens that it's clearly visible there.

And it might even affect 64bit systems with even more RAM; but I don't 
have any such system to test with.

Kind regards,
Alkis


root@pc:/proc/sys/vm# grep . *
admin_reserve_kbytes:8192
block_dump:0
compact_unevictable_allowed:1
dirty_background_bytes:0
dirty_background_ratio:10
dirty_bytes:0
dirty_expire_centisecs:1500
dirty_ratio:20
dirtytime_expire_seconds:43200
dirty_writeback_centisecs:1500
drop_caches:3
extfrag_threshold:500
highmem_is_dirtyable:0
hugepages_treat_as_movable:0
hugetlb_shm_group:0
laptop_mode:0
legacy_va_layout:0
lowmem_reserve_ratio:256	32	32
max_map_count:65530
min_free_kbytes:34420
mmap_min_addr:65536
mmap_rnd_bits:8
nr_hugepages:0
nr_overcommit_hugepages:0
nr_pdflush_threads:0
oom_dump_tasks:1
oom_kill_allocating_task:0
overcommit_kbytes:0
overcommit_memory:0
overcommit_ratio:50
page-cluster:3
panic_on_oom:0
percpu_pagelist_fraction:0
stat_interval:1
swappiness:60
user_reserve_kbytes:131072
vdso_enabled:1
vfs_cache_pressure:100
watermark_scale_factor:10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
