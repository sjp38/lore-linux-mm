Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 45BE36B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 04:22:30 -0400 (EDT)
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <49255b17-02bb-4a4a-b85a-cd5a879beb98@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	 <75efb251-7a5e-4aca-91e2-f85627090363@default>
	 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
	 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
	 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
	 <20111031181651.GF3466@redhat.com 1320142590.7701.64.camel@dabdike>
	 <49255b17-02bb-4a4a-b85a-cd5a879beb98@default>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Nov 2011 12:14:46 +0400
Message-ID: <1320221686.3091.40.camel@dabdike>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Tue, 2011-11-01 at 11:21 -0700, Dan Magenheimer wrote:
> > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
> > 
> > Actually, I think there's an unexpressed fifth requirement:
> > 
> > 5. The optimised use case should be for non-paging situations.
> 
> Not quite sure what you mean here (especially for frontswap)...

I mean could it be used in a more controlled situation than an
alternative to swap?

> > The problem here is that almost every data centre person tries very hard
> > to make sure their systems never tip into the swap zone.  A lot of
> > hosting datacentres use tons of cgroup controllers for this and
> > deliberately never configure swap which makes transcendent memory
> > useless to them under the current API.  I'm not sure this is fixable,
> 
> I can't speak for cgroups, but the generic "state-of-the-art"
> that you describe is a big part of what frontswap DOES try
> to fix, or at least ameliorate.  Tipping "into the swap zone"
> is currently very bad.  Very very bad.  Frontswap doesn't
> "solve" swapping, but it is the foundation for some of the
> first things in a long time that aren't just "add more RAM."

OK, I still don't think you understand what I'm saying.  Machines in a
Data Centre tend to be provisioned to criticality.  What this means is
that the Data Centre has a bunch of mandatory work and a bunch of Best
Effort work (and grades in between).  We load up the mandatory work
according to the resource limits being careful not to overprovision the
capacity then we look at the spare capacity and slot in the Best effort
stuff.  We want the machine to run at capacity, not over it; plus we
need to respond instantly for demands of the mandatory work, which
usually involves either dialling down or pushing away best effort work.
In this situation, action is taken long before the swap paths become
active because if they activate, the entire machine bogs and you've just
blown the SLA on the mandatory work.

This is why a lot of data centres simply never configure swap for this
reason.  Putting frontswap in the swap paths means that the data centre
job scheduler has taken action long before frontswap ever activates, so
it can never be used which is why I wrote the above.  

> > but it's the reason why a large swathe of users would never be
> > interested in the patches, because they by design never operate in the
> > region transcended memory is currently looking to address.
> 
> It's true, those that are memory-rich and can spend nearly
> infinite amounts on more RAM (and on high-end platforms that
> can expand to hold massive amounts of RAM) are not tmem's
> target audience.

Where do you get the infinite RAM idea from?  The most concrete example
of what I said above are Lean Data Centres, which are highly resource
constrained but they want to run at (or just below) criticality so that
they get through all of the Mandatory and as much of the best effort
work as they can.

> > This isn't an inherent design flaw, but it does ask the question "is
> > your design scope too narrow?"
> 
> Considering all the hazing that I've gone through to get
> this far, you think I should _expand_ my design scope?!? :-)
> Thanks, I guess I'll pass. :-)

Sure, I think the conclusion that Transcendent Memory has no
applicability to a lean Data Centre isn't unreasonable; I was just
probing to see if it was the only conclusion.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
