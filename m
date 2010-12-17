Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4ECBB6B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 12:13:57 -0500 (EST)
Received: by mail-pv0-f169.google.com with SMTP id 30so143145pvc.14
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:13:56 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 1/5] drop page reference on remove_from_page_cache
Date: Sat, 18 Dec 2010 02:13:36 +0900
Message-Id: <4bd059fc4f45fba7ed29a9f4325deb4f437d39f3.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1292604745.git.minchan.kim@gmail.com>
References: <cover.1292604745.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Now we add page reference on add_to_page_cache but doesn't drop it
in remove_from_page_cache. Such asymmetric makes confusing about
page reference so that caller should notice it and comment why they
release page reference. It's not good API.

Long time ago, Hugh tried it[1] but gave up of reason which
reiser4's drop_page had to unlock the page between removing it from
page cache and doing the page_cache_release. But now the situation is
changed. I think at least things in current mainline doesn't have any
obstacles. The problem is fs or somethings out of mainline.
If it has done such thing like reiser4, this patch could be a problem.

Do anyone know the such things? Do we care about things out of mainline?

Note :
The comment of remove_from_page_cache make by copy & paste & s/swap/page/
from delete_from_swap_cache.

[1] http://lkml.org/lkml/2004/10/24/140

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/filemap.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 095c393..fb9db36 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -148,6 +148,16 @@ void __remove_from_page_cache(struct page *page)
 	}
 }
 
+/**
+ * remove_from_page_cache - remove page from page cache
+ *
+ * @page: the page which the kernel is trying to remove from page cache
+ *
+ * This must be called only on pages that have
+ * been verified to be in the page cache and locked.
+ * It will never put the page into the free list,
+ * the caller has a reference on the page.
+ */
 void remove_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
@@ -163,6 +173,8 @@ void remove_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
+
+	page_cache_release(page);
 }
 EXPORT_SYMBOL(remove_from_page_cache);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
