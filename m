Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id D4ABF6B0002
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:19:09 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f0272a06-141a-4d33-9976-ee99467f3aa2@default>
Date: Tue, 14 May 2013 13:18:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
 <20130514163541.GC4024@medulla>
In-Reply-To: <20130514163541.GC4024@medulla>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> <snip>
>
> > > +/* The maximum percentage of memory that the compressed pool can occ=
upy */
> > > +static unsigned int zswap_max_pool_percent =3D 20;
> > > +module_param_named(max_pool_percent,
> > > +=09=09=09zswap_max_pool_percent, uint, 0644);
>=20
> <snip>
>
> > This limit, along with the code that enforces it (by calling reclaim
> > when the limit is reached), is IMHO questionable.  Is there any
> > other kernel memory allocation that is constrained by a percentage
> > of total memory rather than dynamically according to current
> > system conditions?  As Mel pointed out (approx.), if this limit
> > is reached by a zswap-storm and filled with pages of long-running,
> > rarely-used processes, 20% of RAM (by default here) becomes forever
> > clogged.
>=20
> So there are two comments here 1) dynamic pool limit and 2) writeback
> of pages in zswap that won't be faulted in or forced out by pressure.
>=20
> Comment 1 feeds from the point of view that compressed pages should just =
be
> another type of memory managed by the core MM.  While ideal, very hard to
> implement in practice.  We are starting to realize that even the policy
> governing to active vs inactive list is very hard to get right. Then shri=
nkers
> add more complexity to the policy problem.  Throwing another type in the =
mix
> would just that much more complex and hard to get right (assuming there e=
ven
> _is_ a "right" policy for everyone in such a complex system).
>=20
> This max_pool_percent policy is simple, works well, and provides a
> deterministic policy that users can understand. Users can be assured that=
 a
> dynamic policy heuristic won't go nuts and allow the compressed pool to g=
row
> unbounded or be so aggressively reclaimed that it offers no value.

Hi Seth --

Hmmm... I'm not sure how to politely say "bullshit". :-)

The default 20% was randomly pulled out of the air long ago for zcache
experiments.  If you can explain why 20% is better than 19% or 21%, or
better than 10% or 30% or even 50%, that would be a start.  Then please try
to explain -- in terms an average sysadmin can understand -- under
what circumstances this number should be higher or lower, that would
be even better.  In fact if you can explain it in even very broadbrush
terms like "higher for embedded" and "lower for server" that would be
useful.  If the top Linux experts in compression can't answer these
questions (and the default is a random number, which it is), I don't
know how we can expect users to be "assured".

What you mean is "works well"... on the two benchmarks you've tried it
on.  You say it's too hard to do dynamically... even though every other
significant RAM user in the kernel has to do it dynamically.
Workloads are dynamic and heavy users of RAM needs to deal with that.
You don't see a limit on the number of anonymous pages in the MM subsystem,
and you don't see a limit on the number of inodes in btrfs.  Linus
would rightfully barf all over those limits and (if he was paying attention
to this discussion) he would barf on this limit too.

It's unfortunate that my proposed topic for LSFMM was pre-empted
by the zsmalloc vs zbud discussion and zswap vs zcache, because
I think the real challenge of zswap (or zcache) and the value to
distros and end users requires us to get this right BEFORE users
start filing bugs about performance weirdness.  After which most
users and distros will simply default to 0% (i.e. turn zswap off)
because zswap unpredictably sometimes sucks.

<flame off> sorry...

> Comment 2 I agree is an issue. I already have patches for a "periodic
> writeback" functionality that starts to shrink the zswap pool via
> writeback if zswap goes idle for a period of time.  This addresses
> the issue with long-lived, never-accessed pages getting stuck in
> zswap forever.

Pulling the call out of zswap_frontswap_store() (and ensuring there still
aren't any new races) would be a good start.  But this is just a mechanism;
you haven't said anything about the policy or how you intend to
enforce the policy.  Which just gets us back to Comment 1...

So Comment 1 and Comment 2 are really the same:  How do we appropriately
manage the number of pages in the system that are used for storing
compressed pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
