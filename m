Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 314FB6B0035
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 22:44:25 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rl12so7382017iec.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 19:44:25 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id hj18si19242670icb.88.2014.09.10.19.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 19:44:24 -0700 (PDT)
Message-ID: <54110C62.4030702@oracle.com>
Date: Wed, 10 Sep 2014 22:43:46 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in unmap_page_range
References: <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de> <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <20140910124732.GT17501@suse.de> <alpine.LSU.2.11.1409101210520.1744@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1409101210520.1744@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 09/10/2014 03:36 PM, Hugh Dickins wrote:
>> migrate: debug patch to try identify race between migration completion and mprotect
>> > 
>> > A migration entry is marked as write if pte_write was true at the
>> > time the entry was created. The VMA protections are not double checked
>> > when migration entries are being removed but mprotect itself will mark
>> > write-migration-entries as read to avoid problems. It means we potentially
>> > take a spurious fault to mark these ptes write again but otherwise it's
>> > harmless.  Still, one dump indicates that this situation can actually
>> > happen so this debugging patch spits out a warning if the situation occurs
>> > and hopefully the resulting warning will contain a clue as to how exactly
>> > it happens
>> > 
>> > Not-signed-off
>> > ---
>> >  mm/migrate.c | 12 ++++++++++--
>> >  1 file changed, 10 insertions(+), 2 deletions(-)
>> > 
>> > diff --git a/mm/migrate.c b/mm/migrate.c
>> > index 09d489c..631725c 100644
>> > --- a/mm/migrate.c
>> > +++ b/mm/migrate.c
>> > @@ -146,8 +146,16 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>> >  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
>> >  	if (pte_swp_soft_dirty(*ptep))
>> >  		pte = pte_mksoft_dirty(pte);
>> > -	if (is_write_migration_entry(entry))
>> > -		pte = pte_mkwrite(pte);
>> > +	if (is_write_migration_entry(entry)) {
>> > +		/*
>> > +		 * This WARN_ON_ONCE is temporary for the purposes of seeing if
>> > +		 * it's a case encountered by trinity in Sasha's testing
>> > +		 */
>> > +		if (!(vma->vm_flags & (VM_WRITE)))
>> > +			WARN_ON_ONCE(1);
>> > +		else
>> > +			pte = pte_mkwrite(pte);
>> > +	}
>> >  #ifdef CONFIG_HUGETLB_PAGE
>> >  	if (PageHuge(new)) {
>> >  		pte = pte_mkhuge(pte);
>> > 
> Right, and Sasha  reports that that can fire, but he sees the bug
> with this patch in and without that firing.

I've changed that WARN_ON_ONCE() to a VM_BUG_ON_VMA() to get some useful VMA information
out, and got the following:

[ 4018.870776] vma ffff8801a0f1e800 start 00007f3fd0ca7000 end 00007f3fd16a7000
[ 4018.870776] next ffff8804e1b89800 prev ffff88008cd9a000 mm ffff88054b17d000
[ 4018.870776] prot 120 anon_vma ffff880bc858a200 vm_ops           (null)
[ 4018.870776] pgoff 41bc8 file           (null) private_data           (null)
[ 4018.879731] flags: 0x8100070(mayread|maywrite|mayexec|account)
[ 4018.881324] ------------[ cut here ]------------
[ 4018.882612] kernel BUG at mm/migrate.c:155!
[ 4018.883649] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 4018.889647] Dumping ftrace buffer:
[ 4018.890323]    (ftrace buffer empty)
[ 4018.890323] Modules linked in:
[ 4018.890323] CPU: 4 PID: 9966 Comm: trinity-main Tainted: G        W      3.17.0-rc4-next-20140910-sasha-00042-ga4bad9b-dirty #1140
[ 4018.890323] task: ffff880695b83000 ti: ffff880560c44000 task.ti: ffff880560c44000
[ 4018.890323] RIP: 0010:[<ffffffff9b2fd4c1>]  [<ffffffff9b2fd4c1>] remove_migration_pte+0x3e1/0x3f0
[ 4018.890323] RSP: 0000:ffff880560c477c8  EFLAGS: 00010292
[ 4018.890323] RAX: 0000000000000001 RBX: 00007f3fd129b000 RCX: 0000000000000000
[ 4018.890323] RDX: 0000000000000001 RSI: ffffffff9e4ba395 RDI: 0000000000000001
[ 4018.890323] RBP: ffff880560c47800 R08: 0000000000000001 R09: 0000000000000001
[ 4018.890323] R10: 0000000000045401 R11: 0000000000000001 R12: ffff8801a0f1e800
[ 4018.890323] R13: ffff88054b17d000 R14: ffffea000478eb40 R15: ffff880122bcf070
[ 4018.890323] FS:  00007f3fd55bb700(0000) GS:ffff8803d6a00000(0000) knlGS:0000000000000000
[ 4018.890323] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 4018.890323] CR2: 0000000000fcbca8 CR3: 0000000561bab000 CR4: 00000000000006a0
[ 4018.890323] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4018.890323] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 4018.890323] Stack:
[ 4018.890323]  ffffea00046ed980 ffff88011079c4d8 ffffea000478eb40 ffff880560c47858
[ 4018.890323]  ffff88019fde0330 00000000000421bc ffff8801a0f1e800 ffff880560c47848
[ 4018.890323]  ffffffff9b2d1b0f ffff880bc858a200 ffff880560c47850 ffffea000478eb40
[ 4018.890323] Call Trace:
[ 4018.890323]  [<ffffffff9b2d1b0f>] rmap_walk+0x22f/0x380
[ 4018.890323]  [<ffffffff9b2fc841>] remove_migration_ptes+0x41/0x50
[ 4018.890323]  [<ffffffff9b2fd0e0>] ? __migration_entry_wait.isra.24+0x160/0x160
[ 4018.890323]  [<ffffffff9b2fd4d0>] ? remove_migration_pte+0x3f0/0x3f0
[ 4018.890323]  [<ffffffff9b2fe73b>] move_to_new_page+0x16b/0x230
[ 4018.890323]  [<ffffffff9b2d1e8c>] ? try_to_unmap+0x6c/0xf0
[ 4018.890323]  [<ffffffff9b2d08a0>] ? try_to_unmap_nonlinear+0x5c0/0x5c0
[ 4018.890323]  [<ffffffff9b2cf0a0>] ? invalid_migration_vma+0x30/0x30
[ 4018.890323]  [<ffffffff9b2d02e0>] ? page_remove_rmap+0x320/0x320
[ 4018.890323]  [<ffffffff9b2ff19c>] migrate_pages+0x85c/0x930
[ 4018.890323]  [<ffffffff9b2b8e20>] ? isolate_freepages_block+0x410/0x410
[ 4018.890323]  [<ffffffff9b2b7a60>] ? arch_local_save_flags+0x30/0x30
[ 4018.890323]  [<ffffffff9b2b9803>] compact_zone+0x4d3/0x8a0
[ 4018.890323]  [<ffffffff9b2b9c2f>] compact_zone_order+0x5f/0xa0
[ 4018.890323]  [<ffffffff9b2b9f87>] try_to_compact_pages+0x127/0x2f0
[ 4018.890323]  [<ffffffff9b298c98>] __alloc_pages_direct_compact+0x68/0x200
[ 4018.890323]  [<ffffffff9b2995af>] __alloc_pages_nodemask+0x77f/0xd90
[ 4018.890323]  [<ffffffff9b192fad>] ? sched_clock_local+0x1d/0x90
[ 4018.890323]  [<ffffffff9b2e8a1c>] alloc_pages_vma+0x13c/0x270
[ 4018.890323]  [<ffffffff9b305934>] ? do_huge_pmd_wp_page+0x494/0xc90
[ 4018.890323]  [<ffffffff9b305934>] do_huge_pmd_wp_page+0x494/0xc90
[ 4018.890323]  [<ffffffff9b308d40>] ? __mem_cgroup_count_vm_event+0xd0/0x240
[ 4018.890323]  [<ffffffff9b2c4b7d>] handle_mm_fault+0x8bd/0xc50
[ 4018.890323]  [<ffffffff9b1ba6e6>] ? __lock_is_held+0x56/0x80
[ 4018.890323]  [<ffffffff9b0afbc7>] __do_page_fault+0x1b7/0x660
[ 4018.890323]  [<ffffffff9b1b5c5e>] ? put_lock_stats.isra.13+0xe/0x30
[ 4018.890323]  [<ffffffff9b193f41>] ? vtime_account_user+0x91/0xa0
[ 4018.890323]  [<ffffffff9b28ac35>] ? context_tracking_user_exit+0xb5/0x1b0
[ 4018.890323]  [<ffffffff9bb55d33>] ? __this_cpu_preempt_check+0x13/0x20
[ 4018.890323]  [<ffffffff9b1b62e2>] ? trace_hardirqs_off_caller+0xe2/0x1b0
[ 4018.890323]  [<ffffffff9b0b0141>] trace_do_page_fault+0x51/0x2b0
[ 4018.890323]  [<ffffffff9b0a6e83>] do_async_page_fault+0x63/0xd0
[ 4018.890323]  [<ffffffff9e4bccf8>] async_page_fault+0x28/0x30
[ 4018.890323] Code: 0f 0b 48 c7 c6 b0 f2 71 9f 4c 89 f7 e8 b9 79 f9 ff 0f 0b 48 83 c9 02 41 f6 44 24 50 02 0f 85 70 fe ff ff 4c 89 e7 e8 af 4a f9 ff <0f> 0b 0f 0b 66 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55
[ 4018.890323] RIP  [<ffffffff9b2fd4c1>] remove_migration_pte+0x3e1/0x3f0
[ 4018.890323]  RSP <ffff880560c477c8>

