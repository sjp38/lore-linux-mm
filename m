Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <20000925003650.A20748@home.ds9a.nl>
	<20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com>
	<20000925190347.E27677@athlon.random>
	<20000925190657.N2615@redhat.com>
	<20000925213242.A30832@athlon.random>
	<20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com>
	<20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com>
	<20000926191027.A16692@athlon.random>
From: Christoph Rohland <cr@sap.com>
Date: 27 Sep 2000 10:11:43 +0200
In-Reply-To: Andrea Arcangeli's message of "Tue, 26 Sep 2000 19:10:27 +0200"
Message-ID: <qwwn1gu6yps.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> writes:

> Said that I heard of real world programs that have a .text larger than 2G

=:-O

> I know Oracle (and most other DB) are very shm intensive.  However
> the fact you say the shm is not locked in memory is really a news to
> me. I really remembered that the shm was locked.

I just checked one oracle system and it did not lock the memory. And I
do not think that the other databases do it by default either.

And our application server doesn't do it definitely. And it uses loads
of shared memory. We will have application servers soon with 16 GB
memory at customer sites which will have the whole memory in shmfs.

> I also don't see the point of keeping data cache in the swap. Swap
> involves SMP tlb flushes and all the other big overhead that you
> could avoid by sizing properly the shm cache and taking it locked.
> 
> Note: having very fast shm swapout/swapin is very good thing (infact
> we introduced readaround of the swapin and moved shm swapout/swapin
> locking to the swap cache in early 2.3.x exactly for that
> reason). But I just don't think DBMS needed that.

Nobody should rely on shm swapping for productive use. But you have
changing/increasing loads on application servers and out of a sudden
you run oom. In this case the system should behave and it is _very_
good to have a smooth behaviour. 

Customers with performance problems very often start with too little
memory, but they cannot upgrade until this really big job finishes :-(

Another issue about shm swapping is interactive transactions, where
some users have very large contexts and go for a coffee before
submitting. This memory can be swapped. 

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
