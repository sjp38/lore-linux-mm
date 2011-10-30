Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B57C86B0069
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 19:19:49 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <8d381812-ea14-46a7-95f7-e2327dbb062e@default>
Date: Sun, 30 Oct 2011 16:19:26 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default
 20111030214748.GB3650@redhat.com>
In-Reply-To: <20111030214748.GB3650@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Johannes Weiner [mailto:jweiner@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)

Hi Johannes --

Thanks for taking the time for some real technical discussion (below).

> On Fri, Oct 28, 2011 at 10:07:12AM -0700, Dan Magenheimer wrote:
> >
> > > From: Johannes Weiner [mailto:jweiner@redhat.com]
> > > Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
> > >
> > > On Fri, Oct 28, 2011 at 06:36:03PM +0300, Pekka Enberg wrote:
> > > > On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
> > > > <dan.magenheimer@oracle.com> wrote:
> > > > Looking at your patches, there's no trace that anyone outside your =
own
> > > > development team even looked at the patches. Why do you feel that i=
t's
> > > > OK to ask Linus to pull them?
> > >
> > > People did look at it.
> > >
> > > In my case, the handwavy benefits did not convince me.  The handwavy
> > > 'this is useful' from just more people of the same company does not
> > > help, either.
> > >
> > > I want to see a usecase that tangibly gains from this, not just more
> > > marketing material.  Then we can talk about boring infrastructure and
> > > adding hooks to the VM.
> > >
> > > Convincing the development community of the problem you are trying to
> > > solve is the undocumented part of the process you fail to follow.
> >
> > Hi Johannes --
> >
> > First, there are several companies and several unaffiliated kernel
> > developers contributing here, building on top of frontswap.  I happen
> > to be spearheading it, and my company is backing me up.  (It
> > might be more appropriate to note that much of the resistance comes
> > from people of your company... but please let's keep our open-source
> > developer hats on and have a technical discussion rather than one
> > which pleases our respective corporate overlords.)
>=20
> I didn't mean to start a mud fight about this, I only mentioned the
> part about your company because I already assume it sees value in tmem
> - it probably wouldn't fund its development otherwise.  I just tend to
> not care too much about Acks from the same company as the patch itself
> and I believe other people do the same.

Oops, sorry for mudslinging if none was intended.

Although I understand your position about Acks from the same company,
isn't that challenging the integrity of the individual's ack/review,
implying that they are not really reviewing the code with the same
intensity as if it came from another company?  Especially with
something like tmem, maybe the review is just as valid, and people
from the same company have just had more incentive to truly
understand the intent and potential of the functionality, as well as
the syntax in the code?  And maybe, on some patches, reviewers ARE
from different companies are "good buddies" and watch each others'
back and those reviews are not really complete?

So perhaps this default assumption about code review is flawed?

> > Second, have you read http://lwn.net/Articles/454795/ ?
> > If not, please do.  If yes, please explain what you don't
> > see as convincing or tangible or documented.  All of this
> > exists today as working publicly available code... it's
> > not marketing material.
>=20
> I remember answering this to you in private already some time ago when
> discussing frontswap.

Yes, reading ahead, all the questions sound familiar and I thought
they were all answered (albeit some offlist).  I think the conversation
ended at that point, so I assumed any issues were resolved.

> You keep proposing a bridge and I keep asking for proof that this is
> not a bridge to nowhere.  Unless that question is answered, I am not
> interested in discussing the bridge's design.
>
> According to the LWN article, there are the following backends:
>=20
> 1. Zcache: allow swapping into compressed memory
>=20
> This sets aside a portion of memory which the kernel will swap
> compressed pages into upon pressure.  Now, obviously, reserving memory
> from the system for this increases the pressure in the first place,
> eating away on what space we have for anonymous memory and page cache.
>=20
> Do you auto-size that region depending on workload?

Yes.  A key value of the whole transcendent memory design
is that everything is done dynamically.  That's one
reason that Nitin Gupta (author of zram) supports zcache.

> If so, how?  If not, is it documented how to size it manually?

See above.  There are some zcache policy parameters that can be
adjusted manually (currently through sysfs) so we can adjust
the defaults as necessary over time.

> Where are the performance numbers for various workloads, including
> both those that benefit from every bit of page cache and those that
> would fit into memory without zcache occupying space?

I have agreed already that more zcache measurement is warranted
(though I maintain it will get a lot more measurement merged than
it will unmerged).  So I can only answer theoretically, though
I would appreciate your comment if you disagree.

Space used for page cache is almost always opportunistic; it is
a "guess" that the page will be needed again in the future.
Frontswap only stores pages that MUST otherwise be swapped.
Swapping occurs only if the clean list is empty (or if the
MM system is too slow to respond to changes in workload).
In fact some of the pages-to-be-swapped that end up in
frontswap can be dirty page cache pages.

All of this is handled dynamically.  The kernel is still deciding
which pages to keep and which to reclaim and which to swap.
The hooks simply grab pages as they are going by.  That's
why the frontswap patch can be so simple and can have many "users"
built on top of it.

> However, looking at the zcache code, it seems it wants to allocate
> storage pages only when already trying to swap out.  Are you sure this
> works in reality?

Yes.  I'd encourage you to try it.  I'd be a fool if I tried
to guarantee that there are no bugs of course.

