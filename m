Date: Mon, 30 Jul 2007 06:30:08 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
Message-ID: <20070730043008.GB7222@wotan.suse.de>
References: <20070727021943.GD13939@wotan.suse.de> <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org> <20070727055406.GA22581@wotan.suse.de> <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org> <20070730030806.GA17367@wotan.suse.de> <alpine.LFD.0.999.0707292026190.4161@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707292026190.4161@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 29, 2007 at 08:45:25PM -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 30 Jul 2007, Nick Piggin wrote:
> > 
> > Well the issue wasn't exactly that, but the fact that a lot of processes
> > all exitted at once, while each having a significant number of ZERO_PAGE
> > mappings. The freeing rate ends up going right down (OK it wasn't quite a
> > livelock, finishing in > 2 hours, but without ZERO_PAGE bouncing they
> > exit in 5 seconds).
> 
> Umm. Isn't this because of the new page->mapping counting for reserved 
> pages?
> 
> The one I was violently against, and told you (and Hugh) was pointless and 
> bad?
> 
> Or what "bouncing" are you talking about?

page->mapcount, yes. I don't quite remember anybody being violently against
it, but that's in the past now anyway.

 
> In other words, this doesn't really sound like a ZERO_PAGE problem at all, 
> but a problem that was engineered by unnecessarily trying to count those 
> pages in the first place. No?

Yeah, but that's a little unfair: it was engineered by removing the code
to *not* count those pages :) Another option I gave you was to add
back some of that code to avoid this refcounting, but you were violently
against that :).


> > > Kernel builds with/without this? If the page faults really are that big a 
> > > deal, this should all be visible.
> > 
> > Sorry if it was misleading: the kernel build numbers weren't really about
> > where ZERO_PAGE hurts us, but just trying to show that it doesn't help too
> > much (for which I realise anything short of a kernel.org release is sadly
> > inadequate).
> > 
> > Anyway, I'll see if I can get anything significant...
> 
> The thing that really riles me up about this is that the whole damn thing 
> seems to be so pointless. This "ZERO_PAGE is bad" thing has been a 
> constant background noise, where people are pushing their opinions with no 
> real technical reasons.
> 
> I want technical reasons, but I get the feeling that this pogrom is abotu 
> anything but technical arguments.
> 
> So I _really_ don't want to hear you blaming ZERO_PAGE for something that 
> you introduced yourself with Hugh, and that had _zero_ to do with 
> ZERO_PAGE, and that I spent weeks saying was pointless, to the point where 
> I just gave up.
> 
> Now, that you apparently have found the perfect load that proved me right, 
> you instead of blaming the pointless refcounting, you want to blame the 
> poor ZERO_PAGE. Again. 

No, I'm not saying ZERO_PAGE is bad because it has a refcounting scalability
problem. We can avoid or eliminate that by *not refcounting it* or doing
something crazy like per-node ZERO_PAGEs.

My first patch to fix the problem was actually to not refcount it. Remember?

The technical argument for this patch is that I'm trying to reason that
ZERO_PAGE is no good in the first place. In this debate, the refcounting
issue is really moot (IOW, I'm not trying to argue the ZERO_PAGE is bad
*because* of the refcounting problem, but because it is not good).

 
> And THAT is what makes me irritated with this patch. I hate the 
> background, and what looks like intellectual dishonesty. I _told_ people 
> that refcounting reserved pages was pointless and bad. Did you listen? No. 
> And now that it causes problems, rather than blame the refcounting, you 
> blame the victim.
> 
> The zero page is *cheaper* to set up than normal pages. It always was. You 
> just *made* it more expensive, because of the irrational fear of 
> PageReserved() that protected us from all those unnecessary bounces in the 
> first place.
> 
> So a totally equivalent fix would be to just re-instate the PageReserved 
> checks. It would likely even be easier these days (one logical place to do 
> so would be in "vm_normal_page()", which automatically would catch all 
> unmapping cases, but you'd still have to make sure you don't *increment* 
> the page count when you map it too, of course).

I didn't like PageReserved for a number of reasons including that it allowed
people to be sloppy with refcounting. However I wouldn't mind adding back
some checks to skip counting (although if we do that, let's add a new page
flag for it, and PageReserved can eventually disappear).

But we should do it on the right level. That is, the struct page itself is
a refcounted object. If we skip refcounting for userspace mappings, it
should be done there, rather than an ugly hack in put_page.

The fear of PageReserved was not irrational -- as I said, I needed to get
rid of the put_page special casing for the lockless pagecache. I'm not
against properly special casing special pages.

 
> But if you can actually show that ZERO_PAGE literally slows things down 
> (and none of this page count bouncing crud that you were the one that 
> introduced in the first place), then _that_ would be a totally different 
> issue. At that point, you have an independent reason for removing code 
> that has basically been there since day 1, and all my arguments go away.
> 
> See?
> 
> I'd love to hear "here's a real-life load, and yes, the ZERO_PAGE logic 
> really does hurt more than it helps, it's time to remove it". At that 
> point I'll happily apply the patch.
> 
> But what I *don't* want to hear is "we screwed up the reference-counting 
> of ZERO_PAGE, so now it's so expensive that we want to remove the page 
> entirely". That just makes me sad. And a bit angry.

I'd say it will be hard to actually get a significant real world
improvement from removing it vs de-refcounting it. Maybe on an mmap_sem
constrained workload, but that seems to be a lot better after the glibc
fix and private futexes...

But is there a good reason to keep it? You say it is cheaper to set up,
but make -j still does 500 extra page faults per second per cpu because
of ZERO_PAGE, making it effectively more expensive even ignoring the
refcounting problem. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
