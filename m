Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 19DDC6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:46:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48kG5H028020
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:46:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB0B745DE3A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:46:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 81F7F45DE51
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:46:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A43E18013
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:46:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C216AE1800C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:46:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 7/7] Try to mark PG_mlocked if wipe_page_reference find VM_LOCKED vma
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174544.58A6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:46:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom 519178d353926466fcb7411d19424c5e559b6b80 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 4 Dec 2009 16:51:20 +0900
Subject: [PATCH 7/7] Try to mark PG_mlocked if wipe_page_reference find VM_=
LOCKED vma

Both try_to_unmap() and wipe_page_reference() walk each ptes, but
latter doesn't mark PG_mlocked altough find VM_LOCKED vma.

This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c   |   14 ++++++++++++++
 mm/vmscan.c |    2 ++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 5ae7c81..cfda0a0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -376,6 +376,7 @@ int page_mapped_in_vma(struct page *page, struct vm_are=
a_struct *vma)
  *
  * SWAP_SUCCESS  - success
  * SWAP_AGAIN    - give up to take lock, try later again
+ * SWAP_MLOCK    - the page is mlocked
  */
 int wipe_page_reference_one(struct page *page,
 			    struct page_reference_context *refctx,
@@ -401,6 +402,7 @@ int wipe_page_reference_one(struct page *page,
 	if (IS_ERR(pte)) {
 		if (PTR_ERR(pte) =3D=3D -EAGAIN) {
 			ret =3D SWAP_AGAIN;
+			goto out_mlock;
 		}
 		goto out;
 	}
@@ -430,6 +432,17 @@ int wipe_page_reference_one(struct page *page,
=20
 out:
 	return ret;
+
+out_mlock:
+	if (refctx->is_page_locked &&
+	    down_read_trylock(&vma->vm_mm->mmap_sem)) {
+		if (vma->vm_flags & VM_LOCKED) {
+			mlock_vma_page(page);
+			ret =3D SWAP_MLOCK;
+		}
+		up_read(&vma->vm_mm->mmap_sem);
+	}
+	return ret;
 }
=20
 static int wipe_page_reference_anon(struct page *page,
@@ -550,6 +563,7 @@ static int wipe_page_reference_file(struct page *page,
  *
  * SWAP_SUCCESS  - success to wipe all ptes
  * SWAP_AGAIN    - temporary busy, try again later
+ * SWAP_MLOCK    - the page is mlocked
  */
 int wipe_page_reference(struct page *page,
 			struct mem_cgroup *memcg,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16e8bd0..164fda7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -625,6 +625,8 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 		ret =3D wipe_page_reference(page, sc->mem_cgroup, &refctx);
 		if (ret =3D=3D SWAP_AGAIN)
 			goto keep_locked;
+		else if (ret =3D=3D SWAP_MLOCK)
+			goto cull_mlocked;
 		VM_BUG_ON(ret !=3D SWAP_SUCCESS);
=20
 		/*
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
