Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA26804
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 09:19:39 -0500
Date: Wed, 25 Nov 1998 14:19:28 GMT
Message-Id: <199811251419.OAA00990@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Linux-2.1.129..
In-Reply-To: <Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com>
References: <199811241525.PAA00862@dax.scot.redhat.com>
	<Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 24 Nov 1998 09:33:11 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Tue, 24 Nov 1998, Stephen C. Tweedie wrote:
>> 
>> Indeed.  However, I think it misses the real advantage, which is that
>> the mechanism would be inherently self-tuning (much more so than the
>> existing code).

> Yes, that's one of the reasons I like it.

> The other reason I like it is that right now it is extremely hard to share
> swapped out pages unless you share them due to a fork(). The problem is
> that the swap cache supports the notion of sharing, but out swap-out
> routines do not - they swap things out on a per-virtual-page basis, and
> that results in various nasty things - we page out the same page to
> multiple places, and lose the sharing. 

No, I fixed that in 2.1.89.  Shared anonymous pages _must_ be COW and
therefore readonly (this is why moving to MAP_SHARED anonymous regions
is so hard).  So, the first process which tries to swap such a shared
page will write it to disk and set up a swap cache entry.  Because the
page is necessarily readonly, we can safely assume it is OK to write it
at this point and not at the point of the last unmapping.

Subsequent processes which pageout the same page will find it in the
swap cache already and will just free the page.  I've tested this with a
program which sets up large anonymous region, forks, and then thrashes
the memory.  On prior kernels we lose the sharing, but on 2.1.89 and
later, that sharing is maintained perfectly even after fork and we never
grow the amount of swap which is used.

> The VM policy changes weren't stability issues, they were only "timing". 
> As such, if they broke something, it was really broken before too. 

Absolutely.

> And I agree that the mechanism is already there, however as it stands we
> really populate the swap cache at page-in rather than page-out, and
> changing that is fairly fundamental. It would be good, no question about
> it, but it's still fairly fundamental. 

We still have to populate the swap cache at page-in time.  The initial
reason for the early swap cache implementation was to prevent us from
having to re-write to disk pages which are still clean in memory.  For
that to work we need to cache the page-in.

However, for pages which become dirty in memory, we _do_ populate the
swap cache only at page-out time.  That's why the sharing still works.
I think that the real change we need is to cleanly support PG_dirty
flags per page.  Once we do that, not only do all of the dirty inode
pageouts get fixed, but we also automatically get MAP_SHARED |
MAP_ANONYMOUS.

While we're on that subject, Linus, do you still have Andrea's patch to
propogate page writes around all shared ptes?  I noticed that Zlatko
Calusic recently re-posted it, and it looks like the sort of short-term
fix we need for this issue in 2.2 (assuming we don't have time to do a
proper PG_dirty fix).

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
