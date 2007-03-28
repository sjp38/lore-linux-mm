Message-ID: <460AAB83.4080306@redhat.com>
Date: Wed, 28 Mar 2007 13:53:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd freed a swap space?
References: <Pine.LNX.4.64.0703281808410.20922@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0703281808410.20922@blonde.wat.veritas.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> (Whereas the simple vm_swap_full remove_exclusive_swap_page which
> Rik added at activate_locked was an order of magnitude more
> successful: not a major route, but still worth doing.)

I'm guessing this depends on the workload, too.  With longer
running jobs, we may have more pages staying on the active
list after being swapped out once, while swap fills up with
unrelated things.

Not sure how to trigger that in a benchmark though - it seems
more like a typical week old desktop that has some things
lingering in the swap cache state for days on end...

> Why did pagevec_swap_free end up freeing so little?  I guess
> because the vm_swap_full remove_exclusive_swap_page in do_swap_page
> was successfully freeing so much.  But also, because of another
> (incomplete) patch I've had around for months, which I added in
> to the instrumentation: when do_wp_page decides it can use the
> swapcache page directly, isn't that a very good time to remove
> from swapcache?  

That sounds like a good idea.  I wonder if it should be
conditional on vm_swap_full()...

> Perhaps Rik can offer some very different results to support
> his patch; but if not, I think drop it (and your debug) from
> mm for now.

Drop just the swap freeing from the active list rotation,
or also the activate_locked: path (which was effective in
your measurements) ?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
