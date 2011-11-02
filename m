Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 08B806B006E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 16:19:54 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <dfda9890-f0e3-4a4a-ab9d-b4475a4f7a66@default>
Date: Wed, 2 Nov 2011 13:19:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike
 4EB16572.70209@redhat.com>
In-Reply-To: <4EB16572.70209@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Avi Kivity [mailto:avi@redhat.com]
> Sent: Wednesday, November 02, 2011 9:45 AM
> To: James Bottomley
> Cc: Andrea Arcangeli; Dan Magenheimer; Pekka Enberg; Cyclonus J; Sasha Le=
vin; Christoph Hellwig; David
> Rientjes; Linus Torvalds; linux-mm@kvack.org; LKML; Andrew Morton; Konrad=
 Wilk; Jeremy Fitzhardinge;
> Seth Jennings; ngupta@vflare.org; Chris Mason; JBeulich@novell.com; Dave =
Hansen; Jonathan Corbet
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On 11/01/2011 12:16 PM, James Bottomley wrote:
> > Actually, I think there's an unexpressed fifth requirement:
> >
> > 5. The optimised use case should be for non-paging situations.
> >
> > The problem here is that almost every data centre person tries very har=
d
> > to make sure their systems never tip into the swap zone.  A lot of
> > hosting datacentres use tons of cgroup controllers for this and
> > deliberately never configure swap which makes transcendent memory
> > useless to them under the current API.  I'm not sure this is fixable,
> > but it's the reason why a large swathe of users would never be
> > interested in the patches, because they by design never operate in the
> > region transcended memory is currently looking to address.
> >
> > This isn't an inherent design flaw, but it does ask the question "is
> > your design scope too narrow?"
>=20
> If you look at cleancache, then it addresses this concern - it extends
> pagecache through host memory.  When dropping a page from the tail of
> the LRU it first goes into tmem, and when reading in a page from disk
> you first try to read it from tmem.  However in many workloads,
> cleancache is actually detrimental.  If you have a lot of cache misses,
> then every one of them causes a pointless vmexit; considering that
> servers today can chew hundreds of megabytes per second, this adds up.
> On the other side, if you have a use-once workload, then every page that
> falls of the tail of the LRU causes a vmexit and a pointless page copy.

I agree with everything you've said except "_many_ workloads".
I would characterize this as "some" workloads, and increasingly
fewer machines... because core-counts are increasing faster than
the ability to attach RAM to them (according to published research).

I did code a horrible hack to fix this, but haven't gotten back
to RFC'ing it to see if there were better, less horrible, ideas.
It essentially only puts into tmem pages that are being reclaimed
but previously had the PageActive bit set... a smaller but
higher-hit-ratio source of pages, I think.

Anyway, I've been very open about this (see
https://lkml.org/lkml/2011/8/29/225 , but it affects cleancache.
Frontswap ONLY deals with pages that would have otherwise
been swapin/swapout to a physical swap device.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
