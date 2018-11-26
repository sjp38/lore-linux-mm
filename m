Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01C436B4471
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:31:19 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w19-v6so22292428plq.1
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:31:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q15sor2537704plr.34.2018.11.26.15.31.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:31:17 -0800 (PST)
Date: Mon, 26 Nov 2018 15:31:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 09/10] mm/khugepaged: collapse_shmem() do not crash on
 Compound
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261529310.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

collapse_shmem()'s VM_BUG_ON_PAGE(PageTransCompound) was unsafe: before
it holds page lock of the first page, racing truncation then extension
might conceivably have inserted a hugepage there already.  Fail with the
SCAN_PAGE_COMPOUND result, instead of crashing (CONFIG_DEBUG_VM=y) or
otherwise mishandling the unexpected hugepage - though later we might
code up a more constructive way of handling it, with SCAN_SUCCESS.

Fixes: f3f0e1d2150b2 ("khugepaged: add support of collapse for tmpfs/shmem pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/khugepaged.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 55930cbed3fd..2c5fe4f7a0c6 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1399,7 +1399,15 @@ static void collapse_shmem(struct mm_struct *mm,
 		 */
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(!PageUptodate(page), page);
-		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+
+		/*
+		 * If file was truncated then extended, or hole-punched, before
+		 * we locked the first page, then a THP might be there already.
+		 */
+		if (PageTransCompound(page)) {
+			result = SCAN_PAGE_COMPOUND;
+			goto out_unlock;
+		}
 
 		if (page_mapping(page) != mapping) {
 			result = SCAN_TRUNCATED;
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
