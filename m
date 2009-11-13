Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 90F646B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 03:16:35 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD8GWjH017437
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 17:16:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 967DD45DE52
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:16:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5170445DE51
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:16:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99826E08002
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:16:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F79E1DB8043
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 17:16:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911111048170.12126@sister.anvils>
References: <20091111102400.FD36.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0911111048170.12126@sister.anvils>
Message-Id: <20091113143930.33BF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2009 17:16:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 11 Nov 2009, KOSAKI Motohiro wrote:
>=20
> Though it doesn't quite answer your question,
> I'll just reinsert the last paragraph of my description here...
>=20
> > > try_to_unmap_file()'s TTU_MUNLOCK nonlinear handling was particularly
> > > amusing: once unravelled, it turns out to have been choosing between
> > > two different ways of doing the same nothing.  Ah, no, one way was
> > > actually returning SWAP_FAIL when it meant to return SWAP_SUCCESS.
>=20
> ...=20
> > > @@ -1081,45 +1053,23 @@ static int try_to_unmap_file(struct page
> ...
> > >
> > > -	if (list_empty(&mapping->i_mmap_nonlinear))
> > > +	/* We don't bother to try to find the munlocked page in nonlinears =
*/
> > > +	if (MLOCK_PAGES && TTU_ACTION(flags) =3D=3D TTU_MUNLOCK)
> > >  		goto out;
> >=20
> > I have dumb question.
> > Does this shortcut exiting code makes any behavior change?
>=20
> Not dumb.  My intention was to make no behaviour change with any of
> this patch; but in checking back before completing the description,
> I suddenly realized that that shortcut intentionally avoids the
>=20
> 	if (max_nl_size =3D=3D 0) {	/* all nonlinears locked or reserved ? */
> 		ret =3D SWAP_FAIL;
> 		goto out;
> 	}
>=20
> (which doesn't show up in the patch: you'll have to look at rmap.c),
> which used to have the effect of try_to_munlock() returning SWAP_FAIL
> in the case when there were one or more VM_NONLINEAR vmas of the file,
> but none of them (and none of the covering linear vmas) VM_LOCKED.
>=20
> That should have been a SWAP_SUCCESS case, or with my changes
> another SWAP_AGAIN, either of which would make munlock_vma_page()
> 				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
> which would be correct; but the SWAP_FAIL meant that count was not
> incremented in this case.

Ah, correct.
Then, we lost the capability unevictability of non linear mapping pages, ri=
ght.
if so, following additional patch makes more consistent?


>=20
> Actually, I've double-fixed that, because I also changed
> munlock_vma_page() to increment the count whenever ret !=3D SWAP_MLOCK;
> which seemed more appropriate, but would have been a no-op if
> try_to_munlock() only returned SWAP_SUCCESS or SWAP_AGAIN or SWAP_MLOCK
> as it claimed.
>=20
> But I wasn't very inclined to boast of fixing that bug, since my testing
> didn't give confidence that those /proc/vmstat unevictable_pgs_*lock*
> counts are being properly maintained anyway - when I locked the same
> pages in two vmas then unlocked them in both, I ended up with mlocked
> bigger than munlocked (with or without my 2/6 patch); which I suspect
> is wrong, but rather off my present course towards KSM swapping...

Ah, vmstat inconsistent is weird. I'll try to debug it later.
Thanks this notice.


----------------------------------
=46rom 3fd3bc58dc6505af73ecf92c981609ecf8b6ac40 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 13 Nov 2009 16:52:03 +0900
Subject: [PATCH] [RFC] mm: non linear mapping page don't mark as PG_mlocked

Now, try_to_unmap_file() lost the capability to treat VM_NONLINEAR.
Then, mlock() shouldn't mark the page of non linear mapping as
PG_mlocked. Otherwise the page continue to drinker walk between
evictable and unevictable lru.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mlock.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 48691fb..4187f9c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -266,25 +266,34 @@ long mlock_vma_pages_range(struct vm_area_struct *vma=
,
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		goto no_mlock;
=20
-	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
+	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
 			is_vm_hugetlb_page(vma) ||
-			vma =3D=3D get_gate_vma(current))) {
+			vma =3D=3D get_gate_vma(current)) {
+
+		/*
+		 * User mapped kernel pages or huge pages:
+		 * make these pages present to populate the ptes, but
+		 * fall thru' to reset VM_LOCKED--no need to unlock, and
+		 * return nr_pages so these don't get counted against task's
+		 * locked limit.  huge pages are already counted against
+		 * locked vm limit.
+		 */
+		make_pages_present(start, end);
+		goto no_mlock;
+	}
=20
+	if (vma->vm_flags & VM_NONLINEAR)
+		/*
+		 * try_to_munmap() doesn't treat VM_NONLINEAR. let's make
+		 * consist.
+		 */
+		make_pages_present(start, end);
+	else
 		__mlock_vma_pages_range(vma, start, end);
=20
-		/* Hide errors from mmap() and other callers */
-		return 0;
-	}
+	/* Hide errors from mmap() and other callers */
+	return 0;
=20
-	/*
-	 * User mapped kernel pages or huge pages:
-	 * make these pages present to populate the ptes, but
-	 * fall thru' to reset VM_LOCKED--no need to unlock, and
-	 * return nr_pages so these don't get counted against task's
-	 * locked limit.  huge pages are already counted against
-	 * locked vm limit.
-	 */
-	make_pages_present(start, end);
=20
 no_mlock:
 	vma->vm_flags &=3D ~VM_LOCKED;	/* and don't come back! */
--=20
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
