Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3836B0031
	for <linux-mm@kvack.org>; Sat, 21 Jun 2014 09:26:57 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so4097166pad.12
        for <linux-mm@kvack.org>; Sat, 21 Jun 2014 06:26:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cm4si11945444pbb.201.2014.06.21.06.26.55
        for <linux-mm@kvack.org>;
        Sat, 21 Jun 2014 06:26:55 -0700 (PDT)
Message-ID: <53A5881B.10702@intel.com>
Date: Sat, 21 Jun 2014 21:26:51 +0800
From: Jet Chen <jet.chen@intel.com>
MIME-Version: 1.0
Subject: Re: [memcontrol] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28
 res_counter_uncharge_locked()
References: <20140620102704.GA8912@localhost> <20140620154209.GI7331@cmpxchg.org>
In-Reply-To: <20140620154209.GI7331@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/20/2014 11:42 PM, Johannes Weiner wrote:
> On Fri, Jun 20, 2014 at 06:27:04PM +0800, Fengguang Wu wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> 
> Thanks for the bisect.
> 
>> commit ddc5bfec501f4be3f9e89084c2db270c0c45d1d6
>> Author:     Johannes Weiner <hannes@cmpxchg.org>
>> AuthorDate: Fri Jun 20 10:27:58 2014 +1000
>> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
>> CommitDate: Fri Jun 20 10:27:58 2014 +1000
>>
>>     mm: memcontrol: rewrite uncharge API
>>     
>>     The memcg uncharging code that is involved towards the end of a page's
>>     lifetime - truncation, reclaim, swapout, migration - is impressively
>>     complicated and fragile.
>>     
>>     Because anonymous and file pages were always charged before they had their
>>     page->mapping established, uncharges had to happen when the page type
>>     could still be known from the context; as in unmap for anonymous, page
>>     cache removal for file and shmem pages, and swap cache truncation for swap
>>     pages.  However, these operations happen well before the page is actually
>>     freed, and so a lot of synchronization is necessary:
>>     
>>     - Charging, uncharging, page migration, and charge migration all need
>>       to take a per-page bit spinlock as they could race with uncharging.
>>     
>>     - Swap cache truncation happens during both swap-in and swap-out, and
>>       possibly repeatedly before the page is actually freed.  This means
>>       that the memcg swapout code is called from many contexts that make
>>       no sense and it has to figure out the direction from page state to
>>       make sure memory and memory+swap are always correctly charged.
>>     
>>     - On page migration, the old page might be unmapped but then reused,
>>       so memcg code has to prevent untimely uncharging in that case.
>>       Because this code - which should be a simple charge transfer - is so
>>       special-cased, it is not reusable for replace_page_cache().
>>     
>>     But now that charged pages always have a page->mapping, introduce
>>     mem_cgroup_uncharge(), which is called after the final put_page(), when we
>>     know for sure that nobody is looking at the page anymore.
>>     
>>     For page migration, introduce mem_cgroup_migrate(), which is called after
>>     the migration is successful and the new page is fully rmapped.  Because
>>     the old page is no longer uncharged after migration, prevent double
>>     charges by decoupling the page's memcg association (PCG_USED and
>>     pc->mem_cgroup) from the page holding an actual charge.  The new bits
>>     PCG_MEM and PCG_MEMSW represent the respective charges and are transferred
>>     to the new page during migration.
>>     
>>     mem_cgroup_migrate() is suitable for replace_page_cache() as well, which
>>     gets rid of mem_cgroup_replace_page_cache().
>>     
>>     Swap accounting is massively simplified: because the page is no longer
>>     uncharged as early as swap cache deletion, a new mem_cgroup_swapout() can
>>     transfer the page's memory+swap charge (PCG_MEMSW) to the swap entry
>>     before the final put_page() in page reclaim.
>>     
>>     Finally, page_cgroup changes are now protected by whatever protection the
>>     page itself offers: anonymous pages are charged under the page table lock,
>>     whereas page cache insertions, swapin, and migration hold the page lock.
>>     Uncharging happens under full exclusion with no outstanding references.
>>     Charging and uncharging also ensure that the page is off-LRU, which
>>     serializes against charge migration.  Remove the very costly page_cgroup
>>     lock and set pc->flags non-atomically.
>>     
>>     Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>     Cc: Michal Hocko <mhocko@suse.cz>
>>     Cc: Hugh Dickins <hughd@google.com>
>>     Cc: Tejun Heo <tj@kernel.org>
>>     Cc: Vladimir Davydov <vdavydov@parallels.com>
>>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>
>> +-----------------------------------------------------------------------+------------+------------+---------------+
>> |                                                                       | 5b647620c6 | ddc5bfec50 | next-20140620 |
>> +-----------------------------------------------------------------------+------------+------------+---------------+
>> | boot_successes                                                        | 60         | 0          | 0             |
>> | boot_failures                                                         | 0          | 20         | 13            |
>> | WARNING:CPU:PID:at_kernel/res_counter.c:res_counter_uncharge_locked() | 0          | 20         | 13            |
>> | backtrace:vm_munmap                                                   | 0          | 20         | 13            |
>> | backtrace:SyS_munmap                                                  | 0          | 20         | 13            |
>> | backtrace:do_sys_open                                                 | 0          | 20         | 13            |
>> | backtrace:SyS_open                                                    | 0          | 20         | 13            |
>> | backtrace:do_execve                                                   | 0          | 20         | 13            |
>> | backtrace:SyS_execve                                                  | 0          | 20         | 13            |
>> | backtrace:do_group_exit                                               | 0          | 20         | 13            |
>> | backtrace:SyS_exit_group                                              | 0          | 20         | 13            |
>> | backtrace:SYSC_renameat2                                              | 0          | 11         | 8             |
>> | backtrace:SyS_rename                                                  | 0          | 11         | 8             |
>> | backtrace:do_munmap                                                   | 0          | 11         | 8             |
>> | backtrace:SyS_brk                                                     | 0          | 11         | 8             |
>> | Out_of_memory:Kill_process                                            | 0          | 1          |               |
>> | backtrace:do_unlinkat                                                 | 0          | 9          | 5             |
>> | backtrace:SyS_unlink                                                  | 0          | 9          | 5             |
>> | backtrace:SYSC_umount                                                 | 0          | 9          |               |
>> | backtrace:SyS_umount                                                  | 0          | 9          |               |
>> | backtrace:cleanup_mnt_work                                            | 0          | 0          | 5             |
>> +-----------------------------------------------------------------------+------------+------------+---------------+
>>
>> [    2.747397] debug: unmapping init [mem 0xffff880001a3a000-0xffff880001bfffff]
>> [    2.748630] debug: unmapping init [mem 0xffff8800021ad000-0xffff8800021fffff]
>> [    2.752857] ------------[ cut here ]------------
>> [    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counter_uncharge_locked+0x48/0x74()
>> [    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gddc5bfe #1
>> [    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff880012073c88
>> [    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff88001200fa50
>> [    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff810bc84b
>> [    2.753355] Call Trace:
>> [    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
>> [    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
>> [    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
>> [    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
>> [    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
>> [    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
>> [    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
>> [    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
>> [    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
>> [    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
>> [    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
>> [    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
>> [    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
>> [    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
>> [    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
>> [    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
>> [    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
>> [    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
>> [    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
>> [    2.780913] ------------[ cut here ]------------
> 
> This is an underflow that happens with memcg enabled but memcg-swap
> disabled - the memsw counter is not accounted, but then unaccounted.
> 
> Andrew, can you please put this in to fix the uncharge rewrite patch
> mentioned above?
> 
> ---
> 
> From 29bcfcf54494467008aaf9d4e37771d3b2e2c2c7 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 20 Jun 2014 11:09:14 -0400
> Subject: [patch] mm: memcontrol: rewrite uncharge API fix
> 
> It's not entirely clear whether do_swap_account or PCG_MEMSW is the
> authoritative answer to whether a page is swap-accounted or not.  This
> currently leads to the following memsw counter underflow when swap
> accounting is disabled:
> 
> [    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_counter_uncharge_locked+0x48/0x74()
> [    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gddc5bfe #1
> [    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff880012073c88
> [    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff88001200fa50
> [    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffffff810bc84b
> [    2.753355] Call Trace:
> [    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
> [    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
> [    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0x74
> [    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
> [    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
> [    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
> [    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
> [    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
> [    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
> [    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
> [    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
> [    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
> [    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
> [    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0x33
> [    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
> [    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
> [    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
> [    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
> [    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
> 
> Don't set PCG_MEMSW when swap accounting is disabled, so that
> uncharging only has to look at this per-page flag.
> 
> mem_cgroup_swapout() could also fully rely on this flag, but as it can
> bail out before even looking up the page_cgroup, check do_swap_account
> as a performance optimization and only sanity test for PCG_MEMSW.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 94d7c40b9f26..d6a20935f9c4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2740,7 +2740,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	 *   have the page locked
>  	 */
>  	pc->mem_cgroup = memcg;
> -	pc->flags = PCG_USED | PCG_MEM | PCG_MEMSW;
> +	pc->flags = PCG_USED | PCG_MEM | (do_swap_account ? PCG_MEMSW : 0);
>  
>  	if (lrucare) {
>  		if (was_on_lru) {
> @@ -6598,7 +6598,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  		return;
>  
>  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), oldpage);
> +	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
>  	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
>  
>  	if (PageTransHuge(oldpage)) {
> 

Johannes, your patch fixes the problem.

Tested-by: Jet Chen <jet.chen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
