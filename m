Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA05882
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 09:50:53 -0400
Date: Wed, 19 Aug 1998 13:07:01 +0100
Message-Id: <199808191207.NAA00885@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: memory overcommitment
In-Reply-To: <Pine.LNX.4.02.9808181600190.6675-100000@pc367.hq.eso.org>
References: <199808171833.TAA03492@dax.dcs.ed.ac.uk>
	<Pine.LNX.4.02.9808181600190.6675-100000@pc367.hq.eso.org>
Sender: owner-linux-mm@kvack.org
To: Nicolas Devillard <ndevilla@mygale.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 18 Aug 1998 16:34:01 +0000 ( ), Nicolas Devillard
<ndevilla@mygale.org> said:

> On Mon, 17 Aug 1998, Stephen C. Tweedie wrote:
>> 
>> The short answer is "don't do that, then"!  

> Well... I certainly don't. The OS does it for me, which is precisely what
> I want to avoid! I allocate N megs of memory, not because I use a system
> function which does it implicitly (like fork() does), but because I want
> this memory to store data and work with it. If the system cannot give me N
> megs of memory, better tell me immediately with a NULL returned by
> malloc() and an ENOMEM (as described in the man page, BTW), than tell me:
> Ok, here's your pointer, so that I start working on my data and then
> suddenly... crash. 

As I said, the only way to do this is to writable private restrict
allocations to the size of available swap.  Otherwise, if you include
physical memory in the calculation, you can lose out: the kernel needs
to allocate physical memory for networking, page tables, stack space
etc.  There simply isn't any way around this.

> It's not that I am working on making Linux fly planes or what, but
> when you start having data the size of a gig you realize it will take
> some time to process it out completely. 

Then initialise the memory after malloc; you know the pages are there by
that stage. 

There are also lots of programs which allocate a gig of memory and only
use a tiny fraction of it.  We don't want them all to suddenly start
failing.  You can't have it both ways!

>> If you can suggest a good algorithm for selecting processes to kill,
>> we'd love to hear about it.  The best algorithm will not be the same for
>> all users.

> Killing processes randomly is maybe one way to solve the problem,
> certainly not the only one. 

Umm, killing inetd?  sendmaild?  init??!!

> For my applications, I found out that the simplest way to allocate
> huge amounts is to open enough temporary files on the user's disk,
> fill them up with zeroes and mmap() them. This way, I get way past the
> physical memory, and because I am never using the whole allocated
> stuff simultaneously, these files are paged by the OS invisibly in a
> much more efficient way than I could do. It is certainly slow, but
> still very reasonable, and avoids quite some headaches in programming.

Yep, that's common practice: essentially a writable mmap acts like
allocating your own swap file, which is an entirely reasonable thing to
do if you don't know in advance whether your data set will fit into the
amount of true swap present.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
