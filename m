Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D5EE76B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 03:44:47 -0400 (EDT)
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default>
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
	 <424e9e3a-670d-4835-914f-83e99a11991a@default 1320142403.7701.62.camel@dabdike>
	 <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Nov 2011 11:44:37 +0400
Message-ID: <1320219877.3091.22.camel@dabdike>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, 2011-11-01 at 11:10 -0700, Dan Magenheimer wrote:
[...]
> For clarity and brevity, let's call the three cases:
> 
> Case A) CONFIG_FRONTSWAP=n
> Case B) CONFIG_FRONTSWAP=y and no tmem backend registers
> Case C) CONFIG_FRONTSWAP=y and a tmem backend DOES register
> 
> There are no interactions in Case A, agreed?  I'm not sure
> if it is clear, but in Case B every hook checks to
> see if a tmem backend is registered... if not, the
> hook is a no-op except for the addition of a
> compare-pointer-against-NULL op, so there is no
> interaction there either.
> 
> So the only case where interactions are possible is
> Case C, which currently only can occur if a user
> specifies a kernel boot parameter of "tmem" or "zcache".
> (I know, a bit ugly, but there's a reason for doing
> it this way, at least for now.)

OK, so what I'd like to see is benchmarks for B and C.  B should confirm
your contention of no cost (which is the ideal anyway) and C quantifies
the passive cost to users.

[...]
> Can we agree that if frontswap is doing its job properly on
> any "normal" workload that is swapping, it is improving on a
> bad situation?

No, not without a set of benchmarks ... that's rather the point of doing
them.

> Then let's get back to your implied question about _negative_
> data.  As described above there is NO impact for Case A
> and Case B.  (The zealot will point out that a pointer-compare
> against-NULL per page-swapped-in/out is not "NO" impact,
> but let's ignore him for now.)  In Case C, there are
> demonstrated benefits for SOME workloads... will frontswap
> HARM some workloads?
> 
> I have openly admitted that for _cleancache_ on _zcache_,
> sometimes the cost can exceed the benefits, and this was
> actually demonstrated by one user on lkml.  For _frontswap_
> it's really hard to imagine even a very contrived workload
> where frontswap fails to provide an advantage.  I suppose
> maybe if your swap disk lives on a PCI SSD and your CPU
> is ancient single-core which does extremely slow copying
> and compression?
> 
> IOW, I feel like you are giving me busywork, and any additional
> evidence I present you will wave away anyway.

Well, OK, so there's a performance issue in some workloads what the
above is basically asking is how bad is it and how widespread?  

> > > I understand that some kernel developers (mostly from one
> > > company) continue to completely discount Xen, and
> > > thus won't even look at the Xen results.  IMHO
> > > that is mudslinging.
> > 
> > OK, so lets look at this another way:  one of the signs of a good ABI is
> > generic applicability.  Any good virtualisation ABI should thus work for
> > all virtualisation systems (including VMware should they choose to take
> > advantage of it).  The fact that transcendent memory only seems to work
> > well for Xen is a red flag in this regard.
> 
> I think the tmem ABI will work fine with any virtualization system,
> and particularly frontswap will.  There are some theoretical arguments
> that KVM will get little or no benefit, but those arguments
> pertain primarily to cleancache.  And I've noted that the ABI
> was designed to be very extensible, so if KVM wants a batching
> interface, they can add one.  To repeat from the LWN KS2011 report:
> 
>   "[Linus] stated that, simply, code that actually is used is
>    code that is actually worth something... code aimed at
>    solving the same problem is just a vague idea that is
>    worthless by comparison...  Even if it truly is crap,
>    we've had crap in the kernel before.  The code does not
>    get better out of tree."
> 
> AND the API/ABI clearly supports other non-virtualization uses
> as well.  The in-kernel hooks are very simple and the layering
> is very clean.  The ABI is extensible, has been published for
> nearly three years, and successfully rev'ed once (to accomodate
> 192-bit exportfs handles for cleancache).  Your arguments are on
> very thin ice here.
> 
> It sounds like you are saying that unless/until KVM has a completed
> measurable implementation... and maybe VMware and Hyper/V as well...
> you don't think the tiny set of hooks that are frontswap should
> be merged.  If so, that "red flag" sounds self-serving, not what I
> would expect from someone like you.  Sorry.

Hm, straw man and ad hominem.  What I said was "one of the signs of a
good ABI is generic applicability".  That doesn't mean you have to apply
an ABI to every situation by coming up with a demonstration for the use
case.  It does mean that people should know how to do it.  I'm not
particularly interested in the hypervisor wars, but it does seem to me
that there are legitimate questions about the applicability of this to
KVM.

[...]
> > > But I have never suggested that every kernel should always
> > > unconditionally compile-time-enable and run-time-enable
> > > frontswap... simply that it should be in-tree so those
> > > who wish to enable it are able to enable it.
> > 
> > In practise, most useful ABIs end up being compiled in ... and useful
> > basically means useful to any constituency, however small.  If your ABI
> > is useless, then fine, we don't have to worry about the configured but
> > inactive case (but then again, we wouldn't have to worry about the ABI
> > at all).  If it has a use, then kernels will end up shipping with it
> > configured in which is why the inactive performance impact is so
> > important to quantify.
> 
> So do you now understand/agree that the inactive performance is zero
> and the interaction of an inactive configuration with the remainder
> of the MM subsystem is zero?  And that you and your users will be
> completely unaffected unless you/they intentionally turn it on,
> not only compiled in, but explicitly at runtime as well?

As I said above, just benchmark it for B and C. As long as nothing nasty
is happening, I'm fine with it.

> So... understanding your preference for more workloads and your
> preference that KVM should be demonstrated as a profitable user
> first... is there anything else that you think should stand
> in the way of merging frontswap so that existing and planned
> kernel developers can build on top of it in-tree?

No, I think that's my list.  The confusion over a KVM interface is
solely because you keep saying it's not a Xen only ABI ... if it were,
I'd be fine for it living in the xen tree.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
