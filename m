Received: from talaria.jf.intel.com (talaria.jf.intel.com [10.7.209.7])
	by hermes.jf.intel.com (8.12.9-20030918-01/8.12.9/d: outer.mc,v 1.66 2003/05/22 21:17:36 rfjohns1 Exp $) with ESMTP id h8IKMQ3D006524
	for <linux-mm@kvack.org>; Thu, 18 Sep 2003 20:22:26 GMT
Date: Thu, 18 Sep 2003 13:21:49 -0700
Message-Id: <200309182021.h8IKLnqX006918@penguin.co.intel.com>
From: Rusty Lynch <rusty@linux.co.intel.com>
Subject: swapping to death by stressing mlock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: rusty@linux.co.intel.com
List-ID: <linux-mm.kvack.org>

While getting more familiar with the vm subsystem I discovered that it is
fairly easy to lockup my system by mlocking enough memory. I believe what 
is happening is that I am reducing the amount of swappable physical ram
to the point that try_to_free_pages() will go into an endless loop waiting
for bdflush to free up some pages.

I'm guessing this is not a valid condition for a properly configured server,
but since I'm not feeling very confident about my above explanation, I'm not
so sure this isn't something to look into.

On my 2.6.0-test5 kernel I run a little utility that attempts to allocate 
a large enough chunk of memory, touch all pages in the buffer, and then 
mlock the buffer.  Just setting vm.overcommit_memory=2 and a real low
vm.overcommit_ratio doesn't help a lot since all I have to do is squeeze out
the available physical ram that can be swapped out.

This is what I see for my offending process if I meta-sysrq-t.

fat_bastard   D 00000001 4293732848   598    550                     (NOTLB)
cc9d3c78 00000082 c1285bc0 00000001 00000003 c1286580 c1285bc0 cc9d3c98
       00000000 00000246 c014f520 cc9d3c6c cf033004 cf6ff000 00000007 00000000
       00000000 ffff8258 cc9d3c8c 00000000 cc9d3cc4 c0134dde cc9d3c8c ffff8258
Call Trace:
 [<c014f520>] background_writeout+0x0/0xe0
 [<c0134dde>] schedule_timeout+0x6e/0xc0
 [<c0134d60>] process_timeout+0x0/0x10
 [<c012793b>] io_schedule_timeout+0x2b/0x40
 [<c031d2bb>] blk_congestion_wait+0x8b/0xa0
 [<c0128c30>] autoremove_wake_function+0x0/0x50
 [<c0128c30>] autoremove_wake_function+0x0/0x50
 [<c01581f2>] try_to_free_pages+0x102/0x1c0
 [<c014e1a7>] __alloc_pages+0x1f7/0x3a0
 [<c0166d31>] read_swap_cache_async+0xb1/0xbd
 [<c015b8b2>] swapin_readahead+0x42/0x90
 [<c015bb68>] do_swap_page+0x268/0x340
 [<c011007b>] save_v86_state+0x4b/0x200
 [<c015c521>] handle_mm_fault+0xf1/0x200
 [<c015ab1e>] get_user_pages+0xee/0x3a0
 [<c015f18d>] insert_vm_struct+0x6d/0x77
 [<c015c74d>] make_pages_present+0x8d/0xa0
 [<c015cd24>] mlock_fixup+0xe4/0x120
 [<c0280e94>] capable+0x24/0x50
 [<c015ce49>] do_mlock+0xe9/0x110
 [<c015cf37>] sys_mlock+0xc7/0xe0
 [<c010c873>] syscall_call+0x7/0xb

If I attempt to kill all processes with meta-sysrq-i, then I start seeing init
stuck in the same spot:

init          D 00000001 21838320   606      1                 605 (NOTLB)
cea9fc5c 00000082 c1285bc0 00000001 00000003 c1286580 c1285bc0 cea9fc7c
       00000000 00000246 c014f520 cea9fc50 ce3d0004 cf6ff000 00000007 00000000
       00000000 00076d98 cea9fc70 00000000 cea9fca8 c0134dde cea9fc70 00076d98
