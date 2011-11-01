Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 411FE6B002D
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 06:15:11 -0400 (EDT)
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <424e9e3a-670d-4835-914f-83e99a11991a@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	 <75efb251-7a5e-4aca-91e2-f85627090363@default>
	 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
	 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
	 <20111028163053.GC1319@redhat.com>
	 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
	 <20138.62532.493295.522948@quad.stoffel.home>
	 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default 1320048767.8283.13.camel@dabdike>
	 <424e9e3a-670d-4835-914f-83e99a11991a@default>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Nov 2011 14:13:23 +0400
Message-ID: <1320142403.7701.62.camel@dabdike>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Mon, 2011-10-31 at 08:39 -0700, Dan Magenheimer wrote:
> > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
> 
> Hi James --
> 
> Thanks for the reply.  You raise some good points but
> I hope you will read what I believe are reasonable though
> long-winded answers.
>  
> > On Fri, 2011-10-28 at 13:19 -0700, Dan Magenheimer wrote:
> > > For those who "hack on the VM", I can't imagine why the handful
> > > of lines in the swap subsystem, which is probably the most stable
> > > and barely touched subsystem in Linux or any OS on the planet,
> > > is going to be a burden or much of a cost.
> > 
> > Saying things like this doesn't encourage anyone to trust you.  The
> > whole of the MM is a complex, highly interacting system.  The recent
> > issues we've had with kswapd and the shrinker code gives a nice
> > demonstration of this ... and that was caused by well tested code
> > updates.
> 
> I do understand that.  My point was that the hooks are
> placed _statically_ in largely stable code so it's not
> going to constantly get in the way of VM developers
> adding new features and fixing bugs, particularly
> any developers that don't care about whether frontswap
> works or not.  I do think that is a very relevant
> point about maintenance... do you disagree?

Well, as I've said, all the mm code is highly interacting, so I don't
really see it as "stable" in the way you suggest.  What I'm saying is
that you need to test a variety of workloads to demonstrate there aren't
any nasty interactions.

> Runtime interactions can only occur if the code is
> config'ed and, if config'ed, only if a tmem backend (e.g.
> Xen or zcache) enables it also at runtime.

So this, I don't accept without proof ... that's what we initially said
about the last set of shrinker updates that caused kswapd to hang
sandybridge systems ...

>   When
> both are enabled, runtime interactions do occur
> and absolutely must be fully tested.  My point was
> that any _users_ who don't care about whether frontswap
> works or not don't need to have any concerns about
> VM system runtime interactions.  I think this is also
> a very relevant point about maintenance... do you
> disagree?

I'm sorry, what point about maintenance?

> > You can't hand wave away the need for benchmarks and
> > performance tests.
> 
> I'm not.  Conclusive benchmarks are available for one user
> (Xen) but not (yet) for other users.  I've already acknowledged
> the feedback desiring benchmarking for zcache, but zcache
> is already merged (albeit in  staging), and Xen tmem
> is already merged in both Linux and the Xen hypervisor,
> and cleancache (the alter ego of frontswap) is already
> merged.

The test results for Xen I've seen are simply that "we're faster than
swapping to disk, and we can be even better if you use self ballooning".
There's no indication (at least in the Xen Summit presentation) what the
actual workloads were.

> So the question is not whether benchmarks are waived,
> but whether one accepts (1) conclusive benchmarks for Xen;
> PLUS (2) insufficiently benchmarked zcache; PLUS (3) at
> least two other interesting-but-not-yet-benchmarkable users;
> as sufficient for adding this small set of hooks into
> swap code.

That's the point: even for Xen, the benchmarks aren't "conclusive".
There may be a workload for which transcendent memory works better, but
make -j8 isn't enough of a variety of workloads)

> I understand that some kernel developers (mostly from one
> company) continue to completely discount Xen, and
> thus won't even look at the Xen results.  IMHO
> that is mudslinging.

OK, so lets look at this another way:  one of the signs of a good ABI is
generic applicability.  Any good virtualisation ABI should thus work for
all virtualisation systems (including VMware should they choose to take
advantage of it).  The fact that transcendent memory only seems to work
well for Xen is a red flag in this regard.

> > You have also answered all questions about inactive cost by saying "the
> > code has zero cost when it's compiled out"  This also is a non starter.
> > For the few use cases it has, this code has to be compiled in.  I
> > suspect even Oracle isn't going to ship separate frontswap and
> > non-frontswap kernels in its distro.  So you have to quantify what the
> > performance impact is when this code is compiled in but not used.
> > Please do so.
> 
> First, no, Oracle is not going to ship separate frontswap and
> non-frontswap kernels.  It IS going to ship a frontswap-enabled
> kernel and this can be seen in Oracle's publicly-available
> kernel git tree (the next release, now in Beta).  Frontswap is
> compiled in, but still must be enabled at runtime (e.g. for
> a Xen guest, either manually by the guest's administrator
> or automagically by the Oracle VM product's management layer).
> 
> I did fully quantify the performance impact elsewhere in
> this thread.  The performance impact with CONFIG_FRONTSWAP=n
> (which is ZERO) is relevant for distros which choose to
> ignore it entirely.  The performance impact for CONFIG_FRONTSWAP=y
> but not-enabled-at-runtume is one compare-pointer-against-NULL
> per page actually swapped in or out (essentially ZERO);
> this is relevant for distros which choose to configure it
> enabled in case they wish to enable it at runtime in
> the future.

So what I don't like about this style of argument is the sleight of
hand: I would expect the inactive but configured case to show mostly in
the shrinker paths, which is where our major problems have been, so that
would be cleancache, not frontswap, wouldn't it?

> So the remaining question is the performance impact when
> compile-time AND runtime enabled; this is in the published
> Xen presentation I've referenced -- the impact is much much
> less than the performance gain.  IMHO benchmark results can
> be easily manipulated so I prefer to discuss the theoretical
> underpinnings which, in short, is that just about anything
> a tmem backend does (hypercall, compression, deduplication,
> even moving data across a fast network) is a helluva lot
> faster than swapping a page to disk.
> 
> Are there corner cases and probably even real workloads
> where the cost exceeds the benefits?  Probably... though
> less likely for frontswap than for cleancache because ONLY
> pages that would actually be swapped out/in use frontswap.
> 
> But I have never suggested that every kernel should always
> unconditionally compile-time-enable and run-time-enable
> frontswap... simply that it should be in-tree so those
> who wish to enable it are able to enable it.

In practise, most useful ABIs end up being compiled in ... and useful
basically means useful to any constituency, however small.  If your ABI
is useless, then fine, we don't have to worry about the configured but
inactive case (but then again, we wouldn't have to worry about the ABI
at all).  If it has a use, then kernels will end up shipping with it
configured in which is why the inactive performance impact is so
important to quantify.

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
