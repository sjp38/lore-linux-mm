Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A561C6B008C
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 22:14:01 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v3] fix __set_page_dirty_no_writeback() return value
Date: Thu, 11 Nov 2010 11:26:03 +0800
Message-ID: <1289445963-29664-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

__set_page_dirty_no_writeback() should return true if it actually transitioned
the page from a clean to dirty state although it seems nobody used its return
value now.

Change from v2:
	* use TestSet to avoid racing

Change from v1:
	* preserving cacheline optimisation as Andrew pointed out

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page-writeback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bf85062..1ebfb86 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1158,7 +1158,7 @@ EXPORT_SYMBOL(write_one_page);
 int __set_page_dirty_no_writeback(struct page *page)
 {
 	if (!PageDirty(page))
-		SetPageDirty(page);
+		return !TestSetPageDirty(page);
 	return 0;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