Call Trace:
 [<c014f520>] background_writeout+0x0/0xe0
 [<c0134dde>] schedule_timeout+0x6e/0xc0
 [<c0134d60>] process_timeout+0x0/0x10
 [<c012793b>] io_schedule_timeout+0x2b/0x40
 [<c031d2bb>] blk_congestion_wait+0x8b/0xa0
 [<c0128c30>] autoremove_wake_function+0x0/0x50
 [<c0128c30>] autoremove_wake_function+0x0/0x50
 [<c01581f2>] try_to_free_pages+0x102/0x1c0
 [<c014e1a7>] __alloc_pages+0x1f7/0x3a0
 [<c0150982>] __do_page_cache_readahead+0x182/0x21e
 [<c014b18f>] filemap_nopage+0x11f/0x330
 [<c015bff1>] do_no_page+0xd1/0x3f0
 [<c015c548>] handle_mm_fault+0x118/0x200
 [<c0123886>] do_page_fault+0x176/0x4dc
 [<c0138c91>] sigprocmask+0x71/0x150
 [<c0138e11>] sys_rt_sigprocmask+0xa1/0x1e0
 [<c0123710>] do_page_fault+0x0/0x4dc
 [<c010d2dd>] error_code+0x2d/0x38

The current process (as seen via meta-sysrq-p) seems to always be the swapper:
Pid: 0, comm:              swapper
EIP: 0060:[<c010a070>] CPU: 0
EIP is at default_idle+0x30/0x40
 EFLAGS: 00000246    Not tainted
EAX: 00000000 EBX: c0600000 ECX: 001d9b2e EDX: c0600000
ESI: c0600000 EDI: c010a040 EBP: c0601fb4 DS: 007b ES: 007b
CR0: 8005003b CR2: 0804d6a0 CR3: 0b9b8000 CR4: 00000680
Call Trace:
 [<c010a106>] cpu_idle+0x46/0x50
 [<c0105000>] rest_init+0x0/0x80
 [<c0602961>] start_kernel+0x181/0x1b0
 [<c0602500>] unknown_bootoption+0x0/0x100

I also noticed that try_to_free_pages() is ignoring the return value for 
wakeup_bdflush(), so for kicks I 

+        WARN_ON(wakeup_bdflush(total_scanned));
-        wakeup_bdflush(total_scanned);

After my system is nicely locked up, I start seeing tons of warnings
like:

Badness in try_to_free_pages at mm/vmscan.c:886
Call Trace:
 [<c01582b8>] try_to_free_pages+0x1c8/0x1e0
 [<c014e1a7>] __alloc_pages+0x1f7/0x3a0
 [<c014e372>] __get_free_pages+0x22/0x50
 [<c0152385>] cache_grow+0x125/0x400
 [<c013437c>] del_timer_sync+0x2c/0x80
 [<c0124819>] kernel_map_pages+0x29/0x64
 [<c015279a>] cache_alloc_refill+0x13a/0x4c0
 [<c0153185>] kmem_cache_alloc+0x1b5/0x1e0
 [<c017ca59>] getname+0x29/0xd0
 [<c017e28b>] __user_walk+0x1b/0x60
 [<c018319e>] select_bits_alloc+0x1e/0x30
 [<c01785ce>] vfs_stat+0x1e/0x60
 [<c01833fb>] sys_select+0x23b/0x520
 [<c0178ccb>] sys_stat64+0x1b/0x40
 [<c012f105>] sys_time+0x35/0x70
 [<c010c873>] syscall_call+0x7/0xb


So... is my explanation on target?  Is this a condition that would really
only pop up in crazy stress testing?  If not then maybe sys_mlock should have
an additional threshold?

    --rustyl
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
