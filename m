Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D43E06B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:26:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 43so7217670qtr.6
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:26:08 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id c16si4725195qkj.104.2017.10.03.07.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 07:26:07 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH] mm: remove unnecessary WARN_ONCE in page_vma_mapped_walk().
Date: Tue,  3 Oct 2017 10:26:06 -0400
Message-Id: <20171003142606.12324-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

A non present pmd entry can appear after pmd_lock is taken in
page_vma_mapped_walk(), even if THP migration is not enabled.
The WARN_ONCE is unnecessary.

Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")
Reported-and-tested-by: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_vma_mapped.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 6a03946469a9..eb462e7db0a9 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -167,8 +167,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 						return not_found(pvmw);
 					return true;
 				}
-			} else
-				WARN_ONCE(1, "Non present huge pmd without pmd migration enabled!");
+			}
 			return not_found(pvmw);
 		} else {
 			/* THP pmd was split under us: handle on pte level */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
