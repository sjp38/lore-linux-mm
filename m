Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 918046B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 15:40:12 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <29d985a7-e140-4ef2-9f1b-6fd49c244e79@default>
Date: Wed, 2 Nov 2011 12:39:49 -0700 (PDT)
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
 <424e9e3a-670d-4835-914f-83e99a11991a@default>
 <1320142403.7701.62.camel@dabdike>
 <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default
 1320219877.3091.22.camel@dabdike>
In-Reply-To: <1320219877.3091.22.camel@dabdike>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)

> Hm, straw man and ad hominem....

Let me apologize to you also for being sarcastic and
disrespectful yesterday.  I'm very sorry, I really do
appreciate your time and effort, and will try to focus
on the core of your excellent feedback, rather than
write another long rant.

> > Case A) CONFIG_FRONTSWAP=3Dn
> > Case B) CONFIG_FRONTSWAP=3Dy and no tmem backend registers
> > Case C) CONFIG_FRONTSWAP=3Dy and a tmem backend DOES register
>=20
> OK, so what I'd like to see is benchmarks for B and C.  B should confirm
> your contention of no cost (which is the ideal anyway) and C quantifies
> the passive cost to users.

OK, we'll see what we can do.  For B, given the natural
variance in any workload that is doing heavy swapping,
I'm not sure that I can prove anything, but I suppose
it will at least reveal if there are any horrible
glaring bugs.  However, in turn, I'd ask you to at
least confirm by code examination that, not counting
swapon and swapoff, the only change to the swapping
path is comparing a function pointer in struct
frontswap_ops against NULL.  (And, for case B, it
is NULL, so no function call ever occurs.)  OK?

For C, understood, benchmarks for zcache needed.
=20
> Well, OK, so there's a performance issue in some workloads what the
> above is basically asking is how bad is it and how widespread?

Just to clarify, the performance issue observed is
with cleancache with zcache, not frontswap.  That issue
has been observed on high-throughput old-single-core-CPU
machines, see https://lkml.org/lkml/2011/8/29/225

That issue is because cleancache (like the pagecache)
has to speculate on what pages might be needed in
the future.

Frontswap with zcache ONLY compresses pages that would
otherwise be physically swapped to a swap device.

So I don't see a performance issue with frontswap.
(But, yes, will still provide some benchmarks.)

> What I said was "one of the signs of a
> good ABI is generic applicability".  That doesn't mean you have to apply
> an ABI to every situation by coming up with a demonstration for the use
> case.  It does mean that people should know how to do it.  I'm not
> particularly interested in the hypervisor wars, but it does seem to me
> that there are legitimate questions about the applicability of this to
> KVM.

The guest->host ABI does work with KVM, and is in Sasha's
git tree.  It is a very simple shim, very similar to what
Xen uses, and will feed the same "opportunities" for swapping
to host memory for KVM as for Xen.

The arguments regarding KVM are whether, when the ABI is
used, if there is a sufficient performance gain, because
each page requires a (costly vmexit/vmenter sequence).
It seems obvious to me, but I've done what I can to
facilitate Sasha's and Neo's tmem-on-KVM work... their
code is just not finished yet.  As I've discussed with
Andrea, the ABI is very extensible so if it makes a huge
difference to add "batching" for KVM, the ABI won't get
in the way.

> As I said above, just benchmark it for B and C. As long as nothing nasty
> is happening, I'm fine with it.
>=20
> > So... understanding your preference for more workloads and your
> > preference that KVM should be demonstrated as a profitable user
> > first... is there anything else that you think should stand
> > in the way of merging frontswap so that existing and planned
> > kernel developers can build on top of it in-tree?
>=20
> No, I think that's my list.  The confusion over a KVM interface is
> solely because you keep saying it's not a Xen only ABI ... if it were,
> I'd be fine for it living in the xen tree.

OK, thanks!  But the core frontswap hooks are in routines in
mm/swapfile.c and mm/page_io.c so can't live in the xen tree.
And the Xen-specific stuff already does.

Sorry, getting long-winded again, but at least not ranting :-}

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
