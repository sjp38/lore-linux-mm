Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C12A86B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 02:12:25 -0400 (EDT)
Subject: Re: Oops in VMA code
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <1308204171.2516.65.camel@pasglop>
Date: Thu, 16 Jun 2011 08:12:21 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <8E75A48A-9EF4-4AF9-B3F2-A5D3479DD870@suse.de>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de> <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com> <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de> <1308204171.2516.65.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>


On 16.06.2011, at 08:02, Benjamin Herrenschmidt wrote:

> On Thu, 2011-06-16 at 07:32 +0200, Alexander Graf wrote:
>> On 16.06.2011, at 06:32, Linus Torvalds wrote:
>=20
>> Thanks a lot for looking at it either way :).
>=20
> Yeah thanks ;-) Let me see what I can dig out.
>=20
> First it's a load from what looks like a valid pointer to the linear
> mapping that had one byte corrupted (or more but it looks reasonably
> "clean"). It's not a one bit error, there's at least 2 bad bits (the
> 09):
>=20
> DAR: c00090026236bbc0
>=20
> Alex, how much RAM do you have ? If that was just a one byte =
corruption,
> the above would imply you have something valid between 9 and 10G. From
> the look of other registers, it seems that it could be a genuine =
pointer
> with just that stay "09" byte that landed onto it.

Heh, you caught me to it. I was just writing up a reply to Linus =
explaining how I only have 8GB of RAM and how this address has more =
invalid bits than just the "09". It's either completely garbaged as of =
the 3rd byte or at least 0x9002 is wrong.

>=20
>> The latter is the one I'm executing, while the former still has all
>> the symbols. But you're right. It looks like this is simply an =
inlined
>> function - which is why it got stripped away. Here's the disassembly
>> of the whole do_unmap function. I hope it's of use despite your =
fading
>> PPC asm skills :). Host compiler is gcc 4.3.4 from SLES11SP1.
>=20
> .../...
>=20
> Ok, so let's see what we can dig from here. It -looks- like:
>=20
> if (!mm) goto out :
>=20
>> 0xc000000000190554 <find_vma_prev>:	cmpdi   cr7,r3,0
>> 0xc000000000190558 <find_vma_prev+4>:	beq     =
cr7,0xc0000000001907f0 <remove_vma_list+836>
>=20
> rb_node =3D mm->mm_rb.rb_node; (rb_node in r9):
>=20
>> 0xc00000000019055c <find_vma_prev+8>:	ld      r9,8(r3)
>=20
> vma =3D mm->mmap (vma in r28)
>=20
>> 0xc000000000190560 <find_vma_prev+12>:	ld      r28,0(r3)
>> 0xc000000000190564 <find_vma_prev+16>:	li      r11,0
>> 0xc000000000190568 <find_vma_prev+20>:	li      r26,0
>=20
> while(rb_node)...
>=20
>> 0xc00000000019056c <find_vma_prev+24>:	cmpdi   cr7,r9,0
>> 0xc000000000190570 <find_vma_prev+28>:	bne     =
cr7,0xc000000000190594 <find_vma_prev+64>
>> 0xc000000000190574 <find_vma_prev+32>:	b       =
0xc0000000001905d0 <do_munmap+368>
>> 0xc000000000190578 <find_vma_prev+36>:	nop
>> 0xc00000000019057c <find_vma_prev+40>:	nop
>> 0xc000000000190580 <find_vma_prev+44>:	ld      r9,16(r9)
>> 0xc000000000190584 <find_vma_prev+48>:	mr      r26,r11
>> 0xc000000000190588 <find_vma_prev+52>:	cmpdi   cr7,r9,0
>> 0xc00000000019058c <find_vma_prev+56>:	mr      r11,r26
>> 0xc000000000190590 <find_vma_prev+60>:	beq     =
cr7,0xc0000000001905c4 <find_vma_prev+112>
>=20
> vma_tmp =3D rb_entry(rb_node, struct vm_area_struct, vm_rb);
>=20
>> 0xc000000000190594 <find_vma_prev+64>:	addi    r26,r9,-56
>=20
> if (vma_tmp->vm_end)
>=20
>> 0xc000000000190598 <find_vma_prev+68>:	ld      r0,16(r26)
>=20
> Here we go. So here vma_tmp is crap, which we got out of the rb_tree,
> so it's either corruption or use after free I'd say. It could also be =
a
> completely unrelated memory corruption of course....

I'm usually pretty sceptic on blaming hardware on memory corruption =
issues, so this would mean some random could would have overwritten =
things here. Sounds pretty hard to find to me.

> If you had xmon we could have dug a little bit more to see what's
> before/after etc... but like this it doesn't ring any special bell to
> me.

Yeah, I've since rebooted the machine :). Let's just leave it here and =
see if maybe someone else stumbles over the same thing, so we can =
potentially gather some data points. I'd claim it unlikely that this =
really is related to memory management code.


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
