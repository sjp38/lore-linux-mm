Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 2D0066B007E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 00:54:09 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1536578pbc.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 21:54:08 -0700 (PDT)
Date: Tue, 27 Mar 2012 21:53:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: hung task (handle_pte_fault)
In-Reply-To: <CA+1xoqc64Nq_GwC=x+rYxxCV9G3J5q804RpKVkGCAap3Votoag@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1203272145250.5922@eggly.anvils>
References: <CA+1xoqczdjPD0OGEuZAu6f9Q8gxAQuhVL-ZhhUcELaz_B=Jfjg@mail.gmail.com> <20120326161705.b96636db.akpm@linux-foundation.org> <CA+1xoqc64Nq_GwC=x+rYxxCV9G3J5q804RpKVkGCAap3Votoag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1143962317-1332910428=:5922"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1143962317-1332910428=:5922
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 28 Mar 2012, Sasha Levin wrote:
> On Tue, Mar 27, 2012 at 1:17 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > The task is waiting for IO to complete against a page, and it isn't
> > happening.
> >
> > There are quite a lot of things which could cause this, alas. =A0VM,
> > readahead, scheduler, core wait/wakeup code, IO system, interrupt
> > system (if it happens outside KVM, I guess).
> >
> > So.... =A0ugh. =A0Hopefully someone will hit this in a situation where =
it
> > can be narrowed down or bisected.
>=20
> I've only managed to reproduce it once, and was unable to get anything
> useful out of it due to technical reasons.
>=20
> The good part is that I've managed to hit something similar (although
> I'm not 100% sure it's the same problem as the one in the original
> mail).

I don't think this one has anything to do with the first you posted,
but it does look like a good catch against current linux-next, where
pagemap_pte_range() appears to do a spin_lock(&walk->mm->page_table_lock)
which should have been removed by "thp: optimize away unnecessary page
table locking".  Some kind of mismerge perhaps: Horiguchi-san added to Cc.

Hugh

