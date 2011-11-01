Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C3D566B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:10:47 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default>
Date: Tue, 1 Nov 2011 11:10:28 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
 <20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
 <20138.62532.493295.522948@quad.stoffel.home>
 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
 <1320048767.8283.13.camel@dabdike>
 <424e9e3a-670d-4835-914f-83e99a11991a@default
 1320142403.7701.62.camel@dabdike>
In-Reply-To: <1320142403.7701.62.camel@dabdike>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Mon, 2011-10-31 at 08:39 -0700, Dan Magenheimer wrote:
> > > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > > Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
> >
> > > On Fri, 2011-10-28 at 13:19 -0700, Dan Magenheimer wrote:
> > > > For those who "hack on the VM", I can't imagine why the handful
> > > > of lines in the swap subsystem, which is probably the most stable
> > > > and barely touched subsystem in Linux or any OS on the planet,
> > > > is going to be a burden or much of a cost.
> > >
> > > Saying things like this doesn't encourage anyone to trust you.  The
> > > whole of the MM is a complex, highly interacting system.  The recent
> > > issues we've had with kswapd and the shrinker code gives a nice
> > > demonstration of this ... and that was caused by well tested code
> > > updates.
> >
> > I do understand that.  My point was that the hooks are
> > placed _statically_ in largely stable code so it's not
> > going to constantly get in the way of VM developers
> > adding new features and fixing bugs, particularly
> > any developers that don't care about whether frontswap
> > works or not.  I do think that is a very relevant
> > point about maintenance... do you disagree?
>=20
> Well, as I've said, all the mm code is highly interacting, so I don't
> really see it as "stable" in the way you suggest.  What I'm saying is
> that you need to test a variety of workloads to demonstrate there aren't
> any nasty interactions.

I guess I don't understand how there can be any interactions
at all, let alone _nasty_ interactions when there is no
code to interact with?

For clarity and brevity, let's call the three cases:

Case A) CONFIG_FRONTSWAP=3Dn
Case B) CONFIG_FRONTSWAP=3Dy and no tmem backend registers
Case C) CONFIG_FRONTSWAP=3Dy and a tmem backend DOES register

There are no interactions in Case A, agreed?  I'm not sure
if it is clear, but in Case B every hook checks to
see if a tmem backend is registered... if not, the
hook is a no-op except for the addition of a
compare-pointer-against-NULL op, so there is no
interaction there either.

So the only case where interactions are possible is
Case C, which currently only can occur if a user
specifies a kernel boot parameter of "tmem" or "zcache".
(I know, a bit ugly, but there's a reason for doing
it this way, at least for now.)

> > Runtime interactions can only occur if the code is
> > config'ed and, if config'ed, only if a tmem backend (e.g.
> > Xen or zcache) enables it also at runtime.
>=20
> So this, I don't accept without proof ... that's what we initially said
> about the last set of shrinker updates that caused kswapd to hang
> sandybridge systems ...

This makes me think that you didn't understand the
code underlying Case B above, true?

> >   When
> > both are enabled, runtime interactions do occur
> > and absolutely must be fully tested.  My point was
> > that any _users_ who don't care about whether frontswap
> > works or not don't need to have any concerns about
> > VM system runtime interactions.  I think this is also
> > a very relevant point about maintenance... do you
> > disagree?
>=20
> I'm sorry, what point about maintenance?

The point is that only Case C has possible interactions
so Case A and Case B end-users and kernel developers need
not worry about the maintenance.

IOW, if Johannes merges some super major swap subsystem rewrite
and he doesn't have a clue if/how to move the frontswap
hooks, his patch doesn't affect any Case A or Case B users
and not even any Case C users that aren't using latest upstream.

That seems relevant to me when we are discussing
how much maintenance cost frontswap requires which,
I think, was where this subthread started several
emails ago :-)

> > > You can't hand wave away the need for benchmarks and
> > > performance tests.
> >
> > I'm not.  Conclusive benchmarks are available for one user
> > (Xen) but not (yet) for other users.  I've already acknowledged
> > the feedback desiring benchmarking for zcache, but zcache
> > is already merged (albeit in  staging), and Xen tmem
> > is already merged in both Linux and the Xen hypervisor,
> > and cleancache (the alter ego of frontswap) is already
> > merged.
>=20
> The test results for Xen I've seen are simply that "we're faster than
> swapping to disk, and we can be even better if you use self ballooning".
> There's no indication (at least in the Xen Summit presentation) what the
> actual workloads were.
>
> > So the question is not whether benchmarks are waived,
> > but whether one accepts (1) conclusive benchmarks for Xen;
> > PLUS (2) insufficiently benchmarked zcache; PLUS (3) at
> > least two other interesting-but-not-yet-benchmarkable users;
> > as sufficient for adding this small set of hooks into
> > swap code.
>=20
> That's the point: even for Xen, the benchmarks aren't "conclusive".
> There may be a workload for which transcendent memory works better, but
> make -j8 isn't enough of a variety of workloads)

OK, you got me, I guess "conclusive" is too strong a word.
It would be more accurate to say that the theoretical basis
for improvement, which some people were very skeptical about,
measures to be even better than expected.

