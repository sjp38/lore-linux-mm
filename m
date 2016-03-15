Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5096B0260
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 10:56:09 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id u190so31991884pfb.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 07:56:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id v13si863117pas.199.2016.03.15.07.56.08
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 07:56:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp, mlock: update unevictable-lru.txt
Date: Tue, 15 Mar 2016 17:55:44 +0300
Message-Id: <1458053744-40664-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Add description of THP handling into unevictable-lru.txt.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/unevictable-lru.txt | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index fa3b527086fa..c47566fc49cb 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -461,6 +461,25 @@ unevictable LRU is enabled, the work of compaction is mostly handled by
 the page migration code and the same work flow as described in MIGRATING
 MLOCKED PAGES will apply.
 
+MLOCKING TRANSPARENT HUGE PAGES
+-------------------------------
+
+Transparent huge page is represented by single entry on a lru list and
+therefore we can only make unevictable entire compound page, not
+individual subpages.
+
+We allow a part of transparent huge page to be mapped PTEs (i.e. after
+mremap() or mprotect()) and VMA with PTE-mapped huge page can be mlocked.
+
+That means we need to be careful, not making entire huge page unevicable
+if user mlock() only part of it.
+
+We handle this by forbidding mlocking PTE-mapped huge pages. This way we
+keep the huge page accessible for vmscan. Under memory pressure the page
+will be split, subpages from VM_LOCKED VMAs moved to unevictable lru and
+the rest can be evicted.
+
+See also comment in follow_trans_huge_pmd().
 
 mmap(MAP_LOCKED) SYSTEM CALL HANDLING
 -------------------------------------
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
