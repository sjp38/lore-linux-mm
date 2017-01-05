Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72A8E6B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 20:34:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so1624954796pgc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 17:34:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r29si74163493pfd.203.2017.01.04.17.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 17:33:59 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v4 0/9] mm/swap: Regular page swap optimizations
References: <cover.1481317367.git.tim.c.chen@linux.intel.com>
	<20161227074503.GA10616@bbox>
Date: Thu, 05 Jan 2017 09:33:55 +0800
In-Reply-To: <20161227074503.GA10616@bbox> (Minchan Kim's message of "Tue, 27
	Dec 2016 16:45:03 +0900")
Message-ID: <8760lujnng.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, jack@suse.cz

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:
[snip]
>
> The patchset has used several techniqueus to reduce lock contention, for example,
> batching alloc/free, fine-grained lock and cluster distribution to avoid cache
> false-sharing. Each items has different complexity and benefits so could you
> show the number for each step of pathchset? It would be better to include the
> nubmer in each description. It helps how the patch is important when we consider
> complexitiy of the patch.

Here is the test data.

We test the vm-scalability swap-w-seq test case with 32 processes on a
Xeon E5 v3 system.  The swap device used is a RAM simulated PMEM
(persistent memory) device.  To test the sequential swapping out, the
test case created 32 processes, which sequentially allocate and write to
the anonymous pages until the RAM and part of the swap device is used
up.

The patchset is rebased on v4.9-rc8.  So the baseline performance is as
follow,

  "vmstat.swap.so": 1428002,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list": 13.94,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg": 13.75,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.swapcache_free.__remove_mapping.shrink_page_list": 7.05,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.swap_info_get.page_swapcount.try_to_free_swap.swap_writepage": 7.03,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.__swap_duplicate.swap_duplicate.try_to_unmap_one.rmap_walk_anon": 7.02,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list": 6.83,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.page_check_address_transhuge.page_referenced_one.rmap_walk_anon.rmap_walk": 0.81,

>> Patch 1 is a clean up patch.
>
> Could it be separated patch?
>
>> Patch 2 creates a lock per cluster, this gives us a more fine graind lock
>>         that can be used for accessing swap_map, and not lock the whole
>>         swap device

After patch 2, the result is as follow,

  "vmstat.swap.so": 1481704,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list": 27.53,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg": 27.01,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.free_pcppages_bulk.drain_pages_zone.drain_pages.drain_local_pages": 1.03,

The swap out throughput is at the same level, but the lock contention on
swap_info_struct->lock is eliminated.

>> Patch 3 splits the swap cache radix tree into 64MB chunks, reducing
>>         the rate that we have to contende for the radix tree.
>

After patch 3,

  "vmstat.swap.so": 2050097,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_page.add_to_swap.shrink_page_list.shrink_inactive_list": 43.27,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault": 4.84,

The swap out throughput is improved about ~43% compared with baseline.
The lock contention on swap cache radix tree lock is eliminated.
swap_info_struct->lock in get_swap_page() becomes the most heavy
contended lock.

>
>> Patch 4 eliminates unnecessary page allocation for read ahead.
>
> Could it be separated patch?
>
>> Patch 5-9 create a per cpu cache of the swap slots, so we don't have
>>         to contend on the swap device to get a swap slot or to release
>>         a swap slot.  And we allocate and release the swap slots
>>         in batches for better efficiency.

After patch 9,

  "vmstat.swap.so": 4170746,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.swapcache_free_entries.free_swap_slot.free_swap_and_cache.unmap_page_range": 13.91,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_vma.handle_mm_fault": 8.56,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_page_from_freelist.__alloc_pages_slowpath.__alloc_pages_nodemask.alloc_pages_vma": 2.56,
  "perf-profile.calltrace.cycles-pp._raw_spin_lock.get_swap_pages.get_swap_page.add_to_swap.shrink_page_list": 2.47,

The swap out throughput is improved about 192% compared with the
baseline.  There are still some lock contention for
swap_info_struct->lock, but the pressure begins to shift to buddy system
now.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