And from a different log:

[ 2035.602565] vma ffff88054b666c00 start 00007f561ffad000 end 00007f56203ad000
[ 2035.602565] next ffff88054b665a00 prev ffff8801f7a31800 mm ffff8804f207a000
[ 2035.602565] prot 120 anon_vma           (null) vm_ops ffffffffb5671e80
[ 2035.602565] pgoff 0 file ffff88054b430a80 private_data           (null)
[ 2035.608469] flags: 0x80000f8(shared|mayread|maywrite|mayexec|mayshare)


And on a maybe related note, I've started seeing the following today. It may
be because we fixed mbind() in trinity but it could also be related to
this issue (free_pgtables() is in the call chain). If you don't think it has
anything to do with it let me know and I'll start a new thread:

[ 1195.996803] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 1196.001744] IP: __rb_erase_color (include/linux/rbtree_augmented.h:107 lib/rbtree.c:229 lib/rbtree.c:367)
[ 1196.001744] PGD 196787067 PUD 117522067 PMD 0
[ 1196.001744] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1196.001744] Dumping ftrace buffer:
[ 1196.001744]    (ftrace buffer empty)
[ 1196.001744] Modules linked in:
[ 1196.001744] CPU: 5 PID: 5724 Comm: trinity-c890 Not tainted 3.17.0-rc4-next-20140910-sasha-00042-ga4bad9b-dirty #1140
[ 1196.001744] task: ffff88024207b000 ti: ffff8808b25e0000 task.ti: ffff8808b25e0000
[ 1196.001744] RIP: __rb_erase_color (include/linux/rbtree_augmented.h:107 lib/rbtree.c:229 lib/rbtree.c:367)
[ 1196.001744] RSP: 0018:ffff8808b25e3d18  EFLAGS: 00010286
[ 1196.001744] RAX: ffff8808890ed059 RBX: ffff88091f75f458 RCX: 0000000000000000
[ 1196.001744] RDX: 0000000000000000 RSI: ffff8800b83396c8 RDI: ffff8808890ed058
[ 1196.001744] RBP: ffff8808b25e3d40 R08: ffff8808890ed058 R09: 0000000000000000
[ 1196.001744] R10: 0000000000000000 R11: ffff88085697d658 R12: ffff8808890ed058
[ 1196.001744] R13: ffffffff912ba700 R14: ffff8800b83396c8 R15: 0000000000000000
[ 1196.001744] FS:  00007f00e4458700(0000) GS:ffff880492c00000(0000) knlGS:0000000000000000
[ 1196.001744] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1196.001744] CR2: 0000000000000000 CR3: 0000000196786000 CR4: 00000000000006a0
[ 1196.001744] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1196.001744] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000070602
[ 1196.001744] Stack:
[ 1196.001744]  ffff88085697d600 ffff8800b5d13480 ffff8800b83396e0 ffff8800b8339660
[ 1196.001744]  ffff88085697d600 ffff8808b25e3d58 ffffffff912ba9e4 ffff88085697d600
[ 1196.001744]  ffff8808b25e3d78 ffffffff912c8446 ffff88085697d600 ffff8800b5d13480
[ 1196.001744] Call Trace:
[ 1196.001744] vma_interval_tree_remove (mm/interval_tree.c:24)
[ 1196.001744] __remove_shared_vm_struct (mm/mmap.c:232)
[ 1196.001744] unlink_file_vma (mm/mmap.c:246)
[ 1196.001744] free_pgtables (mm/memory.c:547)
[ 1196.001744] exit_mmap (mm/mmap.c:2826)
[ 1196.001744] mmput (kernel/fork.c:654)
[ 1196.001744] do_exit (./arch/x86/include/asm/thread_info.h:168 kernel/exit.c:461 kernel/exit.c:746)
[ 1196.001744] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1196.001744] ? trace_hardirqs_on (kernel/locking/lockdep.c:2609)
[ 1196.001744] do_group_exit (./arch/x86/include/asm/current.h:14 kernel/exit.c:874)
[ 1196.001744] SyS_exit_group (kernel/exit.c:900)
[ 1196.001744] tracesys (arch/x86/kernel/entry_64.S:542)
[ 1196.001744] Code: e2 49 89 c4 49 8b 5c 24 08 48 39 d3 0f 84 e2 00 00 00 f6 03 01 75 ad 4c 8b 7b 10 4c 89 e0 48 83 c8 01 4d 89 7c 24 08 4c 89 63 10 <49> 89 07 49 8b 04 24 48 89 03 48 83 e0 fc 49 89 1c 24 0f 84 69
All code
========
   0:	e2 49                	loop   0x4b
   2:	89 c4                	mov    %eax,%esp
   4:	49 8b 5c 24 08       	mov    0x8(%r12),%rbx
   9:	48 39 d3             	cmp    %rdx,%rbx
   c:	0f 84 e2 00 00 00    	je     0xf4
  12:	f6 03 01             	testb  $0x1,(%rbx)
  15:	75 ad                	jne    0xffffffffffffffc4
  17:	4c 8b 7b 10          	mov    0x10(%rbx),%r15
  1b:	4c 89 e0             	mov    %r12,%rax
  1e:	48 83 c8 01          	or     $0x1,%rax
  22:	4d 89 7c 24 08       	mov    %r15,0x8(%r12)
  27:	4c 89 63 10          	mov    %r12,0x10(%rbx)
  2b:*	49 89 07             	mov    %rax,(%r15)		<-- trapping instruction
  2e:	49 8b 04 24          	mov    (%r12),%rax
  32:	48 89 03             	mov    %rax,(%rbx)
  35:	48 83 e0 fc          	and    $0xfffffffffffffffc,%rax
  39:	49 89 1c 24          	mov    %rbx,(%r12)
  3d:	0f                   	.byte 0xf
  3e:	84 69 00             	test   %ch,0x0(%rcx)

