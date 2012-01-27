Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id AD73F6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 13:47:03 -0500 (EST)
MIME-Version: 1.0
Message-ID: <9813c0cd-0335-4994-b734-e9fc7872c0cb@default>
Date: Fri, 27 Jan 2012 10:46:57 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
 <4F218D36.2060308@linux.vnet.ibm.com>
 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
 <20120126163150.31a8688f.akpm@linux-foundation.org>
 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
 <20120126171548.2c85dd44.akpm@linux-foundation.org>
 <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
 <1327671787.2977.17.camel@dabdike.int.hansenpartnership.com>
 <3ac611ee-8830-41bd-8464-6867da701948@default>
 <1327686876.2977.37.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1327686876.2977.37.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, lsf-pc@lists.linux-foundation.org

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: RE: [PATCH] mm: implement WasActive page flag (for improving cle=
ancache)
>=20
> On Fri, 2012-01-27 at 09:32 -0800, Dan Magenheimer wrote:
> > > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > > What I was wondering was instead of using a flag, could we make the L=
RU
> > > lists do this for us ... something like have a special LRU list for
> > > pages added to the page cache but never referenced since added?  It
> > > sounds like you can get your WasActive information from the same type=
 of
> > > LRU list tricks (assuming we can do them).
> >
> > Hmmm... I think this would mean more LRU queues but that may be
> > the right long term answer.  Something like?
> >
> > =09read but not used yet LRU
> > =09readahead but not used yet LRU
>=20
> What's the difference between these two?  I think read but not used is
> some form of readahead regardless of where it came from.

Oops, I meant "read but used only once (to resolve a page fault)" LRU.

> > =09active LRU
> > =09previously active LRU
>=20
> I don't quite understand why you need two queues here, either.  Surely
> active is logically at the bottom of the LRU and previously active at
> the top (assuming we've separated the unused pages to a different LRU
> list).

Cleancache only sees pages when they "fall off the end of the world",
so would like to differentiate between clean pages that were used just
once and pages that were used more than once, but not recently.
There may be better heuristics for cleancache too.
=20
> > Naturally, this then complicates the eviction selection process.
> >
> > > I think the memory pressure eviction heuristic is: referenced but not
> > > recently used pages first followed by unreferenced and not recently u=
sed
> > > readahead pages.  The key being to keep recently read in readahead pa=
ges
> > > until last because there's a time between doing readahead and getting
> > > the page accessed and we don't want to trash a recently red in readah=
ead
> > > page only to have the process touch it and find it has to be read in
> > > again.
> >
> > I suspect that any further progress on the page replacement heuristics
> > is going to require more per-page data to be stored.  Which means
> > that it probably won't work under the constraints of 32-bit systems.
> > So it might also make sense to revisit when/whether to allow the
> > heuristics to be better on a 64-bit system than on a 32-bit.
> > (Even ARM now has 64-bit processors!)  I put this on my topic list
> > for LSF/MM, though I have no history of previous discussion so
> > this may already have previously been decided.
>=20
> I've got to say why? on this.  The object is to find a simple solution
> that's good enough.  I think separating the LRU list into two based on
> once referenced/never referenced might be enough to derive all the
> information we need.

Maybe I'm misunderstanding (in which case a complete list of the LRU
queues you are proposing would be good), but doesn't the existing design
already do this?  Actually, IIUC the existing file cache design has a
=09"referenced more than once" LRU ("active")
and a second ("inactive") LRU queue which combines
=09"referenced only once" OR
=09"readahead and never referenced" OR
=09"referenced more than once but not referenced recently"
Are you proposing to add more queues or define the existing two queues
differently?

So my strawman list of LRU queues separates the three ORs in the inactive
LRU queue to three separate LRU queues, for a total of four.

 INACTIVE-typeA) read but used only once to resolve a page fault LRU
 INACTIVE-typeB) readahead but not used yet LRU
 INACTIVE-typeC) previously active LRU
 ACTIVE) active LRU

> Until that theory is disproved, there's not much
> benefit to developing ever more complex heuristics.

I think we are both "disproving" the theory that the existing
two LRU queues are sufficient.  You need to differentiate between
typeA and typeB (to ensure typeB doesn't get evicted too quickly)
and I would like to differentiate typeC from typeA/typeB to have
heuristic data for cleancache at the time the kernel evicts the page.

Does that make sense?

P.S. I'm interpreting from http://linux-mm.org/PageReplacementDesign=20
rather from full understanding of the current code, so please correct
me if I got it wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
