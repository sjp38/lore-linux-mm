Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31239
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:46:14 -0400
Date: Mon, 27 Jul 1998 12:07:27 +0100
Message-Id: <199807271107.MAA00717@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Good and bad news on 2.1.110, and a fix
In-Reply-To: <Pine.LNX.3.96.980723222349.18464C-100000@mirkwood.dummy.home>
References: <35B75FE8.63173E88@star.net>
	<Pine.LNX.3.96.980723222349.18464C-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Bill Hawes <whawes@star.net>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, "David S. Miller" <davem@dm.cobaltmicro.com>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Mark Hemment <markhe@nextd.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 23 Jul 1998 22:28:39 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Thu, 23 Jul 1998, Bill Hawes wrote:
>> Stephen C. Tweedie wrote:
>> 
>> > The patch to page_alloc.c is a minimal fix for the fragmentation
>> > problem.  It simply records allocation failures for high-order pages,
>> > and forces free_memory_available to return false until a page of at
>> > least that order becomes available.  The impact should be low, since

> This sound suspiciously like the first version of
> free_memory_available() that Linus introduced in
> 2.1.89...

No, it's very different; first, it is adaptive, and second, it only
waits for _one_ of the higher order free page lists to be filled.  The
patch carefully does absolutely nothing until we get a definite
failure to get a higher order page, and then it does the minimum
necessary work to satisfy one request before going inactive again. 

It is the minimum necessary patch to keep the kernel from locking up,
but it does nothing at all most of the time.  

> It will happen for sure; just think of what will happen
> when that 64 kB DMA allocation fails on your 6 MB box :(

Which is one reason why we probably want to timeout the condition
after a second or two.

> Maybe we want to count the number of order-3 memory structures
> free and keep that number above a certain level (back to
> Zlatko's 2.1.59 patch :-).

Again, it's arbitrary, and would result in unnecessary extra
activity.  What we'd like to do is make sure we only do _necessary_
pageing work, and keep as much memory as possible in use the rest of
the time.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
