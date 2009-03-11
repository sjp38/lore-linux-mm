Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 573276B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 16:48:38 -0400 (EDT)
Date: Wed, 11 Mar 2009 21:48:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311204815.GQ27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 01:19:03PM -0700, Linus Torvalds wrote:
> That said, I don't know who the crazy O_DIRECT users are. It may be true 
> that some O_DIRECT users end up using the same pages over and over again, 
> and that this is a good optimization for them.

If it's done on new pages chances are that gup-fast fast-path can't
run in the first place, modulo glibc memalign re-using previously
freed areas. Overall I think it's worthwhile optimization, to avoid
the locked op in the rewrite case that I think it's common enough.

But I totally agree that it'd be good to benchmark gup-fast on already
instantiated ptes where SetPageGUP will run. I thought it'd be like
below measurement error and not measurable but good to check it.

> The advantage of it is that it fixes the problem not just in one place, 
> but "forever". No hacks about exactly how you access the mappings etc.
> 
> Of course, nothing _really_ solves things. If you do some delayed IO after 
> having looked up the mapping and turned it into a physical page, and the 
> original allocator actually unmaps it (or exits), then the same issue can 
> still happen (well, not the _same_ one - but the very similar issue of the 
> child seeing changes even though the IO was started in the parent). 
> 
> This is why I think any "look up by physical" is fundamentally flawed. It 
> very basically becomes a "I have a secret local TLB that cannot be changed 
> or flushed". And any single-bit solution (GUP) is always going to be 
> fairly broken. 

One of the reasons of not sharing when PG_gup is set and page_count is
shown as pinned, is also to fix all sort of drivers that are doing gup
to "lookup by physical" on anon pages and doing "dma by physical some
offset of the page" at any time later and fork. Otherwise PageReserved
should be set by default by gup-fast instead of relying on the drivers
to set it after gup-fast returns.

> Agreed. However, I really think this is a O_DIRECT problem. Just document 
> it. Tell people that O_DIRECT simply doesn't work with COW, and 
> fundamentally can never work well.
>
> If you use O_DIRECT with threading, you had better know what the hell 
> you're doing anyway. I do not think that the kernel should do stupid 
> things just because stupid users don't understand the semantics of the 
> _non-stupid_ thing (which is to just let people think about COW for five 
> seconds).

This really isn't only about O_DIRECT. This is to fix gup vs fork,
O_DIRECT is just one of the million of gup users out there... KVM work
around this by using MADV_DONTFORK, until MADV_DONTFORK was introduced
I once started to get corruption in KVM when a change made system() to
be executed once in a while for whatever unrelated reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
