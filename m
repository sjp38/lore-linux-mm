Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4446B0055
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:26:51 -0400 (EDT)
Message-Id: <4ACCC149020000780001882E@vpn.id2.novell.com>
Date: Wed, 07 Oct 2009 15:26:49 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] adjust gfp mask passed on nested vmalloc() invocation
	 (v3)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

- avoid wasting more precious resources (DMA or DMA32 pools), when
  being called through vmalloc_32{,_user}()
- explicitly allow using high memory here even if the outer allocation
  request doesn't allow it

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

---
 mm/vmalloc.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- linux-2.6.32-rc3/mm/vmalloc.c	2009-10-05 11:59:56.000000000 =
+0200
+++ 2.6.32-rc3-vmalloc-nested-gfp/mm/vmalloc.c	2009-10-07 14:39:38.0000000=
00 +0200
@@ -1410,6 +1410,7 @@ static void *__vmalloc_area_node(struct=20
 {
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
+	gfp_t nested_gfp =3D (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
=20
 	nr_pages =3D (area->size - PAGE_SIZE) >> PAGE_SHIFT;
 	array_size =3D (nr_pages * sizeof(struct page *));
@@ -1417,13 +1418,11 @@ static void *__vmalloc_area_node(struct=20
 	area->nr_pages =3D nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages =3D __vmalloc_node(array_size, gfp_mask | __GFP_ZERO,=

+		pages =3D __vmalloc_node(array_size, nested_gfp | =
__GFP_HIGHMEM,
 				PAGE_KERNEL, node, caller);
 		area->flags |=3D VM_VPAGES;
 	} else {
-		pages =3D kmalloc_node(array_size,
-				(gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO,=

-				node);
+		pages =3D kmalloc_node(array_size, nested_gfp, node);
 	}
 	area->pages =3D pages;
 	area->caller =3D caller;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
