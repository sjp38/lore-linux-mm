Date: Tue, 7 Aug 2001 14:33:44 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108071245250.30280-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0108071425590.1434-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Ben LaHaise wrote:
> > Try pre4.
>
> It's similarly awful (what did you expect -- there are no meaningful
> changes between the two!).  io throughput to a 12 disk array is humming
> along at a whopping 40MB/s (can do 80) that's very spotty and jerky,
> mostly being driven by syncs.

How about some sane approach to "balace_dirty()", like in -pre6.

The sane approach to balance_dirty() is to
 - when we're over the threshold of dirty, but not over the hard limit, we
   start IO. We don't wait for it (except in the sense that if we overflow
   the request queue we will _always_ wait for it, of course. No way to
   avoid that).
 - if we're over the hard limit, we wait for the oldest buffer on the
   locked list.

The only question is "when should we wake up bdflush?" I currently wake it
up any time we're over the soft limit, but I have this feeling that we
really should wait until we're over the hard limit - oherwise we might end
up dribbling again. I haven't tried it, but I will. Others please do too -
its trivially moving the wakeup around in fs/buffer.c: balance_dirty().

At least here it gives quite good results, and was rather usable even
under X when writing a 8GB file. I haven't seen this disk push 20MB/s
sustained before, and it did now (except when I was doing other things at
the time).

Will it keep the IO queues full as hell and make interactive programs
suffer? Yes, of course it will. No way to avoid the fact that reads are
going to be slower if there's a lot of writes going on. But I didn't see
vmstat hickups or anything like that.

Of course, this will depend on machine and on disk controller etc. Which
is why it would be good to test..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
