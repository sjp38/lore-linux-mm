Date: Wed, 26 Apr 2000 10:24:55 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004261410350.16202-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004261019170.756-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 26 Apr 2000, Rik van Riel wrote:
> > 
> > And that subtle issue is that in order for the buddy system to work for
> > contiguous areas, you cannot have "free" pages _outside_ the buddy system.
> 
> This is easy to fix. We can keep a fairly large amount (maybe 4
> times more than pages_high?) amount of these "free" pages on the
> queue. If we are low on contiguous pages, we can bypass the queue
> for these pages or scan memory for pages on this queue (marked with
> as special flag) and take them from the queue...

Note that there are many work-loads that normally have a ton of dirty
pages. Under those kinds of work-loads it is generally hard to keep a lot
of "free" pages around, without just wasting a lot of time flushing them
out all the time.

So I doubt it is "trivial". But it might be somewhere in-between balance,
where you have a heuristic along the lines of "let's try to have enough
'truly free' pages, and if we have lots of 'almost free' pages around we
can somewhat relax the requirements on the 'truly free' page
availability".

The other danger with the 'almost free' pages is that it really is very
load-dependent, and some loads have lots of easily free'd pages. If we
eagerly reap of the 'easily free' component, then that may be extremely
unfair towards one class of users that gets their pages stolen from under
them by another class of users that has less easily freeable pages.. So
fairness may also be an issue.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
