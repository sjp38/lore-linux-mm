Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3BBF66B0069
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 17:48:20 -0400 (EDT)
Date: Sun, 30 Oct 2011 22:47:48 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111030214748.GB3650@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Fri, Oct 28, 2011 at 10:07:12AM -0700, Dan Magenheimer wrote:
> 
> > From: Johannes Weiner [mailto:jweiner@redhat.com]
> > Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
> > 
> > On Fri, Oct 28, 2011 at 06:36:03PM +0300, Pekka Enberg wrote:
> > > On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
> > > <dan.magenheimer@oracle.com> wrote:
> > > Looking at your patches, there's no trace that anyone outside your own
> > > development team even looked at the patches. Why do you feel that it's
> > > OK to ask Linus to pull them?
> > 
> > People did look at it.
> > 
> > In my case, the handwavy benefits did not convince me.  The handwavy
> > 'this is useful' from just more people of the same company does not
> > help, either.
> > 
> > I want to see a usecase that tangibly gains from this, not just more
> > marketing material.  Then we can talk about boring infrastructure and
> > adding hooks to the VM.
> > 
> > Convincing the development community of the problem you are trying to
> > solve is the undocumented part of the process you fail to follow.
> 
> Hi Johannes --
> 
> First, there are several companies and several unaffiliated kernel
> developers contributing here, building on top of frontswap.  I happen
> to be spearheading it, and my company is backing me up.  (It
> might be more appropriate to note that much of the resistance comes
> from people of your company... but please let's keep our open-source
> developer hats on and have a technical discussion rather than one
> which pleases our respective corporate overlords.)

I didn't mean to start a mud fight about this, I only mentioned the
part about your company because I already assume it sees value in tmem
- it probably wouldn't fund its development otherwise.  I just tend to
not care too much about Acks from the same company as the patch itself
and I believe other people do the same.

> Second, have you read http://lwn.net/Articles/454795/ ?
> If not, please do.  If yes, please explain what you don't
> see as convincing or tangible or documented.  All of this
> exists today as working publicly available code... it's
> not marketing material.

I remember answering this to you in private already some time ago when
discussing frontswap.

You keep proposing a bridge and I keep asking for proof that this is
not a bridge to nowhere.  Unless that question is answered, I am not
interested in discussing the bridge's design.

According to the LWN article, there are the following backends:

1. Zcache: allow swapping into compressed memory

This sets aside a portion of memory which the kernel will swap
compressed pages into upon pressure.  Now, obviously, reserving memory
from the system for this increases the pressure in the first place,
eating away on what space we have for anonymous memory and page cache.

Do you auto-size that region depending on workload?

If so, how?  If not, is it documented how to size it manually?

Where are the performance numbers for various workloads, including
both those that benefit from every bit of page cache and those that
would fit into memory without zcache occupying space?

However, looking at the zcache code, it seems it wants to allocate
storage pages only when already trying to swap out.  Are you sure this
works in reality?

2. RAMster: allow swapping between machines in a cluster

Are there people using it?  It, too, sounds like a good idea but I
don't see any proof it actually works as intended.

3. Xen: allow guests to swap into the host.

The article mentions that there is code to put the guests under
pressure and let them swap to host memory when the pressure is too
high.  This sounds useful.

Where is the code that controls the amount of pressure put on the
guests?

Where are the performance numbers?  Surely you can construct a case
where the initial machine sizes are not quite right and then collect
data that demonstrates the machines are rebalancing as expected?

4. kvm: same as Xen

Apart from the questions that already apply to Xen, I remember KVM
people in particular complaining about the synchroneous single-page
interface that results in a hypercall per swapped page.  What happened
to this concern?

---

I would really appreciate if you could pick one of those backends and
present them as a real and practical solution to real and practical
problems.  With documentation on configuration and performance data of
real workloads.  We can discuss implementation details like how memory
is exchanged between source and destination when we come to it.

I am not asking for just more code that uses your interface, I want to
know the real value for real people of the combination of all that
stuff.  With proof, not just explanations of how it's supposed to
work.

Until you can accept that, please include

	Nacked-by: Johannes Weiner <hannes@cmpxchg.org>

on all further stand-alone submissions of tmem core code and/or hooks
in the VM.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
