Date: Sun, 28 Oct 2001 09:59:14 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
In-Reply-To: <E15xu2b-0008QL-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33.0110280945150.7360-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2001, Alan Cox wrote:
>
> > Does the -ac patches have any hpt366-specific stuff? Although I suspect
> > you're right, and that it's just the driver (or controller itself) being
>
> The IDE code matches between the two. It isnt a driver change

It might, of course, just be timing, but that sounds like a bit _too_ easy
an explanation. Even if it could easily be true.

The fact that -ac gets higher speeds, and -ac has a very different
request watermark strategy makes me suspect that that might be the cause.

In particular, the standard kernel _requires_ that in order to get good
performance you can merge many bh's onto one request. That's a very
reasonable assumption: it basically says that any high-performance driver
has to accept merging, because that in turn is required for the elevator
overhead to not grow without bounds. And if the driver doesn't accept big
requests, that driver cannot perform well because it won't have many
requests pending.

In contrast, the -ac logic says roughly "Who the hell cares if the driver
can merge requests or not, we can just give it thousands of small requests
instead, and cap the total number of _sectors_ instead of capping the
total number of requests earlier".

In my opinion, the -ac logic is really bad, but one thing it does allow is
for stupid drivers that look like high-performance drivers. Which may be
why it got implemented.

And it may be that the hpt366 IDE driver has always had this braindamage,
which the -ac code hides. Or something like this.

Does anybody know the hpt driver? Does it, for example, limit the maximum
number of sectors per merge somehow for some reason?

Jens?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
