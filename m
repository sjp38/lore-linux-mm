Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC2A6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 17:59:29 -0400 (EDT)
From: Alexander Graf <agraf@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Subject: Oops in VMA code
Date: Wed, 15 Jun 2011 23:59:21 +0200
Message-Id: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
Mime-Version: 1.0 (Apple Message framework v1084)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi memory management experts,

I just had this crash while compiling code on my PPC G5. I was running =
my PPC KVM tree, which was pretty much =
06e86849cf4019945a106913adb9ff0abcc01770 plus a few unrelated KVM =
patches. User space is 64-bit.

Is this a known issue or did I hit something completely unexpected?


Unable to handle kernel paging request for data at address =
0xc00090026236bbc0
Faulting instruction address: 0xc000000000190598
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=3D4 NUMA PowerMac
Modules linked in:
NIP: c000000000190598 LR: c0000000001908a4 CTR: c000000000190850
REGS: c000000262987a50 TRAP: 0300   Tainted: G        W    (3.0.0-rc2+)
MSR: 9000000000009032 <EE,ME,IR,DR>  CR: 48000448  XER: 00000000
DAR: c00090026236bbc0, DSISR: 40010000
TASK =3D c000000262d6cfb0[13951] 'cc1' THREAD: c000000262984000 CPU: 2
GPR00: 0000040008f1f000 c000000262987cd0 c000000000e31578 =
c000000262828e00=20
GPR04: 0000000000008000 0000000000008000 ffffffffffffffff =
0000000000000000=20
GPR08: fffff000fffff000 c00090026236bbe8 0000100000000000 =
c00000026236b420=20
GPR12: 0000000028000442 c00000000fffef00 000000000000005f =
0000000010026be4=20
GPR16: 0000000000000000 00000000109fa6a4 00000000109eb110 =
00000000108b6338=20
GPR20: 000000001099ca90 000000001099c590 0000000000000000 =
00000000109eb164=20
GPR24: 00000000109fa7a8 0000000000000001 c00090026236bbb0 =
0000040008f45000=20
GPR28: c0000002628fc580 c000000262828e00 c000000000d631e8 =
0000040008f45000=20
NIP [c000000000190598] .do_munmap+0x138/0x3f0
LR [c0000000001908a4] .SyS_munmap+0x54/0x90
Call Trace:
[c000000262987cd0] [0000000000008000] 0x8000 (unreliable)
[c000000262987d90] [c0000000001908a4] .SyS_munmap+0x54/0x90
[c000000262987e30] [c000000000009864] syscall_exit+0x0/0x40
Instruction dump:
3b400000 2fa90000 409e0024 4800005c 60000000 60000000 e9290010 7d7a5b78=20=

2fa90000 7f4bd378 419e0034 3b49ffc8 <e81a0010> 7fbf0040 419cffe0 =
e97a0018=20
---[ end trace 31fd0ba7d8756003 ]---


It seems to be related to vma mapping, but I have no idea in that area =
of code:

