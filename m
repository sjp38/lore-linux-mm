Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id C42F46B0032
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 18:28:53 -0400 (EDT)
Received: by obbsn1 with SMTP id sn1so21433734obb.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 15:28:53 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id t9si1427679oig.65.2015.06.16.15.28.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 15:28:52 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm: Fix MAP_POPULATE and mlock() for DAX
Date: Tue, 16 Jun 2015 16:28:30 -0600
Message-Id: <1434493710-11138-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, willy@linux.intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>

DAX has the following issues in a shared or read-only private
mmap'd file.
 - mmap(MAP_POPULATE) does not pre-fault
 - mlock() fails with -ENOMEM

DAX uses VM_MIXEDMAP for mmap'd files, which do not have struct
page associated with the ranges.  Both MAP_POPULATE and mlock()
call __mm_populate(), which in turn calls __get_user_pages().
Because __get_user_pages() requires a valid page returned from
follow_page_mask(), MAP_POPULATE and mlock(), i.e. FOLL_POPULATE,
fail in the first page.

Change __get_user_pages() to proceed FOLL_POPULATE when the
translation is set but its page does not exist (-EFAULT), and
@pages is not requested.  With that, MAP_POPULATE and mlock()
set translations to the requested range and complete successfully.

MAP_POPULATE still provides a major performance improvement to
DAX as it will avoid page faults during initial access to the
pages.

mlock() continues to set VM_LOCKED to vma and populate the range.
Since there is no struct page, the range is pinned without marking
pages mlocked.

Note, MAP_POPULATE and mlock() already work for a write-able
private mmap'd file on DAX since populate_vma_page_range() breaks
COW, which allocates page caches.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/gup.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6297f6b..16d536f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -490,8 +490,20 @@ retry:
 			}
 			BUG();
 		}
-		if (IS_ERR(page))
+		if (IS_ERR(page)) {
+			/*
+			 * No page may be associated with VM_MIXEDMAP. Proceed
+			 * FOLL_POPULATE when the translation is set but its
+			 * page does not exist (-EFAULT), and @pages is not
+			 * requested by the caller.
+			 */
+			if ((PTR_ERR(page) == -EFAULT) && (!pages) &&
+			    (gup_flags & FOLL_POPULATE) &&
+			    (vma->vm_flags & VM_MIXEDMAP))
+				goto next_page;
+
 			return i ? i : PTR_ERR(page);
+		}
 		if (pages) {
 			pages[i] = page;
 			flush_anon_page(vma, page, start);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
