Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA13153
	for <linux-mm@kvack.org>; Fri, 24 Jul 1998 13:03:01 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <Pine.LNX.3.96.980724161908.21942A-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 24 Jul 1998 19:01:30 +0200
In-Reply-To: Rik van Riel's message of "Fri, 24 Jul 1998 16:25:56 +0200 (CEST)"
Message-ID: <87ww93dvyt.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On 24 Jul 1998, Zlatko Calusic wrote:
> > Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> > 
> > > These solutions are somewhat the same, but your one may take
> > > a little less computational power and has a tradeoff in the
> > > fact that it is very inflexible.
> > 
> > Same? Not in your wildest dream. :)
> > 
> > Limiting means puting "arbitrary" limit. Then page cache would NEVER
> > grow above that limit.
> 
> There's also a 'soft limit', or borrow percentage. Ultimately
> the minimum and maximum percentages should be 0 and 100 %
> respectively.

Could you elaborate on "borrow" percentage? I have some trouble
understanding what that could be.

> 
> > Triple aging has all good characteristics of aging.
> > Why do you think it is inflexible?
> 
> Because there's no way to tune the 'priority' of the page aging.
> It could be good to do triple aging, but it could be a non-optimal
> number on other machines ... and there's no way to get out of it!

Yes, you're right here. See below...

> 
> > I will post another, completely different set of benchmarks today.
> > Under different initial conditions, so as to simulate different
> > machines and loads.
> 
> Good, I like this. You will probably get somewhat different
> results with this...
> 
> Oh, and changing the code to:
> 
> int i;
> for ( i = page_cache_penalty; i--;)
> 	age_page(page);
> 
> and making page_cache_pentalty sysctl tunable will certainly
> make your tests easier...

Yes, I wanted to do something like this, but then again, was to lazy
to further complicate things. So, I was just recompiling kernel and
rebooting (to do testing), since only one file (filemap.c) was really
recompiled and whole operation did not take more than a few minutes. :)

Code like that is easy to put in the kernel, but only if people think
it would be a good idea. And then remains final question, what should
be the default value?

But, I also think that too much configurable parameters make trouble
too. If you have 100 variables to configure one subsystem in the
kernel, where do you start? I like solutions that work good by
themselves. Autotuning. With not too much logic in them. :)

> 
> > I'm very satisfied with changes (in .109 I think)
> > free_memory_available() went through. Old function was much too much
> > unnessecary complicated and not useful at all. And unreadable.
> 
> It _was_ useful; it has always been useful to test for the
> amount of memory fragmentation.

Whoops, here I don't share your opinion.

Checking memory fragmentation and then acting accordingly (in kswapd)
seems like a good idea, but, unfortunately, I am now pretty sure it is
NOT. And there is one and only one reason: throwing pages out of
memory at random (blindly). You know it, too.

I came to this conclusion many months before, with my first patch,
that aimed to solve fragmentation problem.

My first idea was to make sure we have at least one 128KB chunk. It
finished with many lockups and kswapd deadlocks. Then I tried to make
few 16KB chunks available and performance still sucked. To get few
16KB chunks system would happily outswap whole my memory. Thanks, not
again. I used it for a while, only to prevent network lockups.

Old (<= 2.1.108) free_memory_available() was practically that, but
with limit applied which effectively worked like: "Oh, no, memory
fragmented, swap out, swap out, oh no, too much swapped out, never
mind fragmentation, stop swapping." So, it didn't work. And it was
definitely overcomplicated.

Obviously, everybody tried hard to do the right thing, where right
thing could not be done. Wrong place to search for solution.

Stephen's new patch promises. It has some new logic in it which is
not tried before. I already tested it, and results are not bad.

But, I can't say that is final solution, either, since I can still
easily produce memory shortage, with many network simultaneous network
connections even on a 64MB unloaded machine. So, lots of work to be
done for 2.4. :)

> 
> In fact, Linus himself said (when free_memory_available()
> was introduced in 2.1.89) that he would not accept any
> function which used the amount of free pages.
> 
> After some protests (by me) Linus managed to explain to us
> exactly _why_ we should test for fragmentation, I suggest
> we all go through the archives again and reread the arguments...
> 

Yeah, I remember.

That was the time I started patching my kernels with every new
release. That was the time I went for another 32MB to solve my
problems. :(

I'm lagging very much behind on linux-kernel list (~3000 posts) and it
seems like I missed some good discussion about Linux MM (I read about
it on http://lwn.net/). Now, I hope I can still catch that all, and
then spend some time testing and coding. :)

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
     P.S. That Linux-MM page you're doing, kicks ass. Just never
	  had opportunity to tell you that I really like it. :)
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
