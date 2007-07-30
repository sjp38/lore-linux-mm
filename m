Date: Sun, 29 Jul 2007 20:45:25 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: <20070730030806.GA17367@wotan.suse.de>
Message-ID: <alpine.LFD.0.999.0707292026190.4161@woody.linux-foundation.org>
References: <20070727021943.GD13939@wotan.suse.de>
 <alpine.LFD.0.999.0707262226420.3442@woody.linux-foundation.org>
 <20070727055406.GA22581@wotan.suse.de> <alpine.LFD.0.999.0707270811320.3442@woody.linux-foundation.org>
 <20070730030806.GA17367@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 30 Jul 2007, Nick Piggin wrote:
> 
> Well the issue wasn't exactly that, but the fact that a lot of processes
> all exitted at once, while each having a significant number of ZERO_PAGE
> mappings. The freeing rate ends up going right down (OK it wasn't quite a
> livelock, finishing in > 2 hours, but without ZERO_PAGE bouncing they
> exit in 5 seconds).

Umm. Isn't this because of the new page->mapping counting for reserved 
pages?

The one I was violently against, and told you (and Hugh) was pointless and 
bad?

Or what "bouncing" are you talking about?

In other words, this doesn't really sound like a ZERO_PAGE problem at all, 
but a problem that was engineered by unnecessarily trying to count those 
pages in the first place. No?

> > Kernel builds with/without this? If the page faults really are that big a 
> > deal, this should all be visible.
> 
> Sorry if it was misleading: the kernel build numbers weren't really about
> where ZERO_PAGE hurts us, but just trying to show that it doesn't help too
> much (for which I realise anything short of a kernel.org release is sadly
> inadequate).
> 
> Anyway, I'll see if I can get anything significant...

The thing that really riles me up about this is that the whole damn thing 
seems to be so pointless. This "ZERO_PAGE is bad" thing has been a 
constant background noise, where people are pushing their opinions with no 
real technical reasons.

I want technical reasons, but I get the feeling that this pogrom is abotu 
anything but technical arguments.

So I _really_ don't want to hear you blaming ZERO_PAGE for something that 
you introduced yourself with Hugh, and that had _zero_ to do with 
ZERO_PAGE, and that I spent weeks saying was pointless, to the point where 
I just gave up.

Now, that you apparently have found the perfect load that proved me right, 
you instead of blaming the pointless refcounting, you want to blame the 
poor ZERO_PAGE. Again. 

And THAT is what makes me irritated with this patch. I hate the 
background, and what looks like intellectual dishonesty. I _told_ people 
that refcounting reserved pages was pointless and bad. Did you listen? No. 
And now that it causes problems, rather than blame the refcounting, you 
blame the victim.

The zero page is *cheaper* to set up than normal pages. It always was. You 
just *made* it more expensive, because of the irrational fear of 
PageReserved() that protected us from all those unnecessary bounces in the 
first place.

So a totally equivalent fix would be to just re-instate the PageReserved 
checks. It would likely even be easier these days (one logical place to do 
so would be in "vm_normal_page()", which automatically would catch all 
unmapping cases, but you'd still have to make sure you don't *increment* 
the page count when you map it too, of course).

But if you can actually show that ZERO_PAGE literally slows things down 
(and none of this page count bouncing crud that you were the one that 
introduced in the first place), then _that_ would be a totally different 
issue. At that point, you have an independent reason for removing code 
that has basically been there since day 1, and all my arguments go away.

See?

I'd love to hear "here's a real-life load, and yes, the ZERO_PAGE logic 
really does hurt more than it helps, it's time to remove it". At that 
point I'll happily apply the patch.

But what I *don't* want to hear is "we screwed up the reference-counting 
of ZERO_PAGE, so now it's so expensive that we want to remove the page 
entirely". That just makes me sad. And a bit angry.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
