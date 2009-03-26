Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 475586B0047
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 23:17:24 -0400 (EDT)
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.00.0903260927320.3032@localhost.localdomain>
References: <1238043674.25062.823.camel@pasglop>
	 <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
	 <alpine.LFD.2.00.0903260927320.3032@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 10:13:02 +1100
Message-Id: <1238109182.16498.47.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "David S. Miller" <davem@davemloft.net>, Zach Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>


> Side note: this means that CPU's that do speculative TLB fills may still 
> touch the user entries.

Ok. That's what I wasn't sure of. It's fortunately not the case on SW
loaded TLBs so I may still do some optimisations on these guys.

>  They won't _care_ about what they get, though. So 
> you should be able to do any optimizations you want, as long as it doesn't 
> cause machine checks or similar (ie another CPU doing a speculative access 
> and then being really unhappy about a totally invalid page table entry).

Right.

> > Although it looks as if there's a TLB flush at the end of every batch,
> > isn't that deceptive (on x86 anyway)?
> 
> You need to. Again. Even on that CPU the TLB may have gotten re-loaded 
> speculatively, even if nothing _meant_ to touch user pages.
> 
> So you can't just flush the TLB once, and then expect that since you 
> flushed it, and nothing else accessed those user addresses, you don't need 
> to flush it again.
>
> And doing things the other way around - only flushing once at the end - is 
> incorrect because the whole point is that we can only free the page 
> directory once we've flushed all the translations that used it. So we need 
> to flush before the real release, and we need to flush after we've 
> unmapped everything. Thus the repeated flushes.
> 
> It shouldn't be that costly, since kernel mappings should be marked 
> global.

I was talking about the freeing of the individual pages, not the page
tables per-se, but yes, I see that the problem is there too.

I'll do some experiments on embedded stuffs here and see if it's worth
doing things differently. I'm trying to avoid too many IPIs typically.
The problem with our TLBs is that they cache multiple contexts, and so
they may still hold translations for contexts not currently active,
-but- we really don't need to do heavy synchronisation to flush those.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
