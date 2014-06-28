Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD0D06B0036
	for <linux-mm@kvack.org>; Sat, 28 Jun 2014 17:47:13 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so6374039pac.5
        for <linux-mm@kvack.org>; Sat, 28 Jun 2014 14:47:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id hx2si18215953pbb.205.2014.06.28.14.47.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Jun 2014 14:47:13 -0700 (PDT)
Message-ID: <53AF3676.8080509@oracle.com>
Date: Sat, 28 Jun 2014 17:41:10 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz> <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53AC383F.3010007@oracle.com> <alpine.LSU.2.11.1406262236370.27670@eggly.anvils> <53AD84CE.20806@oracle.com> <alpine.LSU.2.11.1406271043270.28744@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406271043270.28744@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 06/27/2014 02:03 PM, Hugh Dickins wrote:
> On Fri, 27 Jun 2014, Sasha Levin wrote:
>> On 06/27/2014 01:59 AM, Hugh Dickins wrote:
>>>>> First, this:
>>>>>
>>>>> [  681.267487] BUG: unable to handle kernel paging request at ffffea0003480048
>>>>> [  681.268621] IP: zap_pte_range (mm/memory.c:1132)
>>> Weird, I don't think we've seen anything like that before, have we?
>>> I'm pretty sure it's not a consequence of my "index = min(index, end)",
>>> but what it portends I don't know.  Please confirm mm/memory.c:1132 -
>>> that's the "if (PageAnon(page))" line, isn't it?  Which indeed matches
>>> the code below.  So accessing page->mapping is causing an oops...
>>
>> Right, that's the correct line.
>>
>> At this point I'm pretty sure that it's somehow related to that one line
>> patch since it reproduced fairly quickly after applying it, and when I
>> removed it I didn't see it happening again during the overnight fuzzing.
> 
> Oh, I assumed it was a one-off: you're saying that you saw it more than
> once with the min(index, end) patch in?  But not since removing it (did
> you replace that by the newer patch? or by the older? or by nothing?).

It reproduced exactly twice, can't say it happens too often.

What I did was revert your original fix for the issue and apply the one-liner.

I've spent most of yesterday chasing a different bug with a "clean" -next
tree (without the revert and the one-line patch) and didn't see any mm/
issues.

However, about 2 hours after doing the revert and applying the one-line
patch I've encountered the following:

