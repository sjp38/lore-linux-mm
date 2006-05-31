Message-ID: <447CE1A3.60507@yahoo.com.au>
Date: Wed, 31 May 2006 10:21:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD9CE.2020505@yahoo.com.au> <Pine.LNX.4.64.0605301911480.10355@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605301911480.10355@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 30 May 2006, Nick Piggin wrote:
> 
>>But for 2.6.17, how's this?
> 
> 
> It was a great emperor's-clothes-like discovery.  But we've survived
> for so many years without noticing, does it have to be fixed right
> now for 2.6.17?  (I bet I'd be insisting yes if I'd found it.)

It's up to Linus and Andrew I guess. I don't see why not, but I
don't much care one way or the other. But thanks having a quick
look at it, we may want it for the Suse kernel.

> 
> The thing I don't like about your lock_page_nosync (reasonable as
> it is) is that the one case you're using it, set_page_dirty_nolock,
> would be so much happier not to have to lock the page in the first
> place - it's only doing _that_ to stabilize page->mapping, and the
> lock_page forbids it from being called from anywhere that can't
> sleep, which is often just where we want to call it from.  Neil's
> suggestion, using a spin_lock against the mapping changing, would
> help there; but seems like more work than I'd want to get into.

But making PG_lock a spinning lock is completely unrelated to the
bug at hand.

> 
> So, although I think lock_page_nosync fixes the bug (at least in
> that one place we've identified there's likely to be such a bug),
> it seems to be aiming at the wrong target.  I'm pacing and thinking,
> doubt I'll come up with anything better, please don't hold breath.

It is the correct target. I know all about your set_page_dirty_lock
problems, but they aren't what I'm trying to fix.

AFAIKS, you could also make set_page_dirty_lock non sleeping quite
easily by making inode slabs RCU freed.

What places want to use set_page_dirty_lock without sleeping?
The only place in drivers/ apart from sg/st that SetPageDirty are
rd.c and via_dmablit.c, both of which look OK, if a bit crufty.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
