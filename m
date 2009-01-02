Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 306DC6B00BB
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 08:00:38 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n02D0PIH005381
	for <linux-mm@kvack.org>; Sat, 3 Jan 2009 00:00:25 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n02CwpQv1777730
	for <linux-mm@kvack.org>; Fri, 2 Jan 2009 23:58:54 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n02Cvxtv008978
	for <linux-mm@kvack.org>; Fri, 2 Jan 2009 23:58:00 +1100
Date: Fri, 2 Jan 2009 18:27:52 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUG] 2.6.28-git-4 - powerpc - kernel expection 'c01 at
	.kernel_thread'
Message-ID: <20090102125752.GA5743@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, sfr@canb.auug.org.au, benh@kernel.crashing.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Hi,

	2.6.28-git4 kernel drops to xmon with kernel expection. Similar kernel
expection was seen next-20081230 and next-20081231 and was reported 
earlier at http://lkml.org/lkml/2008/12/31/157

1:mon> e
cpu 0x1: Vector: 300 (Data Access) at [c0000002763cb700]
    pc: c0000000000e2c54: .kmem_cache_free+0x1b8/0x244
    lr: c00000000005ab04: .__cleanup_sighand+0x44/0x5c
    sp: c0000002763cb980
   msr: 9000000000009032
   dar: 0
 dsisr: 40000000
  current = 0xc0000002763c5180
  paca    = 0xc000000000548500
    pid   = 6, comm = ksoftirqd/1
1:mon> t
[c0000002763cba30] c00000000005ab04 .__cleanup_sighand+0x44/0x5c
[c0000002763cbab0] c00000000006080c .release_task+0x2dc/0x400
[c0000002763cbb50] c0000000000610dc .do_exit+0x7ac/0x858
[c0000002763cbc20] c00000000006128c .complete_and_exit+0x0/0x2c
[c0000002763cbca0] c00000000000852c syscall_exit+0x0/0x40
--- Exception: c01 (System Call) at c00000000002472c .kernel_thread+0x60/0x70
1:mon> 
c0000000000e2cec  fbe1fff8	std	r31,-8(r1)
c0000000000e2cf0  ebc2b260	ld	r30,-19872(r2)
c0000000000e2cf4  7c9f2378	mr	r31,r4
c0000000000e2cf8  f8010010	std	r0,16(r1)
c0000000000e2cfc  f821ff71	stdu	r1,-144(r1)
c0000000000e2d00  7c7d1b78	mr	r29,r3
c0000000000e2d04  60000000	nop
c0000000000e2d08  81630114	lwz	r11,276(r3)
c0000000000e2d0c  e9240018	ld	r9,24(r4)
c0000000000e2d10  e8040010	ld	r0,16(r4)
c0000000000e2d14  796a6fe3	rldicl.	r10,r11,45,63
c0000000000e2d18  7d204850	subf	r9,r0,r9
c0000000000e2d1c  7d244b78	mr	r4,r9
1:mon> di c0000000000e2c54
c0000000000e2c54  817f0000	lwz	r11,0(r31)
c0000000000e2c58  801f0004	lwz	r0,4(r31)
c0000000000e2c5c  7f8b0040	cmplw	cr7,r11,r0
c0000000000e2c60  409c001c	bge	cr7,c0000000000e2c7c	# .kmem_cache_free+0x1e0/0x244
c0000000000e2c64  79691f24	rldicr	r9,r11,3,60
c0000000000e2c68  380b0001	addi	r0,r11,1
c0000000000e2c6c  7d29fa14	add	r9,r9,r31
c0000000000e2c70  901f0000	stw	r0,0(r31)
c0000000000e2c74  fba90018	std	r29,24(r9)
c0000000000e2c78  48000028	b	c0000000000e2ca0	# .kmem_cache_free+0x204/0x244
c0000000000e2c7c  7f63db78	mr	r3,r27
c0000000000e2c80  7fe4fb78	mr	r4,r31
c0000000000e2c84  480005a5	bl	c0000000000e3228	# .cache_flusharray+0x0/0x150

