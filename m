Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id F2A686B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 16:57:28 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fa1so15764021pad.12
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 13:57:28 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id np1si7899516pdb.31.2014.09.02.13.57.24
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 13:57:24 -0700 (PDT)
Message-ID: <54062F32.5070504@sr71.net>
Date: Tue, 02 Sep 2014 13:57:22 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <5406262F.4050705@intel.com>
In-Reply-To: <5406262F.4050705@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

I, of course, forgot to include the most important detail.  This appears
to be pretty run-of-the-mill spinlock contention in the resource counter
code.  Nearly 80% of the CPU is spent spinning in the charge or uncharge
paths in the kernel.  It is apparently spinning on res_counter->lock in
both the charge and uncharge paths.

It already does _some_ batching here on the free side, but that
apparently breaks down after ~40 threads.

It's a no-brainer since the patch in question removed an optimization
skipping the charging, and now we're seeing overhead from the charging.

Here's the first entry from perf top:

    80.18%    80.18%  [kernel]               [k] _raw_spin_lock
                  |
                  --- _raw_spin_lock
                     |
                     |--66.59%-- res_counter_uncharge_until
                     |          res_counter_uncharge
                     |          uncharge_batch
                     |          uncharge_list
                     |          mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |
                     |          |--90.12%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |
                     |           --9.88%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                     |
                     |--46.13%-- __res_counter_charge
                     |          res_counter_charge
                     |          try_charge
                     |          mem_cgroup_try_charge
                     |          |
                     |          |--99.89%-- do_cow_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          testcase
                     |           --0.11%-- [...]
                     |
                     |--1.14%-- do_cow_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          testcase
                      --8217937613.29%-- [...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
