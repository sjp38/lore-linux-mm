Date: Mon, 30 Jul 2007 05:08:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
Message-ID: <20070730030806.GA17367@wotan.suse.de>
References: <20070727021943.GD13939@wotan.suse.de> <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org> <20070727055406.GA22581@wotan.suse.de> <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 27, 2007 at 08:21:54AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 27 Jul 2007, Nick Piggin wrote:
> > 
> > What numbers, though? I can make up benchmarks to show that ZERO_PAGE
> > sucks just as much. The problem I don't think is finding a situatoin that
> > improves without it (we have an extreme case where the Altix livelocked)
> > but to get confidence that nothing is going to blow up.
> 
> Well, the Altix livelock, for example, would seem to be simply because 
> setting up the ZERO_PAGE is so much *faster* that it makes it easier to 
> create humongous processes etc so quickly that you don't have time for 
> them to be interrupted at setup time.
> 
> Is that the "fault" of ZERO_PAGE? Sure. But still..

Well the issue wasn't exactly that, but the fact that a lot of processes
all exitted at once, while each having a significant number of ZERO_PAGE
mappings. The freeing rate ends up going right down (OK it wasn't quite a
livelock, finishing in > 2 hours, but without ZERO_PAGE bouncing they
exit in 5 seconds).


> > > Last time this came up, the logic behind wanting to remove the zero page 
> > > was all screwed up, and it was all based on totally broken premises. So I 
> > > really want somethign else than just "I don't like it".
> > 
> > I thought that last time this came up you thought it might be good to
> > try out in -mm initially.
> 
> I was more thinking about all the churn that we got due to the reference 
> counting stuff. That was pretty painful, and removing ZERO_PAGE wasn't the 
> right answer then either.

OK the refcounting changes (as you know) were basically unifying 2 forms
of refcount handling in the mm to a single form. ZERO_PAGE was in one of
those classes where refcounting was mostly just skipped. However it is
notable among those because it is potentially most frequently shared.

I pushed the refcounting change because it would make lockless pagecache
work, and in this situation, weird ZERO_PAGE refcounting wasn't a problem
for me so I was happy to add back some of those refcounting exceptions
just for ZERO_PAGE. I guess you and Hugh mainly just saw the cleanliness
aspect so are against adding that back, and that's fair enough.

Well now we have a problem, which is that cacheline bouncing hurts. We
have maybe 2 ways to fix that (add more ZERO_PAGEs or don't refcount
ZERO_PAGE). However what if we take a step back and first ask if the
ZERO_PAGE is even worth keeping? IOW, my reasoning is not simply
"ZERO_PAGE refcounting sucks now so let's just rip it out", but rather
"we could fix the refcounting issue, but it is likely to make the code
more complex, so we could look at getting rid of it as another option".

I realise it is a reasonably significant change in behaviour, but we
have to have some process of shuffling these things off the mortal coil.
Suppose ZERO_PAGE had no downside at all except the extra code; if it
had no good reason for being, then we'd like to be able to remove it
eventually.


> > OK, well what numbers would you like to see? I can always try a few
> > things.
> 
> Kernel builds with/without this? If the page faults really are that big a 
> deal, this should all be visible.

Sorry if it was misleading: the kernel build numbers weren't really about
where ZERO_PAGE hurts us, but just trying to show that it doesn't help too
much (for which I realise anything short of a kernel.org release is sadly
inadequate).

Anyway, I'll see if I can get anything significant...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