1:mon> di %pc
c0000000000e2c54  817f0000	lwz	r11,0(r31)
c0000000000e2c58  801f0004	lwz	r0,4(r31)
c0000000000e2c5c  7f8b0040	cmplw	cr7,r11,r0
c0000000000e2c60  409c001c	bge	cr7,c0000000000e2c7c	# .kmem_cache_free+0x1e0/0x244
c0000000000e2c64  79691f24	rldicr	r9,r11,3,60
c0000000000e2c68  380b0001	addi	r0,r11,1
c0000000000e2c6c  7d29fa14	add	r9,r9,r31
c0000000000e2c70  901f0000	stw	r0,0(r31)
c0000000000e2c74  fba90018	std	r29,24(r9)
c0000000000e2c78  48000028	b	c0000000000e2ca0	# .kmem_cache_free+0x204/0x244
c0000000000e2c7c  7f63db78	mr	r3,r27
c0000000000e2c80  7fe4fb78	mr	r4,r31
c0000000000e2c84  480005a5	bl	c0000000000e3228	# .cache_flusharray+0x0/0x150
1:mon> di %lr
c00000000005ab04  60000000	nop
c00000000005ab08  38210080	addi	r1,r1,128
c00000000005ab0c  e8010010	ld	r0,16(r1)
c00000000005ab10  ebc1fff0	ld	r30,-16(r1)
c00000000005ab14  7c0803a6	mtlr	r0
c00000000005ab18  4e800020	blr
c00000000005ab1c  7c0802a6	mflr	r0
c00000000005ab20  fb81ffe0	std	r28,-32(r1)
c00000000005ab24  fbe1fff8	std	r31,-8(r1)
c00000000005ab28  fba1ffe8	std	r29,-24(r1)
c00000000005ab2c  7c7f1b78	mr	r31,r3
c00000000005ab30  f8010010	std	r0,16(r1)
c00000000005ab34  f821ff71	stdu	r1,-144(r1)
1:mon> di $.kmem_cache_free
c0000000000e2a9c  7c0802a6	mflr	r0
c0000000000e2aa0  fb61ffd8	std	r27,-40(r1)
c0000000000e2aa4  fba1ffe8	std	r29,-24(r1)
c0000000000e2aa8  fbc1fff0	std	r30,-16(r1)
c0000000000e2aac  fb41ffd0	std	r26,-48(r1)
c0000000000e2ab0  fb81ffe0	std	r28,-32(r1)
c0000000000e2ab4  fbe1fff8	std	r31,-8(r1)
c0000000000e2ab8  f8010010	std	r0,16(r1)
c0000000000e2abc  ebc2b260	ld	r30,-19872(r2)
c0000000000e2ac0  f821ff51	stdu	r1,-176(r1)
c0000000000e2ac4  7c7b1b78	mr	r27,r3
c0000000000e2ac8  7c9d2378	mr	r29,r4
c0000000000e2acc  38000000	li	r0,0


