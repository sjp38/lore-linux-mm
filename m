Message-ID: <419D8C07.9040606@yahoo.com.au>
Date: Fri, 19 Nov 2004 17:00:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: another approach to rss : sloppy rss
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <419D47E6.8010409@yahoo.com.au> <Pine.LNX.4.58.0411181711130.834@schroedinger.engr.sgi.com> <419D4EC7.6020100@yahoo.com.au> <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181834260.1421@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 19 Nov 2004, Nick Piggin wrote:
> 
> 
>>What do you think a per-mm flag to switch between realtime and lazy rss?
> 
> 
> Yes thats what the patch has.
> 

OK.

> 
>>The only code it would really _add_ would be your mm counting function...
>>I guess another couple of branches in the fault handlers too, but I don't
>>know if they'd be very significant.
> 
> 
> You would need to add hooks to all uses of rss. That adds additional code
> to the critical paths.
> 
> 

It would be an extra branch for each use of rss, yes.

I'm probably going to abstract out direct access to rss anyway (for the
abstracted page table locking patch - so eg. the fully locked system needn't
use atomics).

So after that, you could do it without much intrusiveness. If it is any
consolation, the flag would be read mostly and easily predictable. And you
could make the lazy-rss a CONFIG option as well, which would remove the
cost in the common case.



Just coming back to your sloppy rss patch - this thing will of course allow
unbounded error to build up. Well, it *will* be bounded by the actual RSS if
we assume the races can only cause rss to be underestimated. However, such an
assumption (I think it is a safe one?) also means that rss won't hover around
the correct value, but tend to go increasingly downward.

On your HPC codes that never reclaim memory, and don't do a lot of mapping /
unmapping I guess this wouldn't matter... But a long running database or
something?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
