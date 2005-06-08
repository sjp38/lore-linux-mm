Date: Wed, 8 Jun 2005 18:03:16 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
In-Reply-To: <370550000.1117807258@[10.10.2.4]>
Message-ID: <Pine.LNX.4.58.0506081734480.10706@skynet>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
 <429E20B6.2000907@austin.ibm.com><429E4023.2010308@yahoo.com.au>
 <423970000.1117668514@flay><429E483D.8010106@yahoo.com.au>
 <434510000.1117670555@flay><429E50B8.1060405@yahoo.com.au>
 <429F2B26.9070509@austin.ibm.com><1117770488.5084.25.camel@npiggin-nld.site>
 <Pine.LNX.4.58.0506031349280.10779@skynet> <370550000.1117807258@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, jschopp@austin.ibm.com, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Jun 2005, Martin J. Bligh wrote:

> > Does it need more documentation? If so, I'll write up a detailed blurb on
> > how it works and drop it into Documentation/
> >
> >> Although I can't argue that a buddy allocator is no good without
> >> being able to satisfy higher order allocations.
> >
> > Unfortunately, it is a fundemental flaw of the buddy allocator that it
> > fragments badly. The thing is, other allocators that do not fragment are
> > also slower.
>
> Do we care? 99.9% of allocations are fronted by the hot/cold page cache
> now anyway ...

Very true, but only for order-0 allocations. As it is, higher order
allocations are a lot less important because Linux has always avoided them
unless absolutely necessary. I would like to reach the point where we can
reliably allocate large blocks of memory so we do not have to split large
amounts of data into page-sized chunks all the time.

> and yes, I realise that things popping in/out of that
> obviously aren't going into the "defrag" pool, but still, it should help.
> I suppose all we're slowing down is higher order allocs anyway, which
> is the uncommon case, but ... worth thinking about.
>

I did measure it and there is a slow-down on high order allocations which
is not very surprising. The following is the result of a micro-benchmark
comparing the standard and modified allocator for 1500 order-5
allocations.

Standard
     Average          Max          Min       Allocs
     -------          ---          ---       ------
        0.73         1.09         0.53         1476
        1.33         1.87         1.10           23
        2.10         2.10         2.10            1

Modified
     Average          Max          Min       Allocs
     -------          ---          ---       ------
        0.82         1.23         0.60         1440
        1.36         1.96         1.23           57
        2.42         2.92         2.09            3

The average, max and min are in 1000's of clock cycles for an allocation
so there is not a massive difference between the two allocators. Aim9
still shows that overall, the modified allocator is as fast as the normal
allocator.

High order allocations do slow down a lot when under memory pressure and
neither allocator performs very well although the modified allocator
probably performs worse as it has more lists to search. In the case of the
placement policy though, I can work on the linear scanning patch to avoid
using a blunderbuss on memory. With the standard allocator, linear scanning
will not help significantly because non-reclaimable memory is scattered
all over the place.

I have also found that the modified allocator can fairly reliably allocate
memory on a desktop system which has been running a full day where the
standard allocator cannot. However, that experience is subjective and
benchmarks based on loads like kernel compiles will not be anything like a
desktop system. At the very least, kernel compiles, while they load the
system, will not pin memory used for PTEs like a desktop running
long-lived applications would.

I'll work on reproducing scenarios that show where the standard allocator
fails to allocate large blocks of memory without paging everything out
that the placement policy works with.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
