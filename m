Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 68A206B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 06:58:38 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b205so12592930wmb.1
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 03:58:38 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id a63si10627547wmd.11.2016.02.13.03.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 13 Feb 2016 03:58:37 -0800 (PST)
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sebott@linux.vnet.ibm.com>;
	Sat, 13 Feb 2016 11:58:36 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id B53AB2190019
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 11:58:19 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1DBwYD833685626
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 11:58:34 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1DBwXch008407
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 04:58:34 -0700
Date: Sat, 13 Feb 2016 12:58:31 +0100 (CET)
From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
In-Reply-To: <20160212231510.GB15142@node.shutemov.name>
Message-ID: <alpine.LFD.2.20.1602131238260.1910@schleppi>
References: <20160211192223.4b517057@thinkpad> <20160211190942.GA10244@node.shutemov.name> <20160211205702.24f0d17a@thinkpad> <20160212154116.GA15142@node.shutemov.name> <56BE00E7.1010303@de.ibm.com> <20160212181640.4eabb85f@thinkpad>
 <20160212231510.GB15142@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463785470-1519997186-1455364712=:1910"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463785470-1519997186-1455364712=:1910
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT


On Sat, 13 Feb 2016, Kirill A. Shutemov wrote:
> Could you check if revert of fecffad25458 helps?

I reverted fecffad25458 on top of 721675fcf277cf - it oopsed with:

c 1851.721062! Unable to handle kernel pointer dereference in virtual kernel address space
c 1851.721075! failing address: 0000000000000000 TEID: 0000000000000483
c 1851.721078! Fault in home space mode while using kernel ASCE.
c 1851.721085! AS:0000000000d5c007 R3:00000000ffff0007 S:00000000ffffa800 P:000000000000003d
c 1851.721128! Oops: 0004 ilc:3 c#1! PREEMPT SMP DEBUG_PAGEALLOC
c 1851.721135! Modules linked in: bridge stp llc btrfs mlx4_ib mlx4_en ib_sa ib_mad vxlan xor ip6_udp_tunnel ib_core udp_tunnel ptp pps_core ib_addr ghash_s390raid6_pq prng ecb aes_s390 mlx4_core des_s390 des_generic genwqe_card sha512_s390 sha256_s390 sha1_s390 sha_common crc_itu_t dm_mod scm_block vhost_net tun vhost eadm_sch macvtap macvlan kvm autofs4
c 1851.721183! CPU: 7 PID: 256422 Comm: bash Not tainted 4.5.0-rc3-00058-g07923d7-dirty #178
c 1851.721186! task: 000000007fbfd290 ti: 000000008c604000 task.ti: 000000008c604000
c 1851.721189! Krnl PSW : 0704d00180000000 000000000045d3b8 (__rb_erase_color+0x280/0x308)
c 1851.721200!            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
               Krnl GPRS: 0000000000000001 0000000000000020 0000000000000000 00000000bd07eff1
c 1851.721205!            000000000027ca10 0000000000000000 0000000083e45898 0000000077b61198
c 1851.721207!            000000007ce1a490 00000000bd07eff0 000000007ce1a548 000000000027ca10
c 1851.721210!            00000000bd07c350 00000000bd07eff0 000000008c607aa8 000000008c607a68
c 1851.721221! Krnl Code: 000000000045d3aa: e3c0d0080024       stg     %%r12,8(%%r13)
                          000000000045d3b0: b9040039           lgr     %%r3,%%r9
                         #000000000045d3b4: a53b0001           oill    %%r3,1
                         >000000000045d3b8: e33010000024       stg     %%r3,0(%%r1)
                          000000000045d3be: ec28000e007c       cgij    %%r2,0,8,45d3da
                          000000000045d3c4: e34020000004       lg      %%r4,0(%%r2)
                          000000000045d3ca: b904001c           lgr     %%r1,%%r12
                          000000000045d3ce: ec143f3f0056       rosbg   %%r1,%%r4,63,63,0
