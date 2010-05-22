Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 74BE96B01B4
	for <linux-mm@kvack.org>; Sat, 22 May 2010 06:01:04 -0400 (EDT)
Date: Sat, 22 May 2010 12:00:56 +0200 (CEST)
From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/8] mm: Use ERR_CAST
Message-ID: <Pine.LNX.4.64.1005221200380.13021@ask.diku.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Julia Lawall <julia@diku.dk>

Use ERR_CAST(x) rather than ERR_PTR(PTR_ERR(x)).  The former makes more
clear what is the purpose of the operation, which otherwise looks like a
no-op.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
T x;
identifier f;
@@

T f (...) { <+...
- ERR_PTR(PTR_ERR(x))
+ x
 ...+> }

@@
expression x;
@@

- ERR_PTR(PTR_ERR(x))
+ ERR_CAST(x)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 mm/vmalloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -732,7 +732,7 @@ static struct vmap_block *new_vmap_block
 					node, gfp_mask);
 	if (unlikely(IS_ERR(va))) {
 		kfree(vb);
-		return ERR_PTR(PTR_ERR(va));
+		return ERR_CAST(va);
 	}
 
 	err = radix_tree_preload(gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
