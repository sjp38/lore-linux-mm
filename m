Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA32155
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 04:43:44 -0500
Subject: Re: Alpha quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <m1iue96lhl.fsf@flinx.ccr.net> <34BD0786.93EEC074@xinit.se>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 15 Jan 1999 03:02:07 -0600
In-Reply-To: Hans Eric Sandstrom's message of "Wed, 14 Jan 1998 19:44:22 +0100"
Message-ID: <m1zp7kdi40.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Hans Eric Sandstrom <hes@xinit.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "HS" == Hans Eric Sandstrom <hes@xinit.se> writes:

HS> "Eric W. Biederman" wrote:

>> >>>>> "EB" == Eric W Biederman <ebiederm> writes:
>> 
EB> Please take a look.  If it really is my fault shoot me.
>> Darn. It was me.

HS> I for one like the concept. So I won't shoot you.

HS> Just hope everyone else thinks the same (especially the ones that took the Gnus' with guns
HS> course in Atlanta) :-)

HS> But I would really like to have some trashing control here. Maybe this could be controlled
HS> at a higher level. This daemon is currently run each 30 seconds. Could this be prolonged if
HS> the system currently is doing heavy IO. Or could the daemon itself skip runs if the IO load
HS> is to high.

In the original concept, the daemon was just to sweep through memory and make sure
there were dirty buffers associated with the pages.  The actual writing is as close as
I can come for the 2.2 code base.

As far as crunching the dirty, (after the page scan) it would work about like bdflush.

For IO control I was thinking about having the same IO modes on the pages as we
have in the lowlevel code.  Specifically:
READ, WRITE, READA, WRITEA.  
Where READA & WRITEA are read ahead, or write ahead and it is fine to
throw those requests out of the queue if the can't be combined 
into another request.

Since this basic design also solves a lot of potential lockup
condition I was considering it for 2.2.    But my naive implementation
is having more bugs then I would have ever suspected, and the machine
totally freezes under high swapping load.  So unless something changes
I'm going to go back to aiming for an early 2.3 inclusion.

It is my expectation that getting the generic dirty pages in the page
cache will make the code much easier to balance for either heavy
IO loads or otherwise.

For where I'm aiming there is a lot still to do, but it keeps looking 
closer all the time.   After this patch stabalizes the work left
is to see about finalizing a design for dirty pages in the page cache
that is both generic, and not too open so we can optimize it.

Well that and see about removing some extra layers like the buffer
cache...

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
