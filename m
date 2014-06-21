Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 960D36B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 20:35:06 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id t59so3412231yho.23
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:35:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y49si16221332yhh.61.2014.06.20.17.35.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 17:35:06 -0700 (PDT)
Message-ID: <53A4D323.5080808@oracle.com>
Date: Fri, 20 Jun 2014 20:34:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org> <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 06/18/2014 04:40 PM, Johannes Weiner wrote:
> The memcg uncharging code that is involved towards the end of a page's
> lifetime - truncation, reclaim, swapout, migration - is impressively
> complicated and fragile.
> 
> Because anonymous and file pages were always charged before they had
> their page->mapping established, uncharges had to happen when the page
> type could still be known from the context; as in unmap for anonymous,
> page cache removal for file and shmem pages, and swap cache truncation
> for swap pages.  However, these operations happen well before the page
> is actually freed, and so a lot of synchronization is necessary:
> 
> - Charging, uncharging, page migration, and charge migration all need
>   to take a per-page bit spinlock as they could race with uncharging.
> 
> - Swap cache truncation happens during both swap-in and swap-out, and
>   possibly repeatedly before the page is actually freed.  This means
>   that the memcg swapout code is called from many contexts that make
>   no sense and it has to figure out the direction from page state to
>   make sure memory and memory+swap are always correctly charged.
> 
> - On page migration, the old page might be unmapped but then reused,
>   so memcg code has to prevent untimely uncharging in that case.
>   Because this code - which should be a simple charge transfer - is so
>   special-cased, it is not reusable for replace_page_cache().
> 
> But now that charged pages always have a page->mapping, introduce
> mem_cgroup_uncharge(), which is called after the final put_page(),
> when we know for sure that nobody is looking at the page anymore.
> 
> For page migration, introduce mem_cgroup_migrate(), which is called
> after the migration is successful and the new page is fully rmapped.
> Because the old page is no longer uncharged after migration, prevent
> double charges by decoupling the page's memcg association (PCG_USED
> and pc->mem_cgroup) from the page holding an actual charge.  The new
> bits PCG_MEM and PCG_MEMSW represent the respective charges and are
> transferred to the new page during migration.
> 
> mem_cgroup_migrate() is suitable for replace_page_cache() as well,
> which gets rid of mem_cgroup_replace_page_cache().
> 
> Swap accounting is massively simplified: because the page is no longer
> uncharged as early as swap cache deletion, a new mem_cgroup_swapout()
> can transfer the page's memory+swap charge (PCG_MEMSW) to the swap
> entry before the final put_page() in page reclaim.
> 
> Finally, page_cgroup changes are now protected by whatever protection
> the page itself offers: anonymous pages are charged under the page
> table lock, whereas page cache insertions, swapin, and migration hold
> the page lock.  Uncharging happens under full exclusion with no
> outstanding references.  Charging and uncharging also ensure that the
> page is off-LRU, which serializes against charge migration.  Remove
> the very costly page_cgroup lock and set pc->flags non-atomically.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Hi Johannes,

I'm seeing the following when booting a VM, bisection pointed me to this
patch.

