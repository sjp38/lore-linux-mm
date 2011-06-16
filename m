Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 188256B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:32:21 -0400 (EDT)
Subject: Re: Oops in VMA code
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
Date: Thu, 16 Jun 2011 07:32:10 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de> <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>


On 16.06.2011, at 06:32, Linus Torvalds wrote:

> On Wed, Jun 15, 2011 at 2:59 PM, Alexander Graf <agraf@suse.de> wrote:
>> Hi memory management experts,
>>=20
>> I just had this crash while compiling code on my PPC G5. I was =
running my PPC KVM tree, which was pretty much =
06e86849cf4019945a106913adb9ff0abcc01770 plus a few unrelated KVM =
patches. User space is 64-bit.
>>=20
>> Is this a known issue or did I hit something completely unexpected?
>=20
> It doesn't look at all familiar to me, nor does google really seem to
> find anything half-way related.

Thanks a lot for looking at it either way :).

> In fact, the only thing that that oops makes me think is that we
> should get rid of that find_vma_prev() function these days (the vma
> list is doubly linked since commit 297c5eee3724, and the whole "look
> up prev" thing is some silly old stuff).
>=20
> But that's an entirely unrelated issue.
>=20
> Also, your disassembly and your gdb line lookup is apparently from
> some other kernel, because the addresses don't match. The actual
> running kernel actually says
>=20
>  NIP [c000000000190598] .do_munmap+0x138/0x3f0
>=20
> so it's do_munmap, not find_vma_prev(). Although gdb claiming
> find_vma_prev() might be from some inlining issue, of course.
> Regardless, it's useless for debugging - it's the do_munap()
> disassembly we'd want (but I'm no longer all that fluent in ppc
> assembly anyway, so ir probably wouldn't help).

The reason the symbol lookup here is wrong is because I manually =
stripped the kernel, since yaboot chokes on loading a 250MB elf binary =
with debug symbols included:

clay:/autotest/ppc/kvm # gdb /boot/vmlinux.autotest.unstrip=20
...
(gdb) x /i 0xc000000000190598
0xc000000000190598 <find_vma_prev+68>:	ld      r0,16(r26)
(gdb) x /i do_munmap+0x138
0xc000000000190598 <find_vma_prev+68>:	ld      r0,16(r26)


clay:/autotest/ppc/kvm # gdb /boot/vmlinux.autotest
(gdb) x /i 0xc000000000190598
0xc000000000190598:	ld      r0,16(r26)


The latter is the one I'm executing, while the former still has all the =
symbols. But you're right. It looks like this is simply an inlined =
function - which is why it got stripped away. Here's the disassembly of =
the whole do_unmap function. I hope it's of use despite your fading PPC =
asm skills :). Host compiler is gcc 4.3.4 from SLES11SP1.


