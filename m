Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4B66B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 03:11:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h144so28959587ita.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:11:48 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j19si49884468ioo.156.2016.06.01.00.11.45
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 00:11:46 -0700 (PDT)
Date: Wed, 1 Jun 2016 16:12:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
Message-ID: <20160601071225.GN19976@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
 <20160531091550.GA19976@bbox>
 <20160531171722.GA5763@linux.intel.com>
MIME-Version: 1.0
In-Reply-To: <20160531171722.GA5763@linux.intel.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, May 31, 2016 at 10:17:23AM -0700, Tim Chen wrote:
> On Tue, May 31, 2016 at 06:15:50PM +0900, Minchan Kim wrote:
> > Hello Tim,
> >=20
> > checking file mm/vmscan.c
> > patch: **** malformed patch at line 89: =A0               mapping->a=5F=
ops->is=5Fdirty=5Fwriteback(page, dirty, writeback);
> >=20
> > Could you resend formal patch?
> >=20
> > Thanks.
>=20
> My mail client is misbehaving after a system upgrade.
> Here's the patch again.
>=20
>=20
> Subject: [PATCH] mm: Cleanup - Reorganize the shrink=5Fpage=5Flist code i=
nto smaller functions
>=20
> This patch consolidates the page out and the varous cleanup operations
> within shrink=5Fpage=5Flist function into handle=5Fpgout and pg=5Ffinish
> functions.
>=20
> This makes the shrink=5Fpage=5Flist function more concise and allows for
> the separation of page out and page scan operations at a later time.
> This is desirable if we want to group similar pages together and batch
> process them in the page out path.
>=20
> After we have scanned a page shrink=5Fpage=5Flist and completed any pagin=
g,
> the final disposition and clean up of the page is conslidated into
> pg=5Ffinish.  The designated disposition of the page from page scanning
> in shrink=5Fpage=5Flist is marked with one of the designation in pg=5Fres=
ult.
>=20
> There is no intention to change any functionality or logic in this patch.
>=20
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Hi Tim,

To me, this reorganization is too limited and not good for me,
frankly speaking. It works for only your goal which allocate batch
swap slot, I guess. :)

My goal is to make them work with batch page=5Fcheck=5Freferences,
batch try=5Fto=5Funmap and batch =5F=5Fremove=5Fmapping where we can avoid =
frequent
mapping->lock(e.g., anon=5Fvma or i=5Fmmap=5Flock with hoping such batch lo=
cking
help system performance) if batch pages has same inode or anon.

So, to show my intention roughly, I coded in a short time which never
cannot work and compiled. Just show the intention.

If you guys think it's worth, I will try to make complete patch.

Thanks.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2aec4241b42a..5276b160db00 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -106,6 +106,15 @@ struct scan=5Fcontrol {
 	unsigned long nr=5Freclaimed;
 };
=20
+struct congest=5Fcontrol {
+	unsigned long nr=5Funqueued=5Fdirty;
+	unsigned long nr=5Fdirty;
+	unsigned long nr=5Fcongested;
+	unsigned long nr=5Fwriteback;
+	unsigned long nr=5Fimmediate;
+	gfp=5Ft gfp=5Fmask;
+};
+
 #define lru=5Fto=5Fpage(=5Fhead) (list=5Fentry((=5Fhead)->prev, struct pag=
e, lru))
=20
 #ifdef ARCH=5FHAS=5FPREFETCH
@@ -874,360 +883,260 @@ static void page=5Fcheck=5Fdirty=5Fwriteback(struct=
 page *page,
 		mapping->a=5Fops->is=5Fdirty=5Fwriteback(page, dirty, writeback);
 }
