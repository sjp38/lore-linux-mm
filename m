Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 552896B03E3
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 19:21:57 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n189so18294805pga.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:21:57 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id h13si28430901pgn.139.2016.12.21.16.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 16:21:56 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id i5so25711068pgh.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:21:56 -0800 (PST)
Date: Wed, 21 Dec 2016 16:21:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even when
 deferred
Message-ID: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently, when defrag is set to "madvise", thp allocations will direct
reclaim.  However, when defrag is set to "defer", all thp allocations do
not attempt reclaim regardless of MADV_HUGEPAGE.

This patch always directly reclaims for MADV_HUGEPAGE regions when defrag
is not set to "never."  The idea is that MADV_HUGEPAGE regions really
want to be backed by hugepages and are willing to endure the latency at
fault as it was the default behavior prior to commit 444eb2a449ef ("mm:
thp: set THP defrag by default to madvise and add a stall-free defrag
option").

In this form, "defer" is a stronger, more heavyweight version of
"madvise".

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/vm/transhuge.txt |  7 +++++--
 mm/huge_memory.c               | 10 ++++++----
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -121,8 +121,11 @@ to utilise them.
 
 "defer" means that an application will wake kswapd in the background
 to reclaim pages and wake kcompact to compact memory so that THP is
-available in the near future. It's the responsibility of khugepaged
-to then install the THP pages later.
+available in the near future, unless it is for a region where
+madvise(MADV_HUGEPAGE) has been used, in which case direct reclaim will be
+used. Kcompactd will attempt to make hugepages available for allocation in
+the near future and khugepaged will try to collapse existing memory into
+hugepages later.
 
 "madvise" will enter direct reclaim like "always" but only for regions
 that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -619,15 +619,17 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
-	bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
+	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 				&transparent_hugepage_flags) && vma_madvised)
 		return GFP_TRANSHUGE;
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
-						&transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
-	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
+						&transparent_hugepage_flags)) {
+		return GFP_TRANSHUGE_LIGHT |
+		       (vma_madvised ? __GFP_DIRECT_RECLAIM :
+				       __GFP_KSWAPD_RECLAIM);
+	} else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
 						&transparent_hugepage_flags))
 		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