0xc000000000190460 <do_munmap>:	mflr    r0
0xc000000000190464 <do_munmap+4>:	std     r29,-24(r1)
0xc000000000190468 <do_munmap+8>:	std     r30,-16(r1)
0xc00000000019046c <do_munmap+12>:	mfcr    r12
0xc000000000190470 <do_munmap+16>:	std     r0,16(r1)
0xc000000000190474 <do_munmap+20>:	clrldi. r0,r4,52
0xc000000000190478 <do_munmap+24>:	mr      r29,r3
0xc00000000019047c <do_munmap+28>:	std     r31,-8(r1)
0xc000000000190480 <do_munmap+32>:	std     r23,-72(r1)
0xc000000000190484 <do_munmap+36>:	std     r24,-64(r1)
0xc000000000190488 <do_munmap+40>:	std     r25,-56(r1)
0xc00000000019048c <do_munmap+44>:	std     r26,-48(r1)
0xc000000000190490 <do_munmap+48>:	std     r27,-40(r1)
0xc000000000190494 <do_munmap+52>:	std     r28,-32(r1)
0xc000000000190498 <do_munmap+56>:	stw     r12,8(r1)
0xc00000000019049c <do_munmap+60>:	ld      r30,-18136(r2)
0xc0000000001904a0 <do_munmap+64>:	stdu    r1,-192(r1)
0xc0000000001904a4 <do_munmap+68>:	mr      r31,r4
0xc0000000001904a8 <do_munmap+72>:	beq     0xc0000000001904f0 =
<get_current>
0xc0000000001904ac <remove_vma_list>:	li      r3,-22
0xc0000000001904b0 <do_munmap+80>:	addi    r1,r1,192
0xc0000000001904b4 <do_munmap+84>:	ld      r0,16(r1)
0xc0000000001904b8 <do_munmap+88>:	lwz     r12,8(r1)
0xc0000000001904bc <do_munmap+92>:	ld      r23,-72(r1)
0xc0000000001904c0 <do_munmap+96>:	ld      r24,-64(r1)
0xc0000000001904c4 <do_munmap+100>:	ld      r25,-56(r1)
0xc0000000001904c8 <do_munmap+104>:	ld      r26,-48(r1)
0xc0000000001904cc <do_munmap+108>:	ld      r27,-40(r1)
0xc0000000001904d0 <do_munmap+112>:	ld      r28,-32(r1)
0xc0000000001904d4 <do_munmap+116>:	mtlr    r0
0xc0000000001904d8 <do_munmap+120>:	ld      r29,-24(r1)
0xc0000000001904dc <do_munmap+124>:	ld      r30,-16(r1)
0xc0000000001904e0 <do_munmap+128>:	mtocrf  8,r12
0xc0000000001904e4 <do_munmap+132>:	ld      r31,-8(r1)
0xc0000000001904e8 <do_munmap+136>:	blr
0xc0000000001904ec <do_munmap+140>:	nop
0xc0000000001904f0 <get_current>:	ld      r9,456(r13)
0xc0000000001904f4 <test_ti_thread_flag>:	ld      r11,8(r9)
0xc0000000001904f8 <do_munmap+152>:	ld      r8,-32712(r30)
0xc0000000001904fc <do_munmap+156>:	lis     r10,4096
0xc000000000190500 <do_munmap+160>:	rldicr  r10,r10,16,47
0xc000000000190504 <test_bit>:	ld      r0,128(r11)
0xc000000000190508 <do_munmap+168>:	rldicr  r0,r0,59,4
0xc00000000019050c <do_munmap+172>:	sradi   r0,r0,63
0xc000000000190510 <do_munmap+176>:	and     r0,r0,r8
0xc000000000190514 <do_munmap+180>:	add     r0,r0,r10
0xc000000000190518 <do_munmap+184>:	cmpld   cr7,r0,r4
0xc00000000019051c <do_munmap+188>:	blt     cr7,0xc0000000001904ac =
<remove_vma_list>
0xc000000000190520 <get_current>:	ld      r9,456(r13)
0xc000000000190524 <test_ti_thread_flag>:	ld      r11,8(r9)
0xc000000000190528 <test_bit>:	ld      r0,128(r11)
0xc00000000019052c <do_munmap+204>:	rldicr  r0,r0,59,4
0xc000000000190530 <do_munmap+208>:	sradi   r0,r0,63
0xc000000000190534 <do_munmap+212>:	and     r0,r0,r8
0xc000000000190538 <do_munmap+216>:	add     r0,r0,r10
0xc00000000019053c <do_munmap+220>:	subf    r0,r4,r0
0xc000000000190540 <do_munmap+224>:	cmpld   cr7,r0,r5
0xc000000000190544 <do_munmap+228>:	blt     cr7,0xc0000000001904ac =
<remove_vma_list>
0xc000000000190548 <do_munmap+232>:	addi    r0,r5,4095
0xc00000000019054c <do_munmap+236>:	rldicr. r4,r0,0,51
0xc000000000190550 <do_munmap+240>:	beq     0xc0000000001904ac =
<remove_vma_list>
0xc000000000190554 <find_vma_prev>:	cmpdi   cr7,r3,0
0xc000000000190558 <find_vma_prev+4>:	beq     cr7,0xc0000000001907f0 =
<remove_vma_list+836>
0xc00000000019055c <find_vma_prev+8>:	ld      r9,8(r3)
0xc000000000190560 <find_vma_prev+12>:	ld      r28,0(r3)
0xc000000000190564 <find_vma_prev+16>:	li      r11,0
0xc000000000190568 <find_vma_prev+20>:	li      r26,0
0xc00000000019056c <find_vma_prev+24>:	cmpdi   cr7,r9,0
0xc000000000190570 <find_vma_prev+28>:	bne     cr7,0xc000000000190594 =
<find_vma_prev+64>
0xc000000000190574 <find_vma_prev+32>:	b       0xc0000000001905d0 =
<do_munmap+368>
0xc000000000190578 <find_vma_prev+36>:	nop
0xc00000000019057c <find_vma_prev+40>:	nop
0xc000000000190580 <find_vma_prev+44>:	ld      r9,16(r9)
0xc000000000190584 <find_vma_prev+48>:	mr      r26,r11
0xc000000000190588 <find_vma_prev+52>:	cmpdi   cr7,r9,0
0xc00000000019058c <find_vma_prev+56>:	mr      r11,r26
0xc000000000190590 <find_vma_prev+60>:	beq     cr7,0xc0000000001905c4 =
<find_vma_prev+112>
0xc000000000190594 <find_vma_prev+64>:	addi    r26,r9,-56
0xc000000000190598 <find_vma_prev+68>:	ld      r0,16(r26)
0xc00000000019059c <find_vma_prev+72>:	cmpld   cr7,r31,r0
0xc0000000001905a0 <find_vma_prev+76>:	blt     cr7,0xc000000000190580 =
<find_vma_prev+44>
0xc0000000001905a4 <find_vma_prev+80>:	ld      r11,24(r26)
0xc0000000001905a8 <find_vma_prev+84>:	cmpdi   cr7,r11,0
0xc0000000001905ac <find_vma_prev+88>:	beq     cr7,0xc0000000001905c4 =
<find_vma_prev+112>
0xc0000000001905b0 <find_vma_prev+92>:	ld      r0,16(r11)
0xc0000000001905b4 <find_vma_prev+96>:	cmpld   cr7,r31,r0
0xc0000000001905b8 <find_vma_prev+100>:	blt     cr7,0xc0000000001905c4 =
<find_vma_prev+112>
0xc0000000001905bc <find_vma_prev+104>:	ld      r9,8(r9)
0xc0000000001905c0 <find_vma_prev+108>:	b       0xc000000000190588 =
<find_vma_prev+52>
0xc0000000001905c4 <find_vma_prev+112>:	cmpdi   cr7,r26,0
0xc0000000001905c8 <find_vma_prev+116>:	beq     cr7,0xc0000000001905d0 =
<do_munmap+368>
0xc0000000001905cc <find_vma_prev+120>:	ld      r28,24(r26)
0xc0000000001905d0 <do_munmap+368>:	cmpdi   cr7,r28,0
0xc0000000001905d4 <do_munmap+372>:	beq     cr7,0xc0000000001907f0 =
<remove_vma_list+836>
0xc0000000001905d8 <do_munmap+376>:	ld      r0,8(r28)
0xc0000000001905dc <do_munmap+380>:	add     r24,r4,r31
0xc0000000001905e0 <do_munmap+384>:	cmpld   cr7,r24,r0
0xc0000000001905e4 <do_munmap+388>:	ble     cr7,0xc0000000001907f0 =
<remove_vma_list+836>
0xc0000000001905e8 <do_munmap+392>:	cmpld   cr7,r31,r0
0xc0000000001905ec <do_munmap+396>:	ble     cr7,0xc00000000019061c =
<do_munmap+444>
0xc0000000001905f0 <do_munmap+400>:	ld      r0,16(r28)
0xc0000000001905f4 <do_munmap+404>:	cmpld   cr7,r24,r0
0xc0000000001905f8 <do_munmap+408>:	blt     cr7,0xc000000000190814 =
<do_munmap+948>
0xc0000000001905fc <do_munmap+412>:	mr      r3,r29
0xc000000000190600 <do_munmap+416>:	mr      r4,r28
0xc000000000190604 <do_munmap+420>:	mr      r5,r31
0xc000000000190608 <do_munmap+424>:	li      r6,0
0xc00000000019060c <do_munmap+428>:	bl      0xc000000000190160 =
<__split_vma>
0xc000000000190610 <do_munmap+432>:	cmpdi   r3,0
0xc000000000190614 <do_munmap+436>:	bne     0xc0000000001904b0 =
<do_munmap+80>
0xc000000000190618 <do_munmap+440>:	mr      r26,r28
0xc00000000019061c <do_munmap+444>:	mr      r3,r29
0xc000000000190620 <do_munmap+448>:	mr      r4,r24
0xc000000000190624 <do_munmap+452>:	bl      0xc00000000018e580 =
<find_vma>
0xc000000000190628 <do_munmap+456>:	cmpdi   r3,0
0xc00000000019062c <do_munmap+460>:	beq     0xc00000000019063c =
<do_munmap+476>
0xc000000000190630 <do_munmap+464>:	ld      r0,8(r3)
0xc000000000190634 <do_munmap+468>:	cmpld   cr7,r24,r0
0xc000000000190638 <do_munmap+472>:	bgt     cr7,0xc000000000190830 =
<do_munmap+976>
0xc00000000019063c <do_munmap+476>:	cmpdi   cr4,r26,0
0xc000000000190640 <do_munmap+480>:	beq     cr4,0xc00000000019071c =
<do_munmap+700>
0xc000000000190644 <do_munmap+484>:	ld      r25,24(r26)
0xc000000000190648 <do_munmap+488>:	ld      r0,168(r29)
0xc00000000019064c <do_munmap+492>:	cmpdi   cr7,r0,0
0xc000000000190650 <do_munmap+496>:	bne     cr7,0xc0000000001906b0 =
<do_munmap+592>
0xc000000000190654 <detach_vmas_to_be_unmapped>:	beq     =
cr4,0xc00000000019080c <detach_vmas_to_be_unmapped+440>
0xc000000000190658 <detach_vmas_to_be_unmapped+4>:	addi    =
r27,r26,24
0xc00000000019065c <detach_vmas_to_be_unmapped+8>:	li      r0,0
0xc000000000190660 <detach_vmas_to_be_unmapped+12>:	addi    =
r23,r29,8
0xc000000000190664 <detach_vmas_to_be_unmapped+16>:	mr      r28,r25
0xc000000000190668 <detach_vmas_to_be_unmapped+20>:	std     =
r0,32(r25)
0xc00000000019066c <detach_vmas_to_be_unmapped+24>:	b       =
0xc000000000190680 <detach_vmas_to_be_unmapped+44>
0xc000000000190670 <detach_vmas_to_be_unmapped+28>:	ld      r0,8(r4)
0xc000000000190674 <detach_vmas_to_be_unmapped+32>:	cmpld   =
cr7,r24,r0
0xc000000000190678 <detach_vmas_to_be_unmapped+36>:	ble     =
cr7,0xc000000000190724 <detach_vmas_to_be_unmapped+208>
0xc00000000019067c <detach_vmas_to_be_unmapped+40>:	mr      r28,r4
0xc000000000190680 <detach_vmas_to_be_unmapped+44>:	mr      r4,r23
0xc000000000190684 <detach_vmas_to_be_unmapped+48>:	addi    =
r3,r28,56
0xc000000000190688 <detach_vmas_to_be_unmapped+52>:	bl      =
0xc00000000043b1c0 <rb_erase>
0xc00000000019068c <detach_vmas_to_be_unmapped+56>:	nop
0xc000000000190690 <detach_vmas_to_be_unmapped+60>:	lwz     =
r9,88(r29)
0xc000000000190694 <detach_vmas_to_be_unmapped+64>:	addi    r9,r9,-1
0xc000000000190698 <detach_vmas_to_be_unmapped+68>:	stw     =
r9,88(r29)
0xc00000000019069c <detach_vmas_to_be_unmapped+72>:	ld      =
r4,24(r28)
0xc0000000001906a0 <detach_vmas_to_be_unmapped+76>:	cmpdi   cr6,r4,0
0xc0000000001906a4 <detach_vmas_to_be_unmapped+80>:	bne     =
cr6,0xc000000000190670 <detach_vmas_to_be_unmapped+28>
0xc0000000001906a8 <detach_vmas_to_be_unmapped+84>:	std     =
r4,0(r27)
0xc0000000001906ac <detach_vmas_to_be_unmapped+88>:	b       =
0xc00000000019072c <detach_vmas_to_be_unmapped+216>
0xc0000000001906b0 <do_munmap+592>:	cmpdi   cr7,r25,0
0xc0000000001906b4 <do_munmap+596>:	beq     cr7,0xc000000000190654 =
<detach_vmas_to_be_unmapped>
0xc0000000001906b8 <do_munmap+600>:	ld      r11,8(r25)
0xc0000000001906bc <do_munmap+604>:	cmpld   cr7,r24,r11
0xc0000000001906c0 <do_munmap+608>:	ble     cr7,0xc000000000190654 =
<detach_vmas_to_be_unmapped>
0xc0000000001906c4 <do_munmap+612>:	mr      r28,r25
0xc0000000001906c8 <do_munmap+616>:	ld      r0,48(r28)
0xc0000000001906cc <do_munmap+620>:	rldicl. r9,r0,51,63
0xc0000000001906d0 <do_munmap+624>:	beq     0xc000000000190700 =
<do_munmap+672>
0xc0000000001906d4 <do_munmap+628>:	ld      r0,16(r28)
0xc0000000001906d8 <do_munmap+632>:	ld      r9,168(r29)
0xc0000000001906dc <munlock_vma_pages_all>:	mr      r3,r28
0xc0000000001906e0 <do_munmap+640>:	subf    r0,r11,r0
0xc0000000001906e4 <do_munmap+644>:	rldicl  r0,r0,52,12
0xc0000000001906e8 <do_munmap+648>:	subf    r9,r0,r9
0xc0000000001906ec <do_munmap+652>:	std     r9,168(r29)
0xc0000000001906f0 <munlock_vma_pages_all+20>:	ld      r4,8(r28)
0xc0000000001906f4 <munlock_vma_pages_all+24>:	ld      r5,16(r28)
0xc0000000001906f8 <munlock_vma_pages_all+28>:	bl      =
0xc00000000018d840 <munlock_vma_pages_range>
0xc0000000001906fc <munlock_vma_pages_all+32>:	nop
0xc000000000190700 <do_munmap+672>:	ld      r28,24(r28)
0xc000000000190704 <do_munmap+676>:	cmpdi   cr7,r28,0
0xc000000000190708 <do_munmap+680>:	beq     cr7,0xc000000000190654 =
<detach_vmas_to_be_unmapped>
0xc00000000019070c <do_munmap+684>:	ld      r11,8(r28)
0xc000000000190710 <do_munmap+688>:	cmpld   cr7,r24,r11
0xc000000000190714 <do_munmap+692>:	bgt     cr7,0xc0000000001906c8 =
<do_munmap+616>
0xc000000000190718 <do_munmap+696>:	b       0xc000000000190654 =
<detach_vmas_to_be_unmapped>
0xc00000000019071c <do_munmap+700>:	ld      r25,0(r29)
0xc000000000190720 <do_munmap+704>:	b       0xc000000000190648 =
<do_munmap+488>
0xc000000000190724 <detach_vmas_to_be_unmapped+208>:	std     =
r4,0(r27)
0xc000000000190728 <detach_vmas_to_be_unmapped+212>:	std     =
r26,32(r4)
0xc00000000019072c <detach_vmas_to_be_unmapped+216>:	li      r9,0
0xc000000000190730 <detach_vmas_to_be_unmapped+220>:	ld      =
r0,-32720(r30)
0xc000000000190734 <detach_vmas_to_be_unmapped+224>:	std     =
r9,24(r28)
0xc000000000190738 <detach_vmas_to_be_unmapped+228>:	ld      =
r9,32(r29)
0xc00000000019073c <detach_vmas_to_be_unmapped+232>:	cmpd    =
cr7,r9,r0
0xc000000000190740 <detach_vmas_to_be_unmapped+236>:	beq     =
cr7,0xc000000000190800 <detach_vmas_to_be_unmapped+428>
0xc000000000190744 <detach_vmas_to_be_unmapped+240>:	beq     =
cr6,0xc0000000001907f8 <detach_vmas_to_be_unmapped+420>
0xc000000000190748 <detach_vmas_to_be_unmapped+244>:	ld      r4,8(r4)
0xc00000000019074c <detach_vmas_to_be_unmapped+248>:	ld      r0,0(r9)
0xc000000000190750 <detach_vmas_to_be_unmapped+252>:	std     =
r2,40(r1)
0xc000000000190754 <detach_vmas_to_be_unmapped+256>:	mr      r3,r29
0xc000000000190758 <detach_vmas_to_be_unmapped+260>:	mtctr   r0
0xc00000000019075c <detach_vmas_to_be_unmapped+264>:	ld      =
r11,16(r9)
0xc000000000190760 <detach_vmas_to_be_unmapped+268>:	ld      r2,8(r9)
0xc000000000190764 <detach_vmas_to_be_unmapped+272>:	bctrl
0xc000000000190768 <detach_vmas_to_be_unmapped+276>:	ld      =
r2,40(r1)
0xc00000000019076c <detach_vmas_to_be_unmapped+280>:	li      r0,0
0xc000000000190770 <do_munmap+784>:	mr      r5,r26
0xc000000000190774 <do_munmap+788>:	mr      r6,r31
0xc000000000190778 <do_munmap+792>:	mr      r7,r24
0xc00000000019077c <detach_vmas_to_be_unmapped+296>:	std     =
r0,16(r29)
0xc000000000190780 <do_munmap+800>:	mr      r3,r29
0xc000000000190784 <do_munmap+804>:	mr      r4,r25
0xc000000000190788 <do_munmap+808>:	bl      0xc00000000018ee70 =
<unmap_region>
0xc00000000019078c <update_hiwater_vm>:	ld      r9,160(r29)
0xc000000000190790 <update_hiwater_vm+4>:	ld      r0,152(r29)
0xc000000000190794 <update_hiwater_vm+8>:	cmpld   cr7,r0,r9
0xc000000000190798 <update_hiwater_vm+12>:	bge     =
cr7,0xc0000000001907b4 <vma_pages>
0xc00000000019079c <update_hiwater_vm+16>:	std     r9,152(r29)
0xc0000000001907a0 <update_hiwater_vm+20>:	b       =
0xc0000000001907b4 <vma_pages>
0xc0000000001907a4 <update_hiwater_vm+24>:	nop
0xc0000000001907a8 <update_hiwater_vm+28>:	nop
0xc0000000001907ac <update_hiwater_vm+32>:	nop
0xc0000000001907b0 <update_hiwater_vm+36>:	ld      r9,160(r29)
0xc0000000001907b4 <vma_pages>:	ld      r0,8(r25)
0xc0000000001907b8 <vma_pages+4>:	ld      r6,16(r25)
0xc0000000001907bc <remove_vma_list+784>:	mr      r3,r29
0xc0000000001907c0 <vma_pages+12>:	subf    r6,r0,r6
0xc0000000001907c4 <vma_pages+16>:	rldicl  r6,r6,52,12
0xc0000000001907c8 <remove_vma_list+796>:	subf    r0,r6,r9
0xc0000000001907cc <remove_vma_list+800>:	neg     r6,r6
0xc0000000001907d0 <remove_vma_list+804>:	std     r0,160(r29)
0xc0000000001907d4 <remove_vma_list+808>:	ld      r4,48(r25)
0xc0000000001907d8 <remove_vma_list+812>:	ld      r5,152(r25)
0xc0000000001907dc <remove_vma_list+816>:	bl      =
0xc00000000018e290 <vm_stat_account>
0xc0000000001907e0 <remove_vma_list+820>:	mr      r3,r25
0xc0000000001907e4 <remove_vma_list+824>:	bl      =
0xc00000000018ec30 <remove_vma>
0xc0000000001907e8 <remove_vma_list+828>:	mr.     r25,r3
0xc0000000001907ec <remove_vma_list+832>:	bne     =
0xc0000000001907b0 <update_hiwater_vm+36>
0xc0000000001907f0 <remove_vma_list+836>:	li      r3,0
0xc0000000001907f4 <remove_vma_list+840>:	b       =
0xc0000000001904b0 <do_munmap+80>
0xc0000000001907f8 <detach_vmas_to_be_unmapped+420>:	ld      =
r4,40(r29)
0xc0000000001907fc <detach_vmas_to_be_unmapped+424>:	b       =
0xc00000000019074c <detach_vmas_to_be_unmapped+248>
0xc000000000190800 <detach_vmas_to_be_unmapped+428>:	beq     =
cr4,0xc0000000001907f8 <detach_vmas_to_be_unmapped+420>
0xc000000000190804 <detach_vmas_to_be_unmapped+432>:	ld      =
r4,16(r26)
0xc000000000190808 <detach_vmas_to_be_unmapped+436>:	b       =
0xc00000000019074c <detach_vmas_to_be_unmapped+248>
0xc00000000019080c <detach_vmas_to_be_unmapped+440>:	mr      r27,r29
0xc000000000190810 <detach_vmas_to_be_unmapped+444>:	b       =
0xc00000000019065c <detach_vmas_to_be_unmapped+8>
0xc000000000190814 <do_munmap+948>:	ld      r9,-32728(r30)
0xc000000000190818 <do_munmap+952>:	lwz     r11,88(r29)
0xc00000000019081c <do_munmap+956>:	li      r3,-12
0xc000000000190820 <do_munmap+960>:	lwz     r0,0(r9)
0xc000000000190824 <do_munmap+964>:	cmpw    cr7,r11,r0
0xc000000000190828 <do_munmap+968>:	blt     cr7,0xc0000000001905fc =
<do_munmap+412>
0xc00000000019082c <do_munmap+972>:	b       0xc0000000001904b0 =
<do_munmap+80>
0xc000000000190830 <do_munmap+976>:	mr      r4,r3
0xc000000000190834 <do_munmap+980>:	mr      r5,r24
0xc000000000190838 <do_munmap+984>:	mr      r3,r29
0xc00000000019083c <do_munmap+988>:	li      r6,1
0xc000000000190840 <do_munmap+992>:	bl      0xc000000000190160 =
<__split_vma>
0xc000000000190844 <do_munmap+996>:	cmpdi   r3,0
0xc000000000190848 <do_munmap+1000>:	beq     0xc00000000019063c =
<do_munmap+476>
0xc00000000019084c <do_munmap+1004>:	b       0xc0000000001904b0 =
<do_munmap+80>



Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
