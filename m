Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 34B066007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:43:01 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48gwpG026385
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:42:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D9BC645DE4E
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 93E1945DE53
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2341A1DB803C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E4F22E18009
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/7] VM_LOCKED check don't need pte lock
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174217.589A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:42:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom 24f910b1ac966c21ea5aab825d1f26815b760304 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 3 Dec 2009 16:06:47 +0900
Subject: [PATCH 3/7] VM_LOCKED check don't need pte lock

Currently, page_referenced_one() check VM_LOCKED after taking ptelock.
But it's unnecessary. We can check VM_LOCKED before to take lock.

This patch does it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 1b50425..fb0983a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -383,21 +383,21 @@ int page_referenced_one(struct page *page, struct vm_=
area_struct *vma,
 	spinlock_t *ptl;
 	int referenced =3D 0;
=20
-	pte =3D page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
-
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
 	 * in order that it progresses to try_to_unmap and is moved to the
 	 * unevictable list.
 	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount =3D 1;	/* break early from loop */
+		*mapcount =3D 0;	/* break early from loop */
 		*vm_flags |=3D VM_LOCKED;
-		goto out_unmap;
+		goto out;
 	}
=20
+	pte =3D page_check_address(page, mm, address, &ptl, 0);
+	if (!pte)
+		goto out;
+
 	if (ptep_clear_flush_young_notify(vma, address, pte)) {
 		/*
 		 * Don't treat a reference through a sequentially read
@@ -416,7 +416,6 @@ int page_referenced_one(struct page *page, struct vm_ar=
ea_struct *vma,
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
=20
-out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
=20
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
