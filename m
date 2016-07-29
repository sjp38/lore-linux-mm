Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED7CF6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 14:39:32 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so40220163lfg.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:39:32 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id eo1si20110624wjb.236.2016.07.29.11.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 11:39:30 -0700 (PDT)
Date: Fri, 29 Jul 2016 14:39:25 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.7+] various memory corruption reports.
Message-ID: <20160729183925.GA28376@codemonkey.org.uk>
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
 <20160729154929.GA30611@codemonkey.org.uk>
 <579B9339.7030707@gmail.com>
 <579B98B8.40007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579B98B8.40007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 29, 2016 at 08:56:08PM +0300, Andrey Ryabinin wrote:

 > >>  > I suspect this is false positives due to changes in KASAN.
 > >>  > Bisection probably will point to
 > >>  > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
 > >>  > stackdepot, enable memory quarantine for SLUB)"
 > >>
 > >> good call. reverting that changeset seems to have solved it.
 > > Could you please try with this?
 > Actually, this is not quite right, it should be like this:


Seems to have stopped the corruption, but now I get NMi watchdog traces..


[  109.158553] NMI watchdog: Watchdog detected hard LOCKUP on cpu 2irq event stamp: 1411258
[  109.158797] hardirqs last  enabled at (1411257): [<ffffffff98485c27>] get_page_from_freelist+0x897/0x1bb0
[  109.159034] hardirqs last disabled at (1411258): [<ffffffff99a08e29>] _raw_spin_lock_irq+0x19/0x80
[  109.159246] softirqs last  enabled at (1411096): [<ffffffff99a0cdee>] __do_softirq+0x66e/0x9a7
[  109.159457] softirqs last disabled at (1411089): [<ffffffff9813bd78>] irq_exit+0x118/0x140
[  109.159646] CPU: 2 PID: 2998 Comm: trinity-c6 Not tainted 4.7.0-think+ #12
[  109.159883]  ffff880461380434 00000000f39ba2d9 ffff88046880bab8 ffffffff98a48532
[  109.160050]  0000000000000000 0000000000000002 ffff88046880bad8 ffffffff98357fbb
[  109.160218]  ffff880461380008 ffff88046880bc00 ffff88046880bb20 ffffffff9842f7d1
[  109.160385] Call Trace:
[  109.160439]  <NMI>  [<ffffffff98a48532>] dump_stack+0x68/0x96
[  109.160568]  [<ffffffff98357fbb>] watchdog_overflow_callback+0x15b/0x190
[  109.160721]  [<ffffffff9842f7d1>] __perf_event_overflow+0x1b1/0x540
[  109.172185]  [<ffffffff98455b14>] perf_event_overflow+0x14/0x20
[  109.183591]  [<ffffffff9801976a>] intel_pmu_handle_irq+0x36a/0xad0
[  109.194988]  [<ffffffff98019400>] ? intel_pmu_save_and_restart+0xe0/0xe0
[  109.206444]  [<ffffffff980571e9>] ? nmi_handle+0x2b9/0x480
[  109.218066]  [<ffffffff9836eb79>] ? is_ftrace_trampoline+0xa9/0x100
[  109.229782]  [<ffffffff9800ba4c>] perf_event_nmi_handler+0x2c/0x50
[  109.241370]  [<ffffffff98057058>] nmi_handle+0x128/0x480
[  109.252853]  [<ffffffff98056f35>] ? nmi_handle+0x5/0x480
[  109.264293]  [<ffffffff9836eb79>] ? is_ftrace_trampoline+0xa9/0x100
[  109.275713]  [<ffffffff980576d2>] default_do_nmi+0xb2/0x210
[  109.287158]  [<ffffffff980579da>] do_nmi+0x1aa/0x220
[  109.298562]  [<ffffffff99a0bb07>] end_repeat_nmi+0x1a/0x1e
[  109.309964]  [<ffffffff9846ca45>] ? __add_to_page_cache_locked+0x335/0xaa0
[  109.321366]  [<ffffffff9836eb79>] ? is_ftrace_trampoline+0xa9/0x100
[  109.332776]  [<ffffffff9836eb79>] ? is_ftrace_trampoline+0xa9/0x100
[  109.344091]  [<ffffffff9836eb79>] ? is_ftrace_trampoline+0xa9/0x100
[  109.355283]  <<EOE>>  [<ffffffff981871e6>] __kernel_text_address+0x86/0xb0
[  109.366438]  [<ffffffff98055c4b>] print_context_stack+0x7b/0x100
[  109.377709]  [<ffffffff98054e9b>] dump_trace+0x12b/0x350
[  109.388863]  [<ffffffff9857db12>] ? qlist_free_all+0x42/0x100
[  109.399976]  [<ffffffff98076ceb>] save_stack_trace+0x2b/0x50
[  109.411082]  [<ffffffff98573003>] set_track+0x83/0x140
[  109.422152]  [<ffffffff98575f4a>] free_debug_processing+0x1aa/0x420
[  109.433268]  [<ffffffff9857db12>] ? qlist_free_all+0x42/0x100
[  109.444334]  [<ffffffff9857db12>] ? qlist_free_all+0x42/0x100
[  109.455345]  [<ffffffff98578506>] __slab_free+0x1d6/0x2e0
[  109.466262]  [<ffffffff98aab907>] ? debug_smp_processor_id+0x17/0x20
[  109.477239]  [<ffffffff98226d2d>] ? get_lock_stats+0x1d/0x90
[  109.487929]  [<ffffffff9857db12>] ? qlist_free_all+0x42/0x100
[  109.498521]  [<ffffffff9857a9b6>] ___cache_free+0xb6/0xd0
[  109.509125]  [<ffffffff9857db53>] qlist_free_all+0x83/0x100
[  109.519652]  [<ffffffff9857df07>] quarantine_reduce+0x177/0x1b0
[  109.530159]  [<ffffffff9857c423>] kasan_kmalloc+0xf3/0x100
[  109.540676]  [<ffffffff98226bfd>] ? trace_hardirqs_off+0xd/0x10
[  109.551159]  [<ffffffff98a542d6>] ? radix_tree_node_alloc+0x96/0x190
[  109.561658]  [<ffffffff9857c922>] kasan_slab_alloc+0x12/0x20
[  109.572120]  [<ffffffff98577549>] kmem_cache_alloc+0x109/0x3e0
[  109.582555]  [<ffffffff9859ebf1>] ? get_mem_cgroup_from_mm+0x3c1/0x4c0
[  109.593006]  [<ffffffff98a542d6>] radix_tree_node_alloc+0x96/0x190
[  109.603406]  [<ffffffff98a56e1b>] __radix_tree_create+0x32b/0xa10
[  109.613785]  [<ffffffff9846ca10>] ? __add_to_page_cache_locked+0x300/0xaa0
[  109.624148]  [<ffffffff9846ca45>] __add_to_page_cache_locked+0x335/0xaa0
[  109.634508]  [<ffffffff9846c710>] ? filemap_map_pages+0xcc0/0xcc0
[  109.644814]  [<ffffffff98487b90>] ? gfp_pfmemalloc_allowed+0x130/0x130
[  109.655110]  [<ffffffff98aab907>] ? debug_smp_processor_id+0x17/0x20
[  109.665296]  [<ffffffff98226d2d>] ? get_lock_stats+0x1d/0x90
[  109.675494]  [<ffffffff988a5401>] ? jbd2_journal_stop+0x8f1/0x1390
[  109.685622]  [<ffffffff9846d2ad>] add_to_page_cache_lru+0xdd/0x2c0
[  109.695761]  [<ffffffff9846d1d0>] ? add_to_page_cache_locked+0x20/0x20
[  109.705885]  [<ffffffff9846b4e9>] ? find_get_entry+0x259/0x490
[  109.715981]  [<ffffffff9846b295>] ? find_get_entry+0x5/0x490
[  109.726074]  [<ffffffff9846d621>] pagecache_get_page+0x191/0x620
[  109.736160]  [<ffffffff9846db01>] grab_cache_page_write_begin+0x51/0x80
[  109.746224]  [<ffffffff982712c0>] ? rcu_read_lock_sched_held+0xf0/0x130
[  109.756277]  [<ffffffff98797722>] ext4_da_write_begin+0x1c2/0xaa0
[  109.766287]  [<ffffffff98797560>] ? ext4_write_begin+0xe90/0xe90
[  109.776312]  [<ffffffff98493318>] ? balance_dirty_pages_ratelimited+0x498/0x14c0
[  109.786347]  [<ffffffff984692c0>] generic_perform_write+0x290/0x520
[  109.796322]  [<ffffffff982712c0>] ? rcu_read_lock_sched_held+0xf0/0x130
[  109.806352]  [<ffffffff98469030>] ? generic_file_readonly_mmap+0x1b0/0x1b0
[  109.816359]  [<ffffffff9862da01>] ? __mnt_drop_write_file+0x31/0x40
[  109.826345]  [<ffffffff9861bf0a>] ? file_update_time+0x24a/0x3a0
[  109.836261]  [<ffffffff9861bcc0>] ? should_remove_suid+0xc0/0xc0
[  109.846155]  [<ffffffff98226d2d>] ? get_lock_stats+0x1d/0x90
[  109.855976]  [<ffffffff984710a4>] __generic_file_write_iter+0x314/0x530
[  109.865741]  [<ffffffff9876e044>] ext4_file_write_iter+0x1b4/0xf10
[  109.875549]  [<ffffffff98aab907>] ? debug_smp_processor_id+0x17/0x20
[  109.885328]  [<ffffffff98226d2d>] ? get_lock_stats+0x1d/0x90
[  109.895081]  [<ffffffff9876de90>] ? ext4_unwritten_wait+0x1e0/0x1e0
[  109.904849]  [<ffffffff98231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[  109.914646]  [<ffffffff98502ca6>] ? __might_fault+0xf6/0x1b0
[  109.924394]  [<ffffffff98502d16>] ? __might_fault+0x166/0x1b0
[  109.934012]  [<ffffffff9857c0d4>] ? kasan_check_write+0x14/0x20
[  109.943677]  [<ffffffff985c9f3f>] do_iter_readv_writev+0x23f/0x510
[  109.953248]  [<ffffffff985c9d00>] ? vfs_iter_write+0x550/0x550
[  109.962810]  [<ffffffff98223ef7>] ? percpu_down_read+0x57/0xa0
[  109.972324]  [<ffffffff985d3224>] ? __sb_start_write+0xb4/0xf0
[  109.981729]  [<ffffffff985cbe94>] do_readv_writev+0x394/0x6a0
[  109.991103]  [<ffffffff9876de90>] ? ext4_unwritten_wait+0x1e0/0x1e0
[  110.000348]  [<ffffffff985cbb00>] ? vfs_write+0x4c0/0x4c0
[  110.009503]  [<ffffffff9823115f>] ? mark_held_locks+0xcf/0x130
[  110.018660]  [<ffffffff999ff3fd>] ? mutex_lock_nested+0x4ed/0x8d0
[  110.027762]  [<ffffffff999ff418>] ? mutex_lock_nested+0x508/0x8d0
[  110.036778]  [<ffffffff98625c22>] ? __fdget_pos+0x92/0xc0
[  110.045809]  [<ffffffff98231cd0>] ? debug_check_no_locks_freed+0x280/0x280
[  110.054841]  [<ffffffff982acc09>] ? do_setitimer+0x389/0x7f0
[  110.063794]  [<ffffffff98625c22>] ? __fdget_pos+0x92/0xc0
[  110.072727]  [<ffffffff982315b9>] ? trace_hardirqs_on_caller+0x3f9/0x580
[  110.081643]  [<ffffffff999fef10>] ? mutex_lock_interruptible_nested+0x9e0/0x9e0
[  110.090467]  [<ffffffff98aab907>] ? debug_smp_processor_id+0x17/0x20
[  110.099135]  [<ffffffff98226d2d>] ? get_lock_stats+0x1d/0x90
[  110.107815]  [<ffffffff985cc6b5>] vfs_writev+0x75/0xb0
[  110.116379]  [<ffffffff98625c22>] ? __fdget_pos+0x92/0xc0
[  110.124868]  [<ffffffff985cc7d5>] do_writev+0xe5/0x280
[  110.133279]  [<ffffffff985cc6f0>] ? vfs_writev+0xb0/0xb0
[  110.141704]  [<ffffffff985cf750>] ? SyS_readv+0x20/0x20
[  110.150088]  [<ffffffff985cf760>] SyS_writev+0x10/0x20
[  110.158347]  [<ffffffff980064b0>] do_syscall_64+0x1a0/0x4e0
[  110.166496]  [<ffffffff9800301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  110.174666]  [<ffffffff99a09b1a>] entry_SYSCALL64_slow_path+0x25/0x25

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
