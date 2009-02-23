Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9D96B00B4
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:00:59 -0500 (EST)
Date: Mon, 23 Feb 2009 15:00:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Message-ID: <20090223150055.GK6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <200902240146.03456.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <200902240146.03456.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 01:46:01AM +1100, Nick Piggin wrote:
> Hi Mel,
>=20
> Seems like a nice patchset.
>=20

Thanks

> On Monday 23 February 2009 10:17:09 Mel Gorman wrote:
> > The complexity of the page allocator has been increasing for some time
> > and it has now reached the point where the SLUB allocator is doing stra=
nge
> > tricks to avoid the page allocator. This is obviously bad as it may
> > encourage other subsystems to try avoiding the page allocator as well.
> >
> > This series of patches is intended to reduce the cost of the page
> > allocator by doing the following.
> >
> > Patches 1-3 iron out the entry paths slightly and remove stupid sanity
> > checks from the fast path.
> >
> > Patch 4 uses a lookup table instead of a number of branches to decide w=
hat
> > zones are usable given the GFP flags.
> >
> > Patch 5 avoids repeated checks of the zonelist
> >
> > Patch 6 breaks the allocator up into a fast and slow path where the fast
> > path later becomes one long inlined function.
> >
> > Patches 7-10 avoids calculating the same things repeatedly and instead
> > calculates them once.
> >
> > Patches 11-13 inline the whole allocator fast path
> >
> > Patch 14 avoids calling get_pageblock_migratetype() potentially twice on
> > every page free
> >
> > Patch 15 reduces the number of times interrupts are disabled by reworki=
ng
> > what free_page_mlock() does. However, I notice that the cost of calling
> > TestClearPageMlocked() is still quite high and I'm guessing it's because
> > it's a locked bit operation. It's be nice if it could be established if
> > it's safe to use an unlocked version here. Rik, can you comment?
>=20
> Yes, it can. page flags are owned entirely by the owner of the page.
>=20

I figured that was the case but hadn't convinced myself 100%. I wanted a
second opinion but I'm sure it's safe now.

> free_page_mlock shouldn't really be in free_pages_check, but oh well.
>=20

Agreed, I took it out of there. The name alone implies it's debugging
that could be optionally disabled if you really had to.

>=20
> > Patch 16 avoids using the zonelist cache on non-NUMA machines
> >
> > Patch 17 removes an expensive and excessively paranoid check in the
> > allocator fast path
>=20
> I would be careful of removing useful debug checks completely like
> this. What is the cost? Obviously non-zero, but it is also a check

The cost was something like 1/10th the cost of the path. There are atomic
operations in there that are causing the problems.

> I have seen trigger on quite a lot of occasions (due to kernel bugs
> and hardware bugs, and in each case it is better to warn than not,
> even if many other situations can go undetected).
>=20

Have you really seen it trigger for the allocation path or did it
trigger in teh free path? Essentially we are making the same check on
every allocation and free which is why I considered it excessivly
paranoid.

> One problem is that some of the calls we're making in page_alloc.c
> do the compound_head() thing, wheras we know that we only want to
> look at this page. I've attached a patch which cuts out about 150
> bytes of text and several branches from these paths.
>=20

Nice, I should have spotted that. I'm going to fold this into the series
if that is ok with you? I'll replace patch 17 with it and see does it
still show up on profiles.

>=20
> > Patch 18 avoids a list search in the allocator fast path.
>=20
> Ah, this was badly needed :)
>=20
>=20
> > o On many machines, I'm seeing a 0-2% improvement on kernbench. The
> > dominant cost in kernbench is the compiler and zeroing allocated pages =
for
> > pagetables.
>=20
> zeroing is a factor, but IIRC page faults and page allocator are among
> the top of the profiles.
>=20

kernbench is also very fork heavy. That means lots of pagetable
allocations with lots of zeroing. I tried various ways of reducing the
zeroing cost including having processes exiting zero the pages as they
free but I couldn't make it go any faster.

> > o For tbench, I have seen an 8-12% improvement on two x86-64 machines
> > (elm3b6 on test.kernel.org gained 8%) but generally it was less dramati=
c on
> > x86-64 in the range of 0-4%. On one PPC64, the different was also in the
> > range of 0-4%. Generally there were gains, but one specific ppc64 showe=
d a
> > regression of 7% for one client but a negligible difference for 8 clien=
ts.
> > It's not clear why this machine regressed and others didn't.
>=20
> Did you bisect your patchset? It could have been random or pointed to
> eg the hot/cold removal?
>=20

I didn't bisect, but I probably should to see can this be pinned down. I
should run one kernel for each patch to see what exactly is helping.
When I was writing the patches, I was just running kernbench and reading
profiles.

> > o hackbench is harder to conclude anything from. Most machines showed
> >   performance gains in the 5-11% range but one machine in particular sh=
owed
> >   a mix of gains and losses depending on the number of clients. Might be
> >   a caching thing.
> >
> > o One machine in particular was a major surprise for sysbench with gains
> >   of 4-8% there which was drastically higher than I was expecting. Howe=
ver,
> >   on other machines, it was in the more reasonable 0-4% range, still pr=
etty
> >   respectable. It's not guaranteed though. While most machines showed s=
ome
> >   sort of gain, one ppc64 showed no difference at all.
> >
> > So, by and large it's an improvement of some sort.
>=20
> Most of these benchmarks *really* need to be run quite a few times to get
> a reasonable confidence.
>=20

Most are run repeatedly and an average taken but I should double check
what is going on. It's irritating that gains/regressions are
inconsistent between different machine types but that is nothing new.

> But it sounds pretty positive.
> ---
>  mm/page_alloc.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>=20
> Index: linux-2.6/mm/page_alloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -420,7 +420,7 @@ static inline int page_is_buddy(struct p
>  		return 0;
> =20
>  	if (PageBuddy(buddy) && page_order(buddy) =3D=3D order) {
> -		BUG_ON(page_count(buddy) !=3D 0);
> +		VM_BUG_ON(page_count(buddy) !=3D 0);
>  		return 1;
>  	}
>  	return 0;
> @@ -493,9 +493,9 @@ static inline void __free_one_page(struc
>  static inline int free_pages_check(struct page *page)
>  {
>  	free_page_mlock(page);
> -	if (unlikely(page_mapcount(page) |
> +	if (unlikely((atomic_read(&page->_mapcount) !=3D -1) |
>  		(page->mapping !=3D NULL)  |
> -		(page_count(page) !=3D 0)  |
> +		(atomic_read(&page->_count) !=3D 0) |
>  		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
>  		bad_page(page);
>  		return 1;
> @@ -633,9 +633,9 @@ static inline void expand(struct zone *z
>   */
>  static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
>  {
> -	if (unlikely(page_mapcount(page) |
> +	if (unlikely((atomic_read(&page->_mapcount) !=3D -1) |
>  		(page->mapping !=3D NULL)  |
> -		(page_count(page) !=3D 0)  |
> +		(atomic_read(&page->_count) !=3D 0)  |
>  		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
>  		bad_page(page);
>  		return 1;
> =00

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
