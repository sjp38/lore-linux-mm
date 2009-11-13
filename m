Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 502886B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 01:30:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD6UEtF012235
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 15:30:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC5E945DE6C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:30:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E098345DE63
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:30:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 82C161DB803F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:30:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0233E1DB8048
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:30:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911102151500.2816@sister.anvils>
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils> <Pine.LNX.4.64.0911102151500.2816@sister.anvils>
Message-Id: <20091113151554.33C2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2009 15:30:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -787,6 +787,8 @@ static int try_to_unmap_one(struct page
>  			ret =3D SWAP_MLOCK;
>  			goto out_unmap;
>  		}
> +		if (MLOCK_PAGES && TTU_ACTION(flags) =3D=3D TTU_MUNLOCK)
> +			goto out_unmap;
>  	}
>  	if (!(flags & TTU_IGNORE_ACCESS)) {
>  		if (ptep_clear_flush_young_notify(vma, address, pte)) {
> @@ -852,12 +854,22 @@ static int try_to_unmap_one(struct page
>  	} else
>  		dec_mm_counter(mm, file_rss);
> =20
> -
>  	page_remove_rmap(page);
>  	page_cache_release(page);
> =20
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> +
> +	if (MLOCK_PAGES && ret =3D=3D SWAP_MLOCK) {
> +		ret =3D SWAP_AGAIN;
> +		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +			if (vma->vm_flags & VM_LOCKED) {
> +				mlock_vma_page(page);
> +				ret =3D SWAP_MLOCK;
> +			}
> +			up_read(&vma->vm_mm->mmap_sem);
> +		}
> +	}
>  out:

Very small nit. How about this?


------------------------------------------------------------
=46rom 9d4b507572eccf88dcaa02e650df59874216528c Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 13 Nov 2009 15:00:04 +0900
Subject: [PATCH] Simplify try_to_unmap_one()

SWAP_MLOCK mean "We marked the page as PG_MLOCK, please move it to
unevictable-lru". So, following code is easy confusable.

	if (vma->vm_flags & VM_LOCKED) {
		ret =3D SWAP_MLOCK;
		goto out_unmap;
	}

Plus, if the VMA doesn't have VM_LOCKED, We don't need to check
the needed of calling mlock_vma_page().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 4440a86..81a168c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -784,10 +784,8 @@ static int try_to_unmap_one(struct page *page, struct =
vm_area_struct *vma,
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
-		if (vma->vm_flags & VM_LOCKED) {
-			ret =3D SWAP_MLOCK;
-			goto out_unmap;
-		}
+		if (vma->vm_flags & VM_LOCKED)
+			goto out_unlock;
 		if (MLOCK_PAGES && TTU_ACTION(flags) =3D=3D TTU_MUNLOCK)
 			goto out_unmap;
 	}
@@ -856,18 +854,19 @@ static int try_to_unmap_one(struct page *page, struct=
 vm_area_struct *vma,
=20
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+out:
+	return ret;
=20
-	if (MLOCK_PAGES && ret =3D=3D SWAP_MLOCK) {
-		ret =3D SWAP_AGAIN;
-		if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-			if (vma->vm_flags & VM_LOCKED) {
-				mlock_vma_page(page);
-				ret =3D SWAP_MLOCK;
-			}
-			up_read(&vma->vm_mm->mmap_sem);
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+
+	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mlock_vma_page(page);
+			ret =3D SWAP_MLOCK;
 		}
+		up_read(&vma->vm_mm->mmap_sem);
 	}
-out:
 	return ret;
 }
=20
--=20
1.6.2.5





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
