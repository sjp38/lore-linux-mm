Date: Mon, 25 Sep 2000 16:46:35 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925164635.P22882@athlon.random>
References: <20000925161358.J22882@athlon.random> <Pine.LNX.4.21.0009251628030.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251628030.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 04:29:42PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:29:42PM +0200, Ingo Molnar wrote:
> There is no guarantee at all that the reader will win. If reads and writes
> racing for request slots ever becomes a problem then we should introduce a
> separate read and write waitqueue.

I agree. However here I also have a in flight per-queue limit of locked stuff
(otherwise with 512k sized request on scsi I could fill in some second 128mbyte
of RAM locked and I don't want to decrease the size of the queue because it has
to be large for aggressive reordering when the request are 4k large each).
This in-flight-perqueue limit is actually a non exclusive wakeup and it
triggers more often than the request shortage (because most of the time write
are consecutive) and so having two waitqueues and the reads that reigsters
themself into both shouldn't be very significative improvement at the moment (I
should first care about a wake-one in-flight-limit-per-queue wakeup :).

> the EXCLUSIVE thing was noticed by Dimitris i think, and it makes tons of

Actually I'm the one who introduced the EXCLUSIVE thing there and I audited
_all_ the device drivers to check they do 1 wakeup for each 1 request they
release before sending it off Linus. But I never thought (until some day ago)
about the fact that if a read completes a reserved request the write won't be
able to accept it.

So long term we'll do two wake-one queues with reads registered in both.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
