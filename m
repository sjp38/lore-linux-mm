Date: Fri, 8 Jun 2001 17:12:11 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081804080.3343-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0106081706260.10744-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
>
> Yes. Now the problem is having swap space allocated with _NO_ pressure
> may sound a bit weird to people. _I_ know that we're just allocating the
> swap space, but not everybody does.

Agreed. I would expect bug reports about "free" showing more swap, even
though nothing necessarily actually got written out to disk.

Note that we've actually already gotten many of those, this has been the
2.4.x behaviour all along. We'd just make it trigger even more easily (ie
without having to have any real pressure at all).

Hmm. Actually, the way 2.4.6-pre2 does things, "swap_out()" is only called
from "refill_inactive()", while the background scanning actually calls
into "refill_inactive_scan()" directly. So pre2 won't be adding stuff to
the swap cache unless there is _some_ kind of pressure on it (namely
"inactive_shortage()").

But it would be interesting to hear what people think of moving the
swap_out() call into refill_inactive_scan() instead of doing it outside..
However, that would further confuse the meaning of the "target" and
"maxscan" in the scanning phase.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
