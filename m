Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id A157E6B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:38:21 -0400 (EDT)
Received: by oixx6 with SMTP id x6so12944505oix.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 07:38:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 201si4831014oia.85.2015.10.14.07.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 07:38:20 -0700 (PDT)
Subject: Re: Silent hang up caused by pages being not scanned?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
	<20151013133225.GA31034@dhcp22.suse.cz>
	<201510140119.FGC17641.FSOHMtQOFLJOVF@I-love.SAKURA.ne.jp>
	<20151014132248.GH28333@dhcp22.suse.cz>
In-Reply-To: <20151014132248.GH28333@dhcp22.suse.cz>
Message-Id: <201510142338.IEE21387.LFHSQVtMOFOFJO@I-love.SAKURA.ne.jp>
Date: Wed, 14 Oct 2015 23:38:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Michal Hocko wrote:
> The OOM report is really interesting:
> 
> > [   69.039152] Node 0 DMA32 free:74224kB min:44652kB low:55812kB high:66976kB active_anon:1334792kB inactive_anon:8240kB active_file:48364kB inactive_file:230752kB unevictable:0kB isolated(anon):92kB isolated(file):0kB present:2080640kB managed:1774264kB mlocked:0kB dirty:9328kB writeback:199060kB mapped:38140kB shmem:8472kB slab_reclaimable:17840kB slab_unreclaimable:16292kB kernel_stack:3840kB pagetables:7864kB unstable:0kB bounce:0kB free_pcp:784kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> 
> so your whole file LRUs are either dirty or under writeback and
> reclaimable pages are below min wmark. This alone is quite suspicious.

I did

  $ cat < /dev/zero > /tmp/log

for 10 seconds before starting

  $ ./a.out

Thus, so much memory was waiting for writeback on XFS filesystem.

> Why hasn't balance_dirty_pages throttled writers and allowed them to
> make the whole LRU dirty? What is your dirty{_background}_{ratio,bytes}
> configuration on that system.

All values are defaults of plain CentOS 7 installation.

# sysctl -a | grep ^vm.
vm.admin_reserve_kbytes = 8192
vm.block_dump = 0
vm.compact_unevictable_allowed = 1
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 30
vm.dirty_writeback_centisecs = 500
vm.dirtytime_expire_seconds = 43200
vm.drop_caches = 0
vm.extfrag_threshold = 500
vm.hugepages_treat_as_movable = 0
vm.hugetlb_shm_group = 0
vm.laptop_mode = 0
vm.legacy_va_layout = 0
vm.lowmem_reserve_ratio = 256   256     32
vm.max_map_count = 65530
vm.memory_failure_early_kill = 0
vm.memory_failure_recovery = 1
vm.min_free_kbytes = 45056
vm.min_slab_ratio = 5
vm.min_unmapped_ratio = 1
vm.mmap_min_addr = 4096
vm.nr_hugepages = 0
vm.nr_hugepages_mempolicy = 0
vm.nr_overcommit_hugepages = 0
vm.nr_pdflush_threads = 0
vm.numa_zonelist_order = default
vm.oom_dump_tasks = 1
vm.oom_kill_allocating_task = 0
vm.overcommit_kbytes = 0
vm.overcommit_memory = 0
vm.overcommit_ratio = 50
vm.page-cluster = 3
vm.panic_on_oom = 0
vm.percpu_pagelist_fraction = 0
vm.stat_interval = 1
vm.swappiness = 30
vm.user_reserve_kbytes = 54808
vm.vfs_cache_pressure = 100
vm.zone_reclaim_mode = 0

> 
> Also why throttle_vm_writeout haven't slown the reclaim down?

Too difficult question for me.

> 
> Anyway this is exactly the case where zone_reclaimable helps us to
> prevent OOM because we are looping over the remaining LRU pages without
> making progress... This just shows how subtle all this is :/
> 
> I have to think about this much more..

I'm suspicious about tweaking current reclaim logic.
Could you please respond to Linus's comments?

There are more moles than kernel developers can find. I think that
what we can do for short term is to prepare for moles that kernel
developers could not find, and for long term is to reform page
allocator for preventing moles from living.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