=20
-/*
- * shrink=5Fpage=5Flist() returns the number of reclaimed pages
- */
-static unsigned long shrink=5Fpage=5Flist(struct list=5Fhead *page=5Flist,
-				      struct zone *zone,
-				      struct scan=5Fcontrol *sc,
-				      enum ttu=5Fflags ttu=5Fflags,
-				      unsigned long *ret=5Fnr=5Fdirty,
-				      unsigned long *ret=5Fnr=5Funqueued=5Fdirty,
-				      unsigned long *ret=5Fnr=5Fcongested,
-				      unsigned long *ret=5Fnr=5Fwriteback,
-				      unsigned long *ret=5Fnr=5Fimmediate,
-				      bool force=5Freclaim)
+static int spl=5Fbatch=5Fpages(struct list=5Fhead *page=5Flist,
+			struct list=5Fhead *failed=5Flist,
+			int (*process)(struct page *page, void *private),
+			void *private)
 {
-	LIST=5FHEAD(ret=5Fpages);
-	LIST=5FHEAD(free=5Fpages);
-	int pgactivate =3D 0;
-	unsigned long nr=5Funqueued=5Fdirty =3D 0;
-	unsigned long nr=5Fdirty =3D 0;
-	unsigned long nr=5Fcongested =3D 0;
-	unsigned long nr=5Freclaimed =3D 0;
-	unsigned long nr=5Fwriteback =3D 0;
-	unsigned long nr=5Fimmediate =3D 0;
-
-	cond=5Fresched();
-
-	while (!list=5Fempty(page=5Flist)) {
-		struct address=5Fspace *mapping;
-		struct page *page;
-		int may=5Fenter=5Ffs;
-		enum page=5Freferences references =3D PAGEREF=5FRECLAIM=5FCLEAN;
-		bool dirty, writeback;
-
-		cond=5Fresched();
-
-		page =3D lru=5Fto=5Fpage(page=5Flist);
-		list=5Fdel(&page->lru);
-
-		if (!trylock=5Fpage(page))
-			goto keep;
+	struct page *page, *tmp;
+	int ret;
+	int nr=5Ffailed =3D 0;
=20
-		VM=5FBUG=5FON=5FPAGE(PageActive(page), page);
-		VM=5FBUG=5FON=5FPAGE(page=5Fzone(page) !=3D zone, page);
+	list=5Ffor=5Feach=5Fentry=5Fsafe(page, tmp, page=5Flist, lru) {
+		ret =3D process(page, private);
+		if (!ret) {
+			list=5Fmove(&page->lru, failed=5Flist);
+			VM=5FBUG=5FON=5FPAGE(PageLRU(page) || PageUnevictable(page),
+					page);
+			nr=5Ffailed++;
+		}
+	}
=20
-		sc->nr=5Fscanned++;
+	return nr=5Ffailed;
+}
=20
-		if (unlikely(!page=5Fevictable(page)))
-			goto cull=5Fmlocked;
+static int spl=5Ftrylock=5Fpage(struct page *page, void *private)
+{
+	struct scan=5Fcontrol *sc =3D private;
=20
-		if (!sc->may=5Funmap && page=5Fmapped(page))
-			goto keep=5Flocked;
+	VM=5FBUG=5FON=5FPAGE(PageActive(page), page);
+	sc->nr=5Fscanned++;
=20
-		/* Double the slab pressure for mapped and swapcache pages */
-		if (page=5Fmapped(page) || PageSwapCache(page))
-			sc->nr=5Fscanned++;
+	return trylock=5Fpage(page);
+}
=20
-		may=5Fenter=5Ffs =3D (sc->gfp=5Fmask & =5F=5FGFP=5FFS) ||
-			(PageSwapCache(page) && (sc->gfp=5Fmask & =5F=5FGFP=5FIO));
+static int spl=5Fcheck=5Fevictable(struct page *page, void *private)
+{
+	struct scan=5Fcontrol *sc =3D private;
=20
-		/*
-		 * The number of dirty pages determines if a zone is marked
-		 * reclaim=5Fcongested which affects wait=5Fiff=5Fcongested. kswapd
-		 * will stall and start writing pages if the tail of the LRU
-		 * is all dirty unqueued pages.
-		 */
-		page=5Fcheck=5Fdirty=5Fwriteback(page, &dirty, &writeback);
-		if (dirty || writeback)
-			nr=5Fdirty++;
+	if (unlikely(!page=5Fevictable(page))) {
+		if (PageSwapCache(page))
+			try=5Fto=5Ffree=5Fswap(page);
+		unlock=5Fpage(page);
+		return 0;
+	}
=20
-		if (dirty && !writeback)
-			nr=5Funqueued=5Fdirty++;
+	if (!sc->may=5Funmap && page=5Fmapped(page)) {
+		unlock=5Fpage(page);
+		return 0;
+	}
=20
-		/*
-		 * Treat this page as congested if the underlying BDI is or if
-		 * pages are cycling through the LRU so quickly that the
-		 * pages marked for immediate reclaim are making it to the
-		 * end of the LRU a second time.
-		 */
-		mapping =3D page=5Fmapping(page);
-		if (((dirty || writeback) && mapping &&
-		     inode=5Fwrite=5Fcongested(mapping->host)) ||
-		    (writeback && PageReclaim(page)))
-			nr=5Fcongested++;
+	/* Double the slab pressure for mapped and swapcache pages */
+	if (page=5Fmapped(page) || PageSwapCache(page))
+		sc->nr=5Fscanned++;
=20
-		/*
-		 * If a page at the tail of the LRU is under writeback, there
-		 * are three cases to consider.
-		 *
-		 * 1) If reclaim is encountering an excessive number of pages
-		 *    under writeback and this page is both under writeback and
-		 *    PageReclaim then it indicates that pages are being queued
-		 *    for IO but are being recycled through the LRU before the
-		 *    IO can complete. Waiting on the page itself risks an
-		 *    indefinite stall if it is impossible to writeback the
-		 *    page due to IO error or disconnected storage so instead
-		 *    note that the LRU is being scanned too quickly and the
-		 *    caller can stall after page list has been processed.
-		 *
-		 * 2) Global or new memcg reclaim encounters a page that is
-		 *    not marked for immediate reclaim, or the caller does not
-		 *    have =5F=5FGFP=5FFS (or =5F=5FGFP=5FIO if it's simply going to swa=
p,
-		 *    not to fs). In this case mark the page for immediate
-		 *    reclaim and continue scanning.
-		 *
-		 *    Require may=5Fenter=5Ffs because we would wait on fs, which
-		 *    may not have submitted IO yet. And the loop driver might
-		 *    enter reclaim, and deadlock if it waits on a page for
-		 *    which it is needed to do the write (loop masks off
-		 *    =5F=5FGFP=5FIO|=5F=5FGFP=5FFS for this reason); but more thought
-		 *    would probably show more reasons.
-		 *
-		 * 3) Legacy memcg encounters a page that is already marked
-		 *    PageReclaim. memcg does not have any dirty pages
-		 *    throttling so we could easily OOM just because too many
-		 *    pages are in writeback and there is nothing else to
-		 *    reclaim. Wait for the writeback to complete.
-		 */
-		if (PageWriteback(page)) {
-			/* Case 1 above */
-			if (current=5Fis=5Fkswapd() &&
-			    PageReclaim(page) &&
-			    test=5Fbit(ZONE=5FWRITEBACK, &zone->flags)) {
-				nr=5Fimmediate++;
-				goto keep=5Flocked;
-
-			/* Case 2 above */
-			} else if (sane=5Freclaim(sc) ||
-			    !PageReclaim(page) || !may=5Fenter=5Ffs) {
-				/*
-				 * This is slightly racy - end=5Fpage=5Fwriteback()
-				 * might have just cleared PageReclaim, then
-				 * setting PageReclaim here end up interpreted
-				 * as PageReadahead - but that does not matter
-				 * enough to care.  What we do want is for this
-				 * page to have PageReclaim set next time memcg
-				 * reclaim reaches the tests above, so it will
-				 * then wait=5Fon=5Fpage=5Fwriteback() to avoid OOM;
-				 * and it's also appropriate in global reclaim.
-				 */
-				SetPageReclaim(page);
-				nr=5Fwriteback++;
-				goto keep=5Flocked;
+	return 1;
+}
=20
-			/* Case 3 above */
-			} else {
-				unlock=5Fpage(page);
-				wait=5Fon=5Fpage=5Fwriteback(page);
-				/* then go back and try same page again */
-				list=5Fadd=5Ftail(&page->lru, page=5Flist);
-				continue;
-			}
-		}
=20
-		if (!force=5Freclaim)
-			references =3D page=5Fcheck=5Freferences(page, sc);
-
-		switch (references) {
-		case PAGEREF=5FACTIVATE:
-			goto activate=5Flocked;
-		case PAGEREF=5FKEEP:
-			goto keep=5Flocked;
-		case PAGEREF=5FRECLAIM:
-		case PAGEREF=5FRECLAIM=5FCLEAN:
-			; /* try to reclaim the page below */
-		}
+static int spl=5Fcheck=5Fcongestion(struct page *page, void *private)
+{
+	bool dirty, writeback;
+	struct congest=5Fcontrol *cc =3D private;
+	gfp=5Ft gfp=5Fmask =3D cc->gfp=5Fmask;
+	struct zone *zone =3D page=5Fzone(page);
+	struct address=5Fspace *mapping;
+	int may=5Fenter=5Ffs;
=20
-		/*
-		 * Anonymous process memory has backing store?
-		 * Try to allocate it some swap space here.
-		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!(sc->gfp=5Fmask & =5F=5FGFP=5FIO))
-				goto keep=5Flocked;
-			if (!add=5Fto=5Fswap(page, page=5Flist))
-				goto activate=5Flocked;
-			may=5Fenter=5Ffs =3D 1;
-
-			/* Adding to swap updated mapping */
-			mapping =3D page=5Fmapping(page);
-		}
+	may=5Fenter=5Ffs =3D (gfp=5Fmask & =5F=5FGFP=5FFS) ||
+			(PageSwapCache(page) && (gfp=5Fmask & =5F=5FGFP=5FIO));
=20
-		/*
-		 * The page is mapped into the page tables of one or more
-		 * processes. Try to unmap it here.
-		 */
-		if (page=5Fmapped(page) && mapping) {
-			switch (try=5Fto=5Funmap(page,
-					ttu=5Fflags|TTU=5FBATCH=5FFLUSH)) {
-			case SWAP=5FFAIL:
-				goto activate=5Flocked;
-			case SWAP=5FAGAIN:
-				goto keep=5Flocked;
-			case SWAP=5FMLOCK:
-				goto cull=5Fmlocked;
-			case SWAP=5FSUCCESS:
-				; /* try to free the page below */
-			}
-		}
-
-		if (PageDirty(page)) {
-			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but only writeback
-			 * if many dirty pages have been encountered.
-			 */
-			if (page=5Fis=5Ffile=5Fcache(page) &&
-					(!current=5Fis=5Fkswapd() ||
-					 !test=5Fbit(ZONE=5FDIRTY, &zone->flags))) {
-				/*
-				 * Immediately reclaim when written back.
-				 * Similar in principal to deactivate=5Fpage()
-				 * except we already have the page isolated
-				 * and know it's dirty
-				 */
-				inc=5Fzone=5Fpage=5Fstate(page, NR=5FVMSCAN=5FIMMEDIATE);
-				SetPageReclaim(page);
+	/*
+	 * The number of dirty pages determines if a zone is marked
+	 * reclaim=5Fcongested which affects wait=5Fiff=5Fcongested. kswapd
+	 * will stall and start writing pages if the tail of the LRU
+	 * is all dirty unqueued pages.
+	 */
+	page=5Fcheck=5Fdirty=5Fwriteback(page, &dirty, &writeback);
+	if (dirty || writeback)
+		cc->nr=5Fdirty++;
=20
-				goto keep=5Flocked;
-			}
+	if (dirty && !writeback)
+		cc->nr=5Funqueued=5Fdirty++;
=20
-			if (references =3D=3D PAGEREF=5FRECLAIM=5FCLEAN)
-				goto keep=5Flocked;
-			if (!may=5Fenter=5Ffs)
-				goto keep=5Flocked;
-			if (!sc->may=5Fwritepage)
-				goto keep=5Flocked;
+	/*
+	 * Treat this page as congested if the underlying BDI is or if
+	 * pages are cycling through the LRU so quickly that the
+	 * pages marked for immediate reclaim are making it to the
+	 * end of the LRU a second time.
+	 */
+	mapping =3D page=5Fmapping(page);
+	if (((dirty || writeback) && mapping &&
+	     inode=5Fwrite=5Fcongested(mapping->host)) ||
+	    (writeback && PageReclaim(page)))
+		cc->nr=5Fcongested++;
=20
+	/*
+	 * If a page at the tail of the LRU is under writeback, there
+	 * are three cases to consider.
+	 *
+	 * 1) If reclaim is encountering an excessive number of pages
+	 *    under writeback and this page is both under writeback and
+	 *    PageReclaim then it indicates that pages are being queued
+	 *    for IO but are being recycled through the LRU before the
+	 *    IO can complete. Waiting on the page itself risks an
+	 *    indefinite stall if it is impossible to writeback the
+	 *    page due to IO error or disconnected storage so instead
+	 *    note that the LRU is being scanned too quickly and the
+	 *    caller can stall after page list has been processed.
+	 *
+	 * 2) Global or new memcg reclaim encounters a page that is
+	 *    not marked for immediate reclaim, or the caller does not
+	 *    have =5F=5FGFP=5FFS (or =5F=5FGFP=5FIO if it's simply going to swap,
+	 *    not to fs). In this case mark the page for immediate
+	 *    reclaim and continue scanning.
+	 *
+	 *    Require may=5Fenter=5Ffs because we would wait on fs, which
+	 *    may not have submitted IO yet. And the loop driver might
+	 *    enter reclaim, and deadlock if it waits on a page for
+	 *    which it is needed to do the write (loop masks off
+	 *    =5F=5FGFP=5FIO|=5F=5FGFP=5FFS for this reason); but more thought
+	 *    would probably show more reasons.
+	 *
+	 * 3) Legacy memcg encounters a page that is already marked
+	 *    PageReclaim. memcg does not have any dirty pages
+	 *    throttling so we could easily OOM just because too many
+	 *    pages are in writeback and there is nothing else to
+	 *    reclaim. Wait for the writeback to complete.
+	 */
+	if (PageWriteback(page)) {
+		/* Case 1 above */
+		if (current=5Fis=5Fkswapd() &&
+		    PageReclaim(page) &&
+		    test=5Fbit(ZONE=5FWRITEBACK, &zone->flags)) {
+			cc->nr=5Fimmediate++;
+			unlock=5Fpage(page);
+			return 0;
+		/* Case 2 above */
+		} else if (sane=5Freclaim(sc) ||
+		    !PageReclaim(page) || !may=5Fenter=5Ffs) {
 			/*
-			 * Page is dirty. Flush the TLB if a writable entry
-			 * potentially exists to avoid CPU writes after IO
-			 * starts and then write it out here.
+			 * This is slightly racy - end=5Fpage=5Fwriteback()
+			 * might have just cleared PageReclaim, then
+			 * setting PageReclaim here end up interpreted
+			 * as PageReadahead - but that does not matter
+			 * enough to care.  What we do want is for this
+			 * page to have PageReclaim set next time memcg
+			 * reclaim reaches the tests above, so it will
+			 * then wait=5Fon=5Fpage=5Fwriteback() to avoid OOM;
+			 * and it's also appropriate in global reclaim.
 			 */
-			try=5Fto=5Funmap=5Fflush=5Fdirty();
-			switch (pageout(page, mapping, sc)) {
-			case PAGE=5FKEEP:
-				goto keep=5Flocked;
-			case PAGE=5FACTIVATE:
-				goto activate=5Flocked;
-			case PAGE=5FSUCCESS:
-				if (PageWriteback(page))
-					goto keep;
-				if (PageDirty(page))
-					goto keep;
+			SetPageReclaim(page);
+			cc->nr=5Fwriteback++;
+			unlock=5Fpage(page);
+			return 0;
=20
-				/*
-				 * A synchronous write - probably a ramdisk.  Go
-				 * ahead and try to reclaim the page.
-				 */
-				if (!trylock=5Fpage(page))
-					goto keep;
-				if (PageDirty(page) || PageWriteback(page))
-					goto keep=5Flocked;
-				mapping =3D page=5Fmapping(page);
-			case PAGE=5FCLEAN:
-				; /* try to free the page below */
-			}
-		}
-
-		/*
-		 * If the page has buffers, try to free the buffer mappings
-		 * associated with this page. If we succeed we try to free
-		 * the page as well.
-		 *
-		 * We do this even if the page is PageDirty().
-		 * try=5Fto=5Frelease=5Fpage() does not perform I/O, but it is
-		 * possible for a page to have PageDirty set, but it is actually
-		 * clean (all its buffers are clean).  This happens if the
-		 * buffers were written out directly, with submit=5Fbh(). ext3
-		 * will do this, as well as the blockdev mapping.
-		 * try=5Fto=5Frelease=5Fpage() will discover that cleanness and will
-		 * drop the buffers and mark the page clean - it can be freed.
-		 *
-		 * Rarely, pages can have buffers and no ->mapping.  These are
-		 * the pages which were not successfully invalidated in
-		 * truncate=5Fcomplete=5Fpage().  We try to drop those buffers here
-		 * and if that worked, and the page is no longer mapped into
-		 * process address space (page=5Fcount =3D=3D 1) it can be freed.
-		 * Otherwise, leave the page on the LRU so it is swappable.
-		 */
-		if (page=5Fhas=5Fprivate(page)) {
-			if (!try=5Fto=5Frelease=5Fpage(page, sc->gfp=5Fmask))
-				goto activate=5Flocked;
-			if (!mapping && page=5Fcount(page) =3D=3D 1) {
-				unlock=5Fpage(page);
-				if (put=5Fpage=5Ftestzero(page))
-					goto free=5Fit;
-				else {
-					/*
-					 * rare race with speculative reference.
-					 * the speculative reference will free
-					 * this page shortly, so we may
-					 * increment nr=5Freclaimed here (and
-					 * leave it off the LRU).
-					 */
-					nr=5Freclaimed++;
-					continue;
-				}
-			}
+		/* Case 3 above */
+		} else {
+			unlock=5Fpage(page);
+			wait=5Fon=5Fpage=5Fwriteback(page);
+			/* XXXX */
+			/* then go back and try same page again */
+			// list=5Fmove(&page->lru, page=5Flist);
+			// continue;
 		}
+	}
=20
-		if (!mapping || !=5F=5Fremove=5Fmapping(mapping, page, true))
-			goto keep=5Flocked;
+	return 1;
+}
=20
-		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
-		 */
-		=5F=5Fclear=5Fpage=5Flocked(page);
-free=5Fit:
-		nr=5Freclaimed++;
+static int spl=5Fpage=5Freference=5Fcheck(struct page *page, void *private)
+{
+	struct scan=5Fcontrol *sc =3D private;
+	enum page=5Freferences references =3D PAGEREF=5FRECLAIM=5FCLEAN;
=20
-		/*
-		 * Is there need to periodically free=5Fpage=5Flist? It would
-		 * appear not as the counts should be low
-		 */
-		list=5Fadd(&page->lru, &free=5Fpages);
-		continue;
+	references =3D page=5Fcheck=5Freferences(page, sc);
=20
-cull=5Fmlocked:
-		if (PageSwapCache(page))
+	switch (references) {
+	case PAGEREF=5FACTIVATE:
+		if (PageSwapCache(page) && vm=5Fswap=5Ffull())
 			try=5Fto=5Ffree=5Fswap(page);
+		SetPageActive(page);
+		count=5Fvm=5Fevent(PGACTIVATE);
+		return 0;
+	case PAGEREF=5FKEEP:
 		unlock=5Fpage(page);
-		list=5Fadd(&page->lru, &ret=5Fpages);
-		continue;
+		return 0;
+	case PAGEREF=5FRECLAIM:
+	case PAGEREF=5FRECLAIM=5FCLEAN:
+		; /* try to reclaim the page below */
+	}
=20
-activate=5Flocked:
-		/* Not a candidate for swapping, so reclaim swap space. */
+	return 1;
+}
+
+static int spl=5Fpage=5Freference=5Fcheck(struct page *page, void *private)
+{
+	struct scan=5Fcontrol *sc =3D private;
+	enum page=5Freferences references =3D PAGEREF=5FRECLAIM=5FCLEAN;
+
+	references =3D page=5Fcheck=5Freferences(page, sc);
+
+	switch (references) {
+	case PAGEREF=5FACTIVATE:
 		if (PageSwapCache(page) && vm=5Fswap=5Ffull())
 			try=5Fto=5Ffree=5Fswap(page);
-		VM=5FBUG=5FON=5FPAGE(PageActive(page), page);
 		SetPageActive(page);
-		pgactivate++;
-keep=5Flocked:
+		count=5Fvm=5Fevent(PGACTIVATE);
+		return 0;
+	case PAGEREF=5FKEEP:
 		unlock=5Fpage(page);
-keep:
-		list=5Fadd(&page->lru, &ret=5Fpages);
-		VM=5FBUG=5FON=5FPAGE(PageLRU(page) || PageUnevictable(page), page);
+		return 0;
+	case PAGEREF=5FRECLAIM:
+	case PAGEREF=5FRECLAIM=5FCLEAN:
+		; /* try to reclaim the page below */
 	}
=20
+	return 1;
+}
+
+/*
+ * shrink=5Fpage=5Flist() returns the number of reclaimed pages
+ */
+static unsigned long shrink=5Fpage=5Flist(struct list=5Fhead *page=5Flist,
+				      struct zone *zone,
+				      struct scan=5Fcontrol *sc,
+				      enum ttu=5Fflags ttu=5Fflags,
+				      struct congest=5Fcontrol *cc,
+				      bool force=5Freclaim)
+{
+	LIST=5FHEAD(ret=5Fpages);
+	LIST=5FHEAD(free=5Fpages);
+	int pgactivate =3D 0;
+	unsigned long nr=5Freclaimed =3D 0;
+
+	cond=5Fresched();
+
+	cc->gfp=5Fmask =3D sc->gfp=5Fmask;
+	spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages, spl=5Ftrylock=5Fpage, sc);
+	spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages, spl=5Fcheck=5Fevictable, s=
c);
+	spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages, spl=5Fcheck=5Fcongestion, =
cc);
+	if (!force=5Freclaim)
+		spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages,
+				spl=5Fpage=5Freference=5Fcheck, sc);
+	spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages,
+				spl=5Falloc=5Fswap=5Fslot, sc);
+	spl=5Fbatch=5Fpages(page=5Flist, &ret=5Fpages,
+				spl=5Ftry=5Fto=5Funmap, sc);
+	spl=5Fbatch=5Fpages(page=5Flist, &free=5Fpages,
+				spl=5Ftry=5Fto=5Ffree, sc);
+
 	mem=5Fcgroup=5Funcharge=5Flist(&free=5Fpages);
