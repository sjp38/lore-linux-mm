Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91D0A6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 16:46:06 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <571bc7cd-f97f-4882-960c-06b2944f1c4a@default>
Date: Wed, 2 Nov 2011 13:45:52 -0700 (PDT)
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
 <20139.5644.583790.903531@quad.stoffel.home>
 <3ac142d4-a4ca-4a24-bf0b-69a90bd1d1a0@default>
 <1320005162.15403.14.camel@nimitz 4EB19DE5.4080108@redhat.com>
In-Reply-To: <4EB19DE5.4080108@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Jonathan Corbet <corbet@lwn.net>

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On 10/30/2011 04:06 PM, Dave Hansen wrote:
> > On Sun, 2011-10-30 at 12:18 -0700, Dan Magenheimer wrote:
> >>> since they're the ones who will have to understand this stuff and kno=
w
> >>> how to maintain it.  And keeping this maintainable is a key goal.
> >>
> >> Absolutely agree.  Count the number of frontswap lines that affect
> >> the current VM core code and note also how they are very clearly
> >> identified.  It really is a very VERY small impact to the core VM
> >> code (e.g. in the files swapfile.c and page_io.c).
> >
> > Granted, the impact on the core VM in lines of code is small.  But, I
> > think the behavioral impact is potentially huge since tmem's hooks add
> > non-trivial amounts of framework underneath the VM in core paths.  In
> > zcache's case, this means a bunch of allocations and an entirely new
> > allocator memory allocator being used in the swap paths.
>=20
> My only real behaviour concern with tmem is that
> /proc/sys/overcommit_memory will no longer be able
> to do anything useful, since we'll never know in
> advance how much memory is available.

True, for Case C (as defined in James Bottomley subthread).
For Case A and Case B (ie. no tmem backend enabled),
end-users can still rely on that existing mechanism,
so they have a choice.
=20
> That may be outweighed by the benefits of having
> more memory available than before, and a reasonable
> tradeoff to make for the users.
>=20
> That leaves us with having the code cleaned up to
> reasonable standards.  To be honest, I would rather
> have larger hooks in the existing mm code, than
> exported variables and having the hooks live elsewhere
> (where people changing the "normal" mm code won't see
> it, and are more likely to break it).

Hmmm... the original hooks in 2009 were larger, but there
was lots of feedback to hide the ugly details as much as
possible.  As a side effect, higher level info is
passed via the hooks, e.g. a "struct page *" rather
than swaptype/entry, so backends have more flexibility
(and IIUC it looks like Andrea's proposed changes to
zcache may need the higher level info).

But if you want to propose some code showing what
you mean by "larger" hooks and they result in the
same information available in the backends, and
if others agree your hooks are more maintainable,
I am certainly open to changing them and re-posting.

Note that this could happen post-frontswap-merge too
though which would, naturally, be my preference ;-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
