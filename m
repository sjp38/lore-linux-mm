Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 556816B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 18:48:43 -0400 (EDT)
Date: Wed, 12 Aug 2009 23:48:27 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap: send callback when swap slot is freed
In-Reply-To: <200908122007.43522.ngupta@vflare.org>
Message-ID: <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
References: <200908122007.43522.ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Aug 2009, Nitin Gupta wrote:

> Currently, we have "swap discard" mechanism which sends a discard bio request
> when we find a free cluster during scan_swap_map(). This callback can come a
> long time after swap slots are actually freed.
> 
> This delay in callback is a great problem when (compressed) RAM [1] is used
> as a swap device. So, this change adds a callback which is called as
> soon as a swap slot becomes free. For above mentioned case of swapping
> over compressed RAM device, this is very useful since we can immediately
> free memory allocated for this swap page.
> 
> This callback does not replace swap discard support. It is called with
> swap_lock held, so it is meant to trigger action that finishes quickly.
> However, swap discard is an I/O request and can be used for taking longer
> actions.
> 
> Links:
> [1] http://code.google.com/p/compcache/

Please keep this with compcache for the moment (it has no other users).

I don't share Peter's view that it should be using a more general
notifier interface (but I certainly agree with his EXPORT_SYMBOL_GPL).
There better not be others hooking in here at the same time (a BUG_ON
could check that): in fact I don't even want you hooking in here where
swap_lock is held.  Glancing at compcache, I don't see you violating
lock hierarchy by that, but it is a worry.

The interface to set the notifier, you currently have it by swap type:
that would better be by bdev, wouldn't it?  with a search for the right
slot.  There's nowhere else in ramzswap.c that you rely on swp_entry_t
and page_private(page), let's keep such details out of compcache.

But fundamentally, though I can see how this cutdown communication
path is useful to compcache, I'd much rather deal with it by the more
general discard route if we can.  (I'm one of those still puzzled by
the way swap is mixed up with block device in compcache: probably
because I never found time to pay attention when you explained.)

You're right to question the utility of the current swap discard
placement.  That code is almost a year old, written from a position
of great ignorance, yet only now do we appear to be on the threshold
of having an SSD which really supports TRIM (ah, the Linux ATA TRIM
support seems to have gone missing now, but perhaps it's been
waiting for a reality to check against too - Willy?).

I won't be surprised if we find that we need to move swap discard
support much closer to swap_free (though I know from trying before
that it's much messier there): in which case, even if we decided to
keep your hotline to compcache (to avoid allocating bios etc.), it
would be better placed alongside.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
