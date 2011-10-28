Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2B2B6B002D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 16:52:46 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <20139.5644.583790.903531@quad.stoffel.home>
Date: Fri, 28 Oct 2011 16:52:28 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
In-Reply-To: <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<75efb251-7a5e-4aca-91e2-f85627090363@default>
	<20111027215243.GA31644@infradead.org>
	<1319785956.3235.7.camel@lappy>
	<CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	<552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	<CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	<20111028163053.GC1319@redhat.com>
	<b86860d2-3aac-4edd-b460-bd95cb1103e6@default
 20138.62532.493295.522948@quad.stoffel.home>
	<3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

>>>>> "Dan" == Dan Magenheimer <dan.magenheimer@oracle.com> writes:

>> From: John Stoffel [mailto:john@stoffel.org]
>> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
>> 
>> >>>>> "Dan" == Dan Magenheimer <dan.magenheimer@oracle.com> writes:
>> 
Dan> Second, have you read http://lwn.net/Articles/454795/ ?
Dan> If not, please do.  If yes, please explain what you don't
Dan> see as convincing or tangible or documented.  All of this
Dan> exists today as working publicly available code... it's
Dan> not marketing material.
>> 
>> I was vaguely interested, so I went and read the LWN article, and it
>> didn't really provide any useful information on *why* this is such a
>> good idea.

Dan> Thanks for taking the time to read the LWN article and sending
Dan> some feedback.  I admit that, after being immersed in the topic
Dan> for three years, it's difficult to see it from the perspective of
Dan> a new reader, so I apologize if I may have left out important
Dan> stuff.  I hope you'll take the time to read this long reply.

Will do.  But I'm not the person you need to convince here about the
usefulness of this code and approach, it's the core VM developers,
since they're the ones who will have to understand this stuff and know
how to maintain it.  And keeping this maintainable is a key goal.  

Dan> "WHY" this is such a good idea is the same as WHY it is useful to
Dan> add RAM to your systems. 

So why would I use this instead of increasing the physical RAM?  Yes,
it's an easier thing to do by just installing a new kernel an flipping
on the switch, but give me numbers showing an improvement.

Dan> Tmem expands the amount of useful "space" available to a
Dan> memory-constrained kernel either via compression (transparent to
Dan> the rest of the kernel except for the handful of hooks for
Dan> cleancache and frontswap, using zcache) 

Ok, so why not just a targetted swap compression function instead?
Why is your method superior?  

Dan> or via memory that was otherwise not visible to the kernel
Dan> (hypervisor memory from Xen or KVM, or physical RAM on another
Dan> clustered system using RAMster).

This needs more explaining, because I'm not sure I get your
assumptions here.  For example, from reading your LWN article, I see
that one idea of RAMster is to use another systems memory if you run
low.  Ideally when hooked up via something like Myrinet or some other
highspeed/low latency connection.  And you do say it works over plane
ethernet.  Great, show me the numbers!  Show me the speedup of the
application(s) you've been testing.  

Dan>  Since a kernel always eats memory until it runs out (and then
Dan> does its best to balance that maximum fixed amount), this is
Dan> actually much harder than it sounds.

Yes, it is.  I've been running into this issue myself on RHEL5.5 VNC
servers which are loaded down with lots of user sessions.  If someone
kicks in a cp of a large multi-gig file on an NFS mount point, the box
slams to a halt.  This is the kind of things I think you need to
address and make sure you don't slow down.

Dan> So I'm asking: Is that not clear from the LWN article?  Or
Dan> do you not believe that more "space" is a good idea?  Or
Dan> do you not believe that tmem mitigates that problem?

The article doesn't give me a good diagram showing the memory layouts
and how you optimize/compress/share memory.  And it also doesn't
compare performance to just increasing physical memory instead of your
approach.  

Dan> Clearly if you always cram enough RAM into your system so that
Dan> you never have a paging/swapping problem (i.e your RAM is always
Dan> greater than your "working set"), tmem's NOT a good idea.

This is a statement that you should be making right up front.  And
explaining why this is still a good idea to implement.  I can see that
if I've got a large system which cannot physically use any more
memory, then it might be worth my while to use TMEM to get more
performance out of this expensive hardware.  But if I've got the room,
why is your method better than just adding RAM?  

Dan> So the built-in assumption is that RAM is a constrained resource.
Dan> Increasingly (especially in virtual machines, but elsewhere as
Dan> well), this is true.

Here's another place where you didn't explain yourself well, and where
a diagram would help.  If you have a VM server with 16Gb of RAM, does
TMEM allow you to run more guests (each of which takes 2G of RAM say)
verus before?  And what's the performance gain/loss/tradeoff?  

>> Particularly, I didn't see any before/after numbers which compared the
>> kernel running various loads both with and without these
>> transcendental memory patches applied.  And of course I'd like to see
>> numbers when they patches are applied, but there's no TM
>> (Transcendental Memory) in actual use, so as to quantify the overhead.

Dan> Actually there is.  But the only serious performance analysis has
Dan> been on Xen, and I get reamed every time I use that word, so I'm
Dan> a bit gun-shy.  If you are seriously interested and willing to
Dan> ignore that X-word, see the last few slides of:

I'm not that interested in Xen myself for various reasons, mostly
because it's not something I use at $WORK, and it's not something I've
spent any time playing with at $HOME in my free time.  

