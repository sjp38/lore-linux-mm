Message-ID: <3B04BA0D.8E0CAB90@mindspring.com>
Date: Thu, 17 May 2001 22:58:37 -0700
From: Terry Lambert <tlambert2@mindspring.com>
Reply-To: tlambert2@mindspring.com
MIME-Version: 1.0
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.33.0105161439140.18102-100000@duckman.distro.conectiva> <200105161754.f4GHsCd73025@earth.backplane.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

Matt Dillon wrote:
>     Terry's description of 'ld' mmap()ing and doing all
>     sorts of random seeking causing most UNIXes, including
>     FreeBSD, to have a brainfart of the dataset is too big
>     to fit in the cache is true as far as it goes, but
>     there really isn't much we can do about that situation
>     'automatically'.  Without hints, the system can't predict
>     the fact that it should be trying to cache the whole of
>     the object files being accessed randomly.  A hint could
>     make performance much better... a simple madvise(...
>     MADV_SEQUENTIAL) on the mapped memory inside LD would
>     probably be beneficial, as would madvise(... MADV_WILLNEED).

I don't understand how either of those things could help
but make overall performance worse.

The problem is the program in question is seeking all
over the place, potentially multiple times, in order
to avoid building the table in memory itself.

For many symbols, like "printf", it will hit the area
of the library containing their addresses many, many
times.

The problem in this case is _truly_ that the program in
question is _really_ trying to optimize its performance
at the expense of other programs in the system.

The system _needs_ to make page-ins by this program come
_at the expense of this program_, rather than thrashing
all other programs out of core, only to have the quanta
given to these (now higher priority) programs used to
thrash the pages back in, instead of doing real work.

The problem is what to do about this badly behaved program,
so that the system itself doesn't spend unnecessary time
undoing its evil, and so that other (well behaved) programs
are not unfairly penalized.

Cutler suggested a working set quota (first in VMS, later
in NT) to deal with these programs.

-- Terry
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
