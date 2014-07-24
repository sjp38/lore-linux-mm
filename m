Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE7A06B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:05:52 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3910611pad.13
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 06:05:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id aa10si5983777pac.16.2014.07.24.06.05.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 06:05:51 -0700 (PDT)
Message-ID: <53D104A6.4050402@oracle.com>
Date: Thu, 24 Jul 2014 09:05:42 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com> <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com> <53D07E96.5000006@oracle.com>
In-Reply-To: <53D07E96.5000006@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Andrey Ryabinin <a.ryabinin@samsung.com>

On 07/23/2014 11:33 PM, Sasha Levin wrote:
> On 02/27/2014 02:53 PM, Kirill A. Shutemov wrote:
>> > The patch introduces new vm_ops callback ->map_pages() and uses it for
>> > mapping easy accessible pages around fault address.
>> > 
>> > On read page fault, if filesystem provides ->map_pages(), we try to map
>> > up to FAULT_AROUND_PAGES pages around page fault address in hope to
>> > reduce number of minor page faults.
>> > 
>> > We call ->map_pages first and use ->fault() as fallback if page by the
>> > offset is not ready to be mapped (cold page cache or something).
>> > 
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > ---
> Hi all,
> 
> This patch triggers use-after-free when fuzzing using trinity and the KASAN
> patchset.

FWIW, if it helps, here's another KASAN report with the conventional BUG following it:

