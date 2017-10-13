Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11BF26B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 00:45:31 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q4so13806148qtq.16
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 21:45:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n30si112638qtf.26.2017.10.12.21.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 21:45:29 -0700 (PDT)
Date: Thu, 12 Oct 2017 23:45:21 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [lkp-robot] [x86/kconfig]  81d3871900:
 BUG:unable_to_handle_kernel
Message-ID: <20171013044521.662ck56gkwaw3xog@treble>
References: <20171010121513.GC5445@yexl-desktop>
 <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble>
 <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 12, 2017 at 12:05:04PM -0500, Christopher Lameter wrote:
> On Wed, 11 Oct 2017, Josh Poimboeuf wrote:
> 
> > I failed to add the slab maintainers to CC on the last attempt.  Trying
> > again.
> 
> 
> Hmmm... Yea. SLOB is rarely used and tested. Good illustration of a simple
> allocator and the K&R mechanism that was used in the early kernels.
> 
> > > Adding the slub maintainers.  Is slob still supposed to work?
> 
> Have not seen anyone using it in a decade or so.
> 
> Does the same config with SLUB and slub_debug on the commandline run
> cleanly?
> 
> > > I have no idea how that crypto panic could could be related to slob, but
> > > at least it goes away when I switch to slub.
> 
> Can you run SLUB with full debug? specify slub_debug on the commandline or
> set CONFIG_SLUB_DEBUG_ON

Oddly enough, with CONFIG_SLUB+slub_debug, I get the same crypto panic I
got with CONFIG_SLOB.  The trapping instruction is:

  vmovdqa 0x140(%rdi),%xmm0
  
I'll try to bisect it tomorrow.  It at least goes back to v4.10.  I'm
not really sure whether this panic is related to SLUB or SLOB at all.
(Though the original panic reported upthread by the kernel test robot
*does* look SLOB related.)

  general protection fault: 0000 [#1] PREEMPT SMP
  Modules linked in:
  CPU: 0 PID: 58 Comm: kworker/0:1 Not tainted 4.13.0 #81
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
  Workqueue: crypto mcryptd_flusher
  task: ffff880139108040 task.stack: ffffc9000082c000
  RIP: 0010:skip_7+0x0/0x67
  RSP: 0018:ffffc9000082fd88 EFLAGS: 00010246
  RAX: ffff88013834172c RBX: 00000000f7654321 RCX: 0000000000000003
  RDX: 0000000000000000 RSI: ffffffff81d254f9 RDI: ffff8801381b1a88
  RBP: ffffc9000082fd90 R08: 0000000000000000 R09: 0000000000000001
  R10: 0000000000000001 R11: 0000000000000000 R12: ffffffff82392260
  R13: ffff88013a7e6500 R14: 00000000fffb80f5 R15: 0000000000000000
  FS:  0000000000000000(0000) GS:ffff88013a600000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007f88491ef914 CR3: 0000000001e11000 CR4: 00000000001406f0
  Call Trace:
   sha256_ctx_mgr_flush+0x28/0x30
   sha256_mb_flusher+0x53/0x120
   mcryptd_flusher+0xc4/0xf0
   process_one_work+0x253/0x6b0
   worker_thread+0x4d/0x3b0
   ? preempt_count_sub+0x9b/0x100
   kthread+0x133/0x150
   ? process_one_work+0x6b0/0x6b0
   ? kthread_create_on_node+0x70/0x70
   ret_from_fork+0x2a/0x40
  Code: 89 87 30 01 00 00 c7 87 58 01 00 00 ff ff ff ff 48 83 bf a0 01 00 00 00 75 11 48 89 87 38 01 00 00 c7 87 5c 01 00 00 ff ff ff ff <c5> f9 6f 87 40 01 00 00 c5 f9 6f 8f 50 01 00 00 c4 e2 79 3b d1
  RIP: skip_7+0x0/0x67 RSP: ffffc9000082fd88
  ---[ end trace d89a1613b7d1b8bc ]---
  BUG: sleeping function called from invalid context at ./include/linux/percpu-rwsem.h:33
  in_atomic(): 1, irqs_disabled(): 0, pid: 58, name: kworker/0:1
  INFO: lockdep is turned off.
  Preemption disabled at:
  [<ffffffff81041933>] kernel_fpu_begin+0x13/0x20
  CPU: 0 PID: 58 Comm: kworker/0:1 Tainted: G      D         4.13.0 #81
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
  Workqueue: crypto mcryptd_flusher
  Call Trace:
   dump_stack+0x8e/0xcd
   ___might_sleep+0x185/0x260
   __might_sleep+0x4a/0x80
   exit_signals+0x33/0x2d0
   do_exit+0xb4/0xd80
   ? kthread+0x133/0x150
   rewind_stack_do_exit+0x17/0x20
  note: kworker/0:1[58] exited with preempt_count 1
  tsc: Refined TSC clocksource calibration: 2793.538 MHz
  clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x28446877189, max_idle_ns: 440795280878 ns

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
