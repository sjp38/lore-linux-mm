Date: Tue, 26 Sep 2000 19:10:27 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000926191027.A16692@athlon.random>
References: <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com> <20000925190347.E27677@athlon.random> <20000925190657.N2615@redhat.com> <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com> <20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qww7l7z86qo.fsf@sap.com>; from cr@sap.com on Tue, Sep 26, 2000 at 06:20:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 06:20:47PM +0200, Christoph Rohland wrote:
> O.K. that sound more reasonable. I was reading image as program
> text... and a 1.5GB program text is a something I never have seen (and
> hopefully will never see :-)

:)

>From the shrink_mmap complexity of the algorithm point of view a 1.5GB .text is
completly equal to a MAP_SHARED large 1.5GB or a MAP_PRIVATE large 1.5GB
(it doesn't need to be the .text of the program).

Said that I heard of real world programs that have a .text larger than 2G
(that's why I wasn't very careful to say it doesn't need to be a 1.5G
.text but that any other so large page-cache mapping would have the same
effect).

> > 300M of shm (or 300M of anonymous memory if you prefer) and 200M as
> > filesystem cache?
> 
> I don't really see a reason for fs cache in the application. I think

Infact the application can as well use rawio.

> that parallel applications tend to either share mostly all or nothing,
> but I may be wrong here.

And then at some point you'll run `find /` or `tar mylatestsources.tar.gz
sources/` or updatedb is startedup or whatever. And you don't need more
than 200M of fs cache for that purpose.

Think at the O(N) complexity that we had in si_meminfo (guess why in 2.4.x
`free` say 0 in shared field). It was making impossible to run `xosview` on a
10G box (it was stalling for seconds).

And si_meminfo was only counting 1 field, not rolling pages around
lru grabbing locks and dirtyfing cachelines.

That's a plain complexity/scalability issue as far I can tell, and classzone
solves it completly.  When you run tar with your 1.5G shared mapping in memory
and you happen to hit the low watermark and you need to recycle some byte of
old cache, you'll run as fast as without the mapping in memory. There will be
zero difference in performance.  (just like now if you run `free` on a 10G
machine it runs as fast on a 4mbyte machine)

> I think we fixed this misreading. 

I should have explained things more carefully since the first place sorry.

> But still IMHO you underestimate the importance of shared memory for a
> lot of applications in the high end. There is not only Oracle out
> there and most of the shared memory is _not_ locked.

Well I wasn't claiming that this optimization is very sensitive for DB
applications (at least for DB that doesn't use quite big file mappings).

I know Oracle (and most other DB) are very shm intensive.  However the fact you
say the shm is not locked in memory is really a news to me. I really remembered
that the shm was locked.

I also don't see the point of keeping data cache in the swap. Swap involves SMP
tlb flushes and all the other big overhead that you could avoid by sizing
properly the shm cache and taking it locked.

Note: having very fast shm swapout/swapin is very good thing (infact we
introduced readaround of the swapin and moved shm swapout/swapin locking to the
swap cache in early 2.3.x exactly for that reason). But I just don't think
DBMS needed that.

Note: simulations are completly a different thing (their evolution is not
predicable). Simulations can sure trash shm into swap anytime (but Oracle
shouldn't do that AFIK).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
