Date: Mon, 20 Dec 2004 19:19:30 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
Message-ID: <20041220181930.GH4316@wotan.suse.de>
References: <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org> <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2004 at 10:08:29AM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 20 Dec 2004, Andi Kleen wrote:
> > > 
> > > Because it used to be broken as hell. The code it generated was absolute 
> > > and utter crap.
> > 
> > I disagree. It generated significantly smaller code and the SUSE 
> > kernel has been shipping with it for several releases and I'm not
> > aware of any bug report related to unit-at-a-time.
> 
> You didn't answer my question: have you checked anything but your recent 
> version of gcc?

I have experience with 3.3-hammer (from SUSE kernel releases) and exact
data from a 4.0 snapshot (as posted) 

> 
> The fact is, there _were_ lots of complaints about unit-at-a-time. There 

I remember there was one, but they took a brute-force sledgehammer fix.
The right fix would have been to add the noinlines, not penalize
everybody.


> was a reason that thing got disabled. Maybe they got fixed, BUT THAT 
> DOESN'T HELP, if people are still using the old compilers that support 
> the notion, but do crap for it.

It helps when you add the noinlines. I can do that later - search
for Arjan's old report (I think he reported it), check what compiler
version he used, compile everything with it and unit-at-a-time
and eyeball all the big stack frames and add noinline
if it should be really needed.

> 
> We still support gcc-2.95. By implication, that pretty much means that we 
> support all the early unit-at-a-time compilers too. Not just the 
> potentially fixed ones.

The only widely used compilers with unit-at-a-time are 3.3-hammer (actually
several iterations since it has changed a bit over time) and
3.4 

> Thus your "it works for SuSE" argument is totally pointless, and totally 
> misses the issue.

Well, it's possible that there is a problem in 3.4 that isn't in
3.3-hammer (that is what suse uses), but if yes it should 
be easy to workaround with a few noinlines.

> 
> > The right fix in that case would have been to add a few "noinline"s
> > to these cases (should be easy to check for if it really happens 
> > by grepping assembly code for large stack frames), not penalize code quality
> > of the whole kernel.
> 
> No. The right fix is _always_ to make sure that we are conservative enough 
> that we don't have to depend on getting compiler-specific details really 
> really right. 
> 
> The thing is, performance (even when unit-at-a-time works) comes second to 
> stability. And I don't say that as a user (although it's obviously true 
> for users too), I say that as a _developer_. The amount of effort needed 
> to chase down strange problem reports due to compiler issues is just not 
> worth it.

I agree in the general case, but at least for stack consumption stuff
I don't. Since we have so much code it's pretty much required that
someone does the regular objdump -S ... | grep sub.*esp check
and verifies that nobody added more stack pigs. As the data in my
last mail has shown this is pretty much required. And when there
is a unit-at-a-time problem it can be quickly caught this way.

And I fixed quite a lot of stack consumption bugs over the years, but
none of them was caused by unit-a-a-time.

BTW what I heard from gcc people is that they plan to make unit-at-a-time
mandatory in some future version, so eventually we have to deal with
it anyways.

And I had it always enabled on x86-64 since the beginning and there
was so far not a *single* bug report related to it. 

> I would suggest that if you want unit-at-a-time, you make it a config 
> option, and you mark it very clearly as requiring a new enough compiler 
> that it's worth it and stable. That way if people have problems, we can 
> ask them "did you have unit-at-a-time enabled?" and see if the problem 
> goes away.

If you really suspect unit-at-a-time better just grep the stack frames.
And we already have too many such dumb options, like the totally useless
option to change all the code alignments in the config (I bet 99% of
all users will get it wrong). At least I will not add more of them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
