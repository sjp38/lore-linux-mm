Date: Mon, 9 Sep 2002 16:25:17 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <3D7CF077.FB251EC7@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209091622470.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> > On Mon, 9 Sep 2002, Andrew Morton wrote:
> >
> > > I fiddled with it a bit:  did you forget to move the write(2) pages
> > > to the inactive list?  I changed it to do that at IO completion.
> > > It had little effect.  Probably should be looking at the page state
> > > before doing that.
> >
> > Hmmm indeed, I forgot this.  Note that IO completion state is
> > too late, since then you'll have already pushed other pages
> > out to the inactive list...
>
> OK.  So how would you like to handle those pages?

Move them to the inactive list the moment we're done writing
them, that is, the moment we move on to the next page. We
wouldn't want to move the last page from /var/log/messages to
the inactive list all the time ;)

> > > The inactive list was smaller with this patch.  Around 10%
> > > of allocatable memory usually.
> >
> > It should be a bit bigger than this, I think.  If it isn't
> > something may be going wrong ;)
>
> Well the working set _was_ large.  Sure, we'll be running refill_inactive
> a lot.  But spending some CPU in there with this sort of workload is the
> right thing to do, if it ends up in better replacement decisions.  So
> it doesn't seem to be a problem per-se?

OK, in that case there's no problem.  If the working set
really does take 90% of RAM that's a good thing to know ;)

> Generally, where do you want to go with this code?

If this code turns out to be more predictable and better
or equal performance to use-once, I'd like to see it in
the kernel.  Use-once seems just too hard to tune right
for all workloads.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
