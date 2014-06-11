Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFDB6B0154
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 08:13:08 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uz6so4270635obc.1
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:13:07 -0700 (PDT)
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
        by mx.google.com with ESMTPS id ci3si31037622oec.83.2014.06.11.05.13.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 05:13:07 -0700 (PDT)
Received: by mail-oa0-f44.google.com with SMTP id i7so4393176oag.31
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:13:07 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 11 Jun 2014 16:13:07 +0400
Message-ID: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
Subject: kmemleak: Unable to handle kernel paging request
From: Denis Kirjanov <kda@linux-powerpc.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Hi,

I got a trace while running 3.15.0-08556-gdfb9454:

[  104.534026] Unable to handle kernel paging request for data at
address 0xc00000007f000000
[  104.534197] Faulting instruction address: 0xc00000000019cb50
[  104.534204] Oops: Kernel access of bad area, sig: 11 [#1]
[  104.534891] PREEMPT SMP NR_CPUS=4 NUMA PowerMac
[  104.535550] Modules linked in: ipv6 bonding snd_aoa_codec_onyx
snd_aoa snd soundcore uninorth_agp unix
[  104.536940] CPU: 1 PID: 1241 Comm: kmemleak Not tainted
3.15.0-08556-gdfb9454 #49
[  104.537881] task: c0000001652cc000 ti: c000000165570000 task.ti:
c000000165570000
[  104.538819] NIP: c00000000019cb50 LR: c00000000019cb48 CTR: c0000000000d3e60
[  104.539706] REGS: c000000165573740 TRAP: 0300   Not tainted
(3.15.0-08556-gdfb9454)
[  104.540676] MSR: 9000000000009032 <SF,HV,EE,ME,IR,DR,RI>  CR:
48502542  XER: 00000000
[  104.541887] DAR: c00000007f000000 DSISR: 40010000 SOFTE: 0
GPR00: c00000000019cb48 c0000001655739c0 c0000000012f1858 0000000000000000
GPR04: c00000007f001000 c00000017a024450 0000000000000000 0000000000000000
GPR08: 0000000000000573 c000000165573d98 0000000000000001 0000000000000000
GPR12: 0000000048500544 c00000000ffff400 c0000000000aa5e0 c000000166d43680
GPR16: 0000000000000000 0000000000000000 0000000000000000 c000000002081858
GPR20: 0000000000000100 c0000000020a1858 c0000000011b8ee0 c000000080000000
GPR24: c0000000011c0a28 c0000000011c0b80 c000000000a0ab88 c0000000011c0a28
GPR28: c00000017a024450 c00000007f000ff9 c00000007f000000 c00000017a024450
[  104.550169] NIP [c00000000019cb50] .scan_block+0x70/0x170
[  104.550852] LR [c00000000019cb48] .scan_block+0x68/0x170
[  104.554164] Call Trace:
[  104.557023] [c0000001655739c0] [c00000000019cb48]
.scan_block+0x68/0x170 (unreliable)
[  104.560578] [c000000165573a70] [c00000000019ce68] .scan_gray_list+0x218/0x270
[  104.564030] [c000000165573b30] [c00000000019d240] .kmemleak_scan+0x380/0x740
[  104.567491] [c000000165573c20] [c00000000019d67c]
.kmemleak_scan_thread+0x7c/0x120
[  104.571017] [c000000165573cb0] [c0000000000aa6e4] .kthread+0x104/0x130
[  104.574365] [c000000165573e30] [c00000000000a428]
.ret_from_kernel_thread+0x58/0xb0
[  104.577772] Instruction dump:
[  104.580634] 2e260000 409c00b8 3f62ffed 3f42ff72 3b7bf1d0 7cbc2b78
3b5a9330 3b3b0158
[  104.584274] 409200f0 4bffff2d 2fa30000 409e0090 <e87e0000> 38800001
4bfff279 7c7f1b79
[  104.587973] ---[ end trace 7905ecd9245ab244 ]---

[  104.593854] note: kmemleak[1241] exited with preempt_count 1
[  104.597142] BUG: sleeping function called from invalid context at
kernel/nsproxy.c:205
[  104.600734] in_atomic(): 1, irqs_disabled(): 1, pid: 1241, name: kmemleak
[  104.604230] INFO: lockdep is turned off.
[  104.607417] irq event stamp: 7910916
[  104.610567] hardirqs last  enabled at (7910915):
[<c0000000007cfe24>] ._raw_spin_unlock_irqrestore+0x94/0xc0
[  104.614561] hardirqs last disabled at (7910916):
[<c0000000007cef64>] ._raw_spin_lock_irqsave+0x34/0xd0
[  104.618507] softirqs last  enabled at (7910912):
[<c000000000085a60>] .__do_softirq+0x300/0x3e0
[  104.622411] softirqs last disabled at (7910893):
[<c0000000000860a4>] .irq_exit+0x144/0x160
[  104.626295] Preemption disabled at:[<          (null)>]           (null)

[  104.633121] CPU: 1 PID: 1241 Comm: kmemleak Tainted: G      D
3.15.0-08556-gdfb9454 #49
[  104.637132] Call Trace:
[  104.640453] [c000000165573230] [c000000000016728]
.show_stack+0x78/0x1e0 (unreliable)
[  104.644535] [c000000165573300] [c0000000007d6590] .dump_stack+0x9c/0x108
[  104.648492] [c000000165573390] [c0000000000b6870] .__might_sleep+0x160/0x1d0
[  104.652511] [c000000165573410] [c0000000000afc34]
.switch_task_namespaces+0x34/0xc0
[  104.656597] [c0000001655734a0] [c000000000082cc4] .do_exit+0x334/0xa80
[  104.660586] [c000000165573590] [c00000000001e424] .die+0x2f4/0x460
[  104.664570] [c000000165573650] [c00000000003e1e4] .bad_page_fault+0xd4/0x130
[  104.668680] [c0000001655736d0] [c000000000009584] handle_page_fault+0x2c/0x30
[  104.672793] --- Exception: 300 at .scan_block+0x70/0x170
    LR = .scan_block+0x68/0x170
[  104.680471] [c000000165573a70] [c00000000019ce68] .scan_gray_list+0x218/0x270
[  104.684682] [c000000165573b30] [c00000000019d240] .kmemleak_scan+0x380/0x740
[  104.688924] [c000000165573c20] [c00000000019d67c]
.kmemleak_scan_thread+0x7c/0x120
[  104.693260] [c000000165573cb0] [c0000000000aa6e4] .kthread+0x104/0x130
[  104.697503] [c000000165573e30] [c00000000000a428]
.ret_from_kernel_thread+0x58/0xb0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
