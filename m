Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA5E6B006C
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 16:19:22 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
Date: Fri, 28 Oct 2011 13:19:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
 <20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default
 20138.62532.493295.522948@quad.stoffel.home>
In-Reply-To: <20138.62532.493295.522948@quad.stoffel.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: John Stoffel [mailto:john@stoffel.org]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> >>>>> "Dan" =3D=3D Dan Magenheimer <dan.magenheimer@oracle.com> writes:
>=20
> Dan> Second, have you read http://lwn.net/Articles/454795/ ?
> Dan> If not, please do.  If yes, please explain what you don't
> Dan> see as convincing or tangible or documented.  All of this
> Dan> exists today as working publicly available code... it's
> Dan> not marketing material.
>=20
> I was vaguely interested, so I went and read the LWN article, and it
> didn't really provide any useful information on *why* this is such a
> good idea.

Hi John --

Thanks for taking the time to read the LWN article and sending
some feedback.  I admit that, after being immersed in the
topic for three years, it's difficult to see it from the
perspective of a new reader, so I apologize if I may have
left out important stuff.  I hope you'll take the time
to read this long reply.

"WHY" this is such a good idea is the same as WHY it is
useful to add RAM to your systems.  Tmem expands the amount
of useful "space" available to a memory-constrained kernel
either via compression (transparent to the rest of the kernel
except for the handful of hooks for cleancache and frontswap,
using zcache) or via memory that was otherwise not visible
to the kernel (hypervisor memory from Xen or KVM, or physical
RAM on another clustered system using RAMster).  Since a
kernel always eats memory until it runs out (and then does
its best to balance that maximum fixed amount), this is actually
much harder than it sounds.

So I'm asking: Is that not clear from the LWN article?  Or
do you not believe that more "space" is a good idea?  Or
do you not believe that tmem mitigates that problem?

Clearly if you always cram enough RAM into your system
so that you never have a paging/swapping problem (i.e your
RAM is always greater than your "working set"), tmem's
NOT a good idea.  So the built-in assumption is that
RAM is a constrained resource.  Increasingly (especially
in virtual machines, but elsewhere as well), this is true.

> Particularly, I didn't see any before/after numbers which compared the
> kernel running various loads both with and without these
> transcendental memory patches applied.  And of course I'd like to see
> numbers when they patches are applied, but there's no TM
> (Transcendental Memory) in actual use, so as to quantify the overhead.

Actually there is.  But the only serious performance analysis
has been on Xen, and I get reamed every time I use that word,
so I'm a bit gun-shy.  If you are seriously interested and
willing to ignore that X-word, see the last few slides of:

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/Transc=
endentMemoryXenSummit2010.pdf

There's some argument about whether the value will be as
high for KVM, but that obviously can't be measured until
there is a complete KVM implementation, which requires
frontswap.

It would be nice to also have some numbers for zcache, I agree.

> Your article would also be helped with a couple of diagrams showing
> how this really helps.  Esp in the cases where the system just
> endlessly says "no" to all TM requests and the kernel or apps need to
> them fall back to the regular paths.

The "no" cases occur whenever there is NO additional memory,
so obviously it doesn't help for those cases; the appropriate
question for those cases is "how much does it hurt" and the
answer is (usually) effectively zero.  Again if you know
you've always got enough RAM to exceed your working set,
don't enable tmem/frontswap/cleancache.

For the "does really help" cases, I apologize, but I just
can't think how to diagrammatically show clearly that having
more RAM is a good thing.

> In my case, $WORK is using linux with large memory to run EDA
> simulations, so if we swap, performance tanks and we're out of luck.
> So for my needs, I don't see how this helps.

Do you know what percent of your total system cost is spent
on RAM, including variable expense such as power/cooling?
Is reducing that cost relevant to your $WORK?  Or have
you ever ran into a "buy more RAM" situation where you couldn't
expand because your machine RAM slots were maxed out?

> For my home system, I run an 8Gb RAM box with a couple of KVM VMs, NFS
> file service to two or three clients (not counting the VMs which mount
> home dirs from there as well) as well as some light WWW developement
> and service.  How would TM benefit me?  I don't use Xen, don't want to
> play with it honestly because I'm busy enough as it is, and I just
> don't see the hard benefits.

(I use "tmem" since TM means "trademark" to many people.)

Does 8GB always cover the sum of the working sets of all your
KVM VMs?  If so, tmem won't help.  If a VM in your workload
sometimes spikes, tmem allows that spike to be statistically
"load balanced" across RAM claimed by other VMs which may be
idle or have a temporarily lower working set.  This means less
paging/swapping and better sum-over-all-VMs performance.

> So the onus falls on *you* and the other TM developers to sell this
> code and it's benefits (and to acknowledge it's costs) to the rest of
> the Kernel developers, esp those who hack on the VM.  If you can't
> come up with hard numbers and good examples with good numbers, then

Clearly there's a bit of a chicken-and-egg problem.  Frontswap
(and cleancache) are the foundation, and it's hard to build
anything solid without a foundation.

For those who "hack on the VM", I can't imagine why the handful
of lines in the swap subsystem, which is probably the most stable
and barely touched subsystem in Linux or any OS on the planet,
is going to be a burden or much of a cost.

> you're out of luck.

Another way of looking at it is that the open source
community is out of luck.  Tmem IS going into real shipping
distros, but it (and Xen support and zcache and KVM support and
cool things like RAMster) probably won't be in the distro "you"
care about because this handful of nearly innocuous frontswap hooks
didn't get merged.  I'm trying to be a good kernel citizen
but I can't make people listen who don't want to.

Frontswap is the last missing piece.  Why so much resistance?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
