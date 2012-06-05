Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 9FE026B0069
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 02:34:27 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so4936055lbj.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 23:34:25 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 5 Jun 2012 14:34:25 +0800
Message-ID: <CAA7+ByWuSVzKsgCwyrrac=faWuGY9FxHpeSiJ0-WtP7DVg4y1g@mail.gmail.com>
Subject: [PATCH] vmalloc: walk vmap_areas by sorted list instead of rb_next()
From: Hong zhi guo <honkiko@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, zhiguo.hong@nsn.com

There's a walk by repeating rb_next to find a suitable hole. Could be
simply replaced by walk on the sorted vmap_area_list. More simpler and
efficient.

Mutation of the list and tree only happens in pair within
__insert_vmap_area and __free_vmap_area, under protection of
vmap_area_lock.  The patch code is also under vmap_area_lock, so the
list walk is safe, and consistent with the tree walk.

Tested on SMP by repeating batch of vmalloc anf vfree for random sizes
and rounds for hours.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 mm/vmalloc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2aad499..0eb5347 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -413,11 +413,11 @@ nocache:
 		if (addr + size - 1 < addr)
 			goto overflow;

-		n = rb_next(&first->rb_node);
-		if (n)
-			first = rb_entry(n, struct vmap_area, rb_node);
-		else
+		if (list_is_last(&first->list, &vmap_area_list))
 			goto found;
+
+		first = list_entry(first->list.next,
+				struct vmap_area, list);
 	}

 found:
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
