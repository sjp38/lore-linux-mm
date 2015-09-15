Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0976B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:45:40 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so183016191pac.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:45:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pq4si33536798pac.95.2015.09.15.10.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 10:45:38 -0700 (PDT)
Message-ID: <55F8572D.8010409@oracle.com>
Date: Tue, 15 Sep 2015 13:36:45 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: Multiple potential races on vma->vm_flags
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi> <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1509111734480.7660@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrey Konovalov <andreyknvl@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 09/11/2015 09:27 PM, Hugh Dickins wrote:
> I'm inclined to echo Vlastimil's comment from earlier in the thread:
> sounds like an overkill, unless we find something more serious than this.

I've modified my tests to stress the exit path of processes with many vmas,
and hit the following NULL ptr deref (not sure if it's related to the original issue):

[1181047.935563] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[1181047.937223] Modules linked in:
[1181047.937772] CPU: 4 PID: 21912 Comm: trinity-c341 Not tainted 4.3.0-rc1-next-20150914-sasha-00043-geddd763-dirty #2554
[1181047.939387] task: ffff8804195c8000 ti: ffff880433f00000 task.ti: ffff880433f00000
[1181047.940533] RIP: unmap_vmas (mm/memory.c:1337)
[1181047.941842] RSP: 0000:ffff880433f078a8  EFLAGS: 00010206
[1181047.942383] RAX: dffffc0000000000 RBX: ffff88041acd000a RCX: ffffffffffffffff
[1181047.943091] RDX: 0000000000000099 RSI: ffff88041acd000a RDI: 00000000000004c8
[1181047.943889] RBP: ffff880433f078d8 R08: ffff880415c59c58 R09: 0000000015c59e01
[1181047.944604] R10: 0000000000000000 R11: 0000000000000001 R12: ffffffffffffffff
[1181047.944833] pps pps0: PPS event at 21837.866101174
[1181047.944838] pps pps0: capture assert seq #7188
[1181047.946261] R13: 0000000000000000 R14: ffff880433f07910 R15: 0000000000002e0d
[1181047.947005] FS:  0000000000000000(0000) GS:ffff880252000000(0000) knlGS:0000000000000000
[1181047.947779] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1181047.948361] CR2: 000000000097df90 CR3: 000000044e08c000 CR4: 00000000000006a0
[1181047.949085] Stack:
[1181047.949350]  0000000000000000 ffff880433f07910 1ffff100867e0f1e dffffc0000000000
[1181047.950164]  ffff8801d825d000 0000000000002e0d ffff880433f079d0 ffffffff9276c4ab
[1181047.951070]  ffff88041acd000a 0000000041b58ab3 ffffffff9ecd1a43 ffffffff9276c2a0
[1181047.951906] Call Trace:
[1181047.952201] exit_mmap (mm/mmap.c:2856)
[1181047.952751] ? SyS_remap_file_pages (mm/mmap.c:2826)
[1181047.953633] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2557 mm/huge_memory.c:2169)
[1181047.954281] ? rcu_read_lock_sched_held (kernel/rcu/update.c:109)
[1181047.954936] ? kmem_cache_free (include/trace/events/kmem.h:143 mm/slub.c:2746)
[1181047.955535] ? __khugepaged_exit (./arch/x86/include/asm/atomic.h:118 include/linux/sched.h:2557 mm/huge_memory.c:2169)
[1181047.956204] mmput (include/linux/compiler.h:207 kernel/fork.c:735 kernel/fork.c:702)
[1181047.956691] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:91 kernel/exit.c:438 kernel/exit.c:733)
[1181047.957241] ? lockdep_init (kernel/locking/lockdep.c:3298)
[1181047.958005] ? mm_update_next_owner (kernel/exit.c:654)
[1181047.959007] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[1181047.959995] ? get_lock_stats (kernel/locking/lockdep.c:249)
[1181047.960885] ? lockdep_init (kernel/locking/lockdep.c:3298)
[1181047.961438] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[1181047.962573] ? lock_release (kernel/locking/lockdep.c:3641)
[1181047.963488] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[1181047.964704] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:859)
[1181047.965569] get_signal (kernel/signal.c:2353)
[1181047.966430] do_signal (arch/x86/kernel/signal.c:709)
[1181047.967241] ? do_readv_writev (include/linux/fsnotify.h:223 fs/read_write.c:821)
[1181047.968169] ? v9fs_file_lock_dotl (fs/9p/vfs_file.c:407)
[1181047.969126] ? vfs_write (fs/read_write.c:777)
[1181047.969955] ? setup_sigcontext (arch/x86/kernel/signal.c:706)
[1181047.970916] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[1181047.972139] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[1181047.973489] ? _raw_spin_unlock_irq (./arch/x86/include/asm/preempt.h:95 include/linux/spinlock_api_smp.h:171 kernel/locking/spinlock.c:199)
[1181047.974160] ? do_setitimer (include/linux/spinlock.h:357 kernel/time/itimer.c:227)
[1181047.974818] ? check_preemption_disabled (lib/smp_processor_id.c:18)
[1181047.975480] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[1181047.976142] prepare_exit_to_usermode (arch/x86/entry/common.c:251)
[1181047.976784] syscall_return_slowpath (arch/x86/entry/common.c:318)
[1181047.977473] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)
[1181047.978116] Code: 08 80 3c 02 00 0f 85 22 01 00 00 48 8b 43 40 48 8d b8 c8 04 00 00 48 89 45 d0 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 ee 00 00 00 48 8b 45 d0 48 83 b8 c8 04 00 00
All code
========
   0:   08 80 3c 02 00 0f       or     %al,0xf00023c(%rax)
   6:   85 22                   test   %esp,(%rdx)
   8:   01 00                   add    %eax,(%rax)
   a:   00 48 8b                add    %cl,-0x75(%rax)
   d:   43                      rex.XB
   e:   40                      rex
   f:   48 8d b8 c8 04 00 00    lea    0x4c8(%rax),%rdi
  16:   48 89 45 d0             mov    %rax,-0x30(%rbp)
  1a:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  21:   fc ff df
  24:   48 89 fa                mov    %rdi,%rdx
  27:   48 c1 ea 03             shr    $0x3,%rdx
  2b:*  80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)               <-- trapping instruction
  2f:   0f 85 ee 00 00 00       jne    0x123
  35:   48 8b 45 d0             mov    -0x30(%rbp),%rax
  39:   48 83 b8 c8 04 00 00    cmpq   $0x0,0x4c8(%rax)
  40:   00

Code starting with the faulting instruction
===========================================
   0:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
   4:   0f 85 ee 00 00 00       jne    0xf8
   a:   48 8b 45 d0             mov    -0x30(%rbp),%rax
   e:   48 83 b8 c8 04 00 00    cmpq   $0x0,0x4c8(%rax)
  15:   00
[1181047.981417] RIP unmap_vmas (mm/memory.c:1337)
[1181047.982011]  RSP <ffff880433f078a8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
