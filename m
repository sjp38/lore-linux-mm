Message-ID: <419D5E09.20805@yahoo.com.au>
Date: Fri, 19 Nov 2004 13:44:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: fast path for anonymous memory allocation
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com> <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 19 Nov 2004, Nick Piggin wrote:
> 
> 
>>Ahh, you're doing clear_user_highpage after the pte is already set up?
> 
> 
> The huge page code also has that optimization. Clearing of pages
> may take some time which is one reason the kernel drops the page table
> lock for anonymous page allocation and then reacquires it. The patch does
> not relinquish the lock on the fast path thus the move outside of the
> lock.
> 

But you're doing it after you've set up a pte for that page you are
clearing... I think? What's to stop another thread trying to read or
write to it concurrently?

> 
>>Won't that be racy? I guess that would be an advantage of my approach,
>>the clear_user_highpage can be done first (although that is more likely
>>to be wasteful of cache).
> 
> 
> If you do the clearing with the page table lock held then performance will
> suffer.
> 

Yeah very much, but if you allocate and clear a "just in case" page
_before_ taking any locks for the fault then you'd be able to go
straight through do_anonymous_page.

But yeah that has other issues like having a spare page per CPU (maybe
not so great a loss), and having anonymous faults much more likely to
get pages which are cache cold.

Anyway, glad to see your patches didn't improve things: now we don't
have to think about making *more* tradeoffs :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
