Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA15772
	for <linux-mm@kvack.org>; Mon, 20 Jul 1998 05:17:38 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> 	<m190lxmxmv.fsf@flinx.npwt.net> 	<199807141730.SAA07239@dax.dcs.ed.ac.uk> 	<m14swgm0am.fsf@flinx.npwt.net> <87d8b370ge.fsf@atlas.CARNet.hr> <m1pvf3jeob.fsf@flinx.npwt.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 20 Jul 1998 11:15:12 +0200
In-Reply-To: ebiederm+eric@npwt.net's message of "18 Jul 1998 11:40:20 -0500"
Message-ID: <87hg0c6fz3.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm+eric@npwt.net (Eric W. Biederman) writes:

> >>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> 
> Let me just step back a second so I can be clear:
> 
> A) The idea proposed by Stephen way perhaps we could use Least
> Recently Used lists instead of page aging.  It's effectively the same
> thing but shrink_mmap can find the old pages much much faster, by
> simply following a linked list.

Well, it looks like a good idea.

> 
> B) This idea intrigues me because handling of generic dirty pages
> I have about the same problem.  In cloneing bdflush for the page cache
> I discovered two fields I would need to add to struct page to do an
> exact cloning job.  A page writetime, and LRU list pointers for dirty
> pages.  I went ahead and implemented them, but also implemented an
> alternative, which is the default.
> 

I don't know how much impact does adding a few fields in the struct
page has on the performance.

Why don't you just add that two fields, so we can see what happens.

I don't know if its easy, but we probably should get rid of buffer
cache completely, at one point in time. It's hard to balance things
between two caches, not to mention other memory objects in kernel.

If page cache is ever to replace buffer cache, it will definitely need
some parts of already established mechanisms and data types that
buffer cache has now.

On the other side, I must admit that I didn't saw any more
fragmentation with page aging. It's just that memory gets used in
weird ways, when it's on, and there's lots of unneeded swapping.

Then again, I have made some changes that make my system very stable
wrt memory fragmentation:

#define SLAB_MIN_OBJS_PER_SLAB  1
#define SLAB_BREAK_GFP_ORDER    1

in mm/slab.c

I discussed this privately with slab maintainer Mark Hemment, where
he pointed out that with this setting slab is probably not as
efficient as it could be. Also, slack is bigger, obviously.

I didn't completely understand all reasons why this could be slower,
and I must admit that I can't see any bad impact on the performance.
I did really lots of benchmarking.

5.5MB/sec through two 100MBps NICs via router and straight to cheap
IDE disk on low end Pentium is not what you call a bad performance. :)

But system is much more stable, and it is now very *very* hard to get
that annoying "Couldn't get a free page..." message than before (with
default setup), when it was as easy as clicking a button in the
Netscape.

I even have some custom scripts that make lots of FTP connections to
fast sites, as that was proven to block my system quite easily before.

> So on any discussion with LRU lists I'm terribly interested.
> As soon as I get the time I'll even implement the more general case.
> Mostly I just need to get my computer moved to where I am at so I can
> code when I have free time :)
> 

I hope you that you have found a nice place to live.
So that you can get happy and make loads of great code. :)

> What I have now are controled by the defines I added to
> include/linux/mm.h with my shmfs patches.
> #undef USE_PG_FLUSHTIME  (This tells sync_old_pages when to stop)
> #undef USE_PG_DIRTY_LIST (Define this for a first pass at an LRU list
> for dirty pages)
> 
> If nothing else it's worth trying to see if it improves my write times
> which fall way behind the read times, on Zlato's benchmark :(
> 

As I alredy said, it will be my pleasure to test things and say my
comments. I spent lots of time tweaking here and there and measuring
not only performance, but stability, too.

Half a year ago, my system was really unstable, thanks to memory
fragmentation. I was occasionaly logged via XDM, and had to kill the
whole session (Ctrl-Alt-BS), because everything would stall, after
initial "Couldn't get a free page...".

Than I got annoyed with that, and tried to find a solution, or at
least a workaround... :)

> If I can talk Zlatko or someone into looking at these it would be
> nice.  I really need to get my own copy of bonnie and a few other
> benchmarks...
> 

I'll send you a copy of bonnie source in another private mail.

> ZC> Next week, I will test some ideas which possibly could improve things
> ZC> WITH page aging.
> 
> ZC> I must admit, after lot of critics I made upon page aging, that I
> ZC> believe it's the right way to go, but it should be done properly.
> ZC> Performance should be better, not worse.
> 
> Agreed.  We should look very carefully though to see if any aging
> solution increases fragmentation.  According to Stephen the current
> one does, and this may be a natural result of aging and not just a
> single implementation :(
> 

Speaking of low memory machines, I thinks that inode memory is much
bigger problem there. I had opportunity to test 2.1.x series on 5MB
386DX40, and system runs nothing near perfection. :(

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	"640K ought to be enough for anybody." Bill Gates '81
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
