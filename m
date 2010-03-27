Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ADE926B01C7
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 21:09:35 -0400 (EDT)
Date: Sat, 27 Mar 2010 02:08:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
Message-ID: <20100327010818.GI5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <6a19c093c020d009e736.1269622839@v2.random>
 <4BACEBF8.90909@redhat.com>
 <20100326172321.GA5825@random.random>
 <alpine.LSU.2.00.1003262113310.8896@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1003262113310.8896@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 09:32:28PM +0000, Hugh Dickins wrote:
> It's a nice little catch, but you certainly shouldn't have buried it
> amidst 40 other patches unrelated to it!

Yep ;).
 
> I was going to ack that patch and urge you to forward it to Andrew
> separately, but did you test whether it works?  Isn't it actually a
> no-op?  Because KSM is holding page lock across replace_page() (maybe
> that's something I added after you were last there - at the time I did
> it just from instinct, and to make a block look prettier; but later I
> believe it turned out to be necessary), and free_swap_cache() only
> works if trylock_page() succeeds.
> 
> So if we want the fix, I think it would have to be reworked, perhaps
> slightly messier.

An equivalent patch (a lot messier like you said) was tested and
verified for the pre-swap release). Earlier kernels would do nothing
in free_page_and_swap_cache unless it was the last reference (they
checked page_count(page) != 2, instead of page_mapped()). This is why
it was messier in the earlier version for earlier kernel. But I
thought doing this there would work and it would be cleaner
too by taking advantage of the mapcount check in
free_page_and_swap_cache internals.

In the earlier version I'm not doing it inside replace_page so the
page lock wouldn't be a problem anyway, but the older version that I'm
more familiar with, only takes the PG_lock during page_wrprotect! Why
do you keep the PG_lock during replace_page too? do_wp_page can't run
as we re-verify the pte didn't change. Maybe is just to be safer?

> Something needed for -stable?  No, I think not, it's a situation that

Not needed, it's just for statistics and to speedup ksm so that it
won't require to invoke the page reclaim to collect orhpaned swapcache
that has to go away immediately.

> gradually increases memory pressure, and then memory pressure frees it
> (vmscan.c's __delete_from_swap_cache); it never prevents swapoff.
> 
> But it would be nice to fix it all the same: thanks for spotting.

It wasn't me spotting it, I only fixed it for the earlier version and
ported to mainline after verifying the fix works.

Thanks to you for noticing that replace_page now runs under page lock ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
