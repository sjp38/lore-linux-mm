Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11858
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 09:23:02 -0500
Date: Tue, 26 Jan 1999 15:15:04 +0100 (CET)
From: MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m1059TX-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.96.990126145544.11981B-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, groudier@club-internet.fr, torvalds@transmeta.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jan 1999, Alan Cox wrote:

> Something like
> 
> Chop memory into 4Mb sized chunks that hold the perfectly normal and
> existing pages and buddy memory allocator. Set a flag on 25-33% of them
> to a max of say 10 and for <12Mb boxes simply say "tough".

this is conceptually 'boot-time allocation of big buffers' by splitting
all available memory into two pieces:

	size_kernel: generic memory
	size_user: only swappable

(size_kernel+size_user = ca. size_allmemory)

This still doesnt solve the 'what if we need more big buffers than
size_user' and 'what if we need kernel memory more than size_kernel'
questions, and both are valid.

another (2.3 issue) approach could be to make two garantees for
'pinned-down kernel allocations':

	1) either they will be deallocated after some definit timeout
	2) or they can be explicitly deallocated via special mechanizms

this enables us to implement a 100% algorithm of 'moving' kernel-space
objects, without having to do kernel-space paging or other runtime costs. 
Most 'pinned down' objects already have a specific timeout (buffer heads,
used dentries) or can already be 'flushed'. (eg specific unused
dentry-cache members, and other cached but freeable kernel-space objects).

the mechanizm is to 'ban' kernel-allocations from certain pages either
passively (by waiting on the objects in question), or by actively moving
them. The 'flushing' part is easy and we mainly already use it to reclaim
memory.

the toughest part is the 'moving' stuff, which is not yet present and
hard/impossible to implement in a clean and maintainable way. We need this
eg. for sockets, files, (not inodes fortunately), task structures, vmas,
mms, signal structures, etc. It really feels like a rewrite that needs a
very good architecture to be successful, ie. we _have to_ guarantee
'correctness' automatically somehow to not let this develop into a mess. 
Also, it must have only very limited 'subsystem-side' complexity to not
hinder development. Eg. in the debugging version we could have a
per-allocation timer that warns us if we havent 'unused' that particular
object within a given timeout. Dont know. It's tough.

but iff this mechanizm is present, we could 'ban' allocations from
whatever physical page in the system (this isnt much different from all-VM
solutions, they have to wait for swapouts too anyway, but is a heck better
and faster wrt. mappings issues). This is very generic and does not
presume any 'split' between usage types. This is not at all limited to 4m
sections or whatever, and certainly works on any Linux system even 4M RAM
boxes, and it's still possible to use up all memory for kernel allocations
eg. for dedicated router boxes.

yes it restricts and complicates the way kernel subsystems can allocate
buffers, but we _have_ to do that iff we want to solve the problem 100%.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
