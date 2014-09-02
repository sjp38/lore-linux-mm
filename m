Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C1E4A6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 18:36:33 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so240184pdj.14
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 15:36:33 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id rk5si7785638pab.204.2014.09.02.15.36.32
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 15:36:32 -0700 (PDT)
Message-ID: <5406466D.1020000@sr71.net>
Date: Tue, 02 Sep 2014 15:36:29 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <20140902221814.GA18069@cmpxchg.org>
In-Reply-To: <20140902221814.GA18069@cmpxchg.org>
Content-Type: multipart/mixed;
 boundary="------------090300080702060409030200"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------090300080702060409030200
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 09/02/2014 03:18 PM, Johannes Weiner wrote:
> Accounting new pages is buffered through per-cpu caches, but taking
> them off the counters on free is not, so I'm guessing that above a
> certain allocation rate the cost of locking and changing the counters
> takes over.  Is there a chance you could profile this to see if locks
> and res_counter-related operations show up?

It looks pretty much the same, although it might have equalized the
charge and uncharge sides a bit.  Full 'perf top' output attached.

--------------090300080702060409030200
Content-Type: text/plain; charset=UTF-8;
 name="perf-20140902-johannes-take1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="perf-20140902-johannes-take1.txt"

   PerfTop:  275580 irqs/sec  kernel:98.0%  exact:  0.0% [4000Hz cycles],  (all, 160 CPUs)