Dan> http://oss.oracle.com/projects/tmem/dist/documentation/presentations/TranscendentMemoryXenSummit2010.pdf

Dan> There's some argument about whether the value will be as
Dan> high for KVM, but that obviously can't be measured until
Dan> there is a complete KVM implementation, which requires
Dan> frontswap.

Dan> It would be nice to also have some numbers for zcache, I agree.

It's not nice, it's REQUIRED.  If you can't show numbers which give an
improvement, then why would it be accepted?  

>> Your article would also be helped with a couple of diagrams showing
>> how this really helps.  Esp in the cases where the system just
>> endlessly says "no" to all TM requests and the kernel or apps need to
>> them fall back to the regular paths.

Dan> The "no" cases occur whenever there is NO additional memory,
Dan> so obviously it doesn't help for those cases; the appropriate
Dan> question for those cases is "how much does it hurt" and the
Dan> answer is (usually) effectively zero.  Again if you know
Dan> you've always got enough RAM to exceed your working set,
Dan> don't enable tmem/frontswap/cleancache.

Dan> For the "does really help" cases, I apologize, but I just can't
Dan> think how to diagrammatically show clearly that having more RAM
Dan> is a good thing.

>> In my case, $WORK is using linux with large memory to run EDA
>> simulations, so if we swap, performance tanks and we're out of luck.
>> So for my needs, I don't see how this helps.

Dan> Do you know what percent of your total system cost is spent on
Dan> RAM, including variable expense such as power/cooling?

Nope, can't quantify it unfortunately.  

Dan> Is reducing that cost relevant to your $WORK?  Or have you ever
Dan> ran into a "buy more RAM" situation where you couldn't expand
Dan> because your machine RAM slots were maxed out?

Generally, my engineers can and will take all the RAM they can, since
EDA simulations almost always work better with more RAM, esp as the
designs grow in size.   But it's also not a hard and fast rule.  If a
144Gb box with dual CPUs and 4 cores each costs me $20k or so, then
the power/cooling costs aren't as big a concern, because my enginees
*time* is where the real cost comes from.  And my customers turn
around time to get a design done is another big $$$ center.  The
hardware is cheap.  Have you priced EDA licenses from Cadence,
Synopsys, or other vendors?

But that's besides the point.  How much overhead does TMEM incur when
it's not being used, but when it's avaiable?  

>> For my home system, I run an 8Gb RAM box with a couple of KVM VMs, NFS
>> file service to two or three clients (not counting the VMs which mount
>> home dirs from there as well) as well as some light WWW developement
>> and service.  How would TM benefit me?  I don't use Xen, don't want to
>> play with it honestly because I'm busy enough as it is, and I just
>> don't see the hard benefits.

Dan> (I use "tmem" since TM means "trademark" to many people.)

Yeah, I like your phrase better too, I just got tired of typing the
full thing. 

Dan> Does 8GB always cover the sum of the working sets of all your KVM
Dan> VMs?  If so, tmem won't help.  If a VM in your workload sometimes
Dan> spikes, tmem allows that spike to be statistically "load
Dan> balanced" across RAM claimed by other VMs which may be idle or
Dan> have a temporarily lower working set.  This means less
Dan> paging/swapping and better sum-over-all-VMs performance.

So this is a good thing to show and get hard numbers on.

>> So the onus falls on *you* and the other TM developers to sell this
>> code and it's benefits (and to acknowledge it's costs) to the rest of
>> the Kernel developers, esp those who hack on the VM.  If you can't
>> come up with hard numbers and good examples with good numbers, then

Dan> Clearly there's a bit of a chicken-and-egg problem.  Frontswap
Dan> (and cleancache) are the foundation, and it's hard to build
Dan> anything solid without a foundation.

No one is stopping you from building your own house using the Linux
foundation, showing that it's a great house and then allowing you to
come and re-work the foundations and walls, etc to build the better
house.  

Dan> For those who "hack on the VM", I can't imagine why the handful
Dan> of lines in the swap subsystem, which is probably the most stable
Dan> and barely touched subsystem in Linux or any OS on the planet,
Dan> is going to be a burden or much of a cost.

It's the performance and cleanliness aspects that people worry about. 

>> you're out of luck.

Dan> Another way of looking at it is that the open source community is
Dan> out of luck.  Tmem IS going into real shipping distros, but it
Dan> (and Xen support and zcache and KVM support and cool things like
Dan> RAMster) probably won't be in the distro "you" care about because
Dan> this handful of nearly innocuous frontswap hooks didn't get
Dan> merged.  I'm trying to be a good kernel citizen but I can't make
Dan> people listen who don't want to.

No real skin off my nose, because I haven't seen a compelling reason
to use TMEM.  And if I do run a large Oracle system, with lots of DBs
and table spaces, I don't see how TMEM helps me either, because the
hardware is such a small part of the cost of a large Oracle
deployment.  Adding RAM is cheap.  TMEM... well it could be useful in
an emergency, but unless it's stressed and used alot, it could end up
causing more problems than it solves.  


Dan> Frontswap is the last missing piece.  Why so much resistance?

Because you haven't sold it well with numbers to show how much
overhead it has?  

I'm being negative because I see now reason to use it.  And because I
think you can do a better job of selling it and showing the benefits
with real numbers.  

Load of a XEN box, have a VM spike it's memory usage and show how TMEM
helps.  Compare it to a non-TMEM setup with the same load.  

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
