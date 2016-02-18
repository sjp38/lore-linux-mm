Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A512C6B025B
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:07:02 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b205so34386963wmb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:07:02 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id 12si6491407wmu.76.2016.02.18.09.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:07:01 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id g62so34634552wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:07:01 -0800 (PST)
Date: Thu, 18 Feb 2016 19:06:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160218170658.GC28184@node.shutemov.name>
References: <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160212231510.GB15142@node.shutemov.name>
 <alpine.LFD.2.20.1602131238260.1910@schleppi>
 <20160217201340.2dafad8d@thinkpad>
 <20160217235808.GA21696@node.shutemov.name>
 <20160218160037.627cc7ec@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160218160037.627cc7ec@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Thu, Feb 18, 2016 at 04:00:37PM +0100, Gerald Schaefer wrote:
> On Thu, 18 Feb 2016 01:58:08 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Wed, Feb 17, 2016 at 08:13:40PM +0100, Gerald Schaefer wrote:
> > > On Sat, 13 Feb 2016 12:58:31 +0100 (CET)
> > > Sebastian Ott <sebott@linux.vnet.ibm.com> wrote:
> > > 
> > > > [   59.875935] ------------[ cut here ]------------
> > > > [   59.875937] kernel BUG at mm/huge_memory.c:2884!
> > > > [   59.875979] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > > > [   59.875986] Modules linked in: bridge stp llc btrfs xor mlx4_en vxlan ip6_udp_tunnel udp_tunnel mlx4_ib ptp pps_core ib_sa ib_mad ib_core ib_addr ghash_s390 prng raid6_pq ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 mlx4_core sha_common genwqe_card scm_block crc_itu_t vhost_net tun vhost dm_mod macvtap eadm_sch macvlan kvm autofs4
> > > > [   59.876033] CPU: 2 PID: 5402 Comm: git Tainted: G        W       4.4.0-07794-ga4eff16-dirty #77
> > > > [   59.876036] task: 00000000d2312948 ti: 00000000cfecc000 task.ti: 00000000cfecc000
> > > > [   59.876039] Krnl PSW : 0704d00180000000 00000000002bf3aa (__split_huge_pmd_locked+0x562/0xa10)
> > > > [   59.876045]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
> > > >                Krnl GPRS: 0000000001a7a1cf 000003d10177c000 0000000000044068 000000005df00215
> > > > [   59.876051]            0000000000000001 0000000000000001 0000000000000000 00000000774e6900
> > > > [   59.876054]            000003ff52000000 000000006d403b10 000000006e1eb800 000003ff51f00000
> > > > [   59.876058]            000003d10177c000 0000000000715190 00000000002bf234 00000000cfecfb58
> > > > [   59.876068] Krnl Code: 00000000002bf39c: d507d010a000	clc	16(8,%%r13),0(%%r10)
> > > >                           00000000002bf3a2: a7840004		brc	8,2bf3aa
> > > >                          #00000000002bf3a6: a7f40001		brc	15,2bf3a8
> > > >                          >00000000002bf3aa: 91407440		tm	1088(%%r7),64
> > > >                           00000000002bf3ae: a7840208		brc	8,2bf7be
> > > >                           00000000002bf3b2: a7f401e9		brc	15,2bf784
> > > >                           00000000002bf3b6: 9104a006		tm	6(%%r10),4
> > > >                           00000000002bf3ba: a7740004		brc	7,2bf3c2
> > > > [   59.876089] Call Trace:
> > > > [   59.876092] ([<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10)
> > > > [   59.876095]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
> > > > [   59.876099]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
> > > > [   59.876102]  [<0000000000282d66>] zap_page_range+0x116/0x318
> > > > [   59.876105]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
> > > > [   59.876108]  [<00000000006f9f56>] system_call+0xd6/0x258
> > > > [   59.876111]  [<000003ff9bbfd282>] 0x3ff9bbfd282
> > > > [   59.876113] INFO: lockdep is turned off.
> > > > [   59.876115] Last Breaking-Event-Address:
> > > > [   59.876118]  [<00000000002bf3a6>] __split_huge_pmd_locked+0x55e/0xa10
> > > 
> > > The BUG at mm/huge_memory.c:2884 is interesting, it's the BUG_ON(!pte_none(*pte))
> > > check in __split_huge_pmd_locked(). Obviously we expect the pre-allocated
> > > pagetables to be empty, but in collapse_huge_page() we deposit the original
> > > pagetable instead of allocating a new (empty) one. This saves an allocation,
> > > which is good, but doesn't that mean that if such a collapsed hugepage will
> > > ever be split, we will always run into the BUG_ON(!pte_none(*pte)), or one
> > > of the two other VM_BUG_ONs in mm/huge_memory.c that check the same?
> > > 
> > > This behavior is not new, it was the same before the THP rework, so I do not
> > > assume that it is related to the current problems, maybe with the exception
> > > of this specific crash. I never saw the BUG at mm/huge_memory.c:2884 myself,
> > > and the other crashes probably cannot be explained with this. Maybe I am
> > > also missing something, but I do not see how collapse_huge_page() and the
> > > (non-empty) pgtable deposit there can work out with the BUG_ON(!pte_none(*pte))
> > > checks. Any thoughts?
> > 
> > I don't think there's a problem: ptes in the pgtable are cleared with
> > pte_clear() in __collapse_huge_page_copy().
> > 
> 
> Ah OK, I didn't see that. Still the BUG_ON() tells us that something went
> wrong with the pre-allocated pagetable, or at least with the deposit/withdraw
> list, or both. Given that on s390 we keep the listheads for the deposit/withdraw
> list inside the pre-allocated pgtables, instead of the struct pages, it may
> also explain why we see don't the problems on x86.
> 
> We already have the list corruption warning in exit_mmap -> zap_huge_pmd ->
> withdraw, and from time to time I also hit the BUG_ON(page->pmd_huge_pte)
> in exit_mmap -> free_pgtables -> free_pmd_range, which also indicates some
> issues with the deposit/withdraw list, see below:
> 
> [ 2489.384069] page:000003d101aa6f00 count:1 mapcount:0 mapping:          (null) index:0x0
> [ 2489.384075] flags: 0x0()
> [ 2489.384078] page dumped because: VM_BUG_ON_PAGE(page->pmd_huge_pte)
> [ 2489.384086] ------------[ cut here ]------------
> [ 2489.384088] kernel BUG at include/linux/mm.h:1700!
> [ 2489.384131] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2489.384137] Modules linked in: bridge stp llc mlx4_ib ib_sa ib_mad mlx4_en ib_core vxlan udp_tunnel ptp pps_core ib_addr ghash_s390 prng ecb mlx4_core aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 sha_common eadm_sch dm_mod vhost_net tun vhost macvtap macvlan kvm autofs4
> [ 2489.384173] CPU: 5 PID: 173619 Comm: cc1 Tainted: G    B   W       4.5.0-rc3-00083-gc05235d #10
> [ 2489.384176] task: 00000000c54d0000 ti: 0000000060504000 task.ti: 0000000060504000
> [ 2489.384179] Krnl PSW : 0704c00180000000 0000000000283cf4 (free_pgd_range+0x334/0x460)
> [ 2489.384184]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:0 EA:3
>                Krnl GPRS: 0000000001a161c7 0000000000000000 0000000000000037 0000000000000000
> [ 2489.384189]            0000000000283cf0 0000000000000000 000003ff7d980000 0000000060507e18
> [ 2489.384192]            000003ff00000000 0000000075e43ff0 000003ff7d97ffff 000003ff7d980000
> [ 2489.384195]            000000006a9bc000 00000000006cc390 0000000000283cf0 0000000060507c68
> [ 2489.384201] Krnl Code: 0000000000283ce4: c030002e14dd        larl    %%r3,84669e
>                           0000000000283cea: c0e5ffffd217        brasl   %%r14,27e118
>                          #0000000000283cf0: a7f40001            brc     15,283cf2
>                          >0000000000283cf4: c0e5fffffe5a        brasl   %%r14,2839a8
>                           0000000000283cfa: b9040027            lgr     %%r2,%%r7
>                           0000000000283cfe: b904003c            lgr     %%r3,%%r12
>                           0000000000283d02: c0e5fff509e3        brasl   %%r14,1250c8
>                           0000000000283d08: e31070000004        lg      %%r1,0(%%r7)
> [ 2489.384221] Call Trace:
> [ 2489.384224] ([<0000000000283cf0>] free_pgd_range+0x330/0x460)
> [ 2489.384227]  [<0000000000283f38>] free_pgtables+0x118/0x148
> [ 2489.384230]  [<000000000028c32e>] exit_mmap+0xd6/0x300
> [ 2489.384233]  [<0000000000134d70>] mmput+0x90/0x118
> [ 2489.384235]  [<000000000013a55c>] do_exit+0x41c/0xd18
> [ 2489.384238]  [<000000000013c3c2>] do_group_exit+0x92/0xd8
> [ 2489.384241]  [<000000000013c432>] SyS_exit_group+0x2a/0x30
> [ 2489.384244]  [<00000000006b1a36>] system_call+0xd6/0x258
> [ 2489.384246]  [<000003ff7d343698>] 0x3ff7d343698
> [ 2489.384248] INFO: lockdep is turned off.
> [ 2489.384251] Last Breaking-Event-Address:
> [ 2489.384253]  [<0000000000283cf0>] free_pgd_range+0x330/0x460
> [ 2489.384256]  
> [ 2489.384258] Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> I'll try to add a BUG_ON(pmd_huge(*pmd)) to free_pte_range() and see if that
> catches anything, and I'll also check if debug_cow = 1 or use_zero_page = 0
> makes any difference.

I worth minimizing kernel config on which you can see the bug. Things like
CONFIG_DEBUG_PAGEALLOC used to interfere with THP before.

You can also disable khugepaged, just in case.

One more thing: try add smp_wmb() in pgtable_trans_huge_withdraw() just
before return to make sure all CPUs sees _PAGE_INVALID.
I don't think it would make a difference. Again, just in case.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