[ 3686.797859] BUG: unable to handle kernel paging request at ffff88028a488f98
[ 3686.805732] IP: do_read_fault.isra.40 (mm/memory.c:2856 mm/memory.c:2889)
[ 3686.805732] PGD 12b82067 PUD 704d49067 PMD 704cf6067 PTE 800000028a488060
[ 3686.805732] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3686.815852] Dumping ftrace buffer:
[ 3686.815852]    (ftrace buffer empty)
[ 3686.815852] Modules linked in:
[ 3686.815852] CPU: 10 PID: 8890 Comm: modprobe Not tainted 3.16.0-rc2-next-20140627-sasha-00024-ga284b83-dirty #753
[ 3686.815852] task: ffff8801d1c20000 ti: ffff8801c6a08000 task.ti: ffff8801c6a08000
[ 3686.826134] RIP: do_read_fault.isra.40 (mm/memory.c:2856 mm/memory.c:2889)
[ 3686.826134] RSP: 0000:ffff8801c6a0bc78  EFLAGS: 00010297
[ 3686.826134] RAX: 0000000000000000 RBX: ffff880288531200 RCX: 000000000000001f
[ 3686.826134] RDX: 0000000000000014 RSI: 00007f22949f3000 RDI: ffff88028a488f98
[ 3686.826134] RBP: ffff8801c6a0bd18 R08: 00007f2294a13000 R09: 000000000000000c
[ 3686.826134] R10: 0000000000000000 R11: 00000000000000a8 R12: 00007f2294a07c50
[ 3686.826134] R13: ffff880279fec4b0 R14: 00007f22949f3000 R15: ffff88028ebbc528
[ 3686.826134] FS:  0000000000000000(0000) GS:ffff880292e00000(0000) knlGS:0000000000000000
[ 3686.826134] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3686.826134] CR2: ffff88028a488f98 CR3: 000000026b766000 CR4: 00000000000006a0
[ 3686.826134] Stack:
[ 3686.826134]  ffff8801c6a0bc98 0000000000000001 ffff8802000000a8 0000000000000014
[ 3686.826134]  ffff88028a489038 0000000000000000 ffff88026d40d000 ffff88028eafaee0
[ 3686.826134]  ffff8801c6a0bcd8 ffffffff8e572715 ffffea000a292240 000000000028a489
[ 3686.826134] Call Trace:
[ 3686.826134] ? _raw_spin_unlock (./arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:152 kernel/locking/spinlock.c:183)
[ 3686.826134] ? __pte_alloc (mm/memory.c:598 mm/memory.c:593)
[ 3686.826134] __handle_mm_fault (mm/memory.c:3037 mm/memory.c:3198 mm/memory.c:3322)
[ 3686.826134] handle_mm_fault (include/linux/memcontrol.h:124 mm/memory.c:3348)
[ 3686.826134] ? __do_page_fault (arch/x86/mm/fault.c:1163)
[ 3686.826134] __do_page_fault (arch/x86/mm/fault.c:1230)
[ 3686.826134] ? vtime_account_user (kernel/sched/cputime.c:687)
[ 3686.826134] ? get_parent_ip (kernel/sched/core.c:2550)
[ 3686.826134] ? context_tracking_user_exit (include/linux/vtime.h:89 include/linux/jump_label.h:115 include/trace/events/context_tracking.h:47 kernel/context_tracking.c:180)
[ 3686.826134] ? preempt_count_sub (kernel/sched/core.c:2606)
[ 3686.826134] ? context_tracking_user_exit (kernel/context_tracking.c:184)
[ 3686.826134] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 3686.826134] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
[ 3686.826134] trace_do_page_fault (arch/x86/mm/fault.c:1313 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1314)
[ 3686.826134] do_async_page_fault (arch/x86/kernel/kvm.c:264)
[ 3686.826134] async_page_fault (arch/x86/kernel/entry_64.S:1322)
[ 3686.826134] Code: 89 c0 4c 8b 43 08 48 8d 4c 08 ff 49 01 c1 49 39 c9 4c 0f 47 c9 4c 89 c1 4c 29 f1 48 c1 e9 0c 49 8d 4c 0a ff 49 39 c9 4c 0f 47 c9 <48> 83 3f 00 74 3c 48 83 c0 01 4c 39 c8 77 74 48 81 c6 00 10 00
All code
========
   0:	89 c0                	mov    %eax,%eax
   2:	4c 8b 43 08          	mov    0x8(%rbx),%r8
   6:	48 8d 4c 08 ff       	lea    -0x1(%rax,%rcx,1),%rcx
   b:	49 01 c1             	add    %rax,%r9
   e:	49 39 c9             	cmp    %rcx,%r9
  11:	4c 0f 47 c9          	cmova  %rcx,%r9
  15:	4c 89 c1             	mov    %r8,%rcx
  18:	4c 29 f1             	sub    %r14,%rcx
  1b:	48 c1 e9 0c          	shr    $0xc,%rcx
  1f:	49 8d 4c 0a ff       	lea    -0x1(%r10,%rcx,1),%rcx
  24:	49 39 c9             	cmp    %rcx,%r9
  27:	4c 0f 47 c9          	cmova  %rcx,%r9
  2b:*	48 83 3f 00          	cmpq   $0x0,(%rdi)		<-- trapping instruction
  2f:	74 3c                	je     0x6d
  31:	48 83 c0 01          	add    $0x1,%rax
  35:	4c 39 c8             	cmp    %r9,%rax
  38:	77 74                	ja     0xae
  3a:	48 81 c6 00 10 00 00 	add    $0x1000,%rsi

Code starting with the faulting instruction
===========================================
   0:	48 83 3f 00          	cmpq   $0x0,(%rdi)
   4:	74 3c                	je     0x42
   6:	48 83 c0 01          	add    $0x1,%rax
   a:	4c 39 c8             	cmp    %r9,%rax
   d:	77 74                	ja     0x83
   f:	48 81 c6 00 10 00 00 	add    $0x1000,%rsi
[ 3686.826134] RIP do_read_fault.isra.40 (mm/memory.c:2856 mm/memory.c:2889)
[ 3686.826134]  RSP <ffff8801c6a0bc78>
[ 3686.826134] CR2: ffff88028a488f98

Association is not causation but this is pretty suspicious...

> I want to exclaim "That makes no sense!", but bugs don't make sense
> anyway.  It's going to be a challenge to work out a connection though.
> I think I want to ask for more attempts to reproduce, with and without
> the min(index, end) patch (if you have enough time - there must be a
> limit to the amount of time you can give me on this).
> 
> I rather hoped that the oops on PageAnon might shed light from another
> direction on the outstanding page_mapped bug: both seem like page table
> corruption of some kind (though I've not seen a plausible path to either).
> 
> And regarding the page_mapped bug: we've heard nothing since Dave
> Hansen suggested a VM_BUG_ON_PAGE for that - has it gone away now?

Seems like it. I'm carrying Dave's patch still, but haven't seen it
triggering.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
