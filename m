Date: Thu, 7 Jun 2001 13:51:05 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106071330060.6510-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0106071345190.6604-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Forgot one comment..

> > This is going to make all pages have age 0 on an idle system after some
> > time (the old code from Rik which has been replaced by this code tried to 
> > avoid that)

There's another reason why I think the patch may be ok even without any
added logic: not only does it simplify the code and remove a illogical
heuristic, but there is nothing that really says that "age 0" is
necessarily very bad.

We should strive to keep the active/inactive lists in LRU order anyway, so
the ordering does tell you something about how recent (and thus how
important) the page is. Also, it's certainly MUCH preferable to let pages
age down to zero, than to let pages retain a maximum age over a long time,
like the old code used to do.

If, after long periods of inactivity, we start needing fresh pages again,
it's probably actually an _advantage_ to give the new pages a higher
relative importance. Caches tend to lose their usefulness over time, and
if the old cached pages are really relevant, then the new spurt of usage
will obviously mark them young again.

And if, after the idle time, the behaviour is different, the old pages
have appropriately been aged down and won't stand in the way of a new
cache footprint.

Do you actually have regular usage that shows the age-down to be a bad
thing? 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