c 1851.721269! Call Trace:
c 1851.721273! (c<0000000083e45898>! 0x83e45898)
c 1851.721279!  c<000000000029342a>! unlink_anon_vmas+0x9a/0x1d8
c 1851.721282!  c<0000000000283f34>! free_pgtables+0xcc/0x148
c 1851.721285!  c<000000000028c376>! exit_mmap+0xd6/0x300
c 1851.721289!  c<0000000000134db8>! mmput+0x90/0x118
c 1851.721294!  c<00000000002d76bc>! flush_old_exec+0x5d4/0x700
c 1851.721298!  c<00000000003369f4>! load_elf_binary+0x2f4/0x13e8
c 1851.721301!  c<00000000002d6e4a>! search_binary_handler+0x9a/0x1f8
c 1851.721304!  c<00000000002d8970>! do_execveat_common.isra.32+0x668/0x9a0
c 1851.721307!  c<00000000002d8cec>! do_execve+0x44/0x58
c 1851.721310!  c<00000000002d8f92>! SyS_execve+0x3a/0x48
c 1851.721315!  c<00000000006fb096>! system_call+0xd6/0x258
c 1851.721317!  c<000003ff997436d6>! 0x3ff997436d6
c 1851.721319! INFO: lockdep is turned off.
c 1851.721321! Last Breaking-Event-Address:
c 1851.721323!  c<000000000045d31a>! __rb_erase_color+0x1e2/0x308
c 1851.721327!
c 1851.721329! ---c end trace 0d80041ac00cfae2 !---


> 
> And could you share how crashes looks like? I haven't seen backtraces yet.
> 

Sure. I didn't because they really looked random to me. Most of the time
in rcu or list debugging but I thought these have just been the messenger
observing a corruption first. Anyhow, here is an older one that might look
interesting:

[   59.851421] list_del corruption. next->prev should be 000000006e1eb000, but was 0000000000000400
[   59.851469] ------------[ cut here ]------------
[   59.851472] WARNING: at lib/list_debug.c:71
[   59.851475] Modules linked in: bridge stp llc btrfs xor mlx4_en vxlan ip6_udp_tunnel udp_tunnel mlx4_ib ptp pps_core ib_sa ib_mad ib_core ib_addr ghash_s390 prng raid6_pq ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 mlx4_core sha_common genwqe_card scm_block crc_itu_t vhost_net tun vhost dm_mod macvtap eadm_sch macvlan kvm autofs4
[   59.851532] CPU: 0 PID: 5400 Comm: git Not tainted 4.4.0-07794-ga4eff16-dirty #77
[   59.851535] task: 00000000d2310000 ti: 00000000d6610000 task.ti: 00000000d6610000
[   59.851539] Krnl PSW : 0704c00180000000 0000000000487434 (__list_del_entry+0xa4/0xe0)
[   59.851548]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:0 EA:3
               Krnl GPRS: 0000000001a7a1cf 00000000d2310000 0000000000000054 0000000000000001
[   59.851554]            0000000000487430 0000000000000000 0000000000000000 00000000774e6900
[   59.851557]            000003ff53000000 000000006d4017a0 000003ff52f00000 000003ff52f00000
[   59.851560]            000003d101780000 000000006e1eb000 0000000000487430 00000000d6613b00
[   59.851571] Krnl Code: 0000000000487424: c02000219e3a	larl	%%r2,8bb098
                          000000000048742a: c0e5ffee05db	brasl	%%r14,247fe0
                         #0000000000487430: a7f40001		brc	15,487432
                         >0000000000487434: a7f40017		brc	15,487462
                          0000000000487438: a7390200		lghi	%%r3,512
                          000000000048743c: ec13ffd28064	cgrj	%%r1,%%r3,8,4873e0
                          0000000000487442: e32010000020	cg	%%r2,0(%%r1)
                          0000000000487448: a774ffda		brc	7,4873fc