>=20
> Here's the spew:
>=20
> [ 1450.628565] BUG: sleeping function called from invalid context at
> fs/proc/task_mmu.c:826
> [ 1450.632828] in_atomic(): 1, irqs_disabled(): 0, pid: 17086, name: trin=
ity
> [ 1450.637242] 2 locks held by trinity/17086:
> [ 1450.639308]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124aee3>]
> pagemap_read+0x263/0x340
> [ 1450.656425]  #1:  (&(&mm->page_table_lock)->rlock){+.+.-.}, at:
> [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1450.669409] Pid: 17086, comm: trinity Not tainted
> 3.3.0-next-20120327-sasha #70
> [ 1450.674559] Call Trace:
> [ 1450.676252]  [<ffffffff810eb609>] __might_sleep+0x149/0x200
> [ 1450.679876]  [<ffffffff8124b410>] ? pagemap_pte_range+0x70/0x2d0
> [ 1450.681392]  [<ffffffff8124b4bf>] pagemap_pte_range+0x11f/0x2d0
> [ 1450.684906]  [<ffffffff811191bf>] ? lock_release_non_nested+0x30f/0x35=
0
> [ 1450.687309]  [<ffffffff811ad5e8>] walk_pmd_range+0x118/0x200
> [ 1450.689444]  [<ffffffff811ad7e8>] walk_pud_range+0x118/0x150
> [ 1450.691498]  [<ffffffff811ada31>] walk_page_range+0x211/0x260
> [ 1450.693574]  [<ffffffff8124aef2>] pagemap_read+0x272/0x340
> [ 1450.695271]  [<ffffffff8124b3a0>] ? clear_refs_pte_range+0x190/0x190
> [ 1450.700743]  [<ffffffff81249b10>] ? get_vmalloc_info+0x120/0x120
> [ 1450.704875]  [<ffffffff8124b010>] ? m_stop+0x50/0x50
> [ 1450.707599]  [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1450.709751]  [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1450.713269]  [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> [ 1450.715966] BUG: scheduling while atomic: trinity/17086/0x10000002
> [ 1450.722426] 2 locks held by trinity/17086:
> [ 1450.724283]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8124aee3>]
> pagemap_read+0x263/0x340
> [ 1450.727407]  #1:  (&(&mm->page_table_lock)->rlock){+.+.-.}, at:
> [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1450.732867] Pid: 17086, comm: trinity Not tainted
> 3.3.0-next-20120327-sasha #70
> [ 1450.735580] Call Trace:
> [ 1450.736529]  [<ffffffff810e1b9c>] __schedule_bug+0x8c/0xa0
> [ 1450.738627]  [<ffffffff826ce28d>] __schedule+0x6bd/0x6d0
> [ 1450.740642]  [<ffffffff810e7e83>] __cond_resched+0x13/0x20
> [ 1450.742691]  [<ffffffff826ce4dc>] _cond_resched+0x2c/0x40
> [ 1450.745357]  [<ffffffff8124b4c4>] pagemap_pte_range+0x124/0x2d0
> [ 1450.747744]  [<ffffffff811191bf>] ? lock_release_non_nested+0x30f/0x35=
0
> [ 1450.752051]  [<ffffffff811ad5e8>] walk_pmd_range+0x118/0x200
> [ 1450.755811]  [<ffffffff811ad7e8>] walk_pud_range+0x118/0x150
> [ 1450.758000]  [<ffffffff811ada31>] walk_page_range+0x211/0x260
> [ 1450.760054]  [<ffffffff8124aef2>] pagemap_read+0x272/0x340
> [ 1450.762597]  [<ffffffff8124b3a0>] ? clear_refs_pte_range+0x190/0x190
> [ 1450.765484]  [<ffffffff81249b10>] ? get_vmalloc_info+0x120/0x120
> [ 1450.767166]  [<ffffffff8124b010>] ? m_stop+0x50/0x50
> [ 1450.768858]  [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1450.770809]  [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1450.772074]  [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> [ 1450.791135]
> [ 1450.791397] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [ 1450.792019] [ INFO: possible circular locking dependency detected ]
> [ 1450.792019] 3.3.0-next-20120327-sasha #70 Not tainted
> [ 1450.792019] -------------------------------------------------------
> [ 1450.792019] trinity/17086 is trying to acquire lock:
> [ 1450.792019]  (&mm->mmap_sem){++++++}, at: [<ffffffff8124aee3>]
> pagemap_read+0x263/0x340
> [ 1450.792019]
> [ 1450.792019] but task is already holding lock:
> [ 1450.792019]  (&(&mm->page_table_lock)->rlock){+.+.-.}, at:
> [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1450.792019]
> [ 1450.792019] which lock already depends on the new lock.
> [ 1450.792019]
> [ 1450.792019]
> [ 1450.792019] the existing dependency chain (in reverse order) is:
> [ 1450.813449]
> [ 1450.813449] -> #1 (&(&mm->page_table_lock)->rlock){+.+.-.}:
> [ 1450.813449]        [<ffffffff81115b9c>] validate_chain.clone.26+0x88c/=
0x960
> [ 1450.813449]        [<ffffffff81118735>] __lock_acquire+0x3f5/0xb70
> [ 1450.813449]        [<ffffffff81119553>] lock_acquire+0xc3/0x100
> [ 1450.813449]        [<ffffffff826cf71b>] _raw_spin_lock+0x3b/0x70
> [ 1450.813449]        [<ffffffff8119cd84>] __pmd_alloc+0x44/0x100
> [ 1450.813449]        [<ffffffff811a4fce>] alloc_new_pmd.clone.3+0x13e/0x=
160
> [ 1450.813449]        [<ffffffff811a52cd>] move_page_tables+0x12d/0x3a0
> [ 1450.813449]        [<ffffffff811ea1e7>] shift_arg_pages+0xc7/0x190
> [ 1450.813449]        [<ffffffff811ebb5b>] setup_arg_pages+0x1db/0x200
> [ 1450.813449]        [<ffffffff8123a445>] load_elf_binary+0x455/0xe20
> [ 1450.813449]        [<ffffffff811ec3f1>] search_binary_handler+0x141/0x=
2d0
> [ 1450.813449]        [<ffffffff811ec82d>] do_execve_common.clone.32+0x2a=
d/0x340
> [ 1450.813449]        [<ffffffff811ec8d6>] do_execve+0x16/0x20
> [ 1450.813449]        [<ffffffff810579b5>] sys_execve+0x45/0x70
> [ 1450.813449]        [<ffffffff826d26a8>] kernel_execve+0x68/0xd0
> [ 1450.813449]        [<ffffffff81002130>] init_post+0xb0/0xd0
> [ 1450.813449]        [<ffffffff83927f3b>] kernel_init+0x1d9/0x1eb
> [ 1450.813449]        [<ffffffff826d2634>] kernel_thread_helper+0x4/0x10
> [ 1450.813449]
> [ 1450.813449] -> #0 (&mm->mmap_sem){++++++}:
> [ 1450.813449]        [<ffffffff811152e1>] check_prev_add+0x6b1/0x6e0
> [ 1450.813449]        [<ffffffff81115b9c>] validate_chain.clone.26+0x88c/=
0x960
> [ 1450.813449]        [<ffffffff81118735>] __lock_acquire+0x3f5/0xb70
> [ 1450.813449]        [<ffffffff81119553>] lock_acquire+0xc3/0x100
> [ 1450.813449]        [<ffffffff826cd707>] down_read+0x47/0x90
> [ 1450.813449]        [<ffffffff8124aee3>] pagemap_read+0x263/0x340
> [ 1450.813449]        [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1450.813449]        [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1450.813449]        [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> [ 1450.813449]
> [ 1450.813449] other info that might help us debug this:
> [ 1450.813449]
> [ 1450.813449]  Possible unsafe locking scenario:
> [ 1450.813449]
> [ 1450.813449]        CPU0                    CPU1
> [ 1450.813449]        ----                    ----
> [ 1450.813449]   lock(&(&mm->page_table_lock)->rlock);
> [ 1450.813449]                                lock(&mm->mmap_sem);
> [ 1450.813449]
> lock(&(&mm->page_table_lock)->rlock);
> [ 1450.813449]   lock(&mm->mmap_sem);
> [ 1450.813449]
> [ 1450.813449]  *** DEADLOCK ***
> [ 1450.813449]
> [ 1450.813449] 1 lock held by trinity/17086:
> [ 1450.813449]  #0:  (&(&mm->page_table_lock)->rlock){+.+.-.}, at:
> [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1450.813449]
> [ 1450.813449] stack backtrace:
> [ 1450.813449] Pid: 17086, comm: trinity Not tainted
> 3.3.0-next-20120327-sasha #70
> [ 1450.813449] Call Trace:
> [ 1450.813449]  [<ffffffff81113fcf>] print_circular_bug+0x10f/0x120
> [ 1450.813449]  [<ffffffff811152e1>] check_prev_add+0x6b1/0x6e0
> [ 1450.813449]  [<ffffffff81115b9c>] validate_chain.clone.26+0x88c/0x960
> [ 1450.813449]  [<ffffffff81118735>] __lock_acquire+0x3f5/0xb70
> [ 1450.813449]  [<ffffffff8124b410>] ? pagemap_pte_range+0x70/0x2d0
> [ 1450.813449]  [<ffffffff8124b410>] ? pagemap_pte_range+0x70/0x2d0
> [ 1450.813449]  [<ffffffff811ad5e8>] ? walk_pmd_range+0x118/0x200
> [ 1450.813449]  [<ffffffff81119553>] lock_acquire+0xc3/0x100
> [ 1450.813449]  [<ffffffff8124aee3>] ? pagemap_read+0x263/0x340
> [ 1450.813449]  [<ffffffff826cd707>] down_read+0x47/0x90
> [ 1450.813449]  [<ffffffff8124aee3>] ? pagemap_read+0x263/0x340
> [ 1450.813449]  [<ffffffff810dc02e>] ? up_read+0x1e/0x40
> [ 1450.813449]  [<ffffffff8124aee3>] pagemap_read+0x263/0x340
> [ 1450.813449]  [<ffffffff8124b3a0>] ? clear_refs_pte_range+0x190/0x190
> [ 1450.813449]  [<ffffffff81249b10>] ? get_vmalloc_info+0x120/0x120
> [ 1450.813449]  [<ffffffff8124b010>] ? m_stop+0x50/0x50
> [ 1450.813449]  [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1450.813449]  [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1450.813449]  [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> 391000 iterations.
> 606000 iterations.
> [ 1476.139003] BUG: soft lockup - CPU#0 stuck for 22s! [trinity:17086]
> [ 1476.139012] irq event stamp: 4409
> [ 1476.139012] hardirqs last  enabled at (4409): [<ffffffff826cfa4b>]
> _raw_spin_unlock_irq+0x2b/0x70
> [ 1476.139012] hardirqs last disabled at (4408): [<ffffffff826cf834>]
> _raw_spin_lock_irq+0x24/0x90
> [ 1476.139012] softirqs last  enabled at (4406): [<ffffffff810b9ac3>]
> __do_softirq+0x133/0x180
> [ 1476.139012] softirqs last disabled at (4361): [<ffffffff826d272c>]
> call_softirq+0x1c/0x30
> [ 1476.139012] CPU 0
> [ 1476.139012] Pid: 17086, comm: trinity Not tainted
> 3.3.0-next-20120327-sasha #70
> [ 1476.139012] RIP: 0010:[<ffffffff81056b6c>]  [<ffffffff81056b6c>]
> native_read_tsc+0xc/0x20
> [ 1476.139012] RSP: 0018:ffff880006a71c00  EFLAGS: 00000286
> [ 1476.139012] RAX: 0000000000000359 RBX: ffffffff826d07b4 RCX: 000000001=
27bc595
> [ 1476.139012] RDX: 0000000000000359 RSI: ffffffff82ed0b9f RDI: 000000000=
0000001
> [ 1476.139012] RBP: ffff880006a71c38 R08: 0000000000000000 R09: 000000000=
0000002
> [ 1476.139012] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88000=
6a71b78
> [ 1476.139012] R13: ffff8800253a8000 R14: ffff880006a70000 R15: ffff88000=
6a71fd8
> [ 1476.139012] FS:  00007feb180a7700(0000) GS:ffff88003d600000(0000)
> knlGS:0000000000000000
> [ 1476.139012] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1476.139012] CR2: 0000000000ec86b0 CR3: 0000000023814000 CR4: 000000000=
00406f0
> [ 1476.139012] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [ 1476.139012] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
> [ 1476.139012] Process trinity (pid: 17086, threadinfo
> ffff880006a70000, task ffff8800253a8000)
> [ 1476.139012] Stack:
> [ 1476.139012]  ffffffff818850df 0000000000000018 ffff8800350ad060
> 0000000011c28537
> [ 1476.139012]  00000000948b09e0 0000000000000001 ffff880035177b10
> ffff880006a71c48
> [ 1476.139012]  ffffffff818851ea ffff880006a71c88 ffffffff81899972
> ffff880006a71c88
> [ 1476.139012] Call Trace:
> [ 1476.139012]  [<ffffffff818850df>] ? delay_tsc+0x3f/0x120
> [ 1476.139012]  [<ffffffff818851ea>] __delay+0xa/0x10
> [ 1476.139012]  [<ffffffff81899972>] do_raw_spin_lock+0xf2/0x140
> [ 1476.139012]  [<ffffffff826cf73b>] _raw_spin_lock+0x5b/0x70
> [ 1476.139012]  [<ffffffff8124b410>] ? pagemap_pte_range+0x70/0x2d0
> [ 1476.139012]  [<ffffffff8188640e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [ 1476.139012]  [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1476.139012]  [<ffffffff811ad5e8>] walk_pmd_range+0x118/0x200
> [ 1476.139012]  [<ffffffff811ad7e8>] walk_pud_range+0x118/0x150
> [ 1476.139012]  [<ffffffff811ada31>] walk_page_range+0x211/0x260
> [ 1476.139012]  [<ffffffff8124aef2>] pagemap_read+0x272/0x340
> [ 1476.139012]  [<ffffffff8124b3a0>] ? clear_refs_pte_range+0x190/0x190
> [ 1476.139012]  [<ffffffff81249b10>] ? get_vmalloc_info+0x120/0x120
> [ 1476.139012]  [<ffffffff8124b010>] ? m_stop+0x50/0x50
> [ 1476.139012]  [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1476.139012]  [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1476.139012]  [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> [ 1476.139012] Code: 02 48 c7 43 08 00 00 00 00 48 89 03 48 83 c4 08
> 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 31$
> [ 1476.139012] Call Trace:
> [ 1476.139012]  [<ffffffff818850df>] ? delay_tsc+0x3f/0x120
> [ 1476.139012]  [<ffffffff818851ea>] __delay+0xa/0x10
> [ 1476.139012]  [<ffffffff81899972>] do_raw_spin_lock+0xf2/0x140
> [ 1476.139012]  [<ffffffff826cf73b>] _raw_spin_lock+0x5b/0x70
> [ 1476.139012]  [<ffffffff8124b410>] ? pagemap_pte_range+0x70/0x2d0
> [ 1476.139012]  [<ffffffff8188640e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [ 1476.139012]  [<ffffffff8124b410>] pagemap_pte_range+0x70/0x2d0
> [ 1476.139012]  [<ffffffff811ad5e8>] walk_pmd_range+0x118/0x200
> [ 1476.139012]  [<ffffffff811ad7e8>] walk_pud_range+0x118/0x150
> [ 1476.139012]  [<ffffffff811ada31>] walk_page_range+0x211/0x260
> [ 1476.139012]  [<ffffffff8124aef2>] pagemap_read+0x272/0x340
> [ 1476.139012]  [<ffffffff8124b3a0>] ? clear_refs_pte_range+0x190/0x190
> [ 1476.139012]  [<ffffffff81249b10>] ? get_vmalloc_info+0x120/0x120
> [ 1476.139012]  [<ffffffff8124b010>] ? m_stop+0x50/0x50
> [ 1476.139012]  [<ffffffff811e3a93>] vfs_read+0xc3/0x180
> [ 1476.139012]  [<ffffffff811e3e3f>] sys_read+0x4f/0xa0
> [ 1476.139012]  [<ffffffff826d107d>] system_call_fastpath+0x1a/0x1f
> [ 1476.139012] Kernel panic - not syncing: softlockup: hung tasks
> [ 1476.139012] Rebooting in 1 seconds..  # lkvm run -k ./bzImage -m
> 1024 -c 8 --name run
>=20
--8323584-1143962317-1332910428=:5922--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
