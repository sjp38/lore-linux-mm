Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A86206B0260
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:27 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fe3so41652159pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bm3si7282397pad.35.2016.04.06.15.51.26
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 01/30] thp, mlock: update unevictable-lru.txt
Date: Thu,  7 Apr 2016 01:50:51 +0300
Message-Id: <1459983080-106718-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Add description of THP handling into unevictable-lru.txt.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/unevictable-lru.txt | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index fa3b527086fa..0026a8d33fc0 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -461,6 +461,27 @@ unevictable LRU is enabled, the work of compaction is mostly handled by
 the page migration code and the same work flow as described in MIGRATING
 MLOCKED PAGES will apply.
 
+MLOCKING TRANSPARENT HUGE PAGES
+-------------------------------
+
+A transparent huge page is represented by a single entry on an LRU list.
+Therefore, we can only make unevictable an entire compound page, not
+individual subpages.
+
+If a user tries to mlock() part of a huge page, we want the rest of the
+page to be reclaimable.
+
+We cannot just split the page on partial mlock() as split_huge_page() can
+fail and new intermittent failure mode for the syscall is undesirable.
+
+We handle this by keeping PTE-mapped huge pages on normal LRU lists: the
+PMD on border of VM_LOCKED VMA will be split into PTE table.
+
+This way the huge page is accessible for vmscan. Under memory pressure the
+page will be split, subpages which belong to VM_LOCKED VMAs will be moved
+to unevictable LRU and the rest can be reclaimed.
+
+See also comment in follow_trans_huge_pmd().
 
 mmap(MAP_LOCKED) SYSTEM CALL HANDLING
 -------------------------------------
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
