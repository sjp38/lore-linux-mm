Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E9D636B0273
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:15:41 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id f198so134628209wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:15:41 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id r4si27491840wjw.190.2016.04.11.01.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:15:40 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 5D0021C160C
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:15:40 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/22] mm, page_alloc: Simplify last cpupid reset
Date: Mon, 11 Apr 2016 09:13:37 +0100
Message-Id: <1460362424-26369-15-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The current reset unnecessarily clears flags and makes pointless calculations.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ed6407d1b7b5..8f409818401c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -837,10 +837,7 @@ extern int page_cpupid_xchg_last(struct page *page, int cpupid);
 
 static inline void page_cpupid_reset_last(struct page *page)
 {
-	int cpupid = (1 << LAST_CPUPID_SHIFT) - 1;
-
-	page->flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
-	page->flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
+	page->flags |= LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT;
 }
 #endif /* LAST_CPUPID_NOT_IN_PAGE_FLAGS */
 #else /* !CONFIG_NUMA_BALANCING */
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
