Date: Thu, 27 Apr 2000 14:22:11 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.3.x mem balancing
Message-ID: <20000427142211.U3792@redhat.com>
References: <Pine.LNX.4.21.0004261410350.16202-100000@duckman.conectiva> <Pine.LNX.4.10.10004261019170.756-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10004261019170.756-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Wed, Apr 26, 2000 at 10:24:55AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 10:24:55AM -0700, Linus Torvalds wrote:
> 
> On Wed, 26 Apr 2000, Rik van Riel wrote:
> > > 
> > > And that subtle issue is that in order for the buddy system to work for
> > > contiguous areas, you cannot have "free" pages _outside_ the buddy system.
> > 
> > This is easy to fix. We can keep a fairly large amount (maybe 4
> > times more than pages_high?) amount of these "free" pages on the
> > queue.
> 
> Note that there are many work-loads that normally have a ton of dirty
> pages. Under those kinds of work-loads it is generally hard to keep a lot
> of "free" pages around, without just wasting a lot of time flushing them
> out all the time.

You have an instant win if the second-chance list is protected by an 
interrupt-safe spinlock.  Do that, and you basically don't ever need 
any free pages at all.  An atomic allocation can go throught the second-
chance list freeing pages until either a buddy page of the required
order becomes available, or we exhaust the list.

With a second-chance list of the same size as our current free page
goals, we'd have exactly the same chance as today of finding a high-
order page.  The advantage would be that our current pessimistic 
free-page management would become truly a lazy reclaim mechanism, 
never freeing a page until it is absolutely necessary.

The cost, of course, is a slightly longer latency while allocating 
memory in interrupts: we've moved some of the kswapd work into the
interrupt itself.  The overall system CPU time, however, should be
reduced if we can avoid unnecessarily freeing pages.

> The other danger with the 'almost free' pages is that it really is very
> load-dependent, and some loads have lots of easily free'd pages.

We have that today.  Whether we are populating the free list or the
last-chance list, we're still having to make that judgement.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