[  360.498001] ==================================================================
[  360.500896] AddressSanitizer: use after free in do_read_fault.isra.40+0x3c2/0x510 at addr ffff880581ee3fd0
[  360.504474] page:ffffea001607b8c0 count:0 mapcount:0 mapping:          (null) index:0x0
[  360.507264] page flags: 0xefffff80000000()
[  360.508655] page dumped because: kasan error
[  360.509489] CPU: 8 PID: 9251 Comm: trinity-c159 Not tainted 3.16.0-rc6-next-20140723-sasha-00047-g289342b-dirty #929
[  360.511717]  00000000000000ff 0000000000000000 ffffea001607b8c0 ffff8801ba8bbb98
[  360.513272]  ffffffff8fe40903 ffff8801ba8bbc68 ffff8801ba8bbc58 ffffffff8b42acfc
[  360.514729]  0000000000000001 ffff880592deaa48 ffff8801ba84b038 ffff8801ba8bbbd0
[  360.516156] Call Trace:
[  360.516622] dump_stack (lib/dump_stack.c:52)
[  360.517566] kasan_report_error (mm/kasan/report.c:98 mm/kasan/report.c:166)
[  360.518745] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[  360.519923] ? preempt_count_sub (kernel/sched/core.c:2606)
[  360.521124] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  360.522431] ? do_read_fault.isra.40 (mm/memory.c:2784 mm/memory.c:2849 mm/memory.c:2898)
[  360.523651] __asan_load8 (mm/kasan/kasan.c:364)
[  360.524625] ? do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
[  360.525887] do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
[  360.527156] ? __rcu_read_unlock (kernel/rcu/update.c:101)
[  360.528251] handle_mm_fault (mm/memory.c:3092 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
[  360.529308] ? vmacache_update (mm/vmacache.c:61)
[  360.530505] ? find_vma (mm/mmap.c:2027)
[  360.531453] __do_page_fault (arch/x86/mm/fault.c:1231)
[  360.532503] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[  360.533744] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  360.535001] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2639 (discriminator 8))
[  360.536262] ? trace_hardirqs_off (kernel/locking/lockdep.c:2645)
[  360.537360] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[  360.538493] do_async_page_fault (arch/x86/kernel/kvm.c:279)
[  360.539567] async_page_fault (arch/x86/kernel/entry_64.S:1321)
[  360.540668] Read of size 8 by thread T9251:
[  360.541485] Memory state around the buggy address:
[  360.542463]  ffff880581ee3d00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.543816]  ffff880581ee3d80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.545116]  ffff880581ee3e00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.546476]  ffff880581ee3e80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.547806]  ffff880581ee3f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.549112] >ffff880581ee3f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
[  360.550507]                                                  ^
[  360.551574]  ffff880581ee4000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  360.552910]  ffff880581ee4080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  360.554207]  ffff880581ee4100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  360.555621]  ffff880581ee4180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  360.557035]  ffff880581ee4200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[  360.558489] ==================================================================
[  360.559804] BUG: unable to handle kernel paging request at ffff880581ee3fd0
[  360.559817] IP: do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
[  360.559827] PGD 147b9067 PUD 70353d067 PMD 70352d067 PTE 8000000581ee3060
[  360.559836] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  360.559892] Dumping ftrace buffer:
[  360.560117]    (ftrace buffer empty)
[  360.560132] Modules linked in:
[  360.560145] CPU: 8 PID: 9251 Comm: trinity-c159 Not tainted 3.16.0-rc6-next-20140723-sasha-00047-g289342b-dirty #929
[  360.560154] task: ffff8801ba84b000 ti: ffff8801ba8b8000 task.ti: ffff8801ba8b8000
[  360.560172] RIP: do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
[  360.560180] RSP: 0000:ffff8801ba8bbc98  EFLAGS: 00010296
[  360.560186] RAX: 0000000000000000 RBX: ffff8801ba8d5a00 RCX: 0000000000000006
[  360.560192] RDX: 0000000000000006 RSI: ffffffff912f5fd5 RDI: 0000000000000282
[  360.560199] RBP: ffff8801ba8bbd58 R08: 0000000000000001 R09: 0000000000000000
[  360.560206] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801ba8ad470
[  360.560213] R13: 00007f2411bfa000 R14: 0000000000000000 R15: ffff880581ee3fd0
[  360.560222] FS:  00007f2412de6700(0000) GS:ffff8801de000000(0000) knlGS:0000000000000000
[  360.560228] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  360.560234] CR2: ffff880581ee3fd0 CR3: 00000001ba89b000 CR4: 00000000000006a0
[  360.560255] DR0: 00000000006ec000 DR1: 0000000000000000 DR2: 0000000000000000
[  360.560262] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000d0602
[  360.560264] Stack:
[  360.560278]  0000000000000001 0000000000000000 ffff880581ee4030 ffff880592deaa30
[  360.560290]  0000000000000005 00007f2411c07000 ffff8801ba8d5a90 ffff880592deaa30
[  360.560297]  0000000000000000 000000a8ba84b038 000000000000000c 00007f2411c06220
[  360.560299] Call Trace:
[  360.560317] ? __rcu_read_unlock (kernel/rcu/update.c:101)
[  360.560332] handle_mm_fault (mm/memory.c:3092 mm/memory.c:3225 mm/memory.c:3345 mm/memory.c:3374)
[  360.560345] ? vmacache_update (mm/vmacache.c:61)
[  360.560358] ? find_vma (mm/mmap.c:2027)
[  360.560370] __do_page_fault (arch/x86/mm/fault.c:1231)
[  360.560386] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[  360.560400] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  360.560413] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2639 (discriminator 8))
[  360.560425] ? trace_hardirqs_off (kernel/locking/lockdep.c:2645)
[  360.560432] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
[  360.560440] do_async_page_fault (arch/x86/kernel/kvm.c:279)
[  360.560447] async_page_fault (arch/x86/kernel/entry_64.S:1321)
[ 360.560458] Code: 47 f9 48 8b 8d 68 ff ff ff 48 29 f1 48 c1 e9 0c 49 8d 44 08 ff 48 39 c7 48 0f 46 c7 4c 89 ff 48 89 85 60 ff ff ff e8 3e 19 07 00 <49> 83 3f 00 0f 84 8f 00 00 00 49 83 c6 01 4c 39 b5 60 ff ff ff
All code
========
   0:	47 f9                	rex.RXB stc
   2:	48 8b 8d 68 ff ff ff 	mov    -0x98(%rbp),%rcx
   9:	48 29 f1             	sub    %rsi,%rcx
   c:	48 c1 e9 0c          	shr    $0xc,%rcx
  10:	49 8d 44 08 ff       	lea    -0x1(%r8,%rcx,1),%rax
  15:	48 39 c7             	cmp    %rax,%rdi
  18:	48 0f 46 c7          	cmovbe %rdi,%rax
  1c:	4c 89 ff             	mov    %r15,%rdi
  1f:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  26:	e8 3e 19 07 00       	callq  0x71969
  2b:*	49 83 3f 00          	cmpq   $0x0,(%r15)		<-- trapping instruction
  2f:	0f 84 8f 00 00 00    	je     0xc4
  35:	49 83 c6 01          	add    $0x1,%r14
  39:	4c 39 b5 60 ff ff ff 	cmp    %r14,-0xa0(%rbp)
	...

Code starting with the faulting instruction
===========================================
   0:	49 83 3f 00          	cmpq   $0x0,(%r15)
   4:	0f 84 8f 00 00 00    	je     0x99
   a:	49 83 c6 01          	add    $0x1,%r14
   e:	4c 39 b5 60 ff ff ff 	cmp    %r14,-0xa0(%rbp)
	...
[  360.560458] RIP do_read_fault.isra.40 (mm/memory.c:2864 mm/memory.c:2898)
[  360.560458]  RSP <ffff8801ba8bbc98>
[  360.560458] CR2: ffff880581ee3fd0
[  360.560458] ---[ end trace ccd7cee352be7945 ]---

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
