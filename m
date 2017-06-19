Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 097886B03B3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:47:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u110so8823788wrb.14
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:47:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t77si6519327wmd.114.2017.06.19.05.47.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 05:47:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Fix THP handling in invalidate_mapping_pages()
Date: Mon, 19 Jun 2017 14:47:23 +0200
Message-Id: <20170619124723.21656-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>

The condition checking for THP straddling end of invalidated range is
wrong - it checks 'index' against 'end' but 'index' has been already
advanced to point to the end of THP and thus the condition can never be
true. As a result THP straddling 'end' has been fully invalidated. Given
the nature of invalidate_mapping_pages(), this could be only performance
issue. In fact, we are lucky the condition is wrong because if it was
ever true, we'd leave locked page behind.

Fix the condition checking for THP straddling 'end' and also properly
unlock the page. Also update the comment before the condition to explain
why we decide not to invalidate the page as it was not clear to me and I
had to ask Kirill.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 6479ed2afc53..2330223841fb 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -530,9 +530,15 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			} else if (PageTransHuge(page)) {
 				index += HPAGE_PMD_NR - 1;
 				i += HPAGE_PMD_NR - 1;
-				/* 'end' is in the middle of THP */
-				if (index ==  round_down(end, HPAGE_PMD_NR))
+				/*
+				 * 'end' is in the middle of THP. Don't
+				 * invalidate the page as the part outside of
+				 * 'end' could be still useful.
+				 */
+				if (index > end) {
+					unlock_page(page);
 					continue;
+				}
 			}
 
 			ret = invalidate_inode_page(page);
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
