Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F37A16B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 16:08:31 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2baa4c1a-1fe0-4395-a428-f30703e8c435@default>
Date: Wed, 2 Nov 2011 13:08:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike>
 <49255b17-02bb-4a4a-b85a-cd5a879beb98@default
 1320221686.3091.40.camel@dabdike>
In-Reply-To: <1320221686.3091.40.camel@dabdike>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> > Not quite sure what you mean here (especially for frontswap)...
>=20
> I mean could it be used in a more controlled situation than an
> alternative to swap?

I think it could, but have focused on the cases which reduce
disk I/O: cleancache, which replaces refaults, and frontswap,
which replaces swap in/outs.  Did you have some other
kernel data in mind?
=20
> OK, I still don't think you understand what I'm saying.  Machines in a
> Data Centre tend to be provisioned to criticality.  What this means is
> that the Data Centre has a bunch of mandatory work and a bunch of Best
> Effort work (and grades in between).  We load up the mandatory work
> according to the resource limits being careful not to overprovision the
> capacity then we look at the spare capacity and slot in the Best effort
> stuff.  We want the machine to run at capacity, not over it; plus we
> need to respond instantly for demands of the mandatory work, which
> usually involves either dialling down or pushing away best effort work.
> In this situation, action is taken long before the swap paths become
> active because if they activate, the entire machine bogs and you've just
> blown the SLA on the mandatory work.
>=20
> > It's true, those that are memory-rich and can spend nearly
> > infinite amounts on more RAM (and on high-end platforms that
> > can expand to hold massive amounts of RAM) are not tmem's
> > target audience.
>=20
> Where do you get the infinite RAM idea from?  The most concrete example
> of what I said above are Lean Data Centres, which are highly resource
> constrained but they want to run at (or just below) criticality so that
> they get through all of the Mandatory and as much of the best effort
> work as they can.

OK, I think you are asking the same question as I answered for
Kame earlier today.

By "infinite" I am glibly describing any environment where the
data centre administrator positively knows the maximum working
set of every machine (physical or virtual) and can ensure in
advance that the physical RAM always exceeds that maximum
working set.  As you say, these machines need not be configured
with a swap device as they, by definition, will never swap.

The point of tmem is to use RAM more efficiently by taking
advantage of all the unused RAM when the current working set
size is less than the maximum working set size.  This is very
common in many data centers too, especially virtualized.  It
turned out that an identical set of hooks made pagecache compression
possible, and swappage compression more flexible than zram,
and that became the single-kernel user, zcache.

RAM optimization and QoS guarantees are generally mutually
exclusive, so this doesn't seem like a good test case for tmem
(but see below).

> > > This isn't an inherent design flaw, but it does ask the question "is
> > > your design scope too narrow?"
> >
> > Considering all the hazing that I've gone through to get
> > this far, you think I should _expand_ my design scope?!? :-)
> > Thanks, I guess I'll pass. :-)

(Sorry again for the sarcasm :-(

> Sure, I think the conclusion that Transcendent Memory has no
> applicability to a lean Data Centre isn't unreasonable; I was just
> probing to see if it was the only conclusion.

Now that I understand it better, I think it does have
a limited application for your Lean Data Centre...
but only to optimize the "best effort" part of the
data centre workload.  That would probably be a relatively
easy enhancement... but, please, my brain is full now and
my typing fingers hurt, so can we consider it post-merge?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
