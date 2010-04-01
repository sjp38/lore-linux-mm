Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 21D0B6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 05:30:47 -0400 (EDT)
Date: Thu, 1 Apr 2010 10:30:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
	PageSwapCache pages
Message-ID: <20100401093022.GA621@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie> <1269940489-5776-15-git-send-email-mel@csn.ul.ie> <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com> <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com> <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com> <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 01, 2010 at 01:44:29PM +0900, Minchan Kim wrote:
> On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 1 Apr 2010 11:43:18 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki       /*
> >> >> diff --git a/mm/rmap.c b/mm/rmap.c
> >> >> index af35b75..d5ea1f2 100644
> >> >> --- a/mm/rmap.c
> >> >> +++ b/mm/rmap.c
> >> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
> >> >>
> >> >>       if (unlikely(PageKsm(page)))
> >> >>               return rmap_walk_ksm(page, rmap_one, arg);
> >> >> -     else if (PageAnon(page))
> >> >> +     else if (PageAnon(page)) {
> >> >> +             if (PageSwapCache(page))
> >> >> +                     return SWAP_AGAIN;
> >> >>               return rmap_walk_anon(page, rmap_one, arg);
> >> >
> >> > SwapCache has a condition as (PageSwapCache(page) && page_mapped(page) == true.
> >> >
> >>
> >> In case of tmpfs, page has swapcache but not mapped.
> >>
> >> > Please see do_swap_page(), PageSwapCache bit is cleared only when
> >> >
> >> > do_swap_page()...
> >> >       swap_free(entry);
> >> >        if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> >> >                try_to_free_swap(page);
> >> >
> >> > Then, PageSwapCache is cleared only when swap is freeable even if mapped.
> >> >
> >> > rmap_walk_anon() should be called and the check is not necessary.
> >>
> >> Frankly speaking, I don't understand what is Mel's problem, why he added
> >> Swapcache check in rmap_walk, and why do you said we don't need it.
> >>
> >> Could you explain more detail if you don't mind?
> >>
> > I may miss something.
> >
> > unmap_and_move()
> >  1. try_to_unmap(TTU_MIGRATION)
> >  2. move_to_newpage
> >  3. remove_migration_ptes
> >        -> rmap_walk()
> >
> > Then, to map a page back we unmapped we call rmap_walk().
> >
> > Assume a SwapCache which is mapped, then, PageAnon(page) == true.
> >
> >  At 1. try_to_unmap() will rewrite pte with swp_entry of SwapCache.
> >       mapcount goes to 0.
> >  At 2. SwapCache is copied to a new page.
> >  At 3. The new page is mapped back to the place. Now, newpage's mapcount is 0.
> >       Before patch, the new page is mapped back to all ptes.
> >       After patch, the new page is not mapped back because its mapcount is 0.
> >
> > I don't think shared SwapCache of anon is not an usual behavior, so, the logic
> > before patch is more attractive.
> >
> > If SwapCache is not mapped before "1", we skip "1" and rmap_walk will do nothing
> > because page->mapping is NULL.
> >
> 
> Thanks. I agree. We don't need the check.
> Then, my question is why Mel added the check in rmap_walk.
> He mentioned some BUG trigger and fixed things after this patch.
> What's it?

If I remove the check for (PageSwapCache(page) && !page_mapped(page))
in rmap_walk(), then the bug below occurs. The first one is lockdep going
bad because it's accessing a bad lock implying that anon_vma->lock is
already invalid. The bug that triggers after it is the list walk.

[  373.951347] INFO: trying to register non-static key.
[  373.984314] the code is fine but needs lockdep annotation.
[  374.020512] turning off the locking correctness validator.
[  374.020512] Pid: 4272, comm: bench-stresshig Not tainted 2.6.34-rc2-mm1-compaction-v7r5 #2
[  374.020512] Call Trace:
[  374.020512]  [<ffffffff810758f2>] __lock_acquire+0xf99/0x1776
[  374.020512]  [<ffffffff810761c5>] lock_acquire+0xf6/0x122
[  374.020512]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
[  374.020512]  [<ffffffff812fcfeb>] _raw_spin_lock+0x3b/0x47
[  374.020512]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
[  374.020512]  [<ffffffff810ef121>] rmap_walk+0x5c/0x16d
[  374.020512]  [<ffffffff81106396>] ? remove_migration_pte+0x0/0x234
[  374.677618]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  374.677618]  [<ffffffff81106914>] ? migrate_page_copy+0xa0/0x1ed
[  374.677618]  [<ffffffff81106ea4>] migrate_pages+0x3fc/0x5d3
[  374.880569]  [<ffffffff81106c56>] ? migrate_pages+0x1ae/0x5d3
[  374.994700]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  375.018405]  [<ffffffff81107e11>] ? compaction_alloc+0x0/0x283
[  375.097256]  [<ffffffff811079b0>] ? compact_zone+0x14e/0x4bd
[  375.097256]  [<ffffffff812fd851>] ? _raw_spin_unlock_irq+0x30/0x5d
[  375.097256]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  375.097256]  [<ffffffff81107b43>] compact_zone+0x2e1/0x4bd
[  375.097256]  [<ffffffff811082f2>] try_to_compact_pages+0x1de/0x248
[  375.516928]  [<ffffffff810d3cd2>] __alloc_pages_nodemask+0x45a/0x81c
[  375.516928]  [<ffffffff812fde14>] ? restore_args+0x0/0x30
[  375.620035]  [<ffffffff8103995e>] ? finish_task_switch+0x0/0xe3
[  375.684491]  [<ffffffff810fe297>] alloc_pages_current+0x9b/0xa4
[  375.803591]  [<ffffffffa00a9a58>] test_alloc_runtest+0x781/0x140a [highalloc]
[  375.803591]  [<ffffffff81076398>] ? lock_release_non_nested+0x97/0x267
[  375.803591]  [<ffffffffa00aa7ce>] vmr_write_proc+0xed/0x102 [highalloc]
[  375.803591]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  375.803591]  [<ffffffff812fd92e>] ? _raw_spin_unlock+0x35/0x51
[  375.803591]  [<ffffffff810e5a17>] ? do_wp_page+0x6af/0x763
[  375.803591]  [<ffffffff8115bb2a>] ? proc_file_write+0x45/0x92
[  376.322379]  [<ffffffff8115bb5d>] proc_file_write+0x78/0x92
[  376.349787]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  376.349787]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  376.349787]  [<ffffffff8115647a>] proc_reg_write+0x89/0xa6
[  376.349787]  [<ffffffff8110c1f6>] vfs_write+0xb3/0x15a
[  376.349787]  [<ffffffff8110c36b>] sys_write+0x4c/0x73
[  376.349787]  [<ffffffff81002d32>] system_call_fastpath+0x16/0x1b
[  376.786203] BUG: unable to handle kernel NULL pointer dereference at (null)
[  376.857874] IP: [<ffffffff810ef170>] rmap_walk+0xab/0x16d
[  376.929206] PGD 7f561067 PUD 7eba2067 PMD 0 
[  376.942703] Oops: 0000 [#1] PREEMPT SMP 
[  376.942703] last sysfs file: /sys/block/sr0/capability
[  377.072011] CPU 3 
[  377.116386] Modules linked in: highalloc trace_allocmap buddyinfo vmregress_core oprofile dm_crypt loop i2c_piix4 evdev processor serio_raw tpm_tis tpm tpm_bios i2c_core shpchp pci_hotplug button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sg sr_mod sd_mod cdrom ata_generic ahci libahci r8169 libata mii ide_pci_generic ide_core ehci_hcd ohci_hcd scsi_mod floppy thermal fan thermal_sys
[  377.520011] 
[  377.520011] Pid: 4272, comm: bench-stresshig Not tainted 2.6.34-rc2-mm1-compaction-v7r5 #2 GA-MA790GP-UD4H/GA-MA790GP-UD4H
[  377.637060] RIP: 0010:[<ffffffff810ef170>]  [<ffffffff810ef170>] rmap_walk+0xab/0x16d
[  377.787277] RSP: 0000:ffff880037a797a8  EFLAGS: 00010202
[  377.787277] RAX: 0000000000000000 RBX: ffffffffffffffe0 RCX: 0000000000000000
[  377.895088] RDX: 0000000000000101 RSI: ffffffff8152ea0f RDI: ffffffff810ef121
[  377.895088] RBP: ffff880037a79828 R08: ffff880037a79458 R09: ffff880037044000
[  377.895088] R10: ffffffff81067358 R11: ffff880037a79228 R12: 0000000000000001
[  377.895088] R13: ffff88007bbf6af0 R14: ffffea00019bd798 R15: ffff88007bbf6b28
[  377.895088] FS:  00007fa3e984d6e0(0000) GS:ffff880002380000(0000) knlGS:0000000000000000
[  378.366669] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  378.366669] CR2: 0000000000000000 CR3: 000000003784d000 CR4: 00000000000006e0
[  378.366669] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  378.366669] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  378.366669] Process bench-stresshig (pid: 4272, threadinfo ffff880037a78000, task ffff880037044000)
[  378.800010] Stack:
[  378.800010]  ffffea000027f920 ffffffff81106396 ffff880037a797f8 ffffffff81300dc1
[  378.907796] <0> ffff880037a797f8 ffffffff81106914 ffffea000027f920 ffffea000027f920
[  378.907796] <0> 0000000000000000 ffffea00019bd798 ffff880037a79828 ffffffff816a1cf0
[  378.907796] Call Trace:
[  378.907796]  [<ffffffff81106396>] ? remove_migration_pte+0x0/0x234
[  379.214225]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  379.296228]  [<ffffffff81106914>] ? migrate_page_copy+0xa0/0x1ed
[  379.296228]  [<ffffffff81106ea4>] migrate_pages+0x3fc/0x5d3
[  379.296228]  [<ffffffff81106c56>] ? migrate_pages+0x1ae/0x5d3
[  379.492124]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  379.492124]  [<ffffffff81107e11>] ? compaction_alloc+0x0/0x283
[  379.492124]  [<ffffffff811079b0>] ? compact_zone+0x14e/0x4bd
[  379.714743]  [<ffffffff812fd851>] ? _raw_spin_unlock_irq+0x30/0x5d
[  379.714743]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  379.714743]  [<ffffffff81107b43>] compact_zone+0x2e1/0x4bd
[  379.714743]  [<ffffffff811082f2>] try_to_compact_pages+0x1de/0x248
[  380.001915]  [<ffffffff810d3cd2>] __alloc_pages_nodemask+0x45a/0x81c
[  380.093011]  [<ffffffff812fde14>] ? restore_args+0x0/0x30
[  380.160604]  [<ffffffff8103995e>] ? finish_task_switch+0x0/0xe3
[  380.160604]  [<ffffffff810fe297>] alloc_pages_current+0x9b/0xa4
[  380.160604]  [<ffffffffa00a9a58>] test_alloc_runtest+0x781/0x140a [highalloc]
[  380.160604]  [<ffffffff81076398>] ? lock_release_non_nested+0x97/0x267
[  380.160604]  [<ffffffffa00aa7ce>] vmr_write_proc+0xed/0x102 [highalloc]
[  380.527282]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  380.600599]  [<ffffffff812fd92e>] ? _raw_spin_unlock+0x35/0x51
[  380.640179]  [<ffffffff810e5a17>] ? do_wp_page+0x6af/0x763
[  380.722097]  [<ffffffff8115bb2a>] ? proc_file_write+0x45/0x92
[  380.776200]  [<ffffffff8115bb5d>] proc_file_write+0x78/0x92
[  380.776200]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  380.936426]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  380.936426]  [<ffffffff8115647a>] proc_reg_write+0x89/0xa6
[  380.936426]  [<ffffffff8110c1f6>] vfs_write+0xb3/0x15a
[  380.936426]  [<ffffffff8110c36b>] sys_write+0x4c/0x73
[  381.197157]  [<ffffffff81002d32>] system_call_fastpath+0x16/0x1b
[  381.197157] Code: 22 48 3b 56 10 73 1c 48 83 fa f2 74 16 48 8b 4d 80 4c 89 f7 ff 55 88 83 f8 01 41 89 c4 0f 85 a8 00 00 00 48 8b 43 20 48 8d 58 e0 <48> 8b 43 20 0f 18 08 48 8d 43 20 49 39 c7 75 ab e9 8b 00 00 00 
[  381.512188] RIP  [<ffffffff810ef170>] rmap_walk+0xab/0x16d
[  381.541457]  RSP <ffff880037a797a8>
[  381.541457] CR2: 0000000000000000
[  381.667153] ---[ end trace b72e829e744f4e05 ]---
[  381.722475] note: bench-stresshig[4272] exited with preempt_count 2
[  381.797590] BUG: scheduling while atomic: bench-stresshig/4272/0x10000003
[  381.878912] INFO: lockdep is turned off.
[  381.925924] Modules linked in: highalloc trace_allocmap buddyinfo vmregress_core oprofile dm_crypt loop i2c_piix4 evdev processor serio_raw tpm_tis tpm tpm_bios i2c_core shpchp pci_hotplug button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sg sr_mod sd_mod cdrom ata_generic ahci libahci r8169 libata mii ide_pci_generic ide_core ehci_hcd ohci_hcd scsi_mod floppy thermal fan thermal_sys
[  382.368391] Pid: 4272, comm: bench-stresshig Tainted: G      D     2.6.34-rc2-mm1-compaction-v7r5 #2
[  382.477829] Call Trace:
[  382.507155]  [<ffffffff81072e3d>] ? __debug_show_held_locks+0x1b/0x24
[  382.584339]  [<ffffffff81039959>] __schedule_bug+0x77/0x7c
[  382.650075]  [<ffffffff812fa32d>] schedule+0xcc/0x723
[  382.710610]  [<ffffffff8103bd9d>] __cond_resched+0x18/0x24
[  382.776348]  [<ffffffff812faac0>] _cond_resched+0x29/0x34
[  382.841046]  [<ffffffff810e6521>] unmap_vmas+0x76e/0x96b
[  382.904702]  [<ffffffff810eb14f>] exit_mmap+0xd5/0x17a
[  382.966280]  [<ffffffff81043be0>] mmput+0x46/0xf0
[  383.022654]  [<ffffffff81048179>] ? exit_mm+0xd9/0x14c
[  383.084231]  [<ffffffff810481dd>] exit_mm+0x13d/0x14c
[  383.144767]  [<ffffffff812fd879>] ? _raw_spin_unlock_irq+0x58/0x5d
[  383.218825]  [<ffffffff812237f6>] ? tty_audit_exit+0x28/0x91
[  383.286643]  [<ffffffff81049e6b>] do_exit+0x20f/0x70d
[  383.347179]  [<ffffffff810472e4>] ? kmsg_dump+0x153/0x16d
[  383.411878]  [<ffffffff812fed94>] oops_end+0xbe/0xc6
[  383.471373]  [<ffffffff81028005>] no_context+0x1f8/0x207
[  383.535029]  [<ffffffff810281e7>] __bad_area_nosemaphore+0x1d3/0x1f9
[  383.611170]  [<ffffffff810758f2>] ? __lock_acquire+0xf99/0x1776
[  383.682107]  [<ffffffff812fcdd6>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  383.759289]  [<ffffffff810a38e9>] ? __rcu_process_callbacks+0xa7/0x30b
[  383.837507]  [<ffffffff81028220>] bad_area_nosemaphore+0x13/0x15
[  383.909484]  [<ffffffff81300c4e>] do_page_fault+0x24e/0x3b8
[  383.976259]  [<ffffffff81067358>] ? up+0x14/0x3e
[  384.031597]  [<ffffffff812fe075>] page_fault+0x25/0x30
[  384.093169]  [<ffffffff81067358>] ? up+0x14/0x3e
[  384.148504]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
[  384.212163]  [<ffffffff810ef170>] ? rmap_walk+0xab/0x16d
[  384.275818]  [<ffffffff810ef121>] ? rmap_walk+0x5c/0x16d
[  384.339476]  [<ffffffff81106396>] ? remove_migration_pte+0x0/0x234
[  384.413536]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  384.483434]  [<ffffffff81106914>] ? migrate_page_copy+0xa0/0x1ed
[  384.555412]  [<ffffffff81106ea4>] migrate_pages+0x3fc/0x5d3
[  384.622190]  [<ffffffff81106c56>] ? migrate_pages+0x1ae/0x5d3
[  384.691046]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  384.771347]  [<ffffffff81107e11>] ? compaction_alloc+0x0/0x283
[  384.841246]  [<ffffffff811079b0>] ? compact_zone+0x14e/0x4bd
[  384.909062]  [<ffffffff812fd851>] ? _raw_spin_unlock_irq+0x30/0x5d
[  384.983120]  [<ffffffff81073a24>] ? trace_hardirqs_on_caller+0x110/0x134
[  385.063421]  [<ffffffff81107b43>] compact_zone+0x2e1/0x4bd
[  385.129158]  [<ffffffff811082f2>] try_to_compact_pages+0x1de/0x248
[  385.203215]  [<ffffffff810d3cd2>] __alloc_pages_nodemask+0x45a/0x81c
[  385.279353]  [<ffffffff812fde14>] ? restore_args+0x0/0x30
[  385.344053]  [<ffffffff8103995e>] ? finish_task_switch+0x0/0xe3
[  385.414988]  [<ffffffff810fe297>] alloc_pages_current+0x9b/0xa4
[  385.485927]  [<ffffffffa00a9a58>] test_alloc_runtest+0x781/0x140a [highalloc]
[  385.571427]  [<ffffffff81076398>] ? lock_release_non_nested+0x97/0x267
[  385.649647]  [<ffffffffa00aa7ce>] vmr_write_proc+0xed/0x102 [highalloc]
[  385.728907]  [<ffffffff81300dc1>] ? sub_preempt_count+0x9/0x83
[  385.798800]  [<ffffffff812fd92e>] ? _raw_spin_unlock+0x35/0x51
[  385.868700]  [<ffffffff810e5a17>] ? do_wp_page+0x6af/0x763
[  385.934436]  [<ffffffff8115bb2a>] ? proc_file_write+0x45/0x92
[  386.003294]  [<ffffffff8115bb5d>] proc_file_write+0x78/0x92
[  386.070072]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  386.137888]  [<ffffffff8115bae5>] ? proc_file_write+0x0/0x92
[  386.205708]  [<ffffffff8115647a>] proc_reg_write+0x89/0xa6
[  386.271442]  [<ffffffff8110c1f6>] vfs_write+0xb3/0x15a
[  386.333019]  [<ffffffff8110c36b>] sys_write+0x4c/0x73
[  386.393556]  [<ffffffff81002d32>] system_call_fastpath+0x16/0x1b

> Is it really related to this logic?
> I don't think so or we are missing something.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
