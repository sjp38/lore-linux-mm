Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 372676B0062
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 12:05:39 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so9252216vbk.14
        for <linux-mm@kvack.org>; Mon, 17 Sep 2012 09:05:38 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 17 Sep 2012 20:05:38 +0400
Message-ID: <CALo0P118RQCNoUOv+WexDz9VLE6r-doFDUDFdZRuA=bOYL4xLQ@mail.gmail.com>
Subject: [PATCH] Set page active bit in mincore() call.
From: Roman Guschin <guroan@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi all!

It's a very simple patch that allows to see which pages are active and
which not.
It's very useful for debugging performance issues in mm.
I used the vmtouch tool (with a simple modification) to display the results.

R.

---
 mm/mincore.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 7c2874a..31301d2 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -61,7 +61,7 @@ static void mincore_hugetlb_page_range(struct
vm_area_struct *vma,
  */
 static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 {
-	unsigned char present = 0;
+	unsigned char flags = 0;
 	struct page *page;

 	/*
@@ -79,13 +79,15 @@ static unsigned char mincore_page(struct
address_space *mapping, pgoff_t pgoff)
 	}
 #endif
 	if (page) {
-		present = PageUptodate(page);
-		if (present)
-			present |= (PageReadaheadUnused(page) << 7);
+		flags = PageUptodate(page);
+		if (flags) {
+			flags |= (PageActive(page) << 1);
+			flags |= (PageReadaheadUnused(page) << 7);
+		}
 		page_cache_release(page);
 	}

-	return present;
+	return flags;
 }

 static void mincore_unmapped_range(struct vm_area_struct *vma,
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
