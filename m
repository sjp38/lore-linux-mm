Received: from touchtunes.com (vantr.touchtunes.com [192.168.0.138])
	by mail.touchtunes.com (Postfix) with ESMTP id 5ECA4153E3
	for <linux-mm@kvack.org>; Mon,  8 Dec 2003 09:41:45 -0500 (EST)
Message-ID: <3FD48E06.5050303@touchtunes.com>
Date: Mon, 08 Dec 2003 09:43:18 -0500
From: Tristan Van Berkom <vantr@touchtunes.com>
MIME-Version: 1.0
Subject: How to share large portions of memory with user land
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,
     This is one of those "How do I ..." questions
which I asked at the LKML and got no response; Maybe
my MM sub-system related question is better targeted
here.

I did my homework and all the info I could find is pretty
old (dating from kernel 2.2.x) so I was hoping to be
brought up-to-speed in regards to io buffers and current
memory sharing techniques.

My question is already well phrased and andswered in an
email archived from a few years ago:
     http://www.ussg.iu.edu/hypermail/linux/kernel/0005.2/0505.html

Andi > The traditional linux way is to implement mmap for
Andi > your character device, vmalloc the memory in kernel
Andi > and supply it to the user process via mmap.

That means (I'm not mistaken) that first you use vmalloc
to allocate a contiguous virtual memory region and suply a
`nopage' method (via mmap) which returns the physical page
coresponding to user's _and_ the module's virtual address
plane; that means that after mucking about with page tables
a while; you have two virtual contiguous memory regions
(one user/one kernel) that both access the same physical
scattered pages. ... ( ?? hmmm ??)

Andi > 2.3 and some patched 2.2 kernels also offer a way to do this
Andi > directly (usion kiovecs and map_user_kiobuf()). This is not in
Andi > standard 2.2 kernel though.

This approach basicly save's me from the `nopage' aspect
of the afore mentioned method; but I dont have a contiguous
memory region in kernel space; only in user land.

Linus > Basically, the way kio buffers work is that
Linus > they are 100% based on only physical pages. There are no virtual
Linus > issues at all in the IO, and that's exactly how I want it. There
Linus > is no reason to confuse virtual addresses into this, because the
Linus > thing should be usable even in the complete absense of virtual
Linus > mappings (ie the kernel can do direct IO purely based on pages -
Linus > think sendfile() etc).

After reading that (above quoted from...):
  (http://www.ussg.iu.edu/hypermail/linux/kernel/0010.2/0338.html)
I can understand why.

So If I have a collection of physical pages in a kio buffer
is there a way to create a contigous virtual memory region out
of that ?

ie: unsigned long kmap_kiovec(int nr, struct kiobuf *iovec[]);

Must it be done by modifying the page tables by hand ?
(If so; is "linux" interrested in such an api as kmap_kiovec
or is it total nonsence ?)

Is there a preferred way to do this
   (mmap -> nopage vs. map_user_kiobuf()) ?

Best regards,
	                -Tristan



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
