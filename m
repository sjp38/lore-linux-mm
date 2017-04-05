Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 726556B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 10:53:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 81so8142344pgh.3
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 07:53:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g78si20852515pfb.222.2017.04.05.07.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 07:53:16 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35Emi6W046159
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 10:53:15 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29mspykbkh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 10:53:15 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 08:53:14 -0600
Date: Wed, 5 Apr 2017 09:53:05 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170404072329.GA15132@dhcp22.suse.cz>
 <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405092427.GG6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170405092427.GG6035@dhcp22.suse.cz>
Message-Id: <20170405145304.wxzfavqxnyqtrlru@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Apr 05, 2017 at 11:24:27AM +0200, Michal Hocko wrote:
>On Wed 05-04-17 08:42:39, Michal Hocko wrote:
>> On Tue 04-04-17 16:43:39, Reza Arbab wrote:
>> > It's new. Without this patchset, I can repeatedly
>> > add_memory()->online_movable->offline->remove_memory() all of a node's
>> > memory.
>>
>> This is quite unexpected because the code obviously cannot handle the
>> first memory section. Could you paste /proc/zoneinfo and
>> grep . -r /sys/devices/system/memory/auto_online_blocks/memory*, after
>> onlining for both patched and unpatched kernels?
>
>Btw. how do you test this? I am really surprised you managed to
>hotremove such a low pfn range.

When I boot, I have node 0 (4GB) and node 1 (empty):

Early memory node ranges
  node   0: [mem 0x0000000000000000-0x00000000ffffffff]
Initmem setup node 0 [mem 0x0000000000000000-0x00000000ffffffff]
On node 0 totalpages: 65536
  DMA zone: 64 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 65536 pages, LIFO batch:1
Could not find start_pfn for node 1
Initmem setup node 1 [mem 0x0000000000000000-0x0000000000000000]
On node 1 totalpages: 0

My steps from there:

1. add_memory(1, 0x100000000, 0x100000000)
2. echo online_movable > /sys/devices/system/node/node1/memory[511..256]
3. echo offline > /sys/devices/system/node/node1/memory[256..511]
4. remove_memory(1, 0x100000000, 0x100000000)

After step 2, regardless of kernel:

$ cat /proc/zoneinfo
Node 0, zone      DMA
  per-node stats
      nr_inactive_anon 418
      nr_active_anon 2710
      nr_inactive_file 4895
      nr_active_file 1945
      nr_unevictable 0
      nr_isolated_anon 0
      nr_isolated_file 0
      nr_pages_scanned 0
      workingset_refault 0
      workingset_activate 0
      workingset_nodereclaim 0
      nr_anon_pages 2654
      nr_mapped    739
      nr_file_pages 7314
      nr_dirty     1
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     474
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 0
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   3259
      nr_written   460
  pages free     53520
        min      63
        low      128
        high     193
   node_scanned  0
        spanned  65536
        present  65536
        managed  65218
      nr_free_pages 53520
      nr_zone_inactive_anon 418
      nr_zone_active_anon 2710
      nr_zone_inactive_file 4895
      nr_zone_active_file 1945
      nr_zone_unevictable 0
      nr_zone_write_pending 1
      nr_mlock     0
      nr_slab_reclaimable 438
      nr_slab_unreclaimable 808
      nr_page_table_pages 32
      nr_kernel_stack 2080
      nr_bounce    0
      numa_hit     313226
      numa_miss    0
      numa_foreign 0
      numa_interleave 3071
      numa_local   313226
      numa_other   0
      nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 2
              high:  6
              batch: 1
  vm stats threshold: 12
  node_unreclaimable:  0
  start_pfn:           0
  node_inactive_ratio: 0
Node 1, zone  Movable
  per-node stats
      nr_inactive_anon 0
      nr_active_anon 0
      nr_inactive_file 0
      nr_active_file 0
      nr_unevictable 0
      nr_isolated_anon 0
      nr_isolated_file 0
      nr_pages_scanned 0
      workingset_refault 0
      workingset_activate 0
      workingset_nodereclaim 0
      nr_anon_pages 0
      nr_mapped    0
      nr_file_pages 0
      nr_dirty     0
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     0
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 0
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   0
      nr_written   0
  pages free     65536
        min      63
        low      128
        high     193
   node_scanned  0
        spanned  65536
        present  65536
        managed  65536
      nr_free_pages 65536
      nr_zone_inactive_anon 0
      nr_zone_active_anon 0
      nr_zone_inactive_file 0
      nr_zone_active_file 0
      nr_zone_unevictable 0
      nr_zone_write_pending 0
      nr_mlock     0
      nr_slab_reclaimable 0
      nr_slab_unreclaimable 0
      nr_page_table_pages 0
      nr_kernel_stack 0
      nr_bounce    0
      numa_hit     0
      numa_miss    0
      numa_foreign 0
      numa_interleave 0
      numa_local   0
      numa_other   0
      nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 0
              high:  6
              batch: 1
  vm stats threshold: 14
  node_unreclaimable:  1
  start_pfn:           65536
  node_inactive_ratio: 0

After step 2, on v4.11-rc5:

$ grep . /sys/devices/system/memory/memory*/valid_zones
/sys/devices/system/memory/memory[0..254]/valid_zones:DMA
/sys/devices/system/memory/memory255/valid_zones:DMA Normal Movable
/sys/devices/system/memory/memory256/valid_zones:Movable Normal
/sys/devices/system/memory/memory[257..511]/valid_zones:Movable

After step 2, on v4.11-rc5 + all the patches from this thread:

$ grep . /sys/devices/system/memory/memory*/valid_zones
/sys/devices/system/memory/memory[0..255]/valid_zones:DMA
/sys/devices/system/memory/memory[256..511]/valid_zones:Movable

On v4.11-rc5, I can do steps 1-4 ad nauseam.
On v4.11-rc5 + all the patches from this thread, I can do things 
repeatedly, but starting on the second iteration, all the

  /sys/devices/system/node/node1/memory*

symlinks are not created. I can still proceed using the actual files,

  /sys/devices/system/memory/memory[256..511]

instead. I think it may be because step 4 does node_set_offline(1). That 
is, the node is not only emptied of memory, it is offlined completely.

I hope this made sense. :/

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
