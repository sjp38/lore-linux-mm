Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA00836
	for <linux-mm@kvack.org>; Wed, 2 Dec 1998 16:19:15 -0500
Subject: Re: [PATCH] swapin readahead
References: <87vhjvkccu.fsf@atlas.CARNet.hr> <Pine.LNX.3.96.981201192554.4046A-100000@mirkwood.dummy.home> <199812021735.RAA04489@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 02 Dec 1998 22:18:58 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 2 Dec 1998 17:35:26 GMT"
Message-ID: <87d862gs3h.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Tue, 1 Dec 1998 19:32:52 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I took the bet that shrink_mmap() would take care of that, but
> > aperrantly not always :(
> 
> shrink_mmap() only gets rid of otherwise unused pages (pages whose count
> is one).  After read_swap_cache_async(), the page count will be three:
> once for the swap cache, once for the io in progress, once for the
> reference returned by read_swap_cache_async().  You need to free that
> last reference explicitly after doing the readahead call.  The io
> reference will be returned once IO completes, and shrink_mmap() will
> take care of the final swap cache reference.
> 

That is exactly what I had in mind, but didn't have time to
investigate further. Nor courage to say that, without trying first. :)

I've been hacking shrink_mmap() and swap_out() most of the time last
few days and in fact completely understood all inner workings of them.
Quite complicated stuff, now I see why it so easily breaks if we
change something aruond.

Trying 2.1.131-2, I'm mostly satisfied with MM workout, but...

Still, I have a feeling that limit imposed on cache growth is now too
hard, unlike kernels from the 2.1.1[01]? era, that had opposite
problems (excessive cache growth during voluminous I/O operations).

What I wanted to ask is: do you guys share my opinion, and what
changes would you like to see before 2.2 comes out?

Thanks for any opinion.
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	"640K ought to be enough for anybody." Bill Gates '81
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