> 2. RAMster: allow swapping between machines in a cluster
>=20
> Are there people using it?  It, too, sounds like a good idea but I
> don't see any proof it actually works as intended.

No.  I've posted the code publicly but it's still a godawful mess
and I'd be embarrassed if anyone looked at it.  But the code
does work and I've got some ideas on how to make it more
upstreamable.  If anybody seriously wants to work on it right
now, I could do that, but I'd prefer some more time alone with
it first.

Conceptually, it's just a matter of moving pages to a different
machine instead of across a hypercall interface.  All the "magic"
is in the frontswap and cleancache hooks.  They run on both
machines, both dynamically managing space (and compressing it
too).  The code uses ocfs2 for "cluster" discovery and is built
on top of a modified zcache.

> 3. Xen: allow guests to swap into the host.
>=20
> The article mentions that there is code to put the guests under
> pressure and let them swap to host memory when the pressure is too
> high.  This sounds useful.
>
> Where is the code that controls the amount of pressure put on the
> guests?

See drivers/xen/xen-selfballoon.c, which was just merged at 3.1,
though there have been versions of it floating around for 2+ years.
Note there's a bug fix pending that makes the pressure a little less
aggressive.  I think it is/was submitted for the open 3.2 window.
(Note the same file manipulates the number of pages in frontswap.)
=20
> Where are the performance numbers?  Surely you can construct a case
> where the initial machine sizes are not quite right and then collect
> data that demonstrates the machines are rebalancing as expected?

Yes I can.  It just works and with the right tools running, it's
even fun to watch.  Some interesting performance numbers were
published at Xen Summit 2010.  See the last few pages of:

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/Transc=
endentMemoryXenSummit2010.pdf=20

The speakers notes (so you can follow the presentation without video)
are in the same dir.

> 4. kvm: same as Xen
>=20
> Apart from the questions that already apply to Xen, I remember KVM
> people in particular complaining about the synchroneous single-page
> interface that results in a hypercall per swapped page.  What happened
> to this concern?

I think we (me and the KVM people) agreed that the best way to determine
if this is a concern is to just measure it.  Sasha and Neo are working on
a KVM implementation which should make this possible (but neither wants
to invest a lot of time if frontswap isn't merged or has a clear path
to merging).

So, again, theoretically, and please argue if you disagree...
(and yes I know real measurements are better, but I think we all
know how easy it is to manipulate benchmarks so IMHO a
theoretical understanding is useful too).

What is the cost of a KVM hypercall (vmexit/vmenter) vs the cost of
swapping a page?  Clearly, reading/writing a disk is a very slow
operation, but has very little CPU overhead (though preparing a
page to be swapped via blkio is NOT very inexpensive).  But if
you are swapping, it is almost never the case that the CPU is busy,
especially on a multicore CPU.

I expect on old slow (e.g. first gen 1 core VT-x processors) this might
sometimes be measureable, but rarely an issue.  On modern processors,
I don't expect it to be significant.

BTW, it occurs to me that this is now measureable on Xen too, since
Xen tmem works now for fully-virtualized guests.  I don't have
the machines to reproduce the same experiment, but if you look at
the graphs in the Xen presentation, you can see that CPU utilization
goes up substantially, but throughput still improves.  I am almost
positive that the CPU cost of compression/decompression plus the
cost of deduplication insert/fetch exceeds the cost of a vmexit/vmenter,
so the additional cost of vmexit/vmenter will at most increase
the CPU utilization.  The real performance gain comes from avoiding
(waiting for) disk accesses.

> I would really appreciate if you could pick one of those backends and
> present them as a real and practical solution to real and practical
> problems.  With documentation on configuration and performance data of
> real workloads.  We can discuss implementation details like how memory
> is exchanged between source and destination when we come to it.
>=20
> I am not asking for just more code that uses your interface, I want to
> know the real value for real people of the combination of all that
> stuff.  With proof, not just explanations of how it's supposed to
> work.

Well, the Xen implementation is by far the most mature and the
Xen presentation above is reasonably conclusive though, as always,
more measurements of more workloads would be good.

Not to get back into the mudslinging, but certain people from certain
companies try to ignore or minimize the value of Xen, so I've been
trying to emphasize the other (non-Xen, non-virtualization) code.
Personally, I think the Xen use case is sufficient by itself as it
solves a problem nobody else has ever solved (or, more precisely,
that VMware attempted to solve but, as real VMware customers will
attest, did so very poorly).

To be a good Linux kernel citizen, I've encouraged my company to hold
off on widespread support for Xen tmem until all the parts are upstream
in Linux, so there isn't a wide existing body of "proof" data.  And
releasing customer data from my employer requires an act of God.  But
private emails to Linus for cleancache seemed to convince him that
there was enough justification for cleancache.  I thought frontswap
was simpler and would be the easy part, but was clearly mistaken :-(
We are now proceeding fully with Xen tmem with both frontswap
and cleancache in the kernel.

> Until you can accept that, please include
>=20
> =09Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
> on all further stand-alone submissions of tmem core code and/or hooks
> in the VM.  Thanks.

If you are willing to accept that Xen is a valid use case, I
think I have provided that (although I agree that more data would
be good and would be happy to take suggestions for what data to
provide).  If not, I would call that a form of mudslinging
but will add your Nack.  Please let me know.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
