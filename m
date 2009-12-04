Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 867FD6007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:44:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48iiqi009878
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:44:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 35B2045DE54
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:44:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C892B45DE4E
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:44:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AC4C1DB8040
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:44:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CD0F8E1800D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:44:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/7] Don't deactivate the page if trylock_page() is failed.
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174347.58A0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:44:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom 7635eaa033cfcce7f351b5023952f23f0daffefe Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 4 Dec 2009 12:03:07 +0900
Subject: [PATCH 5/7] Don't deactivate the page if trylock_page() is failed.

Currently, wipe_page_reference() increment refctx->referenced variable
if trylock_page() is failed. but it is meaningless at all.
shrink_active_list() deactivate the page although the page was
referenced. The page shouldn't be deactivated with young bit. it
break reclaim basic theory and decrease reclaim throughput.

This patch introduce new SWAP_AGAIN return value to
wipe_page_reference().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/rmap.c   |    5 ++++-
 mm/vmscan.c |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 2f4451b..b84f350 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -539,6 +539,9 @@ static int wipe_page_reference_file(struct page *page,
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
+ *
+ * SWAP_SUCCESS  - success to wipe all ptes
+ * SWAP_AGAIN    - temporary busy, try again later
  */
 int wipe_page_reference(struct page *page,
 			struct mem_cgroup *memcg,
@@ -555,7 +558,7 @@ int wipe_page_reference(struct page *page,
 		    (!PageAnon(page) || PageKsm(page))) {
 			we_locked =3D trylock_page(page);
 			if (!we_locked) {
-				refctx->referenced++;
+				ret =3D SWAP_AGAIN;
 				goto out;
 			}
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0db9c06..9684e40 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -577,6 +577,7 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
+		int ret;
 		struct page_reference_context refctx =3D {
 			.is_page_locked =3D 1,
 		};
@@ -621,7 +622,11 @@ static unsigned long shrink_page_list(struct list_head=
 *page_list,
 				goto keep_locked;
 		}
=20
-		wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		ret =3D wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		if (ret =3D=3D SWAP_AGAIN)
+			goto keep_locked;
+		VM_BUG_ON(ret !=3D SWAP_SUCCESS);
+
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
@@ -1326,6 +1331,7 @@ static void shrink_active_list(unsigned long nr_pages=
, struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
=20
 	while (!list_empty(&l_hold)) {
+		int ret;
 		struct page_reference_context refctx =3D {
 			.is_page_locked =3D 0,
 		};
@@ -1345,7 +1351,12 @@ static void shrink_active_list(unsigned long nr_page=
s, struct zone *zone,
 			continue;
 		}
=20
-		wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		ret =3D wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		if (ret =3D=3D SWAP_AGAIN) {
+			list_add(&page->lru, &l_active);
+			continue;
+		}
+		VM_BUG_ON(ret !=3D SWAP_SUCCESS);
=20
 		if (refctx.referenced)
 			nr_rotated++;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
