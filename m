Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1C3766B005A
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 02:27:24 -0400 (EDT)
Message-ID: <508F73C5.7050409@redhat.com>
Date: Tue, 30 Oct 2012 14:29:25 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/31] numa/core patches
References: <20121025121617.617683848@chello.nl> <508A52E1.8020203@redhat.com> <1351242480.12171.48.camel@twins> <20121028175615.GC29827@cmpxchg.org>
In-Reply-To: <20121028175615.GC29827@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, CAI Qian <caiqian@redhat.com>

On 10/29/2012 01:56 AM, Johannes Weiner wrote:
> On Fri, Oct 26, 2012 at 11:08:00AM +0200, Peter Zijlstra wrote:
>> On Fri, 2012-10-26 at 17:07 +0800, Zhouping Liu wrote:
>>> [  180.918591] RIP: 0010:[<ffffffff8118c39a>]  [<ffffffff8118c39a>] mem_cgroup_prepare_migration+0xba/0xd0
>>> [  182.681450]  [<ffffffff81183b60>] do_huge_pmd_numa_page+0x180/0x500
>>> [  182.775090]  [<ffffffff811585c9>] handle_mm_fault+0x1e9/0x360
>>> [  182.863038]  [<ffffffff81632b62>] __do_page_fault+0x172/0x4e0
>>> [  182.950574]  [<ffffffff8101c283>] ? __switch_to_xtra+0x163/0x1a0
>>> [  183.041512]  [<ffffffff8101281e>] ? __switch_to+0x3ce/0x4a0
>>> [  183.126832]  [<ffffffff8162d686>] ? __schedule+0x3c6/0x7a0
>>> [  183.211216]  [<ffffffff81632ede>] do_page_fault+0xe/0x10
>>> [  183.293705]  [<ffffffff8162f518>] page_fault+0x28/0x30
>> Johannes, this looks like the thp migration memcg hookery gone bad,
>> could you have a look at this?
> Oops.  Here is an incremental fix, feel free to fold it into #31.
Hello Johannes,

maybe I don't think the below patch completely fix this issue, as I 
found a new error(maybe similar with this):

