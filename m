Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA31998
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 12:37:10 -0500
Date: Mon, 11 Jan 1999 17:35:55 GMT
Message-Id: <199901111735.RAA01052@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990111122039.53340@atrey.karlin.mff.cuni.cz>
References: <199901101659.QAA00922@dax.scot.redhat.com>
	<Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
	<199901102249.WAA01684@dax.scot.redhat.com>
	<19990111122039.53340@atrey.karlin.mff.cuni.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@atrey.karlin.mff.cuni.cz>, Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Jan 1999 12:20:39 +0100, Pavel Machek
<pavel@atrey.karlin.mff.cuni.cz> said:

> Hi!
>> In fact, to make it really safe we'd need to avoid synchronous swapout
>> altogether: otherwise we can have
>> 
>> A			kswiod		nbd server process
>> [deadlock]

> Is this only matter of nbd? If so, maybe the best solution is to start
> claiming: "don't swap over nbd, don't mount localhost drives read
> write". [It is bad, but it is probably better than polluting rest of
> kernel with nbd workarounds...]

No.  Any other process which gets in the way of our IO and which blocks
for memory allocation can cause the deadlock.  That might be another
process doing a file IO, locking a buffer and then allocating memory
inside the scsi layers, for example.  It is not limited to nbd, but
nbd's networking use will probably make it particularly bad.

Linus, I've also realised that making semaphores recursive does not fix
the inode deadlock.  It only eliminates the single process case.  We can
still have two separate processes each writing to a separate mmaped()
file deadlock.  If each process starts a msync() on its own file and in
the process of that tries to sync one of the other process's pages via
try_to_free_page, we get the deadlock back.

I can't see any way around this other than to make try_to_free never,
ever block on IO, which implies having a separate page writer thread, or
to rework the code so that we never allocate memory while holding one of
the critical filesystem locks (which is a non-starter for 2.2).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
