Received: from pc367.hq.eso.org (pc367.hq.eso.org [134.171.13.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA00519
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 12:35:25 -0400
Date: Tue, 18 Aug 1998 16:34:01 +0000 (   )
From: Nicolas Devillard <ndevilla@mygale.org>
Subject: Re: memory overcommitment
In-Reply-To: <199808171833.TAA03492@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.4.02.9808181600190.6675-100000@pc367.hq.eso.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>


On Mon, 17 Aug 1998, Stephen C. Tweedie wrote:
>
> The short answer is "don't do that, then"!  

Well... I certainly don't. The OS does it for me, which is precisely what
I want to avoid! I allocate N megs of memory, not because I use a system
function which does it implicitly (like fork() does), but because I want
this memory to store data and work with it. If the system cannot give me N
megs of memory, better tell me immediately with a NULL returned by
malloc() and an ENOMEM (as described in the man page, BTW), than tell me:
Ok, here's your pointer, so that I start working on my data and then
suddenly... crash. It's not that I am working on making Linux fly planes
or what, but when you start having data the size of a gig you realize it
will take some time to process it out completely. You certainly want to
know ASAP if your machine has enough memory or not, you don't want to wait
48h to realize everything has crashed on the machine during the week-end,
including 'inetd' which means "take your car and go see by yourself". :-)

Why not separate allocators into two classes: lazy ones doing allocation
with overcommit, and the strong ones returning pointers to certified
memory (i.e. good old memory reserved for this process only)? Don't ask me
how to do it, you're the expert, I'm not :-)

> If you can suggest a good algorithm for selecting processes to kill,
> we'd love to hear about it.  The best algorithm will not be the same for
> all users.

Killing processes randomly is maybe one way to solve the problem,
certainly not the only one. Once you have cleared all solutions and come
to the conclusion that this is the only good one, let's go for it. For my
applications, I found out that the simplest way to allocate huge amounts
is to open enough temporary files on the user's disk, fill them up with
zeroes and mmap() them. This way, I get way past the physical memory, and
because I am never using the whole allocated stuff simultaneously, these
files are paged by the OS invisibly in a much more efficient way than I
could do. It is certainly slow, but still very reasonable, and avoids 
quite some headaches in programming.

Cheers
Nicolas

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
