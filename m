Date: Mon, 08 Jul 2002 21:28:32 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <1214790647.1026163711@[10.10.2.3]>
In-Reply-To: <3D2A55D0.35C5F523@zip.com.au>
References: <3D2A55D0.35C5F523@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> It's a bit weird that copy_strings is the heaviest user of kmap().

I can dig out the whole acg, and see what was calling copy_strings,
that might help give us a clue.

> I bet it's kmapping the same page over and over.  A little cache
> there will help.  I'll fix that up.

Sounds like a plan ...

> So here's the patch.  Seems to work.  Across a `make -j6 bzImage'
> the number of calls to kmap_high() went from 490,429 down to 41,174.
> 
> And guess what?   Zero change in wallclock time.

Well, I was going to try to bench this tonight, but am having a
problem with 2.5.25 right now (we've been on 2.4 for a while,
but are shifting). Hopefully get you some numbers tommorow, and 
will get some other benchmarks done by people here on various 
machines.

> Any theories?

Maybe the cost of the atomic kmap counters the gain? Having to do a 
single line tlbflush every time ... a per cpu pool might help if that
is the problem, but would have to make it a reasonable size to counter
the cost. I'll do some more measurements first, and get some profile
data to see if the number of ticks changes down in one function and
up in the other?

Thanks to all for looking at this,

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
