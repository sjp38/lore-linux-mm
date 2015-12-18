Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 40CAC6B000C
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:03:48 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l126so54978774wml.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:03:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ld9si24102190wjb.130.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 07/14] mm, page_alloc: print symbolic gfp_flags on allocation failure
Date: Fri, 18 Dec 2015 10:03:19 +0100
Message-Id: <1450429406-7081-8-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

It would be useful to translate gfp_flags into string representation when
printing in case of an allocation failure, especially as the flags have been
undergoing some changes recently and the script ./scripts/gfp-translate needs
a matching source version to be accurate.

Example output:

stapio: page allocation failure: order:9, mode:0x2080020(GFP_ATOMIC)

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 25409714160e..08e514721a57 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2689,9 +2689,8 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
 		va_end(args);
 	}
 
-	pr_warn("%s: page allocation failure: order:%u, mode:0x%x\n",
-		current->comm, order, gfp_mask);
-
+	pr_warn("%s: page allocation failure: order:%u, mode:%#x(%pgg)\n",
+		current->comm, order, gfp_mask, &gfp_mask);
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
