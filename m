Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA05574
	for <linux-mm@kvack.org>; Sat, 18 Jul 1998 12:25:20 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk>
	<m190lxmxmv.fsf@flinx.npwt.net>
	<199807141730.SAA07239@dax.dcs.ed.ac.uk>
	<m14swgm0am.fsf@flinx.npwt.net> <87d8b370ge.fsf@atlas.CARNet.hr>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 18 Jul 1998 11:40:20 -0500
In-Reply-To: Zlatko Calusic's message of 18 Jul 1998 15:28:17 +0200
Message-ID: <m1pvf3jeob.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

Let me just step back a second so I can be clear:

A) The idea proposed by Stephen way perhaps we could use Least
Recently Used lists instead of page aging.  It's effectively the same
thing but shrink_mmap can find the old pages much much faster, by
simply following a linked list.

B) This idea intrigues me because handling of generic dirty pages
I have about the same problem.  In cloneing bdflush for the page cache
I discovered two fields I would need to add to struct page to do an
exact cloning job.  A page writetime, and LRU list pointers for dirty
pages.  I went ahead and implemented them, but also implemented an
alternative, which is the default.

So on any discussion with LRU lists I'm terribly interested.
As soon as I get the time I'll even implement the more general case.
Mostly I just need to get my computer moved to where I am at so I can
code when I have free time :)

What I have now are controled by the defines I added to
include/linux/mm.h with my shmfs patches.
#undef USE_PG_FLUSHTIME  (This tells sync_old_pages when to stop)
#undef USE_PG_DIRTY_LIST (Define this for a first pass at an LRU list
for dirty pages)

If nothing else it's worth trying to see if it improves my write times
which fall way behind the read times, on Zlato's benchmark :(

If I can talk Zlatko or someone into looking at these it would be
nice.  I really need to get my own copy of bonnie and a few other
benchmarks...

ZC> Next week, I will test some ideas which possibly could improve things
ZC> WITH page aging.

ZC> I must admit, after lot of critics I made upon page aging, that I
ZC> believe it's the right way to go, but it should be done properly.
ZC> Performance should be better, not worse.

Agreed.  We should look very carefully though to see if any aging
solution increases fragmentation.  According to Stephen the current
one does, and this may be a natural result of aging and not just a
single implementation :(

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
