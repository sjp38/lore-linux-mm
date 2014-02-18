Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id F3FBF6B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:13:02 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so26862077qcz.3
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:13:02 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id v9si11222610qgd.13.2014.02.18.14.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:12:59 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH -mm 2/3] mm,numa: reorganize change_pmd_range
Date: Tue, 18 Feb 2014 17:12:45 -0500
Message-Id: <1392761566-24834-3-git-send-email-riel@redhat.com>
In-Reply-To: <1392761566-24834-1-git-send-email-riel@redhat.com>
References: <1392761566-24834-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

From: Rik van Riel <riel@redhat.com>

Reorganize the order of ifs in change_pmd_range a little, in
preparation for the next patch.

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Xing Gang <gang.xing@hp.com>
Tested-by: Chegu Vinod <chegu_vinod@hp.com>
---
 mm/mprotect.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 769a67a..6006c05 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -118,6 +118,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		unsigned long this_pages;
 
 		next = pmd_addr_end(addr, end);
+		if (!pmd_trans_huge(*pmd) && pmd_none_or_clear_bad(pmd))
+				continue;
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
 				split_huge_page_pmd(vma, addr, pmd);
@@ -133,10 +135,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 					continue;
 				}
 			}
-			/* fall through */
+			/* fall through, the trans huge pmd just split */
 		}
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
+		VM_BUG_ON(pmd_trans_huge(*pmd));
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable, prot_numa);
 		pages += this_pages;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