-	try=5Fto=5Funmap=5Fflush();
 	free=5Fhot=5Fcold=5Fpage=5Flist(&free=5Fpages, true);
=20
 	list=5Fsplice(&ret=5Fpages, page=5Flist);
 	count=5Fvm=5Fevents(PGACTIVATE, pgactivate);
=20
-	*ret=5Fnr=5Fdirty +=3D nr=5Fdirty;
-	*ret=5Fnr=5Fcongested +=3D nr=5Fcongested;
-	*ret=5Fnr=5Funqueued=5Fdirty +=3D nr=5Funqueued=5Fdirty;
-	*ret=5Fnr=5Fwriteback +=3D nr=5Fwriteback;
-	*ret=5Fnr=5Fimmediate +=3D nr=5Fimmediate;
 	return nr=5Freclaimed;
 }
=20
@@ -1239,8 +1148,9 @@ unsigned long reclaim=5Fclean=5Fpages=5Ffrom=5Flist(s=
truct zone *zone,
 		.priority =3D DEF=5FPRIORITY,
 		.may=5Funmap =3D 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	struct congest=5Fcontrol cc;
 	struct page *page, *next;
+	unsigned long ret;
 	LIST=5FHEAD(clean=5Fpages);
=20
 	list=5Ffor=5Feach=5Fentry=5Fsafe(page, next, page=5Flist, lru) {
@@ -1252,8 +1162,7 @@ unsigned long reclaim=5Fclean=5Fpages=5Ffrom=5Flist(s=
truct zone *zone,
 	}
=20
 	ret =3D shrink=5Fpage=5Flist(&clean=5Fpages, zone, &sc,
-			TTU=5FUNMAP|TTU=5FIGNORE=5FACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			TTU=5FUNMAP|TTU=5FIGNORE=5FACCESS, &cc, true);
 	list=5Fsplice(&clean=5Fpages, page=5Flist);
 	mod=5Fzone=5Fpage=5Fstate(zone, NR=5FISOLATED=5FFILE, -ret);
 	return ret;
@@ -1571,6 +1480,7 @@ shrink=5Finactive=5Flist(unsigned long nr=5Fto=5Fscan=
, struct lruvec *lruvec,
 	int file =3D is=5Ffile=5Flru(lru);
 	struct zone *zone =3D lruvec=5Fzone(lruvec);
 	struct zone=5Freclaim=5Fstat *reclaim=5Fstat =3D &lruvec->reclaim=5Fstat;
+	struct congest=5Fcontrol cc;
=20
 	while (unlikely(too=5Fmany=5Fisolated(zone, file, sc))) {
 		congestion=5Fwait(BLK=5FRW=5FASYNC, HZ/10);
@@ -1607,10 +1517,9 @@ shrink=5Finactive=5Flist(unsigned long nr=5Fto=5Fsca=
n, struct lruvec *lruvec,
 	if (nr=5Ftaken =3D=3D 0)
 		return 0;
=20
+	memset(&cc, 0, sizeof(struct congest=5Fcontrol));
 	nr=5Freclaimed =3D shrink=5Fpage=5Flist(&page=5Flist, zone, sc, TTU=5FUNM=
AP,
-				&nr=5Fdirty, &nr=5Funqueued=5Fdirty, &nr=5Fcongested,
-				&nr=5Fwriteback, &nr=5Fimmediate,
-				false);
+					&cc, false);
=20
 	spin=5Flock=5Firq(&zone->lru=5Flock);
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