[   59.851615] Call Trace:
[   59.851618] ([<0000000000487430>] __list_del_entry+0xa0/0xe0)
[   59.851621]  [<0000000000487498>] list_del+0x28/0x40
[   59.851627]  [<00000000001259ec>] pgtable_trans_huge_withdraw+0x74/0x90
[   59.851632]  [<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10
[   59.851635]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
[   59.851639]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
[   59.851643]  [<0000000000282d66>] zap_page_range+0x116/0x318
[   59.851646]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
[   59.851652]  [<00000000006f9f56>] system_call+0xd6/0x258
[   59.851656]  [<000003ff9bbfd282>] 0x3ff9bbfd282
[   59.851658] 2 locks held by git/5400:
[   59.851660]  #0:  (&mm->mmap_sem){++++++}, at: [<000000000029bb5a>] SyS_madvise+0x562/0x5e8
[   59.851670]  #1:  (&(ptlock_ptr(page))->rlock){+.+...}, at: [<00000000002c4268>] __split_huge_pmd+0x70/0x218
[   59.851679] Last Breaking-Event-Address:
[   59.851682]  [<0000000000487430>] __list_del_entry+0xa0/0xe0
[   59.851686] ---[ end trace 7bce9a4f571985b6 ]---
[   59.875754] list_del corruption. prev->next should be 000000006e1eb820, but was           (null)
[   59.875768] ------------[ cut here ]------------
[   59.875771] WARNING: at lib/list_debug.c:68
[   59.875774] Modules linked in: bridge stp llc btrfs xor mlx4_en vxlan ip6_udp_tunnel udp_tunnel mlx4_ib ptp pps_core ib_sa ib_mad ib_core ib_addr ghash_s390 prng raid6_pq ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 mlx4_core sha_common genwqe_card scm_block crc_itu_t vhost_net tun vhost dm_mod macvtap eadm_sch macvlan kvm autofs4
[   59.875820] CPU: 2 PID: 5402 Comm: git Tainted: G        W       4.4.0-07794-ga4eff16-dirty #77
[   59.875823] task: 00000000d2312948 ti: 00000000cfecc000 task.ti: 00000000cfecc000
[   59.875826] Krnl PSW : 0704c00180000000 0000000000487416 (__list_del_entry+0x86/0xe0)
[   59.875832]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:0 EA:3
               Krnl GPRS: 0000000001a7a1cf 00000000d2312948 0000000000000054 0000000000000001
[   59.875838]            0000000000487412 0000000000000000 0000000000000000 00000000774e6900
[   59.875841]            000003ff52000000 000000006d403b10 000003ff51f00000 000003ff51f00000
[   59.875843]            000003d10177c000 000000006e1eb820 0000000000487412 00000000cfecfb00
[   59.875851] Krnl Code: 0000000000487406: c02000219e2c	larl	%%r2,8bb05e
                          000000000048740c: c0e5ffee05ea	brasl	%%r14,247fe0
                         #0000000000487412: a7f40001		brc	15,487414
                         >0000000000487416: a7f40026		brc	15,487462
                          000000000048741a: b9040032		lgr	%%r3,%%r2
                          000000000048741e: e34040080004	lg	%%r4,8(%%r4)
                          0000000000487424: c02000219e3a	larl	%%r2,8bb098
                          000000000048742a: c0e5ffee05db	brasl	%%r14,247fe0
[   59.875874] Call Trace:
[   59.875876] ([<0000000000487412>] __list_del_entry+0x82/0xe0)
[   59.875879]  [<0000000000487498>] list_del+0x28/0x40
[   59.875882]  [<00000000001259ec>] pgtable_trans_huge_withdraw+0x74/0x90
[   59.875885]  [<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10
[   59.875888]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
[   59.875891]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
[   59.875894]  [<0000000000282d66>] zap_page_range+0x116/0x318
[   59.875896]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
[   59.875899]  [<00000000006f9f56>] system_call+0xd6/0x258
[   59.875902]  [<000003ff9bbfd282>] 0x3ff9bbfd282
[   59.875904] 2 locks held by git/5402:
[   59.875906]  #0:  (&mm->mmap_sem){++++++}, at: [<000000000029bb5a>] SyS_madvise+0x562/0x5e8
[   59.875914]  #1:  (&(ptlock_ptr(page))->rlock){+.+...}, at: [<00000000002c4268>] __split_huge_pmd+0x70/0x218
[   59.875922] Last Breaking-Event-Address:
[   59.875925]  [<0000000000487412>] __list_del_entry+0x82/0xe0
[   59.875927] ---[ end trace 7bce9a4f571985b7 ]---
[   59.875935] ------------[ cut here ]------------
[   59.875937] kernel BUG at mm/huge_memory.c:2884!
[   59.875979] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   59.875986] Modules linked in: bridge stp llc btrfs xor mlx4_en vxlan ip6_udp_tunnel udp_tunnel mlx4_ib ptp pps_core ib_sa ib_mad ib_core ib_addr ghash_s390 prng raid6_pq ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 mlx4_core sha_common genwqe_card scm_block crc_itu_t vhost_net tun vhost dm_mod macvtap eadm_sch macvlan kvm autofs4
[   59.876033] CPU: 2 PID: 5402 Comm: git Tainted: G        W       4.4.0-07794-ga4eff16-dirty #77
[   59.876036] task: 00000000d2312948 ti: 00000000cfecc000 task.ti: 00000000cfecc000
[   59.876039] Krnl PSW : 0704d00180000000 00000000002bf3aa (__split_huge_pmd_locked+0x562/0xa10)
[   59.876045]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
               Krnl GPRS: 0000000001a7a1cf 000003d10177c000 0000000000044068 000000005df00215
[   59.876051]            0000000000000001 0000000000000001 0000000000000000 00000000774e6900
[   59.876054]            000003ff52000000 000000006d403b10 000000006e1eb800 000003ff51f00000
[   59.876058]            000003d10177c000 0000000000715190 00000000002bf234 00000000cfecfb58
[   59.876068] Krnl Code: 00000000002bf39c: d507d010a000	clc	16(8,%%r13),0(%%r10)
                          00000000002bf3a2: a7840004		brc	8,2bf3aa
                         #00000000002bf3a6: a7f40001		brc	15,2bf3a8
                         >00000000002bf3aa: 91407440		tm	1088(%%r7),64
                          00000000002bf3ae: a7840208		brc	8,2bf7be
                          00000000002bf3b2: a7f401e9		brc	15,2bf784
                          00000000002bf3b6: 9104a006		tm	6(%%r10),4
                          00000000002bf3ba: a7740004		brc	7,2bf3c2
[   59.876089] Call Trace:
[   59.876092] ([<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10)
[   59.876095]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
[   59.876099]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
[   59.876102]  [<0000000000282d66>] zap_page_range+0x116/0x318
[   59.876105]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
[   59.876108]  [<00000000006f9f56>] system_call+0xd6/0x258
[   59.876111]  [<000003ff9bbfd282>] 0x3ff9bbfd282
[   59.876113] INFO: lockdep is turned off.
[   59.876115] Last Breaking-Event-Address:
[   59.876118]  [<00000000002bf3a6>] __split_huge_pmd_locked+0x55e/0xa10
[   59.876122]  
[   59.876124] ---[ end trace 7bce9a4f571985b8 ]---
[   59.876128] BUG: sleeping function called from invalid context at include/linux/sched.h:2791
[   59.876130] in_atomic(): 1, irqs_disabled(): 0, pid: 5402, name: git
[   59.876132] INFO: lockdep is turned off.
[   59.876134] Preemption disabled at:[<00000000002c4268>] __split_huge_pmd+0x70/0x218
[   59.876138] 
[   59.876141] CPU: 2 PID: 5402 Comm: git Tainted: G      D W       4.4.0-07794-ga4eff16-dirty #77
[   59.876144]        00000000cfecf610 00000000cfecf6a0 0000000000000002 0000000000000000 
                      00000000cfecf740 00000000cfecf6b8 00000000cfecf6b8 0000000000113402 
                      0000000000000000 000000000089ab4e 00000000008b0a84 0704d0010000000b 
                      00000000cfecf700 00000000cfecf6a0 0000000000000000 0000000000000000 
                      0000000000000000 0000000000113402 00000000cfecf6a0 00000000cfecf700 
[   59.876176] Call Trace:
[   59.876182] ([<000000000011330e>] show_trace+0x126/0x148)
[   59.876185]  [<00000000001133b8>] show_stack+0x88/0xe8
[   59.876189]  [<000000000045549a>] dump_stack+0x7a/0xd8
[   59.876193]  [<00000000001666c6>] ___might_sleep+0x236/0x248
[   59.876198]  [<000000000014a314>] exit_signals+0x3c/0x158
[   59.876202]  [<000000000013a4e0>] do_exit+0x140/0xd18
[   59.876206]  [<00000000001137c4>] die+0x164/0x170
[   59.876209]  [<0000000000100ac6>] do_report_trap+0x14e/0x160
[   59.876211]  [<0000000000100c94>] illegal_op+0x134/0x148
[   59.876214]  [<00000000006fa26c>] pgm_check_handler+0x15c/0x1b4
[   59.876217]  [<00000000002bf3aa>] __split_huge_pmd_locked+0x562/0xa10
[   59.876221] ([<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10)
[   59.876223]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
[   59.876226]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
[   59.876229]  [<0000000000282d66>] zap_page_range+0x116/0x318
[   59.876232]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
[   59.876235]  [<00000000006f9f56>] system_call+0xd6/0x258
[   59.876238]  [<000003ff9bbfd282>] 0x3ff9bbfd282
[   59.876240] INFO: lockdep is turned off.
[   59.876243] note: git[5402] exited with preempt_count 1
---1463785470-1519997186-1455364712=:1910--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
