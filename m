Date: Fri, 05 Nov 2004 22:49:58 +0900 (JST)
Message-Id: <20041105.224958.94279091.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041028160520.GB7562@logos.cnet>
References: <20041027.224837.118287069.taka@valinux.co.jp>
	<20041028151928.GA7562@logos.cnet>
	<20041028160520.GB7562@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi, Marcelo,

I happened to meet a bug.

> > Yep thats probably what caused your failures.
> > 
> > I'll prepare a new patch.
> 
> Here it is - with the copy_page_range() fix as you pointed out,
> plus sys_swapon() fix as suggested by Hiroyuki.
> 
> I've also added a BUG() in case of swap_free() failure, so we 
> get a backtrace.
> 
> Can you please test this - thanks.

>From the attached message, lookup_migration_cache() returned NULL
in do_swap_page(). There might be a race condition related the
migration cache.


Nov  5 22:18:22 target1 kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000000
Nov  5 22:18:22 target1 kernel:  printing eip:
Nov  5 22:18:22 target1 kernel: c0141364
Nov  5 22:18:22 target1 kernel: *pde = 00000000
Nov  5 22:18:22 target1 kernel: Oops: 0000 [#1]
Nov  5 22:18:22 target1 kernel: SMP 
Nov  5 22:18:22 target1 kernel: Modules linked in:
Nov  5 22:18:22 target1 kernel: CPU:    0
Nov  5 22:18:22 target1 kernel: EIP:    0060:[mark_page_accessed+4/80]    Not tainted VLI
Nov  5 22:18:22 target1 kernel: EIP:    0060:[<c0141364>]    Not tainted VLI
Nov  5 22:18:22 target1 kernel: EFLAGS: 00010246   (2.6.9-rc4-mm1) 
Nov  5 22:18:22 target1 kernel: EIP is at mark_page_accessed+0x4/0x50
Nov  5 22:18:22 target1 kernel: eax: 00000000   ebx: 00000000   ecx: c0304700   edx: f8000005
Nov  5 22:18:22 target1 kernel: esi: 00000000   edi: 0000053e   ebp: b72eafe0   esp: ce12be90
Nov  5 22:18:22 target1 kernel: ds: 007b   es: 007b   ss: 0068
Nov  5 22:18:22 target1 kernel: Process grep (pid: 2441, threadinfo=ce12a000 task=cf66d550)
Nov  5 22:18:22 target1 kernel: Stack: f8000005 00000000 c01474d4 c01065c2 00000001 ef720000 cf2655f4 ccc13b70 
Nov  5 22:18:22 target1 kernel:        b72eafe0 cf76cdc0 c0147cf4 cf76cdc0 cf2655f4 b72eafe0 c84f8ba8 ccc13b70 
Nov  5 22:18:22 target1 kernel:        0000053e 00000000 b72eafe0 cf76cdc0 cf2655f4 cf66d550 c0114835 cf76cdc0 
Nov  5 22:18:22 target1 kernel: Call Trace:
Nov  5 22:18:22 target1 kernel:  [do_swap_page+372/784] do_swap_page+0x174/0x310
Nov  5 22:18:22 target1 kernel:  [<c01474d4>] do_swap_page+0x174/0x310
Nov  5 22:18:22 target1 kernel:  [apic_timer_interrupt+26/32] apic_timer_interrupt+0x1a/0x20
Nov  5 22:18:22 target1 kernel:  [<c01065c2>] apic_timer_interrupt+0x1a/0x20
Nov  5 22:18:22 target1 kernel:  [handle_mm_fault+228/352] handle_mm_fault+0xe4/0x160
Nov  5 22:18:22 target1 kernel:  [<c0147cf4>] handle_mm_fault+0xe4/0x160
Nov  5 22:18:22 target1 kernel:  [do_page_fault+469/1487] do_page_fault+0x1d5/0x5cf
Nov  5 22:18:22 target1 kernel:  [<c0114835>] do_page_fault+0x1d5/0x5cf
Nov  5 22:18:22 target1 kernel:  [run_timer_softirq+481/496] run_timer_softirq+0x1e1/0x1f0
Nov  5 22:18:22 target1 kernel:  [<c0124821>] run_timer_softirq+0x1e1/0x1f0
Nov  5 22:18:22 target1 kernel:  [update_wall_time+21/64] update_wall_time+0x15/0x40
Nov  5 22:18:22 target1 kernel:  [<c01244d5>] update_wall_time+0x15/0x40
Nov  5 22:18:22 target1 kernel:  [do_timer+46/192] do_timer+0x2e/0xc0
Nov  5 22:18:22 target1 kernel:  [<c012486e>] do_timer+0x2e/0xc0
Nov  5 22:18:22 target1 kernel:  [timer_interrupt+72/240] timer_interrupt+0x48/0xf0
Nov  5 22:18:22 target1 kernel:  [<c010b148>] timer_interrupt+0x48/0xf0
Nov  5 22:18:22 target1 kernel:  [timer_interrupt+229/240] timer_interrupt+0xe5/0xf0
Nov  5 22:18:22 target1 kernel:  [<c010b1e5>] timer_interrupt+0xe5/0xf0
Nov  5 22:18:22 target1 kernel:  [handle_IRQ_event+44/96] handle_IRQ_event+0x2c/0x60
Nov  5 22:18:22 target1 kernel:  [<c013530c>] handle_IRQ_event+0x2c/0x60
Nov  5 22:18:22 target1 kernel:  [__do_IRQ+280/336] __do_IRQ+0x118/0x150
Nov  5 22:18:22 target1 kernel:  [<c0135458>] __do_IRQ+0x118/0x150
Nov  5 22:18:22 target1 kernel:  [__do_IRQ+318/336] __do_IRQ+0x13e/0x150
Nov  5 22:18:22 target1 kernel:  [<c013547e>] __do_IRQ+0x13e/0x150
Nov  5 22:18:22 target1 kernel:  [do_page_fault+0/1487] do_page_fault+0x0/0x5cf
Nov  5 22:18:22 target1 kernel:  [<c0114660>] do_page_fault+0x0/0x5cf
Nov  5 22:18:22 target1 kernel:  [error_code+45/56] error_code+0x2d/0x38
Nov  5 22:18:22 target1 kernel:  [<c010663d>] error_code+0x2d/0x38
Nov  5 22:18:22 target1 kernel: Code: 1c 85 20 80 3f c0 01 da ff 42 38 51 9d 8d 86 00 01 00 00 e8 ef e9 14 00 5b 5e 5f c3 8d 74 26 00 8d bc 27 00 00 00 00 56 53 89 c3 <8b> 03 83 e0 40 75 25 8b 03 be 02 00 00 00 83 e0 04 74 19 8b 03 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