[88099.923724] ------------[ cut here ]------------
[88099.924036] kernel BUG at mm/memcontrol.c:1134!
[88099.924036] invalid opcode: 0000 [#1] SMP
[88099.924036] Modules linked in: lockd sunrpc kvm_amd kvm 
amd64_edac_mod edac_core ses enclosure serio_raw bnx2 pcspkr shpchp 
joydev i2c_piix4 edac_mce_amd k8temp dcdbas ata_generic pata_acpi 
megaraid_sas pata_serverworks usb_storage radeon i2c_algo_bit 
drm_kms_helper ttm drm i2c_core
[88099.924036] CPU 7
[88099.924036] Pid: 3441, comm: stress Not tainted 3.7.0-rc2Jons+ #3 
Dell Inc. PowerEdge 6950/0WN213
[88099.924036] RIP: 0010:[<ffffffff81188e97>] [<ffffffff81188e97>] 
mem_cgroup_update_lru_size+0x27/0x30
[88099.924036] RSP: 0000:ffff88021b247ca8  EFLAGS: 00010082
[88099.924036] RAX: ffff88011d310138 RBX: ffffea0002f18000 RCX: 
0000000000000001
[88099.924036] RDX: fffffffffffffe00 RSI: 000000000000000e RDI: 
ffff88011d310138
[88099.924036] RBP: ffff88021b247ca8 R08: 0000000000000000 R09: 
a8000bc600000000
[88099.924036] R10: 0000000000000000 R11: 0000000000000000 R12: 
00000000fffffe00
[88099.924036] R13: ffff88011ffecb40 R14: 0000000000000286 R15: 
0000000000000000
[88099.924036] FS:  00007f787d0bf740(0000) GS:ffff88021fc80000(0000) 
knlGS:0000000000000000
[88099.924036] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[88099.924036] CR2: 00007f7873a00010 CR3: 000000021bda0000 CR4: 
00000000000007e0
[88099.924036] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[88099.924036] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[88099.924036] Process stress (pid: 3441, threadinfo ffff88021b246000, 
task ffff88021b399760)
[88099.924036] Stack:
[88099.924036]  ffff88021b247cf8 ffffffff8113a9cd ffffea0002f18000 
ffff88011d310138
[88099.924036]  0000000000000200 ffffea0002f18000 ffff88019bace580 
00007f7873c00000
[88099.924036]  ffff88021aca0cf0 ffffea00081e0000 ffff88021b247d18 
ffffffff8113aa7d
[88099.924036] Call Trace:
[88099.924036]  [<ffffffff8113a9cd>] __page_cache_release.part.11+0xdd/0x140
[88099.924036]  [<ffffffff8113aa7d>] __put_compound_page+0x1d/0x30
[88099.924036]  [<ffffffff8113ac4d>] put_compound_page+0x5d/0x1e0
[88099.924036]  [<ffffffff8113b1a5>] put_page+0x45/0x50
[88099.924036]  [<ffffffff8118378c>] do_huge_pmd_numa_page+0x2ec/0x4e0
[88099.924036]  [<ffffffff81158089>] handle_mm_fault+0x1e9/0x360
[88099.924036]  [<ffffffff8162cd22>] __do_page_fault+0x172/0x4e0
[88099.924036]  [<ffffffff810958b9>] ? task_numa_work+0x1c9/0x220
[88099.924036]  [<ffffffff8107c56c>] ? task_work_run+0xac/0xe0
[88099.924036]  [<ffffffff8162d09e>] do_page_fault+0xe/0x10
[88099.924036]  [<ffffffff816296d8>] page_fault+0x28/0x30
[88099.924036] Code: 00 00 00 00 66 66 66 66 90 44 8b 1d 1c 90 b5 00 55 
48 89 e5 45 85 db 75 10 89 f6 48 63 d2 48 83 c6 0e 48 01 54 f7 08 78 02 
5d c3 <0f> 0b 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48 89 e5 48 83 ec
[88099.924036] RIP  [<ffffffff81188e97>] 
mem_cgroup_update_lru_size+0x27/0x30
[88099.924036]  RSP <ffff88021b247ca8>
[88099.924036] ---[ end trace c8d6b169e0c3f25a ]---
[88108.054610] ------------[ cut here ]------------
[88108.054610] WARNING: at kernel/watchdog.c:245 
watchdog_overflow_callback+0x9c/0xd0()
[88108.054610] Hardware name: PowerEdge 6950
[88108.054610] Watchdog detected hard LOCKUP on cpu 3
[88108.054610] Modules linked in: lockd sunrpc kvm_amd kvm 
amd64_edac_mod edac_core ses enclosure serio_raw bnx2 pcspkr shpchp 
joydev i2c_piix4 edac_mce_amd k8temp dcdbas ata_generic pata_acpi 
megaraid_sas pata_serverworks usb_storage radeon i2c_algo_bit 
drm_kms_helper ttm drm i2c_core
[88108.054610] Pid: 3429, comm: stress Tainted: G      D 3.7.0-rc2Jons+ #3
[88108.054610] Call Trace:
[88108.054610]  <NMI>  [<ffffffff8105c29f>] warn_slowpath_common+0x7f/0xc0
[88108.054610]  [<ffffffff8105c396>] warn_slowpath_fmt+0x46/0x50
[88108.054610]  [<ffffffff81093fa8>] ? sched_clock_cpu+0xa8/0x120
[88108.054610]  [<ffffffff810e95c0>] ? touch_nmi_watchdog+0x80/0x80
[88108.054610]  [<ffffffff810e965c>] watchdog_overflow_callback+0x9c/0xd0
[88108.054610]  [<ffffffff81124e6d>] __perf_event_overflow+0x9d/0x230
[88108.054610]  [<ffffffff81121f44>] ? perf_event_update_userpage+0x24/0x110
[88108.054610]  [<ffffffff81125a74>] perf_event_overflow+0x14/0x20
[88108.054610]  [<ffffffff8102440a>] x86_pmu_handle_irq+0x10a/0x160
[88108.054610]  [<ffffffff8162ac4d>] perf_event_nmi_handler+0x1d/0x20
[88108.054610]  [<ffffffff8162a411>] nmi_handle.isra.0+0x51/0x80
[88108.054610]  [<ffffffff8162a5b9>] do_nmi+0x179/0x350
[88108.054610]  [<ffffffff81629a30>] end_repeat_nmi+0x1e/0x2e
[88108.054610]  [<ffffffff816290c2>] ? _raw_spin_lock_irqsave+0x32/0x40
[88108.054610]  [<ffffffff816290c2>] ? _raw_spin_lock_irqsave+0x32/0x40
[88108.054610]  [<ffffffff816290c2>] ? _raw_spin_lock_irqsave+0x32/0x40
[88108.054610]  <<EOE>>  [<ffffffff8113b087>] pagevec_lru_move_fn+0x97/0x110
[88108.054610]  [<ffffffff8113a5f0>] ? pagevec_move_tail_fn+0x80/0x80
[88108.054610]  [<ffffffff8113b11c>] __pagevec_lru_add+0x1c/0x20
[88108.054610]  [<ffffffff8113b4e8>] __lru_cache_add+0x68/0x90
[88108.054610]  [<ffffffff8113b71b>] lru_cache_add_lru+0x3b/0x60
[88108.054610]  [<ffffffff81161151>] page_add_new_anon_rmap+0xc1/0x170
[88108.054610]  [<ffffffff811854b2>] do_huge_pmd_anonymous_page+0x242/0x330
[88108.054610]  [<ffffffff81158162>] handle_mm_fault+0x2c2/0x360
[88108.054610]  [<ffffffff8162cd22>] __do_page_fault+0x172/0x4e0
[88108.054610]  [<ffffffff8109520f>] ? __dequeue_entity+0x2f/0x50
[88108.054610]  [<ffffffff810125d1>] ? __switch_to+0x181/0x4a0
[88108.054610]  [<ffffffff8162d09e>] do_page_fault+0xe/0x10
[88108.054610]  [<ffffffff816296d8>] page_fault+0x28/0x30
[88108.054610] ---[ end trace c8d6b169e0c3f25b ]---
......
......

it's easy to reproduce with stress[1] workload.
what command I used  is '# stress -i 20 -m 30 -v'

I will report it on a new subject if it's a new issue.

let me know if you need other info.

[1] http://weather.ou.edu/~apw/projects/stress/

Thanks,
Zhouping
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 5c30a14..0d7ebd3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -801,8 +801,6 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	if (!new_page)
>   		goto alloc_fail;
>   
> -	mem_cgroup_prepare_migration(page, new_page, &memcg);
> -
>   	lru = PageLRU(page);
>   
>   	if (lru && isolate_lru_page(page)) /* does an implicit get_page() */
> @@ -835,6 +833,14 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   
>   		return;
>   	}
> +	/*
> +	 * Traditional migration needs to prepare the memcg charge
> +	 * transaction early to prevent the old page from being
> +	 * uncharged when installing migration entries.  Here we can
> +	 * save the potential rollback and start the charge transfer
> +	 * only when migration is already known to end successfully.
> +	 */
> +	mem_cgroup_prepare_migration(page, new_page, &memcg);
>   
>   	entry = mk_pmd(new_page, vma->vm_page_prot);
>   	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> @@ -845,6 +851,12 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   	set_pmd_at(mm, haddr, pmd, entry);
>   	update_mmu_cache_pmd(vma, address, entry);
>   	page_remove_rmap(page);
> +	/*
> +	 * Finish the charge transaction under the page table lock to
> +	 * prevent split_huge_page() from dividing up the charge
> +	 * before it's fully transferred to the new page.
> +	 */
> +	mem_cgroup_end_migration(memcg, page, new_page, true);
>   	spin_unlock(&mm->page_table_lock);
>   
>   	put_page(page);			/* Drop the rmap reference */
> @@ -856,18 +868,14 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   
>   	unlock_page(new_page);
>   
> -	mem_cgroup_end_migration(memcg, page, new_page, true);
> -
>   	unlock_page(page);
>   	put_page(page);			/* Drop the local reference */
>   
>   	return;
>   
>   alloc_fail:
> -	if (new_page) {
> -		mem_cgroup_end_migration(memcg, page, new_page, false);
> +	if (new_page)
>   		put_page(new_page);
> -	}
>   
>   	unlock_page(page);
>   
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7acf43b..011e510 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3255,15 +3255,18 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
>   				  struct mem_cgroup **memcgp)
>   {
>   	struct mem_cgroup *memcg = NULL;
> +	unsigned int nr_pages = 1;
>   	struct page_cgroup *pc;
>   	enum charge_type ctype;
>   
>   	*memcgp = NULL;
>   
> -	VM_BUG_ON(PageTransHuge(page));
>   	if (mem_cgroup_disabled())
>   		return;
>   
> +	if (PageTransHuge(page))
> +		nr_pages <<= compound_order(page);
> +
>   	pc = lookup_page_cgroup(page);
>   	lock_page_cgroup(pc);
>   	if (PageCgroupUsed(pc)) {
> @@ -3325,7 +3328,7 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
>   	 * charged to the res_counter since we plan on replacing the
>   	 * old one and only one page is going to be left afterwards.
>   	 */
> -	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
> +	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
>   }
>   
>   /* remove redundant charge if migration failed*/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
