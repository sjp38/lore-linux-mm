Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0EF6B003D
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:48:14 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1385435pbb.8
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 13:48:14 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ia5si42678478pbb.236.2014.06.12.13.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 13:48:14 -0700 (PDT)
Message-ID: <539A0FC8.8090504@oracle.com>
Date: Thu, 12 Jun 2014 16:38:32 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com>
In-Reply-To: <52F82E62.2010709@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 02/09/2014 08:41 PM, Sasha Levin wrote:
> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>> Would trinity be likely to have a thread or process repeatedly faulting
>> in pages from the hole while it is being punched?
> 
> I can see how trinity would do that, but just to be certain - Cc davej.
> 
> On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>> Does this happen with other holepunch filesystems?  If it does not,
>> I'd suppose it's because the tmpfs fault-in-newly-created-page path
>> is lighter than a consistent disk-based filesystem's has to be.
>> But we don't want to make the tmpfs path heavier to match them.
> 
> No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
> punching in other filesystems and I make sure to get a bunch of those
> mounted before starting testing.

Just pinging this one again. I still see hangs in -next where the hang
location looks same as before:


[ 3602.443529] CPU: 6 PID: 1153 Comm: trinity-c35 Not tainted 3.15.0-next-20140612-sasha-00022-g5e4db85-dirty #645
[ 3602.443529] task: ffff8801b45eb000 ti: ffff8801a0b90000 task.ti: ffff8801a0b90000
[ 3602.443529] RIP: vtime_account_system (include/linux/seqlock.h:229 include/linux/seqlock.h:234 include/linux/seqlock.h:301 kernel/sched/cputime.c:664)
[ 3602.443529] RSP: 0018:ffff8801b4e03ef8  EFLAGS: 00000046
[ 3602.443529] RAX: ffffffffb31a83b8 RBX: ffff8801b45eb000 RCX: 0000000000000001
[ 3602.443529] RDX: ffffffffb31a80bb RSI: ffffffffb7915a75 RDI: 0000000000000082
[ 3602.443529] RBP: ffff8801b4e03f28 R08: 0000000000000001 R09: 0000000000000000
[ 3602.443529] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801b45eb968
[ 3602.443529] R13: ffff8801b45eb938 R14: 0000000000000282 R15: ffff8801b45ebda0
[ 3602.443529] FS:  00007f93ac8ec700(0000) GS:ffff8801b4e00000(0000) knlGS:0000000000000000
[ 3602.443529] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3602.443529] CR2: 00007f93a8854c9f CR3: 000000018a189000 CR4: 00000000000006a0
[ 3602.443529] Stack:
[ 3602.443529]  ffff8801b45eb000 00000000001d7800 ffffffffb32bd749 ffff8801b45eb000
[ 3602.443529]  00000000001d7800 ffffffffb32bd749 ffff8801b4e03f48 ffffffffb31a83b8
[ 3602.443529]  ffff8801b4e03f48 ffff8801b45eb000 ffff8801b4e03f68 ffffffffb31666a0
[ 3602.443529] Call Trace:
[ 3602.443529]  <IRQ>
[ 3602.443529] vtime_common_account_irq_enter (kernel/sched/cputime.c:430)
[ 3602.443529] irq_enter (include/linux/vtime.h:63 include/linux/vtime.h:115 kernel/softirq.c:334)
[ 3602.443529] scheduler_ipi (kernel/sched/core.c:1589 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/tick.h:168 include/linux/tick.h:199 kernel/sched/core.c:1590)
[ 3602.443529] smp_reschedule_interrupt (arch/x86/kernel/smp.c:266)
[ 3602.443529] reschedule_interrupt (arch/x86/kernel/entry_64.S:1046)
[ 3602.443529]  <EOI>
[ 3602.443529] _raw_spin_unlock (include/linux/spinlock_api_smp.h:151 kernel/locking/spinlock.c:183)
[ 3602.443529] zap_pte_range (mm/memory.c:1218)
[ 3602.443529] unmap_single_vma (mm/memory.c:1256 mm/memory.c:1277 mm/memory.c:1302 mm/memory.c:1348)
[ 3602.443529] zap_page_range_single (include/linux/mmu_notifier.h:234 mm/memory.c:1429)
[ 3602.443529] unmap_mapping_range (mm/memory.c:2316 mm/memory.c:2392)
[ 3602.443529] truncate_inode_page (mm/truncate.c:136 mm/truncate.c:180)
[ 3602.443529] shmem_undo_range (mm/shmem.c:429)
[ 3602.443529] shmem_truncate_range (mm/shmem.c:527)
[ 3602.443529] shmem_fallocate (mm/shmem.c:1740)
[ 3602.443529] do_fallocate (include/linux/fs.h:1281 fs/open.c:299)
[ 3602.443529] SyS_madvise (mm/madvise.c:335 mm/madvise.c:384 mm/madvise.c:534 mm/madvise.c:465)
[ 3602.443529] tracesys (arch/x86/kernel/entry_64.S:542)
[ 3602.443529] Code: 09 00 00 48 89 5d e8 48 89 fb 4c 89 e7 4c 89 6d f8 e8 25 69 3b 03 83 83 30 09 00 00 01 48 8b 45 08 4c 8d ab 38 09 00 00 45 31 c9 <41> b8 01 00 00 00 31 c9 31 d2 31 f6 4c 89 ef 48 89 04 24 e8 e8
All code
========
   0:   09 00                   or     %eax,(%rax)
   2:   00 48 89                add    %cl,-0x77(%rax)
   5:   5d                      pop    %rbp
   6:   e8 48 89 fb 4c          callq  0x4cfb8953
   b:   89 e7                   mov    %esp,%edi
   d:   4c 89 6d f8             mov    %r13,-0x8(%rbp)
  11:   e8 25 69 3b 03          callq  0x33b693b
  16:   83 83 30 09 00 00 01    addl   $0x1,0x930(%rbx)
  1d:   48 8b 45 08             mov    0x8(%rbp),%rax
  21:   4c 8d ab 38 09 00 00    lea    0x938(%rbx),%r13
  28:   45 31 c9                xor    %r9d,%r9d
  2b:*  41 b8 01 00 00 00       mov    $0x1,%r8d                <-- trapping instruction
  31:   31 c9                   xor    %ecx,%ecx
  33:   31 d2                   xor    %edx,%edx
  35:   31 f6                   xor    %esi,%esi
  37:   4c 89 ef                mov    %r13,%rdi
  3a:   48 89 04 24             mov    %rax,(%rsp)
  3e:   e8                      .byte 0xe8
  3f:   e8                      .byte 0xe8
        ...

Code starting with the faulting instruction
===========================================
   0:   41 b8 01 00 00 00       mov    $0x1,%r8d
   6:   31 c9                   xor    %ecx,%ecx
   8:   31 d2                   xor    %edx,%edx
   a:   31 f6                   xor    %esi,%esi
   c:   4c 89 ef                mov    %r13,%rdi
   f:   48 89 04 24             mov    %rax,(%rsp)
  13:   e8                      .byte 0xe8
  14:   e8                      .byte 0xe8


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