-------------------------------------------------------------------------------

    68.10%    68.10%  [kernel]               [k] _raw_spin_lock           
                  |
                  --- _raw_spin_lock
                     |          
                     |--57.35%-- __res_counter_charge
                     |          res_counter_charge
                     |          try_charge
                     |          mem_cgroup_try_charge
                     |          |          
                     |          |--99.93%-- do_cow_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          testcase
                     |           --0.07%-- [...]
                     |          
                     |--53.93%-- res_counter_uncharge_until
                     |          res_counter_uncharge
                     |          refill_stock
                     |          uncharge_batch
                     |          uncharge_list
                     |          mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.62%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.38%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                     |          
                     |--2.18%-- do_cow_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          testcase
                      --9307219025.55%-- [...]

    64.00%     1.34%  page_fault2_processes  [.] testcase                 
                  |
                  --- testcase

    62.64%     0.37%  [kernel]               [k] page_fault               
                  |
                  --- page_fault
                     |          
                     |--114.21%-- testcase
                      --10118485450.89%-- [...]

    62.27%     0.01%  [kernel]               [k] do_page_fault            
                  |
                  --- do_page_fault
                     |          
                     |--114.28%-- page_fault
                     |          |          
                     |          |--99.93%-- testcase
                     |           --0.07%-- [...]
                      --10178525138.33%-- [...]

    62.25%     0.07%  [kernel]               [k] __do_page_fault          
                  |
                  --- __do_page_fault
                     |          
                     |--114.27%-- do_page_fault
                     |          page_fault
                     |          |          
                     |          |--99.93%-- testcase
                     |           --0.07%-- [...]
                      --10182230022.41%-- [...]

    62.08%     0.26%  [kernel]               [k] handle_mm_fault          
                  |
                  --- handle_mm_fault
                     |          
                     |--114.28%-- __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          |          
                     |          |--99.94%-- testcase
                     |           --0.06%-- [...]
                      --10210709377.69%-- [...]

    44.32%     0.22%  [kernel]               [k] do_cow_fault             
                  |
                  --- do_cow_fault
                     |          
                     |--114.28%-- handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          testcase
                      --14302986980.21%-- [...]

    35.23%     0.00%  [kernel]               [k] sys_munmap               
                  |
                  --- sys_munmap
                      system_call_fastpath
                      __GI___munmap

    34.84%     0.04%  [kernel]               [k] mem_cgroup_try_charge    
                  |
                  --- mem_cgroup_try_charge
                     |          
                     |--114.18%-- do_cow_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          testcase
                      --18195666899.12%-- [...]

    34.74%     0.49%  [kernel]               [k] unmap_single_vma         
                  |
                  --- unmap_single_vma
                      unmap_vmas
                      unmap_region
                      do_munmap
                      vm_munmap
                      sys_munmap
                      system_call_fastpath
                      __GI___munmap

    34.66%     0.00%  [kernel]               [k] tlb_flush_mmu_free       
                  |
                  --- tlb_flush_mmu_free
                     |          
                     |--112.70%-- unmap_single_vma
                     |          unmap_vmas
                     |          unmap_region
                     |          do_munmap
                     |          vm_munmap
                     |          sys_munmap
                     |          system_call_fastpath
                     |          __GI___munmap
                     |          
                     |--1.59%-- tlb_flush_mmu
                     |          tlb_finish_mmu
                     |          unmap_region
                     |          do_munmap
                     |          vm_munmap
                     |          sys_munmap
                     |          system_call_fastpath
                     |          __GI___munmap
                      --18285481100.94%-- [...]

    34.66%     0.12%  [kernel]               [k] free_pages_and_swap_cache
                  |
                  --- free_pages_and_swap_cache
                      tlb_flush_mmu_free
                     |          
                     |--112.70%-- unmap_single_vma
                     |          unmap_vmas
                     |          unmap_region
                     |          do_munmap
                     |          vm_munmap
                     |          sys_munmap
                     |          system_call_fastpath
                     |          __GI___munmap
                     |          
                     |--1.59%-- tlb_flush_mmu
                     |          tlb_finish_mmu
                     |          unmap_region
                     |          do_munmap
                     |          vm_munmap
                     |          sys_munmap
                     |          system_call_fastpath
                     |          __GI___munmap
                      --18286531934.97%-- [...]

    34.61%     0.04%  [kernel]               [k] try_charge               
                  |
                  --- try_charge
                     |          
                     |--114.26%-- mem_cgroup_try_charge
                     |          |          
                     |          |--99.93%-- do_cow_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          testcase
                     |           --0.07%-- [...]
                      --18312751937.56%-- [...]

    34.57%     0.00%  [kernel]               [k] res_counter_charge       
                  |
                  --- res_counter_charge
                     |          
                     |--114.27%-- try_charge
                     |          mem_cgroup_try_charge
                     |          |          
                     |          |--99.93%-- do_cow_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          testcase
                     |           --0.07%-- [...]
                      --18334689838.42%-- [...]

    34.56%     0.08%  [kernel]               [k] release_pages            
                  |
                  --- release_pages
                     |          
                     |--114.21%-- free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.61%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.39%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                      --18340488029.00%-- [...]

    34.26%     0.08%  [kernel]               [k] __res_counter_charge     
                  |
                  --- __res_counter_charge
                     |          
                     |--114.28%-- res_counter_charge
                     |          try_charge
                     |          mem_cgroup_try_charge
                     |          |          
                     |          |--99.93%-- do_cow_fault
                     |          |          handle_mm_fault
                     |          |          __do_page_fault
                     |          |          do_page_fault
                     |          |          page_fault
                     |          |          testcase
                     |           --0.07%-- [...]
                      --18502823676.22%-- [...]

    33.45%     0.00%  [kernel]               [k] mem_cgroup_uncharge_list 
                  |
                  --- mem_cgroup_uncharge_list
                     |          
                     |--114.28%-- release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.62%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.38%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                      --18949679654.78%-- [...]

    33.45%     0.01%  [kernel]               [k] uncharge_list            
                  |
                  --- uncharge_list
                     |          
                     |--114.29%-- mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.62%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.38%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                      --18951232568.52%-- [...]

    33.43%     0.02%  [kernel]               [k] uncharge_batch           
                  |
                  --- uncharge_batch
                     |          
                     |--114.28%-- uncharge_list
                     |          mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.62%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.38%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                      --18962452122.61%-- [...]

    32.43%     0.01%  [kernel]               [k] refill_stock             
                  |
                  --- refill_stock
                     |          
                     |--114.27%-- uncharge_batch
                     |          uncharge_list
                     |          mem_cgroup_uncharge_list
                     |          release_pages
                     |          free_pages_and_swap_cache
                     |          tlb_flush_mmu_free
                     |          |          
                     |          |--98.62%-- unmap_single_vma
                     |          |          unmap_vmas
                     |          |          unmap_region
                     |          |          do_munmap
                     |          |          vm_munmap
                     |          |          sys_munmap
                     |          |          system_call_fastpath
                     |          |          __GI___munmap
                     |          |          
                     |           --1.38%-- tlb_flush_mmu
                     |                     tlb_finish_mmu
                     |                     unmap_region
                     |                     do_munmap
                     |                     vm_munmap
                     |                     sys_munmap
                     |                     system_call_fastpath
                     |                     __GI___munmap
                      --19543678319.29%-- [...]

--------------090300080702060409030200--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
