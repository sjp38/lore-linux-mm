Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF6EF6B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 1so81805348pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:31 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h11si6624942pln.322.2017.03.01.22.39.30
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 04/11] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Date: Thu,  2 Mar 2017 15:39:18 +0900
Message-Id: <1488436765-32350-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

If the page is mapped and rescue in ttuo, page_mapcount(page) == 0 cannot
be true so page_mapcount check in ttu is enough to return SWAP_SUCCESS.
IOW, SWAP_MLOCK check is redundant so remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 3a14013..0a48958 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1523,7 +1523,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
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
