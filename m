Date: Mon, 25 Sep 2000 09:46:18 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.21.0009251608570.9122-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10009250940540.1739-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jens Axboe <axboe@suse.de>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Ingo Molnar wrote:
> > 
> > And a new elevator was introduced some months ago to solve this.
> 
> and these are still not solved in the vanilla kernel, as recent complaints
> on l-k prove.

THE ELEVATOR IS PROBABLY NOT THE PROBLEM.

People blame the elevator for bad IO performance. But the elevator is just
doing what it's told to do - and if it is told to do something bad, it
will do something bad.

The "something bad" is doing things like writing out 4 dicsontiguous
pages, waiting a while, and then writing out 4 more discontiguous pages.

There's nothing the elevator can do for that case - except just ignore the
write requests completely, and wait for more requests to come in. Which it
certainly could do, but that's really a policy question and should be
handled at a higher level. The elevator doesn't know if there is going to
be more writes.

In short, I bet that the problem is at least partly that bdflush is
broken, and doesn't do a good job of streaming writes. It's probably been
broken to get low latencies, and in order to avoid "choppy" behaviour. But
the elevator works _best_ with choppy behaviour, when there's a BIG stream
of requests at a time.

Blaming the elevator is unfair and unrealistic. Look at the performance
reports - there was a good test-case that showed that read-performance was
fine but that writes to different parts of the filesystem just suck. Which
is _exactly_ what you'd expect if the elevator was fine but the writes
were blocked up by higher levels.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
