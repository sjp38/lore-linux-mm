Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B16416007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:41:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48fcZ6008566
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:41:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF56345DE79
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:41:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E85245DE6F
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:41:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B0DB21DB8040
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:41:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 174301DB8049
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:41:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/7] Replace page_mapping_inuse() with page_mapped()
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174016.5894.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:41:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom c0cd3ee2bb13567a36728600a86f43abac3125b5 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 2 Dec 2009 12:05:26 +0900
Subject: [PATCH 1/7] Replace page_mapping_inuse() with page_mapped()

page reclaim logic need to distingish mapped and unmapped pages.
However page_mapping_inuse() don't provide proper test way. it test
the address space (i.e. file) is mmpad(). Why `page' reclaim need
care unrelated page's mapped state? it's unrelated.

Thus, This patch replace page_mapping_inuse() with page_mapped()

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   25 ++-----------------------
 1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index da6cf42..4ba08da 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -262,27 +262,6 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t=
 gfp_mask,
 	return ret;
 }
=20
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping =3D page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -649,7 +628,7 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
 		 * try_to_unmap moves it to unevictable list
 		 */
 		if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page)
+					referenced && page_mapped(page)
 					&& !(vm_flags & VM_LOCKED))
 			goto activate_locked;
=20
@@ -1356,7 +1335,7 @@ static void shrink_active_list(unsigned long nr_pages=
, struct zone *zone,
 		}
=20
 		/* page_referenced clears PageReferenced */
-		if (page_mapping_inuse(page) &&
+		if (page_mapped(page) &&
 		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
 			nr_rotated++;
 			/*
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