1:mon> ls .kmem_cache_free
.kmem_cache_free: c0000000000e2a9c
1:mon> di c0000000000e2a9c+1b8
c0000000000e2a9c  7c0802a6	mflr	r0
c0000000000e2aa0  fb61ffd8	std	r27,-40(r1)
c0000000000e2aa4  fba1ffe8	std	r29,-24(r1)
c0000000000e2aa8  fbc1fff0	std	r30,-16(r1)
c0000000000e2aac  fb41ffd0	std	r26,-48(r1)
c0000000000e2ab0  fb81ffe0	std	r28,-32(r1)
c0000000000e2ab4  fbe1fff8	std	r31,-8(r1)
c0000000000e2ab8  f8010010	std	r0,16(r1)
c0000000000e2abc  ebc2b260	ld	r30,-19872(r2)
c0000000000e2ac0  f821ff51	stdu	r1,-176(r1)
c0000000000e2ac4  7c7b1b78	mr	r27,r3
c0000000000e2ac8  7c9d2378	mr	r29,r4
c0000000000e2acc  38000000	li	r0,0
c0000000000e2ad0  8b4d01da	lbz	r26,474(r13)
c0000000000e2ad4  980d01da	stb	r0,474(r13)
c0000000000e2ad8  e93e8110	ld	r9,-32496(r30)
c0000000000e2adc  a00d000a	lhz	r0,10(r13)
c0000000000e2ae0  7daa6b78	mr	r10,r13
c0000000000e2ae4  81290000	lwz	r9,0(r9)
c0000000000e2ae8  78001f24	rldicr	r0,r0,3,60
c0000000000e2aec  7fe3002a	ldx	r31,r3,r0
c0000000000e2af0  2f890000	cmpwi	cr7,r9,0
c0000000000e2af4  419e0160	beq	cr7,c0000000000e2c54	# .kmem_cache_free+0x1b8/0x244
c0000000000e2af8  3d204000	lis	r9,16384
c0000000000e2afc  f8810070	std	r4,112(r1)
c0000000000e2b00  38000038	li	r0,56
c0000000000e2b04  3960ffff	li	r11,-1
c0000000000e2b08  792907c6	rldicr	r9,r9,32,31
c0000000000e2b0c  796b00c4	rldicr	r11,r11,0,3
c0000000000e2b10  7d244a14	add	r9,r4,r9
c0000000000e2b14  7929a302	rldicl	r9,r9,52,12
c0000000000e2b18  7d2901d2	mulld	r9,r9,r0
c0000000000e2b1c  7c09582a	ldx	r0,r9,r11
c0000000000e2b20  7d695a14	add	r11,r9,r11
c0000000000e2b24  780997e3	rldicl.	r9,r0,50,63
c0000000000e2b28  41a20008	beq	c0000000000e2b30	# .kmem_cache_free+0x94/0x244
c0000000000e2b2c  e96b0010	ld	r11,16(r11)
c0000000000e2b30  e80b0000	ld	r0,0(r11)
c0000000000e2b34  68000080	xori	r0,r0,128
c0000000000e2b38  7800cfe2	rldicl	r0,r0,57,63
c0000000000e2b3c  0b000000	tdnei	r0,0
c0000000000e2b40  a00a000a	lhz	r0,10(r10)
c0000000000e2b44  e93e8028	ld	r9,-32728(r30)
c0000000000e2b48  e96b0030	ld	r11,48(r11)
c0000000000e2b4c  78001764	rldicr	r0,r0,2,61
c0000000000e2b50  a38b0028	lhz	r28,40(r11)
c0000000000e2b54  7d2902aa	lwax	r9,r9,r0
c0000000000e2b58  7f9c4800	cmpw	cr7,r28,r9
c0000000000e2b5c  41be00f8	beq	cr7,c0000000000e2c54	# .kmem_cache_free+0x1b8/0x244
c0000000000e2b60  79291f24	rldicr	r9,r9,3,60
c0000000000e2b64  7d29da14	add	r9,r9,r27
c0000000000e2b68  e9290168	ld	r9,360(r9)
c0000000000e2b6c  e8690050	ld	r3,80(r9)
c0000000000e2b70  2fa30000	cmpdi	cr7,r3,0
c0000000000e2b74  419e0088	beq	cr7,c0000000000e2bfc	# .kmem_cache_free+0x160/0x244
c0000000000e2b78  7b891f24	rldicr	r9,r28,3,60
c0000000000e2b7c  7fa3482a	ldx	r29,r3,r9
c0000000000e2b80  2fbd0000	cmpdi	cr7,r29,0
c0000000000e2b84  419e0078	beq	cr7,c0000000000e2bfc	# .kmem_cache_free+0x160/0x244
c0000000000e2b88  387d0010	addi	r3,r29,16
c0000000000e2b8c  4823eb5d	bl	c0000000003216e8	# ._spin_lock+0x0/0x88
c0000000000e2b90  60000000	nop
c0000000000e2b94  801d0000	lwz	r0,0(r29)
c0000000000e2b98  813d0004	lwz	r9,4(r29)
c0000000000e2b9c  7f804840	cmplw	cr7,r0,r9
c0000000000e2ba0  40be0014	bne	cr7,c0000000000e2bb4	# .kmem_cache_free+0x118/0x244
c0000000000e2ba4  7f63db78	mr	r3,r27

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
