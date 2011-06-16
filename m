Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 61DC46B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 02:03:01 -0400 (EDT)
Subject: Re: Oops in VMA code
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
	 <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
	 <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 16:02:51 +1000
Message-ID: <1308204171.2516.65.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Thu, 2011-06-16 at 07:32 +0200, Alexander Graf wrote:
> On 16.06.2011, at 06:32, Linus Torvalds wrote:

> Thanks a lot for looking at it either way :).

Yeah thanks ;-) Let me see what I can dig out.

First it's a load from what looks like a valid pointer to the linear
mapping that had one byte corrupted (or more but it looks reasonably
"clean"). It's not a one bit error, there's at least 2 bad bits (the
09):

DAR: c00090026236bbc0

Alex, how much RAM do you have ? If that was just a one byte corruption,
the above would imply you have something valid between 9 and 10G. From
the look of other registers, it seems that it could be a genuine pointer
with just that stay "09" byte that landed onto it.

> The latter is the one I'm executing, while the former still has all
> the symbols. But you're right. It looks like this is simply an inlined
> function - which is why it got stripped away. Here's the disassembly
> of the whole do_unmap function. I hope it's of use despite your fading
> PPC asm skills :). Host compiler is gcc 4.3.4 from SLES11SP1.

 .../...

Ok, so let's see what we can dig from here. It -looks- like:

if (!mm) goto out :

> 0xc000000000190554 <find_vma_prev>:	cmpdi   cr7,r3,0
> 0xc000000000190558 <find_vma_prev+4>:	beq     cr7,0xc0000000001907f0 <remove_vma_list+836>

rb_node = mm->mm_rb.rb_node; (rb_node in r9):

> 0xc00000000019055c <find_vma_prev+8>:	ld      r9,8(r3)

vma = mm->mmap (vma in r28)

> 0xc000000000190560 <find_vma_prev+12>:	ld      r28,0(r3)
> 0xc000000000190564 <find_vma_prev+16>:	li      r11,0
> 0xc000000000190568 <find_vma_prev+20>:	li      r26,0

while(rb_node)...

> 0xc00000000019056c <find_vma_prev+24>:	cmpdi   cr7,r9,0
> 0xc000000000190570 <find_vma_prev+28>:	bne     cr7,0xc000000000190594 <find_vma_prev+64>
> 0xc000000000190574 <find_vma_prev+32>:	b       0xc0000000001905d0 <do_munmap+368>
> 0xc000000000190578 <find_vma_prev+36>:	nop
> 0xc00000000019057c <find_vma_prev+40>:	nop
> 0xc000000000190580 <find_vma_prev+44>:	ld      r9,16(r9)
> 0xc000000000190584 <find_vma_prev+48>:	mr      r26,r11
> 0xc000000000190588 <find_vma_prev+52>:	cmpdi   cr7,r9,0
> 0xc00000000019058c <find_vma_prev+56>:	mr      r11,r26
> 0xc000000000190590 <find_vma_prev+60>:	beq     cr7,0xc0000000001905c4 <find_vma_prev+112>

vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);

> 0xc000000000190594 <find_vma_prev+64>:	addi    r26,r9,-56

if (vma_tmp->vm_end)

> 0xc000000000190598 <find_vma_prev+68>:	ld      r0,16(r26)

Here we go. So here vma_tmp is crap, which we got out of the rb_tree,
so it's either corruption or use after free I'd say. It could also be a
completely unrelated memory corruption of course....

If you had xmon we could have dug a little bit more to see what's
before/after etc... but like this it doesn't ring any special bell to
me.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
