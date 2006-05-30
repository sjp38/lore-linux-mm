Date: Tue, 30 May 2006 19:31:52 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] remove racy sync_page?
In-Reply-To: <447BD9CE.2020505@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0605301911480.10355@blonde.wat.veritas.com>
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org>
 <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org>
 <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
 <447BD31E.7000503@yahoo.com.au> <447BD9CE.2020505@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, axboe@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 30 May 2006, Nick Piggin wrote:
> 
> But for 2.6.17, how's this?

It was a great emperor's-clothes-like discovery.  But we've survived
for so many years without noticing, does it have to be fixed right
now for 2.6.17?  (I bet I'd be insisting yes if I'd found it.)

The thing I don't like about your lock_page_nosync (reasonable as
it is) is that the one case you're using it, set_page_dirty_nolock,
would be so much happier not to have to lock the page in the first
place - it's only doing _that_ to stabilize page->mapping, and the
lock_page forbids it from being called from anywhere that can't
sleep, which is often just where we want to call it from.  Neil's
suggestion, using a spin_lock against the mapping changing, would
help there; but seems like more work than I'd want to get into.

So, although I think lock_page_nosync fixes the bug (at least in
that one place we've identified there's likely to be such a bug),
it seems to be aiming at the wrong target.  I'm pacing and thinking,
doubt I'll come up with anything better, please don't hold breath.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
