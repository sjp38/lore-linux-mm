Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 93D636B0254
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 11:21:33 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id cy9so101478854pac.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 08:21:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id mi6si2749821pab.95.2016.02.02.08.21.32
        for <linux-mm@kvack.org>;
        Tue, 02 Feb 2016 08:21:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 2/2] mm: downgrade VM_BUG in isolate_lru_page() to warning
Date: Tue,  2 Feb 2016 19:21:01 +0300
Message-Id: <1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Calling isolate_lru_page() is wrong and shouldn't happen, but it not
nessesary fatal: the page just will not be isolated if it's not on LRU.

Let's downgrade the VM_BUG_ON_PAGE() to WARN_RATELIMIT().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb3dd37ccd7c..71b1c29948db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
 	int ret = -EBUSY;
 
 	VM_BUG_ON_PAGE(!page_count(page), page);
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	WARN_RATELIMIT(PageTail(page), "trying to isolate tail page");
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
