Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FE006B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 01:44:01 -0500 (EST)
Date: Thu, 28 Jan 2010 01:43:12 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] rmap: remove obsolete check from __page_check_anon_rmap
Message-ID: <20100128014312.47c5045d@annuminas.surriel.com>
In-Reply-To: <20100128002000.2bf5e365@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

When an anonymous page is inherited from a parent process, the
vma->anon_vma can differ from the page anon_vma.  This can trip
up __page_check_anon_rmap, which is indirectly called from
do_swap_page().

Remove that obsolete check to prevent an oops.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
The previous patch survived a short AIM7 run and only got upset when I
invoked pkill.  Presumably pkill paged in a page that was created in the
parent process of the process is was scanning.  With this patch it all
seems to be stable.

diff --git a/mm/rmap.c b/mm/rmap.c
index de7fde0..9e63424 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -755,9 +755,6 @@ static void __page_check_anon_rmap(struct page *page,
 	 * are initially only visible via the pagetables, and the pte is locked
 	 * over the call to page_add_new_anon_rmap.
 	 */
-	struct anon_vma *anon_vma = vma->anon_vma;
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	BUG_ON(page->mapping != (struct address_space *)anon_vma);
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