Code starting with the faulting instruction
===========================================
   0:	49 89 07             	mov    %rax,(%r15)
   3:	49 8b 04 24          	mov    (%r12),%rax
   7:	48 89 03             	mov    %rax,(%rbx)
   a:	48 83 e0 fc          	and    $0xfffffffffffffffc,%rax
   e:	49 89 1c 24          	mov    %rbx,(%r12)
  12:	0f                   	.byte 0xf
  13:	84 69 00             	test   %ch,0x0(%rcx)
[ 1196.001744] RIP __rb_erase_color (include/linux/rbtree_augmented.h:107 lib/rbtree.c:229 lib/rbtree.c:367)
[ 1196.001744]  RSP <ffff8808b25e3d18>
[ 1196.001744] CR2: 0000000000000000
[ 1196.001744] ---[ end trace 67e0103d243f3c04 ]---
[ 1196.050031] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[ 1196.050031] IP: __rb_insert_augmented (lib/rbtree.c:94 lib/rbtree.c:411)
[ 1196.050031] PGD a3ea09067 PUD a69b38067 PMD 0
[ 1196.050031] Oops: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[ 1196.050031] Dumping ftrace buffer:
[ 1196.050031]    (ftrace buffer empty)
[ 1196.050031] Modules linked in:
[ 1196.050031] CPU: 3 PID: 5688 Comm: trinity-c802 Tainted: G      D        3.17.0-rc4-next-20140910-sasha-00042-ga4bad9b-dirty #1140
[ 1196.050031] task: ffff880a508f8000 ti: ffff880a6950c000 task.ti: ffff880a6950c000
[ 1196.050031] RIP: __rb_insert_augmented (lib/rbtree.c:94 lib/rbtree.c:411)
[ 1196.050031] RSP: 0018:ffff880a6950fd68  EFLAGS: 00010246
[ 1196.050031] RAX: ffff88091f75a058 RBX: 0000000000000000 RCX: 0000000000000000
[ 1196.050031] RDX: ffffffff912ba700 RSI: ffff8800b4cb3718 RDI: ffff8802d786ca58
[ 1196.050031] RBP: ffff880a6950fd90 R08: ffff8802d786ca00 R09: ffff8800b4cb3718
[ 1196.050031] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8801fd067400
[ 1196.050031] R13: ffff8802d786ca00 R14: ffff8800b4cb3718 R15: 00007f00e44589d0
[ 1196.050031] FS:  00007f00e4458700(0000) GS:ffff88031ac00000(0000) knlGS:0000000000000000
[ 1196.050031] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1196.050031] CR2: 0000000000000008 CR3: 0000000a62597000 CR4: 00000000000006a0
[ 1196.050031] DR0: 00000000006f0000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1196.050031] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000070602
[ 1196.050031] Stack:
[ 1196.050031]  ffffffff9115499e ffff88028bc7a000 ffff8801fd067400 ffff8802d786ca00
[ 1196.050031]  ffff8800b4cb3730 ffff880a6950fda0 ffffffff912babfd ffff880a6950fe70
[ 1196.050031]  ffffffff91154a77 ffff8800b4cb36b0 000000003ebe3540 0000000000000000
[ 1196.050031] Call Trace:
[ 1196.050031] ? copy_process (kernel/fork.c:409 kernel/fork.c:859 kernel/fork.c:913 kernel/fork.c:1381)
[ 1196.050031] vma_interval_tree_insert_after (mm/interval_tree.c:60)
[ 1196.050031] copy_process (kernel/fork.c:442 kernel/fork.c:859 kernel/fork.c:913 kernel/fork.c:1381)
[ 1196.050031] do_fork (kernel/fork.c:1644)
[ 1196.050031] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[ 1196.050031] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1196.050031] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2559 kernel/locking/lockdep.c:2601)
[ 1196.050031] ? trace_hardirqs_on (kernel/locking/lockdep.c:2609)
[ 1196.050031] SyS_clone (kernel/fork.c:1733)
[ 1196.050031] stub_clone (arch/x86/kernel/entry_64.S:637)
[ 1196.050031] ? tracesys (arch/x86/kernel/entry_64.S:542)
[ 1196.050031] Code: ff ff 0f 1f 00 48 8b 07 48 85 c0 0f 84 a4 01 00 00 55 48 89 e5 41 56 49 89 f6 41 55 41 54 53 48 83 ec 08 48 8b 18 f6 c3 01 75 6b <48> 8b 4b 08 49 89 d8 48 39 c8 0f 84 a5 00 00 00 48 85 c9 74 05
All code
========
   0:	ff                   	(bad)
   1:	ff 0f                	decl   (%rdi)
   3:	1f                   	(bad)
   4:	00 48 8b             	add    %cl,-0x75(%rax)
   7:	07                   	(bad)
   8:	48 85 c0             	test   %rax,%rax
   b:	0f 84 a4 01 00 00    	je     0x1b5
  11:	55                   	push   %rbp
  12:	48 89 e5             	mov    %rsp,%rbp
  15:	41 56                	push   %r14
  17:	49 89 f6             	mov    %rsi,%r14
  1a:	41 55                	push   %r13
  1c:	41 54                	push   %r12
  1e:	53                   	push   %rbx
  1f:	48 83 ec 08          	sub    $0x8,%rsp
  23:	48 8b 18             	mov    (%rax),%rbx
  26:	f6 c3 01             	test   $0x1,%bl
  29:	75 6b                	jne    0x96
  2b:*	48 8b 4b 08          	mov    0x8(%rbx),%rcx		<-- trapping instruction
  2f:	49 89 d8             	mov    %rbx,%r8
  32:	48 39 c8             	cmp    %rcx,%rax
  35:	0f 84 a5 00 00 00    	je     0xe0
  3b:	48 85 c9             	test   %rcx,%rcx
  3e:	74 05                	je     0x45
	...

Code starting with the faulting instruction
===========================================
   0:	48 8b 4b 08          	mov    0x8(%rbx),%rcx
   4:	49 89 d8             	mov    %rbx,%r8
   7:	48 39 c8             	cmp    %rcx,%rax
   a:	0f 84 a5 00 00 00    	je     0xb5
  10:	48 85 c9             	test   %rcx,%rcx
  13:	74 05                	je     0x1a
	...
[ 1196.050031] RIP __rb_insert_augmented (lib/rbtree.c:94 lib/rbtree.c:411)
[ 1196.050031]  RSP <ffff880a6950fd68>
[ 1196.050031] CR2: 0000000000000008


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