(gdb) l *0xc000000000190598
0xc000000000190598 is in find_vma_prev (mm/mmap.c:1641).
1636=09
1637		while (rb_node) {
1638			struct vm_area_struct *vma_tmp;
1639			vma_tmp =3D rb_entry(rb_node, struct =
vm_area_struct, vm_rb);
1640=09
1641			if (addr < vma_tmp->vm_end) {
1642				rb_node =3D rb_node->rb_left;
1643			} else {
1644				prev =3D vma_tmp;
1645				if (!prev->vm_next || (addr < =
prev->vm_next->vm_end))


Ben suggested to also dump the disassembly of that function, so here it =
is:


0xc00000000018e630 <find_vma_prev>:	cmpdi   r3,0
0xc00000000018e634 <find_vma_prev+4>:	beq     0xc00000000018e6d0 =
<find_vma_prev+160>
0xc00000000018e638 <find_vma_prev+8>:	ld      r11,8(r3)
0xc00000000018e63c <find_vma_prev+12>:	ld      r3,0(r3)
0xc00000000018e640 <find_vma_prev+16>:	cmpdi   cr7,r11,0
0xc00000000018e644 <find_vma_prev+20>:	beq     cr7,0xc00000000018e6dc =
<find_vma_prev+172>
0xc00000000018e648 <find_vma_prev+24>:	li      r8,0
0xc00000000018e64c <find_vma_prev+28>:	b       0xc00000000018e65c =
<find_vma_prev+44>
0xc00000000018e650 <find_vma_prev+32>:	ld      r11,16(r11)
0xc00000000018e654 <find_vma_prev+36>:	cmpdi   cr7,r11,0
0xc00000000018e658 <find_vma_prev+40>:	beq     cr7,0xc00000000018e694 =
<find_vma_prev+100>
0xc00000000018e65c <find_vma_prev+44>:	addi    r9,r11,-56
0xc00000000018e660 <find_vma_prev+48>:	ld      r0,16(r9)
0xc00000000018e664 <find_vma_prev+52>:	cmpld   cr7,r0,r4
0xc00000000018e668 <find_vma_prev+56>:	bgt     cr7,0xc00000000018e650 =
<find_vma_prev+32>
0xc00000000018e66c <find_vma_prev+60>:	ld      r10,24(r9)
0xc00000000018e670 <find_vma_prev+64>:	mr      r8,r9
0xc00000000018e674 <find_vma_prev+68>:	cmpdi   cr7,r10,0
0xc00000000018e678 <find_vma_prev+72>:	beq     cr7,0xc00000000018e6b0 =
<find_vma_prev+128>
0xc00000000018e67c <find_vma_prev+76>:	ld      r0,16(r10)
0xc00000000018e680 <find_vma_prev+80>:	cmpld   cr7,r4,r0
0xc00000000018e684 <find_vma_prev+84>:	blt     cr7,0xc00000000018e6b0 =
<find_vma_prev+128>
0xc00000000018e688 <find_vma_prev+88>:	ld      r11,8(r11)
0xc00000000018e68c <find_vma_prev+92>:	cmpdi   cr7,r11,0
0xc00000000018e690 <find_vma_prev+96>:	bne     cr7,0xc00000000018e65c =
<find_vma_prev+44>
0xc00000000018e694 <find_vma_prev+100>:	cmpdi   cr7,r8,0
0xc00000000018e698 <find_vma_prev+104>:	std     r8,0(r5)
0xc00000000018e69c <find_vma_prev+108>:	beqlr-  cr7
0xc00000000018e6a0 <find_vma_prev+112>:	ld      r3,24(r8)
0xc00000000018e6a4 <find_vma_prev+116>:	blr
0xc00000000018e6a8 <find_vma_prev+120>:	nop
0xc00000000018e6ac <find_vma_prev+124>:	nop
0xc00000000018e6b0 <find_vma_prev+128>:	mr      r8,r9
0xc00000000018e6b4 <find_vma_prev+132>:	cmpdi   cr7,r8,0
0xc00000000018e6b8 <find_vma_prev+136>:	std     r8,0(r5)
0xc00000000018e6bc <find_vma_prev+140>:	bne+    cr7,0xc00000000018e6a0 =
<find_vma_prev+112>
0xc00000000018e6c0 <find_vma_prev+144>:	blr
0xc00000000018e6c4 <find_vma_prev+148>:	nop
0xc00000000018e6c8 <find_vma_prev+152>:	nop
0xc00000000018e6cc <find_vma_prev+156>:	nop
0xc00000000018e6d0 <find_vma_prev+160>:	std     r3,0(r5)
0xc00000000018e6d4 <find_vma_prev+164>:	li      r3,0
0xc00000000018e6d8 <find_vma_prev+168>:	blr
0xc00000000018e6dc <find_vma_prev+172>:	std     r11,0(r5)
0xc00000000018e6e0 <find_vma_prev+176>:	blr


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