[   32.830823] BUG: using __this_cpu_add() in preemptible [00000000] code: mkdir/8677
[   32.831522] caller is __this_cpu_preempt_check+0x13/0x20
[   32.832079] CPU: 35 PID: 8677 Comm: mkdir Not tainted 3.16.0-rc1-next-20140620-sasha-00023-g8fc12ed #700
[   32.832898]  ffffffffb27ea69d ffff8800cb91b618 ffffffffb151820b 0000000000000002
[   32.833607]  0000000000000023 ffff8800cb91b648 ffffffffaeb4c799 ffff88006efa5b60
[   32.834318]  ffffea0007cff9c0 0000000000000001 0000000000000001 ffff8800cb91b658
[   32.835030] Call Trace:
[   32.835257] dump_stack (lib/dump_stack.c:52)
[   32.835755] check_preemption_disabled (./arch/x86/include/asm/preempt.h:80 lib/smp_processor_id.c:49)
[   32.836336] __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[   32.836991] mem_cgroup_charge_statistics.isra.23 (mm/memcontrol.c:930)
[   32.837682] commit_charge (mm/memcontrol.c:2761)
[   32.838187] ? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[   32.838735] ? get_parent_ip (kernel/sched/core.c:2546)
[   32.839230] mem_cgroup_commit_charge (mm/memcontrol.c:6519)
[   32.839807] __add_to_page_cache_locked (mm/filemap.c:588 include/linux/jump_label.h:115 include/trace/events/filemap.h:50 mm/filemap.c:589)
[   32.840479] add_to_page_cache_lru (mm/filemap.c:627)
[   32.841048] read_cache_pages (mm/readahead.c:92)
[   32.841560] ? v9fs_cache_session_get_key (fs/9p/cache.c:306)
[   32.842145] ? v9fs_write_begin (fs/9p/vfs_addr.c:99)
[   32.842694] v9fs_vfs_readpages (fs/9p/vfs_addr.c:127)
[   32.843251] __do_page_cache_readahead (mm/readahead.c:123 mm/readahead.c:200)
[   32.843848] ? __do_page_cache_readahead (include/linux/rcupdate.h:877 mm/readahead.c:178)
[   32.844435] ? __const_udelay (arch/x86/lib/delay.c:126)
[   32.844944] filemap_fault (include/linux/memcontrol.h:141 include/linux/memcontrol.h:198 mm/filemap.c:1869)
[   32.845465] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[   32.845999] __do_fault (mm/memory.c:2705)
[   32.846472] ? mem_cgroup_try_charge (include/linux/cgroup.h:158 mm/memcontrol.c:6467)
[   32.847048] do_cow_fault (mm/memory.c:2936)
[   32.847561] __handle_mm_fault (mm/memory.c:3078 mm/memory.c:3205 mm/memory.c:3322)
[   32.848092] ? __const_udelay (arch/x86/lib/delay.c:126)
[   32.848596] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[   32.849157] handle_mm_fault (mm/memory.c:3345)
[   32.849665] __do_page_fault (arch/x86/mm/fault.c:1230)
[   32.850239] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[   32.850963] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[   32.851442] ? sched_clock_local (kernel/sched/clock.c:214)
[   32.852034] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[   32.852669] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[   32.853243] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
[   32.853854] trace_do_page_fault (arch/x86/mm/fault.c:1313 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1314)
[   32.854393] do_async_page_fault (arch/x86/kernel/kvm.c:264)
[   32.854924] async_page_fault (arch/x86/kernel/entry_64.S:1322)
[   32.855507] ? __clear_user (arch/x86/lib/usercopy_64.c:22)
[   32.855999] ? __clear_user (arch/x86/lib/usercopy_64.c:18 arch/x86/lib/usercopy_64.c:21)
[   32.856488] clear_user (arch/x86/lib/usercopy_64.c:54)
[   32.856997] padzero (fs/binfmt_elf.c:122)
[   32.857440] load_elf_binary (fs/binfmt_elf.c:909 (discriminator 1))
[   32.857949] ? search_binary_handler (fs/exec.c:1374)
[   32.858550] ? preempt_count_sub (kernel/sched/core.c:2602)
[   32.859089] search_binary_handler (fs/exec.c:1375)
[   32.859654] do_execve_common.isra.19 (fs/exec.c:1412 fs/exec.c:1508)
[   32.860319] ? do_execve_common.isra.19 (./arch/x86/include/asm/current.h:14 fs/exec.c:1406 fs/exec.c:1508)
[   32.860949] do_execve (fs/exec.c:1551)
[   32.861390] SyS_execve (fs/exec.c:1602)
[   32.861848] stub_execve (arch/x86/kernel/entry_64.S:662)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
