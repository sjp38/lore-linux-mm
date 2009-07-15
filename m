Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CEB4E6B0082
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 05:10:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6F9mGVU019105
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Jul 2009 18:48:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C795545DE4F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 18:48:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4E7945DE4E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 18:48:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D64BE38002
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 18:48:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C4601DB803A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 18:48:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Jul 2009 18:48:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi

On 2.6.31-rc3, following test makes kernel panic immediately.

  numactl --interleave=all echo

Panic message is below. I don't think commit 58568d2a8 is correct patch.

old behavior:
  do_set_mempolicy
    mpol_new
      cpuset_update_task_memory_state
        guarantee_online_mems
          nodes_and(cs->mems_allowed, node_states[N_HIGH_MEMORY]);

but new code doesn't consider N_HIGH_MEMORY. Then, the userland program
passing non-online node bit makes crash, I guess.

Miao, What do you think?


========================================================
login: numactl[4506]: NaT consumption 17179869216 [1]
Modules linked in: binfmt_misc nls_iso8859_1 nls_cp437 dm_multipath scsi_dh fan sg processor button thermal container e100 mii dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 4506, CPU 1, comm:              numactl
psr : 00001010085a6010 ifs : 8000000000000a1c ip  : [<a0000001001c16b0>]    Not tainted (2.6.31-rc2-g8b48a9f-dirty)
ip is at __alloc_pages_nodemask+0x130/0xc00
unat: 0000000000000000 pfs : 0000000000000a1c rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0021055a065a9555
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001c16b0 b6  : a0000001001b2620 b7  : a00000010000c300
f6  : 1003e0000000000000002 f7  : 1003e00000000fffffffe
f8  : 1001580200800ffbfeffc f9  : 1003efffffffffffffc01
f10 : 10006acfffffffeeae330 f11 : 1003e0000000000000000
r1  : a0000001010c5840 r2  : e0000040cf590ea0 r3  : 0000000000000000
r8  : 0000000000000000 r9  : a000000100ec64d8 r10 : 0000000000080008
r11 : 0000000000000008 r12 : e0000040cf59fdc0 r13 : e0000040cf590000
r14 : 0000000000000000 r15 : 0000000000000002 r16 : 0000000000080008
r17 : 0000000000000000 r18 : 0000000000000002 r19 : 00000000003fffff
r20 : a000000100d45538 r21 : a000000100ec6180 r22 : 0000000000000000
r23 : 0000000000000000 r24 : 0000000000000070 r25 : 0000000000000028
r26 : a000000100e5ee28 r27 : a000000100e5ee20 r28 : 0000000000000001
r29 : e0000040cf590ea4 r30 : e0000040c011012c r31 : 0000000000000000

Call Trace:
 [<a000000100019c00>] show_stack+0x80/0xa0
                                sp=e0000040cf59f810 bsp=e0000040cf591610
 [<a00000010001a710>] show_regs+0xa90/0xac0
                                sp=e0000040cf59f9e0 bsp=e0000040cf5915b0
 [<a000000100057360>] die+0x2c0/0x3e0
                                sp=e0000040cf59f9e0 bsp=e0000040cf591568
 [<a0000001000574d0>] die_if_kernel+0x50/0x80
                                sp=e0000040cf59f9e0 bsp=e0000040cf591538
 [<a0000001008c3990>] ia64_fault+0xf0/0x2080
                                sp=e0000040cf59f9e0 bsp=e0000040cf5914e8
 [<a00000010008df20>] paravirt_leave_kernel+0x0/0x40
                                sp=e0000040cf59fbf0 bsp=e0000040cf5914e8
 [<a0000001001c16b0>] __alloc_pages_nodemask+0x130/0xc00
                                sp=e0000040cf59fdc0 bsp=e0000040cf591408
 [<a0000001002249b0>] alloc_page_interleave+0xb0/0x180
                                sp=e0000040cf59fde0 bsp=e0000040cf5913c8
 [<a000000100225010>] alloc_page_vma+0x1d0/0x2e0
                                sp=e0000040cf59fdf0 bsp=e0000040cf591390
 [<a0000001001eeea0>] handle_mm_fault+0xa20/0x15a0
                                sp=e0000040cf59fdf0 bsp=e0000040cf591308
 [<a0000001001efca0>] __get_user_pages+0x280/0x9e0
                                sp=e0000040cf59fe00 bsp=e0000040cf591260
 [<a0000001001f0460>] get_user_pages+0x60/0x80
                                sp=e0000040cf59fe10 bsp=e0000040cf591208
 [<a00000010025bbe0>] get_arg_page+0xa0/0x220
                                sp=e0000040cf59fe10 bsp=e0000040cf5911d0
 [<a00000010025c4a0>] copy_strings+0x3e0/0x6c0
                                sp=e0000040cf59fe20 bsp=e0000040cf591120
 [<a00000010025c880>] copy_strings_kernel+0x100/0x180
                                sp=e0000040cf59fe20 bsp=e0000040cf5910e8
 [<a000000100261790>] do_execve+0x6b0/0xba0
                                sp=e0000040cf59fe20 bsp=e0000040cf591080
 [<a000000100017fc0>] sys_execve+0x60/0xc0
                                sp=e0000040cf59fe30 bsp=e0000040cf591048
 [<a00000010000c030>] ia64_execve+0x30/0x160
                                sp=e0000040cf59fe30 bsp=e0000040cf590ff0
 [<a00000010000c980>] ia64_ret_from_syscall+0x0/0x40
                                sp=e0000040cf59fe30 bsp=e0000040cf590ff0
 [<a000000000012000>] __kernel_syscall_via_break+0x0/0x20
                                sp=e0000040cf5a0000 bsp=e0000040cf590ff0
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Fatal exception
Rebooting in 1 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
