Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3664D6B005A
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 08:16:36 -0400 (EDT)
Message-Id: <4AC9E38E0200007800017F57@vpn.id2.novell.com>
Date: Mon, 05 Oct 2009 11:16:14 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] adjust gfp mask passed on nested vmalloc() invocation
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

- fix a latent bug resulting from blindly or-ing in __GFP_ZERO, since
  the combination of this and __GFP_HIGHMEM (possibly passed into the
  function) is forbidden in interrupt context
- avoid wasting more precious resources (DMA or DMA32 pools), when
  being called through vmalloc_32{,_user}()
- explicitly allow using high memory here even if the outer allocation
  request doesn't allow it, unless is collides with __GFP_ZERO

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 mm/vmalloc.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

--- linux-2.6.32-rc3/mm/vmalloc.c	2009-10-05 11:59:56.000000000 =
+0200
+++ 2.6.32-rc3-vmalloc-nested-gfp/mm/vmalloc.c	2009-10-05 08:40:36.0000000=
00 +0200
@@ -1410,6 +1410,7 @@ static void *__vmalloc_area_node(struct=20
 {
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
+	gfp_t nested_gfp =3D (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
=20
 	nr_pages =3D (area->size - PAGE_SIZE) >> PAGE_SHIFT;
 	array_size =3D (nr_pages * sizeof(struct page *));
@@ -1417,13 +1418,16 @@ static void *__vmalloc_area_node(struct=20
 	area->nr_pages =3D nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages =3D __vmalloc_node(array_size, gfp_mask | __GFP_ZERO,=

+#ifdef CONFIG_HIGHMEM
+		/* See the comment in prep_zero_page(). */
+		if (!in_interrupt())
+			nested_gfp |=3D __GFP_HIGHMEM;
+#endif
+		pages =3D __vmalloc_node(array_size, nested_gfp,
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
