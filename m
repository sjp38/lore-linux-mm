Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8C06B0256
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:36 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so34014256wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b66si3783684wmf.33.2015.11.04.07.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/5] mm, page_owner: print migratetype of a page, not pageblock
Date: Wed,  4 Nov 2015 16:00:57 +0100
Message-Id: <1446649261-27122-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

The information in /sys/kernel/debug/page_owner includes the migratetype
declared during the page allocation via gfp_flags. This is also checked against
the pageblock's migratetype, and reported as Fallback allocation if these two
differ (although in fact fallback allocation is not the only reason why they
can differ).

However, the migratetype actually printed is the one of the pageblock, not of
the page itself, so it's the same for all pages in the pageblock. This is
apparently a bug, noticed when working on other page_owner improvements. Fixed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 983c3a1..a9f16b8 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -113,7 +113,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
 			pfn,
 			pfn >> pageblock_order,
-			pageblock_mt,
+			page_mt,
 			pageblock_mt != page_mt ? "Fallback" : "        ",
 			PageLocked(page)	? "K" : " ",
 			PageError(page)		? "E" : " ",
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
