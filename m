Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA04311
	for <linux-mm@kvack.org>; Thu, 3 Dec 1998 05:39:38 -0500
Date: Thu, 3 Dec 1998 11:07:53 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead
In-Reply-To: <m1af15iyp9.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981203110335.4894A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 2 Dec 1998, Eric W. Biederman wrote:
> >>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> 
> ZC> Trying 2.1.131-2, I'm mostly satisfied with MM workout, but...
> 
> ZC> Still, I have a feeling that limit imposed on cache growth is now too
> ZC> hard, unlike kernels from the 2.1.1[01]? era, that had opposite
> ZC> problems (excessive cache growth during voluminous I/O operations).
> 
> My gut reaction is that we need a check in swap_out to see if we have
> written out a swap_cluster or some other indication that we have
> started all of the disk i/o that is reasonable for now and need to
> switch to something else.

     if (buffer_over_borrow() || pgcache_over_borrow())
             state = 0;              
     if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
             shrink_mmap(i, gfp_mask);

I have this piece of code in my vmscan.c in do_try_to_free_page().

It turns out to give the result we all seem to want. It has the
old balancing code (that works) and makes an extra round through
shrink_mmap() when we have been swapping stuff...

Please try it before dismissing :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