I agree that one workload isn't enough... I can assure you that
there have been others.  But I really don't think you are asking
for more _positive_ data, you are asking if there is _negative_
data.  As you point out "we" are faster than swapping is not
a hard bar to clear.  IOW comparing any workload that swaps a lot
against the same workload swapping a lot less, doesn't really
prove anything.  OR DOES IT?  Considering that reducing swapping
is the WHOLE POINT of frontswap, I would argue that it does.

Can we agree that if frontswap is doing its job properly on
any "normal" workload that is swapping, it is improving on a
bad situation?

Then let's get back to your implied question about _negative_
data.  As described above there is NO impact for Case A
and Case B.  (The zealot will point out that a pointer-compare
against-NULL per page-swapped-in/out is not "NO" impact,
but let's ignore him for now.)  In Case C, there are
demonstrated benefits for SOME workloads... will frontswap
HARM some workloads?

I have openly admitted that for _cleancache_ on _zcache_,
sometimes the cost can exceed the benefits, and this was
actually demonstrated by one user on lkml.  For _frontswap_
it's really hard to imagine even a very contrived workload
where frontswap fails to provide an advantage.  I suppose
maybe if your swap disk lives on a PCI SSD and your CPU
is ancient single-core which does extremely slow copying
and compression?

IOW, I feel like you are giving me busywork, and any additional
evidence I present you will wave away anyway.

> > I understand that some kernel developers (mostly from one
> > company) continue to completely discount Xen, and
> > thus won't even look at the Xen results.  IMHO
> > that is mudslinging.
>=20
> OK, so lets look at this another way:  one of the signs of a good ABI is
> generic applicability.  Any good virtualisation ABI should thus work for
> all virtualisation systems (including VMware should they choose to take
> advantage of it).  The fact that transcendent memory only seems to work
> well for Xen is a red flag in this regard.

I think the tmem ABI will work fine with any virtualization system,
and particularly frontswap will.  There are some theoretical arguments
that KVM will get little or no benefit, but those arguments
pertain primarily to cleancache.  And I've noted that the ABI
was designed to be very extensible, so if KVM wants a batching
interface, they can add one.  To repeat from the LWN KS2011 report:

  "[Linus] stated that, simply, code that actually is used is
   code that is actually worth something... code aimed at
   solving the same problem is just a vague idea that is
   worthless by comparison...  Even if it truly is crap,
   we've had crap in the kernel before.  The code does not
   get better out of tree."

AND the API/ABI clearly supports other non-virtualization uses
as well.  The in-kernel hooks are very simple and the layering
is very clean.  The ABI is extensible, has been published for
nearly three years, and successfully rev'ed once (to accomodate
192-bit exportfs handles for cleancache).  Your arguments are on
very thin ice here.

It sounds like you are saying that unless/until KVM has a completed
measurable implementation... and maybe VMware and Hyper/V as well...
you don't think the tiny set of hooks that are frontswap should
be merged.  If so, that "red flag" sounds self-serving, not what I
would expect from someone like you.  Sorry.

> So what I don't like about this style of argument is the sleight of
> hand: I would expect the inactive but configured case to show mostly in
> the shrinker paths, which is where our major problems have been, so that
> would be cleancache, not frontswap, wouldn't it?

Yes, this is cleancache (already merged).  As described
above, frontswap executes no code in Case A or Case B so
can't possibly interact with the shrinker path.

> > So the remaining question is the performance impact when
> > compile-time AND runtime enabled; this is in the published
> > Xen presentation I've referenced -- the impact is much much
> > less than the performance gain.  IMHO benchmark results can
> > be easily manipulated so I prefer to discuss the theoretical
> > underpinnings which, in short, is that just about anything
> > a tmem backend does (hypercall, compression, deduplication,
> > even moving data across a fast network) is a helluva lot
> > faster than swapping a page to disk.
> >
> > Are there corner cases and probably even real workloads
> > where the cost exceeds the benefits?  Probably... though
> > less likely for frontswap than for cleancache because ONLY
> > pages that would actually be swapped out/in use frontswap.
> >
> > But I have never suggested that every kernel should always
> > unconditionally compile-time-enable and run-time-enable
> > frontswap... simply that it should be in-tree so those
> > who wish to enable it are able to enable it.
>=20
> In practise, most useful ABIs end up being compiled in ... and useful
> basically means useful to any constituency, however small.  If your ABI
> is useless, then fine, we don't have to worry about the configured but
> inactive case (but then again, we wouldn't have to worry about the ABI
> at all).  If it has a use, then kernels will end up shipping with it
> configured in which is why the inactive performance impact is so
> important to quantify.

So do you now understand/agree that the inactive performance is zero
and the interaction of an inactive configuration with the remainder
of the MM subsystem is zero?  And that you and your users will be
completely unaffected unless you/they intentionally turn it on,
not only compiled in, but explicitly at runtime as well?

So... understanding your preference for more workloads and your
preference that KVM should be demonstrated as a profitable user
first... is there anything else that you think should stand
in the way of merging frontswap so that existing and planned
kernel developers can build on top of it in-tree?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
