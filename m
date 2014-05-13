Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E8DF86B0036
	for <linux-mm@kvack.org>; Tue, 13 May 2014 18:21:47 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so801520pbc.12
        for <linux-mm@kvack.org>; Tue, 13 May 2014 15:21:47 -0700 (PDT)
Received: from mail-pb0-x22d.google.com (mail-pb0-x22d.google.com [2607:f8b0:400e:c01::22d])
        by mx.google.com with ESMTPS id ps1si8639201pbc.164.2014.05.13.15.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 15:21:47 -0700 (PDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so798919pbc.32
        for <linux-mm@kvack.org>; Tue, 13 May 2014 15:21:46 -0700 (PDT)
Date: Tue, 13 May 2014 15:20:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shmem: NULL ptr deref in shmem_fault
In-Reply-To: <53713A01.3050502@oracle.com>
Message-ID: <alpine.LSU.2.11.1405131442260.22181@eggly.anvils>
References: <5370DA09.7020801@oracle.com> <20140512141238.3a0673b3f1a2ee5d47498719@linux-foundation.org> <53713A01.3050502@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

Adding Peter and Ingo from the perf_even_mmap thread, and Kirill.

On Mon, 12 May 2014, Sasha Levin wrote:
> On 05/12/2014 05:12 PM, Andrew Morton wrote:
> > On Mon, 12 May 2014 10:26:17 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
> > 
> >> Hi all,
> >>
> >> While fuzzing with trinity inside a KVM tools guest running the latest -next
> >> kernel I've stumbled on the following spew.
> >>
> >> It seems that in this case, 'inode->i_mapping' was NULL, and the deref happened
> >> when we tried to get it's flags in mapping_gfp_mask().

Not quite, I think it's just before that: it's got a NULL inode out of
vma->vm_file->f_inode, and is now trying to use that to get i_mapping.

> >>
> >> [ 4431.615828] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
> >> [ 4431.617708] IP: shmem_fault (mm/shmem.c:2960 mm/shmem.c:1236)
> >> [ 4431.621711] PGD 1d7fb5067 PUD 1d7fb4067 PMD 0
> >> [ 4431.621945] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >> [ 4431.621945] Dumping ftrace buffer:
> >> [ 4431.621945]    (ftrace buffer empty)
> >> [ 4431.621945] Modules linked in:
> >> [ 4431.621945] CPU: 1 PID: 20571 Comm: trinity-c61 Not tainted 3.15.0-rc5-next-20140512-sasha-00019-ga20bc00-dirty #456
> >> [ 4431.621945] task: ffff8803333e0000 ti: ffff88032b562000 task.ti: ffff88032b562000
> >> [ 4431.621945] RIP: shmem_fault (mm/shmem.c:2960 mm/shmem.c:1236)
> >> [ 4431.621945] RSP: 0018:ffff88032b5639b8  EFLAGS: 00010296
> >> [ 4431.621945] RAX: ffff88005daab100 RBX: ffff88005db19e00 RCX: 0000000000000001
> >> [ 4431.621945] RDX: 0000000000000001 RSI: ffff88032b5639f8 RDI: 0000000000000000
> >> [ 4431.621945] RBP: ffff88032b5639d8 R08: ffff88032b563a70 R09: ffff88032b5639c4
> >> [ 4431.621945] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801caad2ed0
> >> [ 4431.621945] R13: ffff8801ca27c7e8 R14: 0000000000000000 R15: ffff88005db19e00
> >> [ 4431.621945] FS:  00007f8c3b4ef700(0000) GS:ffff88006ec00000(0000) knlGS:0000000000000000
> >> [ 4431.621945] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >> [ 4431.621945] CR2: 0000000000000030 CR3: 00000001d7fb6000 CR4: 00000000000006a0
> >> [ 4431.621945] DR0: 00000000006df000 DR1: 0000000000000000 DR2: 0000000000000000
> >> [ 4431.621945] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> >> [ 4431.621945] Stack:
> >> [ 4431.621945]  ffffffff8a2bb583 0000020000000286 ffff88032b563a18 ffff88032b563a70
> >> [ 4431.621945]  ffff88032b563a38 ffffffff8a2b83d9 ffff8801e71f8338 00000000ffffffff
> >> [ 4431.621945]  ffff880300000000 0000000000000001 00007f8c3b4fd000 0000000000000000
> >> [ 4431.621945] Call Trace:
> >> [ 4431.621945] ? do_read_fault.isra.40 (mm/memory.c:2882)
> >> [ 4431.621945] __do_fault (mm/memory.c:2703)
> >> [ 4431.621945] ? _raw_spin_unlock (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
> >> [ 4431.621945] do_read_fault.isra.40 (mm/memory.c:2883)
> >> [ 4431.621945] ? get_parent_ip (kernel/sched/core.c:2519)
> >> [ 4431.621945] ? get_parent_ip (kernel/sched/core.c:2519)
> >> [ 4431.621945] __handle_mm_fault (mm/memory.c:3021 mm/memory.c:3182 mm/memory.c:3306)
> >> [ 4431.621945] ? __const_udelay (arch/x86/lib/delay.c:126)
> >> [ 4431.621945] ? __rcu_read_unlock (kernel/rcu/update.c:97)
> >> [ 4431.621945] handle_mm_fault (mm/memory.c:3329)
> >> [ 4431.621945] __get_user_pages (mm/gup.c:281 mm/gup.c:466)
> >> [ 4431.621945] ? preempt_count_sub (kernel/sched/core.c:2575)
> >> [ 4431.621945] get_user_pages (mm/gup.c:632)
> >> [ 4431.621945] get_user_pages_fast (arch/x86/mm/gup.c:394)
> >> [ 4431.621945] vmsplice_to_pipe (fs/splice.c:1487 fs/splice.c:1607)
> >> [ 4431.621945] ? page_cache_pipe_buf_release (fs/splice.c:267)
> >> [ 4431.621945] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
> >> [ 4431.621945] ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
> >> [ 4431.621945] ? sched_clock_local (kernel/sched/clock.c:214)
> >> [ 4431.621945] ? vtime_account_user (kernel/sched/cputime.c:687)
> >> [ 4431.621945] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
> >> [ 4431.621945] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
> >> [ 4431.621945] ? vtime_account_user (kernel/sched/cputime.c:687)
> >> [ 4431.621945] ? get_parent_ip (kernel/sched/core.c:2519)
> >> [ 4431.621945] ? get_parent_ip (kernel/sched/core.c:2519)
> >> [ 4431.621945] ? __fget_light (include/linux/rcupdate.h:428 include/linux/fdtable.h:80 fs/file.c:684)
> >> [ 4431.621945] SyS_vmsplice (fs/splice.c:1650 fs/splice.c:1636)
> >> [ 4431.621945] tracesys (arch/x86/kernel/entry_64.S:746)
> >> [ 4431.621945] Code: 66 66 66 90 55 b9 01 00 00 00 48 89 e5 53 48 89 fb 4c 8d 4d ec 48 83 ec 18 c7 45 ec 00 02 00 00 48 8b 87 a0 00 00 00 48 8b 78 20 <48> 8b 57 30 4c 8b 82 48 01 00 00 48 8d 56 18 48 8b 76 08 41 81
> >> [ 4431.621945] RIP shmem_fault (mm/shmem.c:2960 mm/shmem.c:1236)
> >> [ 4431.621945]  RSP <ffff88032b5639b8>
> >> [ 4431.621945] CR2: 0000000000000030
> > 
> > OK, how the heck can we get all the way to shmem_fault and then find an
> > inode with no ->mapping?  A race, presumably.
> > 
> > viro has been mucking with the splice code, but I don't see how that
> > can affect things down here.
> > 
> > Stumped. 
> > 

And the second dump you sent was kernel paging request at ffffffffffffff48
in mpol_shared_policy_lookup().  I don't have your exact config, but I
expect that if you disassemble your shmem_get_policy(), you'll find it
subtracting 0xb8 from inode pointer to locate &SHMEM_I(inode)->policy.

Not that I'll care if it's not exactly 0xb8: we have no particular
reason to expect NULL f_inode once struct file has been freed.

> 
> There seems to be a race issue with files going away unexpectedly (ignore
> me blaming perf):
> 
> https://lkml.org/lkml/2014/5/12/514
> 
> Can it possibly be the same bug?

I haven't delved into the perf_even_mmap d_path (fs/dcache.c:2947) one,
but the Sys_mremap one on file->f_op->f_unmapped_area sounds like what
we have here: struct file has been freed.

I believe Al is innocent: I point a quivering finger at... Kirill.

Just guessing, but we know how fond trinity is of remap_file_pages(),
and comparing old and new emulations shows that interesting

	struct file *file = get_file(vma->vm_file);
        addr = mmap_region(...);
	fput(file);

in mm/fremap.c's old emulation, but no get_file() and fput() around 
the do_mmap_pgoff() in mm/mmap.c's new emulation.

Before it puts in the new, do_mmap_pgoff() might unmap the last reference
to vma->vm_file, so emulation needs to take its own reference.  I'm not
sure how that plays out nowadays with Al's deferred fput, but it does
look suspicious to me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
