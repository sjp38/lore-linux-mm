Received: from mail.ccr.net (ccr@alogconduit1ab.ccr.net [208.130.159.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA14897
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 13:58:55 -0500
Subject: Re: Linux-2.1.129..
References: <19981119223434.00625@boole.suse.de> 	<Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com> <199811231713.RAA17361@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 Nov 1998 13:16:26 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 23 Nov 1998 17:13:34 GMT"
Message-ID: <m1r9uudxth.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> That would be true if we didn't do the free_page_and_swap_cache trick.
ST> However, doing that would require two passes: once by the swapper, and
ST> once by shrink_mmap(): before actually freeing a page.  This actually
ST> sounds like a *very* good idea to explore, since it means that vmscan.c
ST> will be concerned exclusively with returning mapped and anonymous pages
ST> to the page cache.  As a result, all of the actual freeing of pages will
ST> be done in shrink_mmap(), which is the closest we can get to a true
ST> self-balancing system for freeing memory.

There are a few other reasons this would be useful as well.
1) It resembles a 2 handed clock algorithm.  So there would
  be some real page aging functionality.  And we could reclaim pages
  that we are currently writing to disk.

2) We could remove the swap lock map.

I have wanted to suggest this for a while but I haven't had the time
to carry it through. :(

ST> I'm going to check this out: I'll post preliminary benchmarks and a
ST> patch for other people to test tomorrow.  Getting the balancing right
ST> will then just be a matter of making sure that try_to_swap_out gets
ST> called often enough under normal running conditions.  I'm open to
ST> suggestions about that: we've never tried that sort of behaviour in the
ST> vm to my knowledge.

We might want to look at the balance between the buffer cache writing and
shrink_mmap.  Because that is how those two systems interact already.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
