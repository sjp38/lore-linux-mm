Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 973692803A5
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:19:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 85so135602pge.9
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:19:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i61si3815868plb.195.2017.08.29.22.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 22:19:27 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm: Improve readability of clear_huge_page
Date: Wed, 30 Aug 2017 13:18:42 +0800
Message-Id: <20170830051842.1397-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>

From: Huang Ying <ying.huang@intel.com>

The optimized clear_huge_page() isn't easy to read and understand.
This is suggested by Michael Hocko to improve it.

Suggested-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/memory.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 20ac58c128e9..694ddbd3a020 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4507,12 +4507,15 @@ void clear_huge_page(struct page *page,
 	 * towards the sub-page to access
 	 */
 	for (i = 0; i < l; i++) {
+		int left_idx = base + i;
+		int right_idx = base + 2 * l - 1 - i;
+
 		cond_resched();
-		clear_user_highpage(page + base + i,
-				    addr + (base + i) * PAGE_SIZE);
+		clear_user_highpage(page + left_idx,
+				    addr + left_idx * PAGE_SIZE);
 		cond_resched();
-		clear_user_highpage(page + base + 2 * l - 1 - i,
-				    addr + (base + 2 * l - 1 - i) * PAGE_SIZE);
+		clear_user_highpage(page + right_idx,
+				    addr + right_idx * PAGE_SIZE);
 	}
 }
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
