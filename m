Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 735B86B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 17:13:52 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id z6so14348yhz.1
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 14:13:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e43si118774yhe.93.2014.09.04.14.13.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 14:13:51 -0700 (PDT)
Message-ID: <5408D5EF.2080202@oracle.com>
Date: Thu, 04 Sep 2014 17:13:19 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: memory corruption in mm->ptl
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi all,

I've reported a few issues which got a "that's impossible response" (BUG at mm/rmap.c:530
and BUG at include/asm-generic/pgtable.h:724). I've just hit the following on few of
my VMs, which might be able to explain that:

[ 3832.961261] =============================================================================
[ 3832.970028] BUG page->ptl (Not tainted): Redzone overwritten
[ 3832.970028] -----------------------------------------------------------------------------
[ 3832.970028]
[ 3832.970028] INFO: 0xffff8802841bc368-0xffff8802841bc36f. First byte 0x0 instead of 0xcc
[ 3832.970028] INFO: Slab 0xffffea000a106f00 objects=40 used=36 fp=0xffff8802841be3f0 flags=0x6fffff80004081
[ 3832.970028] INFO: Object 0xffff8802841bc320 @offset=800 fp=0x          (null)
[ 3832.970028]
[ 3832.970028] Bytes b4 ffff8802841bc310: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3832.970028] Object ffff8802841bc320: 36 03 36 03 00 00 00 00 ff ff ff ff 00 00 00 00  6.6.............
[ 3832.970028] Object ffff8802841bc330: ff ff ff ff ff ff ff ff 38 c3 1b 84 02 88 ff ff  ........8.......
[ 3832.970028] Object ffff8802841bc340: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3832.970028] Object ffff8802841bc350: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3832.970028] Object ffff8802841bc360: 00 00 00 00 00 00 00 00                          ........
[ 3832.970028] Redzone ffff8802841bc368: 00 00 00 00 00 00 00 00                          ........
[ 3832.970028] Padding ffff8802841bc4a8: 00 00 00 00 00 00 00 00                          ........
[ 3832.970028] CPU: 3 PID: 12505 Comm: trinity-c647 Tainted: G    B          3.17.0-rc3-next-20140903-sasha-00034-g33e7ae9 #1108
[ 3832.970028]  ffff8802841bc320 ffff88073a407898 ffffffffae4f3a19 0000000000000003
[ 3832.970028]  ffff88027740ad80 ffff88073a4078c8 ffffffffab2ffe41 ffff8802841bc370
[ 3832.970028]  ffff88027740ad80 00000000000000cc ffff8802841bc320 ffff88073a407918
[ 3832.970028] Call Trace:
[ 3832.970028] dump_stack (lib/dump_stack.c:52)
[ 3832.970028] print_trailer (mm/slub.c:640)
[ 3832.970028] check_bytes_and_report (mm/slub.c:679 mm/slub.c:703)
[ 3832.970028] check_object (mm/slub.c:803)
[ 3832.970028] free_debug_processing (mm/slub.c:1073)
[ 3832.970028] ? get_parent_ip (kernel/sched/core.c:2570)
[ 3832.970028] ? ptlock_free (mm/memory.c:3829)
[ 3832.970028] __slab_free (mm/slub.c:2526 (discriminator 1))
[ 3832.970028] ? __debug_check_no_obj_freed (lib/debugobjects.c:713)
[ 3832.970028] ? get_parent_ip (kernel/sched/core.c:2570)
[ 3832.970028] kmem_cache_free (mm/slub.c:2672 mm/slub.c:2681)
[ 3832.970028] ? ptlock_free (mm/memory.c:3829)
[ 3832.970028] ptlock_free (mm/memory.c:3829)
[ 3832.970028] ___pte_free_tlb (include/linux/mm.h:1502 arch/x86/mm/pgtable.c:56)
[ 3832.970028] free_pgd_range (mm/memory.c:396 mm/memory.c:413 mm/memory.c:446 mm/memory.c:522)
[ 3832.970028] ? kmem_cache_free (mm/slub.c:2672 mm/slub.c:2681)
[ 3832.970028] free_pgtables (mm/memory.c:554 (discriminator 3))
[ 3832.970028] exit_mmap (mm/mmap.c:2821)
[ 3832.970028] mmput (kernel/fork.c:654)
[ 3832.970028] do_exit (./arch/x86/include/asm/thread_info.h:168 kernel/exit.c:461 kernel/exit.c:745)
[ 3832.970028] ? get_signal (kernel/signal.c:2199)
[ 3832.970028] ? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[ 3832.970028] do_group_exit (kernel/exit.c:886)
[ 3832.970028] get_signal (kernel/signal.c:2350)
[ 3832.970028] do_signal (arch/x86/kernel/signal.c:698)
[ 3832.970028] ? get_parent_ip (kernel/sched/core.c:2570)
[ 3832.970028] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[ 3832.970028] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2566)
[ 3832.970028] ? trace_hardirqs_on (kernel/locking/lockdep.c:2609)
[ 3832.970028] do_notify_resume (arch/x86/kernel/signal.c:751)
[ 3832.970028] int_signal (arch/x86/kernel/entry_64.S:600)
[ 3832.970028] FIX page->ptl: Restoring 0xffff8802841bc368-0xffff8802841bc36f=0xcc

We're seeing here what we saw on the other two bug reports where memory is being
zeroed out, exactly like it was here.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
