Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7D16B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 11:44:37 -0400 (EDT)
Date: Thu, 26 Mar 2009 09:38:18 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
In-Reply-To: <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
Message-ID: <alpine.LFD.2.00.0903260927320.3032@localhost.localdomain>
References: <1238043674.25062.823.camel@pasglop> <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "David S. Miller" <davem@davemloft.net>, Zach Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>



On Thu, 26 Mar 2009, Hugh Dickins wrote:

> On Thu, 26 Mar 2009, Benjamin Herrenschmidt wrote:
> > 
> > I'd like to clarify something about the semantics of the "full_mm_flush"
> > argument of tlb_gather_mmu().
> > 
> > The reason is that it can either mean:
> > 
> >  - All the mappings for that mm are being flushed
> > 
> > or
> > 
> >  - The above +plus+ the mm is dead and has no remaining user. IE, we
> > can relax some of the rules because we know the mappings cannot be
> > accessed concurrently, and thus the PTEs cannot be reloaded into the
> > TLB.
> 
> No remaining user in the sense of no longer connected to any user task,
> but may still be active_mm on some cpus.

Side note: this means that CPU's that do speculative TLB fills may still 
touch the user entries. They won't _care_ about what they get, though. So 
you should be able to do any optimizations you want, as long as it doesn't 
cause machine checks or similar (ie another CPU doing a speculative access 
and then being really unhappy about a totally invalid page table entry).

> Although it looks as if there's a TLB flush at the end of every batch,
> isn't that deceptive (on x86 anyway)?

You need to. Again. Even on that CPU the TLB may have gotten re-loaded 
speculatively, even if nothing _meant_ to touch user pages.

So you can't just flush the TLB once, and then expect that since you 
flushed it, and nothing else accessed those user addresses, you don't need 
to flush it again.

And doing things the other way around - only flushing once at the end - is 
incorrect because the whole point is that we can only free the page 
directory once we've flushed all the translations that used it. So we need 
to flush before the real release, and we need to flush after we've 
unmapped everything. Thus the repeated flushes.

It shouldn't be that costly, since kernel mappings should be marked 
global.

> I'm thinking that the first flush_tlb_mm() will end up calling 
> leave_mm(), and the subsequent ones do nothing because the cpu_vm_mask 
> is then empty.

The subsequent ones shouldn't need to do anything on _other_ CPU's, 
because the other CPU's will have changed their active_vm to NULL, and no 
longer use that VM at all. The unmapping process still uses the old VM in 
the general case.

(The "do_exit()" case is special, and in that case we should not need to 
do any of this at all, but on x86 doing different paths depending on the 
"full" bit is unlikely to be worth it - it shouldn't be all that 
noticeable. You could _try_, though).

> Hmm, but the cpu which is actually doing the flush_tlb_mm() calls
> leave_mm() without considering cpu_vm_mask: won't we get repeated
> unnecessary load_cr3(swapper_pg_dir)s from that?

Yes, but see above: it's necessary for the non-full case, and I doubt it 
matters much for the full case.

But nobody has done timings as far as I know.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
