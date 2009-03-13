Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 192416B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:34:36 -0400 (EDT)
Date: Fri, 13 Mar 2009 20:34:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090313193416.GG27823@random.random>
References: <20090311170611.GA2079@elte.hu> <200903130420.28772.nickpiggin@yahoo.com.au> <20090312180648.GV27823@random.random> <200903140309.39777.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903140309.39777.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 14, 2009 at 03:09:39AM +1100, Nick Piggin wrote:
> Of course I could have a race in fast-gup, but I don't think I can see
> one. I'm working on removing the vma stuff and just making it per-page,
> which might make it easier to review.

If you didn't touch gup-fast and you don't send ipis in fork, you most
certainly have one, it's the one Linus pointed out and that I've fixed
(with Izik, then I sorted out the ordering details and how to make it
safe on frok side).

> Well, it would save having to touch the parent's pagetables after
> doing the atomic copy-on-fork in the child. Just have the parent do
> a do_wp_page, which will notice it is the only user of the page and
> reuse it rather than COW it (now that Hugh has fixed the races in
> the reuse check that should be fine).

If we're into the trouble path, it means parent already owns the
page. I just leave it owned to the parent, pte remains the same before
and after fork. No point in changing the pte value if we're in the
troublesome path as far as I can tell. I only verify that the parent pte
didn't go away from under fork when I temporarily release the parent
PT lock to allocate the cow page in the slow path (see the -EAGAIN
path, I also verified it triggers with swapping and system survives fine ;).

> Now I also see that your patch still hasn't covered the other side of
> the race, wheras my scheme should do. Hmm, I think that if we want to

Sorry, but can you elaborate again what the other side of the race is?

If child gets a whole new page, and parent keeps its own page with pte
marked read-write the whole time that a page fault can run (page fault
takes mmap_sem, all we have to protect against when temporarily
releasing parent PT lock is the VM rmap code and that is taken care of
by the pte_same path), so I don't see any other side of the race...

> go to the extent of adding all this code in and tell userspace apps
> they can use zerocopy IO and not care about COW, then we really must
> cover both sides of the race otherwise it is just asking for data
> corruption.

Surely I agree if there's another side of the race left uncovered by
my patch we've to address it too if we make any change and we don't
consider this a 'feature'!

> Conversely, if we leave *any* holes open by design, then we may as well
> leave *all* holes open and have simpler code -- because apps will have
> to know about the zerocopy vs COW problem anyway. Don't you agree?

Indeed ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
