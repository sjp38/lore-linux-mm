Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4D9280959
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f21so274959498pgi.4
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h16si16542510pli.228.2017.03.12.17.36.00
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 03/10] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Date: Mon, 13 Mar 2017 09:35:46 +0900
Message-ID: <1489365353-28205-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-1-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
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
index d47af09..1cfb3a3 100644
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
