Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA04815
	for <linux-mm@kvack.org>; Mon, 13 Jul 1998 12:57:20 -0400
Date: Mon, 13 Jul 1998 17:53:55 +0100
Message-Id: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: More info: 2.1.108 page cache performance on low memory
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Benjamin LaHaise <bcrlahai@calum.csclub.uwaterloo.ca>, Alan Cox <number6@the-village.bc.nu>, Linus Torvalds <torvalds@transmeta.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi all,

OK, a bit more benchmarking is showing bad problems with page ageing.
I've been running 2.1 with a big ramdisk and without, with page ageing
and without.  The results for a simple compile job (make a few
dependency files then compile four .c files) look like this:

	2.0.34, 6m ram:			1:22

	2.1.108, 16m ram, 10m ramdisk:
		With page cache ageing:	Not usable (swap death during boot.)
		Without cache ageing:	8:47

	2.1.108, 6m ram:
		With page cache ageing:	4:14
		Without cache ageing:	3:22

So we can see that on these low memory configurations, the page cache
ageing is a definite performance loss.  The situation with the ramdisk
is VERY markedly worse, which I think we can attribute to an
overly-large page cache due to the %age-physical-memory tuning
parameters; I'll be following this up to check (that's easy, since those
parameters are sysctl-able).  This is not an artificial situation:
having the page cache limits fixed in terms of %age of physical pages is
just not going to work if you can have large numbers of those pages
locked down for particular purposes.  Effectively we're reducing the
size of the page pool without the vm taking it into account.

Performance sucks overall compared to 2.0.  That may well be due to the
extra memory lost to the inode and dirent caches on 2.1, which tend to
grow much more than they did before; it may be that we can address that
without too much pain.  It is certainly possible to trim back the
kernel's ability to stop caching unused inodes/dirents, and although a
self-tuning system will be necessary in the long term, putting bounds on
these caches will at least let us see if this is where things are going
wrong.

I'll be experimenting a bit more to try to identify just where the
performance is disappearing here.  However you look at it, things look
pretty grim on 2.1 right now on low memory machines.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
