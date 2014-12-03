Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BFA046B006E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 19:42:50 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id z12so18518002wgg.1
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 16:42:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vv5si37354195wjc.173.2014.12.02.16.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 16:42:49 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: fadvise: Document the fadvise(FADV_DONTNEED) behaviour for partial pages
Date: Wed,  3 Dec 2014 00:42:46 +0000
Message-Id: <1417567367-9298-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1417567367-9298-1-git-send-email-mgorman@suse.de>
References: <1417567367-9298-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A random seek IO benchmark appeared to regress because of a change to
readahead but the real problem was the benchmark. To ensure the IO request
accesssed disk, it used fadvise(FADV_DONTNEED) on a block boundary (512K)
but the hint is ignored by the kernel. This is correct but not necessarily
obvious behaviour.  As much as I dislike comment patches, the explanation
for this behaviour predates current git history. Clarify why it behaves
like this in case someone "fixes" fadvise or readahead for the wrong reasons.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/fadvise.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81d..c908c72 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -117,7 +117,11 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
 
-		/* First and last FULL page! */
+		/*
+		 * First and last FULL page! Partial pages are deliberately
+		 * preserved on the expectation that it is better to preserve
+		 * needed memory than to discard unneeded memory.
+		 */
 		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
 		end_index = (endbyte >> PAGE_CACHE_SHIFT);
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
