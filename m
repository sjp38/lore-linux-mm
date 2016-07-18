Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B764E6B0261
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 10:50:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id r97so10709320lfi.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:50:34 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id mf18si1534960wjb.189.2016.07.18.07.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 07:50:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 80AA698EF9
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:50:27 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, vmstat: remove zone and node double accounting by approximating retries -fix
Date: Mon, 18 Jul 2016 15:50:26 +0100
Message-Id: <1468853426-12858-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As pointed out by Vlastimil, the atomic_add() functions are already assumed
to be able to handle negative numbers. The atomic_sub handling was wrong
anyway but this patch fixes it unconditionally.

This is a fix to the mmotm patch
mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm_inline.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index d29237428199..bcc4ed07fa90 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -10,12 +10,8 @@ extern atomic_t highmem_file_pages;
 static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
 							int nr_pages)
 {
-	if (is_highmem_idx(zid) && is_file_lru(lru)) {
-		if (nr_pages > 0)
-			atomic_add(nr_pages, &highmem_file_pages);
-		else
-			atomic_sub(nr_pages, &highmem_file_pages);
-	}
+	if (is_highmem_idx(zid) && is_file_lru(lru))
+		atomic_add(nr_pages, &highmem_file_pages);
 }
 #else
 static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
