Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC1C6B025F
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:55 -0500 (EST)
Received: by wmww144 with SMTP id w144so136643465wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:36:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 124si26519323wmw.25.2015.11.24.04.36.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:44 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 8/9] mm, page_alloc: print symbolic gfp_flags on allocation failure
Date: Tue, 24 Nov 2015 13:36:20 +0100
Message-Id: <1448368581-6923-9-git-send-email-vbabka@suse.cz>
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

It would be useful to translate gfp_flags into string representation when
printing in case of an allocation failure, especially as the flags have been
undergoing some changes recently and the script ./scripts/gfp-translate needs
a matching source version to be accurate.

Example output:

stapio: page allocation failure: order:9, mode:0x2080020(GFP_ATOMIC)

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f806a1a..80349ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2711,9 +2711,9 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
 		va_end(args);
 	}
 
-	pr_warn("%s: page allocation failure: order:%u, mode:0x%x\n",
+	pr_warn("%s: page allocation failure: order:%u, mode:0x%x",
 		current->comm, order, gfp_mask);
-
+	dump_gfpflag_names(gfp_mask);
 	dump_stack();
 	if (!should_suppress_show_mem())
 		show_mem(filter);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
