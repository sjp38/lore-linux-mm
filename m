Date: Fri, 19 Nov 2004 11:21:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: another approach to rss : sloppy rss
In-Reply-To: <419D8C07.9040606@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411191116480.24095@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com>
 <419D4EC7.6020100@yahoo.com.au> <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com>
 <419D8C07.9040606@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2004, Nick Piggin wrote:

> Just coming back to your sloppy rss patch - this thing will of course allow
> unbounded error to build up. Well, it *will* be bounded by the actual RSS if
> we assume the races can only cause rss to be underestimated. However, such an
> assumption (I think it is a safe one?) also means that rss won't hover around
> the correct value, but tend to go increasingly downward.
>
> On your HPC codes that never reclaim memory, and don't do a lot of mapping /
> unmapping I guess this wouldn't matter... But a long running database or
> something?

Databases preallocate memory on startup and then manage memory themselves.
One reason for this patch is that these applications cause anonymous page
fault storms on startup given lots of memory which will make
the system seem to freeze for awhile.

It is rare for a program to actually free up memory.

Where this approach could be problematic is when the system is under
heavy swap load. Pages of an application will be repeatedly paged in and
out and therefore rss will be incremented and decremented. But in those
cases these incs and decs are not done in a way that is on purpose
parallel like in my test programs. So I would expect rss to be more
accurate than in my tests.

I think the sloppy rss approach is the right way to go.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
