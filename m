Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A01396007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:42:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48gM0P008957
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:42:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0103745DE60
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B254645DE79
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 743811DB803A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 804D61DB8041
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:42:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/7] Introduce __page_check_address
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174139.5897.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:42:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom 381108e1ff6309f45f45a67acf2a1dd66e41df4f Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 3 Dec 2009 15:01:42 +0900
Subject: [PATCH 2/7] Introduce __page_check_address

page_check_address() need to take ptelock. but it might be contended.
Then we need trylock version and this patch introduce new helper function.

it will be used latter patch.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++---------=
---
 1 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 278cd27..1b50425 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -268,44 +268,80 @@ unsigned long page_address_in_vma(struct page *page, =
struct vm_area_struct *vma)
  * the page table lock when the pte is not present (helpful when reclaimin=
g
  * highly shared pages).
  *
- * On success returns with pte mapped and locked.
+ * if @noblock is true, page_check_address may return -EAGAIN if lock is
+ * contended.
+ *
+ * Returns valid pte pointer if success.
+ * Returns -EFAULT if address seems invalid.
+ * Returns -EAGAIN if trylock failed.
  */
-pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
+static pte_t *__page_check_address(struct page *page, struct mm_struct *mm=
,
+				   unsigned long address, spinlock_t **ptlp,
+				   int sync, int noblock)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int err =3D -EFAULT;
=20
 	pgd =3D pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		return NULL;
+		goto out;
=20
 	pud =3D pud_offset(pgd, address);
 	if (!pud_present(*pud))
-		return NULL;
+		goto out;
=20
 	pmd =3D pmd_offset(pud, address);
 	if (!pmd_present(*pmd))
-		return NULL;
+		goto out;
=20
 	pte =3D pte_offset_map(pmd, address);
 	/* Make a quick check before getting the lock */
-	if (!sync && !pte_present(*pte)) {
-		pte_unmap(pte);
-		return NULL;
-	}
+	if (!sync && !pte_present(*pte))
+		goto out_unmap;
=20
 	ptl =3D pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	if (noblock) {
+		if (!spin_trylock(ptl)) {
+			err =3D -EAGAIN;
+			goto out_unmap;
+		}
+	} else
+		spin_lock(ptl);
+
 	if (pte_present(*pte) && page_to_pfn(page) =3D=3D pte_pfn(*pte)) {
 		*ptlp =3D ptl;
 		return pte;
 	}
-	pte_unmap_unlock(pte, ptl);
-	return NULL;
+
+	spin_unlock(ptl);
+ out_unmap:
+	pte_unmap(pte);
+ out:
+	return ERR_PTR(err);
+}
+
+/*
+ * Check that @page is mapped at @address into @mm.
+ *
+ * If @sync is false, page_check_address may perform a racy check to avoid
+ * the page table lock when the pte is not present (helpful when reclaimin=
g
+ * highly shared pages).
+ *
+ * On success returns with pte mapped and locked.
+ */
+pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+			  unsigned long address, spinlock_t **ptlp, int sync)
+{
+	pte_t *pte;
+
+	pte =3D __page_check_address(page, mm, address, ptlp, sync, 0);
+	if (IS_ERR(pte))
+		return NULL;
+	return pte;
 }
=20
 /**
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
