Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A34BF6B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:40:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a74so612848pfg.20
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:40:48 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o33si5115253plb.749.2017.12.08.00.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 00:40:47 -0800 (PST)
From: kemi <kemi.wang@intel.com>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
 <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
 <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
Message-ID: <9cd6cc9f-252a-3c6f-2f1f-e39d4ec0457b@intel.com>
Date: Fri, 8 Dec 2017 16:38:46 +0800
MIME-Version: 1.0
In-Reply-To: <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'11ae??30ae?JPY 17:45, Michal Hocko wrote:
> On Thu 30-11-17 17:32:08, kemi wrote:

> Do not get me wrong. If we want to make per-node stats more optimal,
> then by all means let's do that. But having 3 sets of counters is just
> way to much.
> 

Hi, Michal
  Apologize to respond later in this email thread.

After thinking about how to optimize our per-node stats more gracefully, 
we may add u64 vm_numa_stat_diff[] in struct per_cpu_nodestat, thus,
we can keep everything in per cpu counter and sum them up when read /proc
or /sys for numa stats. 
What's your idea for that? thanks

The motivation for that modification is listed below:
1) thanks to 0-day system, a bug is reported for the V1 patch:

[    0.000000] BUG: unable to handle kernel paging request at 0392b000
[    0.000000] IP: __inc_numa_state+0x2a/0x34
[    0.000000] *pdpt = 0000000000000000 *pde = f000ff53f000ff53 
[    0.000000] Oops: 0002 [#1] PREEMPT SMP
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.14.0-12996-g81611e2 #1
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[    0.000000] task: cbf56000 task.stack: cbf4e000
[    0.000000] EIP: __inc_numa_state+0x2a/0x34
[    0.000000] EFLAGS: 00210006 CPU: 0
[    0.000000] EAX: 0392b000 EBX: 00000000 ECX: 00000000 EDX: cbef90ef
[    0.000000] ESI: cffdb320 EDI: 00000004 EBP: cbf4fd80 ESP: cbf4fd7c
[    0.000000]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[    0.000000] CR0: 80050033 CR2: 0392b000 CR3: 0c0a8000 CR4: 000406b0
[    0.000000] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[    0.000000] DR6: fffe0ff0 DR7: 00000400
[    0.000000] Call Trace:
[    0.000000]  zone_statistics+0x4d/0x5b
[    0.000000]  get_page_from_freelist+0x257/0x993
[    0.000000]  __alloc_pages_nodemask+0x108/0x8c8
[    0.000000]  ? __bitmap_weight+0x38/0x41
[    0.000000]  ? pcpu_next_md_free_region+0xe/0xab
[    0.000000]  ? pcpu_chunk_refresh_hint+0x8b/0xbc
[    0.000000]  ? pcpu_chunk_slot+0x1e/0x24
[    0.000000]  ? pcpu_chunk_relocate+0x15/0x6d
[    0.000000]  ? find_next_bit+0xa/0xd
[    0.000000]  ? cpumask_next+0x15/0x18
[    0.000000]  ? pcpu_alloc+0x399/0x538
[    0.000000]  cache_grow_begin+0x85/0x31c
[    0.000000]  ____cache_alloc+0x147/0x1e0
[    0.000000]  ? debug_smp_processor_id+0x12/0x14
[    0.000000]  kmem_cache_alloc+0x80/0x145
[    0.000000]  create_kmalloc_cache+0x22/0x64
[    0.000000]  kmem_cache_init+0xf9/0x16c
[    0.000000]  start_kernel+0x1d4/0x3d6
[    0.000000]  i386_start_kernel+0x9a/0x9e
[    0.000000]  startup_32_smp+0x15f/0x170

That is because u64 percpu pointer vm_numa_stat is used before initialization.

[...]
> +extern u64 __percpu *vm_numa_stat;
[...]
> +#ifdef CONFIG_NUMA
> +	size = sizeof(u64) * num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS;
> +	align = __alignof__(u64[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS]);
> +	vm_numa_stat = (u64 __percpu *)__alloc_percpu(size, align);
> +#endif

The pointer is used in mm_init->kmem_cache_init->create_kmalloc_cache->...->
__alloc_pages() when CONFIG_SLAB/CONFIG_ZONE_DMA is set in kconfig, while the
vm_numa_stat is initialized in setup_per_cpu_pageset after mm_init is called.
The proposal mentioned above can fix it by making the numa stats counter ready
before calling mm_init (start_kernel->build_all_zonelists() can help to do that)

2) Compare to the V1 patch, this modification makes the semantics of per-node numa
stats more clear for review and maintenance. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
