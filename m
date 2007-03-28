Date: Wed, 28 Mar 2007 20:51:22 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: kswapd freed a swap space?
In-Reply-To: <460AAB83.4080306@redhat.com>
Message-ID: <Pine.LNX.4.64.0703282035450.676@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703281808410.20922@blonde.wat.veritas.com>
 <460AAB83.4080306@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Mar 2007, Rik van Riel wrote:
> Hugh Dickins wrote:
> 
> Not sure how to trigger that in a benchmark though - it seems
> more like a typical week old desktop that has some things
> lingering in the swap cache state for days on end...

That seems plausible to me, but I'm now a bit wary of what seems
plausible!

> 
> > Why did pagevec_swap_free end up freeing so little?  I guess
> > because the vm_swap_full remove_exclusive_swap_page in do_swap_page
> > was successfully freeing so much.  But also, because of another
> > (incomplete) patch I've had around for months, which I added in
> > to the instrumentation: when do_wp_page decides it can use the
> > swapcache page directly, isn't that a very good time to remove
> > from swapcache?  
> 
> That sounds like a good idea.  I wonder if it should be
> conditional on vm_swap_full()...

No, I don't think so (and I wasn't making it conditional on
vm_swap_full in the test): if the swap write locality works out
as expected, then it's goodness whether vm_swap_full or not.

I'd better not pretend to remember what numbers I got when I
tested just that change a couple of months ago, should try it
again: it was good on some simple things, no difference on others;
but good from a vm_swap_full point of view even when it gives no
speedup.

> 
> > Perhaps Rik can offer some very different results to support
> > his patch; but if not, I think drop it (and your debug) from
> > mm for now.
> 
> Drop just the swap freeing from the active list rotation,
> or also the activate_locked: path (which was effective in
> your measurements) ?

I was meaning drop the patch+debug currently in -mm, and you
or I add back the activate_locked mod whenever: do go ahead.

(Suddenly wonder whether I counted that path before relaxing
the page_count restriction in remove_exclusive: I think I did,
I think that one works without modification, but I ought to
recheck tomorrow if you don't first.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
