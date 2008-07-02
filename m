Date: Wed, 02 Jul 2008 22:19:24 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [resend][PATCH] fix lru_cache_add_active_or_unevictable
Message-Id: <20080702221101.D16A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

I found I forgot insert below patch to my patchset for 2.6.26-rc5-mm3 today.
So, I resend it.

enjoy!


-------------------------
From: Rik van Riel <riel@redhat.com>

Undo an overzealous code cleanup to lru_cache_add_active_or_unevictable.
The callers do not set PageActive so the page would get added to the
wrong list.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Index: linux-2.6.26-rc5-mm3/mm/swap.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/swap.c	2008-07-01 18:47:04.000000000 +0900
+++ linux-2.6.26-rc5-mm3/mm/swap.c	2008-07-01 19:28:43.000000000 +0900
@@ -259,7 +259,7 @@
 					struct vm_area_struct *vma)
 {
 	if (page_evictable(page, vma))
-		lru_cache_add_lru(page, page_lru(page));
+		lru_cache_add_lru(page, LRU_ACTIVE + page_is_file_cache(page));
 	else
 		add_page_to_unevictable_list(page);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
