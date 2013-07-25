Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A34AC6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:59:01 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] Revert "page-writeback.c: subtract min_free_kbytes from dirtyable memory"
Date: Thu, 25 Jul 2013 18:58:54 -0400
Message-Id: <1374793134-16678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Szabo <psz@maths.usyd.edu.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This reverts commit 75f7ad8e043d9383337d917584297f7737154bbf.  It was
the result of a problem observed with a 3.2 kernel and merged in 3.9,
while the issue had been resolved upstream in 3.3 (ab8fabd mm: exclude
reserved pages from dirtyable memory).

The "reserved pages" are a superset of min_free_kbytes, thus this
change is redundant and confusing.  Revert it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page-writeback.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3f0c895..d374b29 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -241,9 +241,6 @@ static unsigned long global_dirtyable_memory(void)
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
 
-	/* Subtract min_free_kbytes */
-	x -= min_t(unsigned long, x, min_free_kbytes >> (PAGE_SHIFT - 10));
-
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
