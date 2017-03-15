Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACD0E6B038C
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:24:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j5so14262438pfb.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 71si675849pfi.365.2017.03.14.22.24.58
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:58 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 03/10] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Date: Wed, 15 Mar 2017 14:24:46 +0900
Message-ID: <1489555493-14659-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

If the page is mapped and rescue in try_to_unmap_one,
page_mapcount(page) == 0 cannot be true so page_mapcount check
in try_to_unmap is enough to return SWAP_SUCCESS.
IOW, SWAP_MLOCK check is redundant so remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index e692cb5..bdc7310 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1530,7 +1530,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	else
 		ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapcount(page))
+	if (!page_mapcount(page))
 		ret = SWAP_SUCCESS;
 	return ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
