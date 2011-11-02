Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C04846B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 16:27:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1ef1abbc-f092-4784-9f2e-1d9ca151e9e0@default>
Date: Wed, 2 Nov 2011 13:27:01 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike>
 <4EB16572.70209@redhat.com> <20111102160201.GB18879@redhat.com
 4EB16C17.40906@redhat.com>
In-Reply-To: <4EB16C17.40906@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Avi Kivity [mailto:avi@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On 11/02/2011 06:02 PM, Andrea Arcangeli wrote:
> > Hi Avi,
> >
> > On Wed, Nov 02, 2011 at 05:44:50PM +0200, Avi Kivity wrote:
> > > If you look at cleancache, then it addresses this concern - it extend=
s
> > > pagecache through host memory.  When dropping a page from the tail of
> > > the LRU it first goes into tmem, and when reading in a page from disk
> > > you first try to read it from tmem.  However in many workloads,
> > > cleancache is actually detrimental.  If you have a lot of cache misse=
s,
> > > then every one of them causes a pointless vmexit; considering that
> > > servers today can chew hundreds of megabytes per second, this adds up=
.
> > > On the other side, if you have a use-once workload, then every page t=
hat
> > > falls of the tail of the LRU causes a vmexit and a pointless page cop=
y.
> >
> > I also think it's bad design for Virt usage, but hey, without this
> > they can't even run with cache=3Dwriteback/writethrough and they're
> > forced to cache=3Doff, and then they claim specvirt is marketing, so fo=
r
> > Xen it's better than nothing I guess.
>=20
> Surely Xen can use the pagecache, it uses Linux for I/O just like kvm.
>=20
> > I'm trying right now to evaluate it as a pure zcache host side
> > optimization.
>=20
> zcache style usage is fine.  It's purely internal so no ABI constraints,
> and no hypercalls either.  It's still synchronous though so RAMster like
> approaches will not work well.

Still experimental, but only the initial local put must be synchronous.
RAMster uses a separate thread to "remotify" pre-compressed pages.
The "get" still needs to be synchronous, but (if I ever have time to
get back to coding it) I've got some ideas on how to fix that.  If
I manage to get that working, perhaps it could be used for Andrea's
write-precompressed-zcache-pages-to-disk.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
