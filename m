Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EAD956B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 04:34:27 -0400 (EDT)
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
	 <1306617270.2497.516.camel@laptop>
	 <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
	 <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com>
	 <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 29 May 2011 10:33:44 +0200
Message-ID: <1306658024.1200.1222.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-05-28 at 17:12 -0700, Hugh Dickins wrote:

> Though I think I'm arriving at the conclusion that this patch
> is correct as is, despite the doubts that have arisen.
>=20
> One argument is by induction: since we've noticed no problems before
> Peter's patchset, and actually Peter's patchset plus my patch is not
> really making any difference to this "anon_vma changing beneath you"
> case, is it?

I'll buy that argument, and on those grounds would have Acked the patch,
but since Linus already committed it, that's a tad moot.

Still understanding why the previous code was right (if so) is
important.

> > I'm wondering - wouldn't it be nicer to just re-check (after getting
> > the anon_vma lock) that page->mapping still matches anon_mapping?
>=20
> I toyed with that: it seemed a better idea than relying on the refcount,
> which wasn't giving the guarantee we needed (the refcount is perfectly
> good in other respects, it just isn't good for this particular check).
>=20
> However, the problem (if there is one) goes a bit further than that:
> if we don't actually have serialization against page->anon_vma (okay,
> it's actually page->mapping, but simpler to express this way) being
> changed at any instant, i.e. we're serving the page_referenced() without
> PageLocked case, then what good is the "anon_vma" that page_lock_anon_vma=
()
> returns?  If that can be freed and reused at any moment?

Agreed, all except page_referenced() are serialized using PageLock.

> I believe that although it may no longer be the anon_vma that the page
> is pointing to, it remains stable.  Because even if page->anon_vma is
> updated, it will certainly have the same anon_vma->root as before
> (see the first BUG_ON in __page_check_anon_rmap() for reassurance),
> so the mutex locking holds good.
>=20
> And the structure itself won't be freed: although the page is now
> pointing to a less inclusive, more optimal anon_vma for reclaim to use,
> the anon_vma which was originally pointed to remains on the same vma's
> chains as it ever was, and only gets freed up when they're all gone.
>=20
> So, when there's this race with moving anon_vma, page_lock_anon_vma()
> may end up returning a less than optimal anon_vma, but it's still valid
> as a good though longer list of vmas to look through.

Yes, and I think I see what you mean, if a page's anon_vma is changed
while it remains mapped it will only ever be moved to a child of the
original anon_vma. And because of the anon_vma ref-counting, the
original anon_vma will stick around until that too is dead, which won't
happen for as long as the page remains mapped.

Therefore, for as long as we observe page_mapped(), any anon_vma
obtained from it remains valid.

Talk about tricky.. shees. I bet that wants a comment or so.

> The previous code would have broken horribly, wouldn't it, were that
> not the case?

It would have, yes.

---
Subject: mm, rmap: Add yet more comments to page_get_anon_vma/page_lock_ano=
n_vma

Inspired by an analysis from Hugh on why again all this doesn't explode
in our face.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/rmap.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 6bada99..487d5cc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -350,7 +350,12 @@ void __init anon_vma_init(void)
  * have been relevant to this page.
  *
  * The page might have been remapped to a different anon_vma or the anon_v=
ma
- * returned may already be freed (and even reused).
+ * returned may already be freed (and even reused).=20
+ *
+ * In case it was remapped to a different anon_vma, the new anon_vma will =
be a
+ * child of the old anon_vma, and the anon_vma lifetime rules will therefo=
re
+ * ensure that any anon_vma obtained from the page will still be valid for=
 as
+ * long as we observe page_mapped() [ hence all those page_mapped() tests =
].
  *
  * All users of this function must be very careful when walking the anon_v=
ma
  * chain and verify that the page in question is indeed mapped in it
@@ -421,7 +426,7 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
 		/*
 		 * If the page is still mapped, then this anon_vma is still
 		 * its anon_vma, and holding the mutex ensures that it will
-		 * not go away, see __put_anon_vma().
+		 * not go away, see anon_vma_free().
 		 */
 		if (!page_mapped(page)) {
 			mutex_unlock(&root_anon_vma->mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
