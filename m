Date: Thu, 28 Sep 2000 07:08:51 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <20000927155608.D27898@athlon.random>
Message-ID: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2000, Andrea Arcangeli wrote:
> On Wed, Sep 27, 2000 at 10:11:43AM +0200, Christoph Rohland wrote:
> > I just checked one oracle system and it did not lock the memory. And I
> 
> If that memory is used for I/O cache then such memory should
> released when the system runs into swap instead of swapping it
> out too (otherwise it's not cache anymore and it could be slower
> than re-reading from disk the real data in rawio).

It could also be faster. If the database spent half an hour
gathering pieces of data from all over the database, it might
be faster to keep it in one place in swap so it can be read
in again in one swoop.  (I had an interesting talk about this
with a database person while at OLS)

But that's not the point. If your assertion is true, then the
database will probably be using an mlock()ed SHM region and
taking care of this itself. But this is not something the OS
should prescribe to the application.

If the OS finds that certain SHM pages are used far less than
the pages in the I/O cache, then those SHM pages should be
swapped out. The system's job is to keep the most used pages
of data in memory to minimise the amount of page faults
happening. Trying to outsmart the application shouldn't (IHMO
of course) be part of that job...

> > Customers with performance problems very often start with too little
> > memory, but they cannot upgrade until this really big job finishes :-(
> > 
> > Another issue about shm swapping is interactive transactions, where
> > some users have very large contexts and go for a coffee before
> > submitting. This memory can be swapped. 
> 
> Agreed, that's why I said shm performance under swap is very important
> as well (I'm not understimating it).
> 
> But again: if the shm contains I/O cache it should be released
> and not swapped out.  Swapping out shmfs that contains I/O cache
> would be exactly like swapping out page-cache.

The OS has no business knowing what's inside that SHM page.
IF the shm contains I/O cache, maybe you're right. However,
until you know that this is the case, optimising for that
situation just doesn't make any sense.

(unless the SHM users tell you that this is the normal way
they use SHM ... but as Christoph just told us, it isn't)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
