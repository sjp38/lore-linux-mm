Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B78D96B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 10:46:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z3so6192301wme.21
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 07:46:39 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id b45si12195007wrg.225.2017.10.30.07.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 07:46:38 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH] mm: migration: deposit page table when copying a PMD migration entry.
Date: Mon, 30 Oct 2017 10:46:36 -0400
Message-Id: <20171030144636.4836-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Fengguang Wu <fengguang.wu@intel.com>

From: Zi Yan <zi.yan@cs.rutgers.edu>

We need to deposit pre-allocated PTE page table when a PMD migration
entry is copied in copy_huge_pmd(). Otherwise, we will leak the
pre-allocated page and cause a NULL pointer dereference later
in zap_huge_pmd().

The missing counters during PMD migration entry copy process are added
as well.

The bug report is here: https://lkml.org/lkml/2017/10/29/214

Fixes: 84c3fc4e9c563 ("mm: thp: check pmd migration entry in common path")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..1981ed697dab 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -941,6 +941,9 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 				pmd = pmd_swp_mksoft_dirty(pmd);
 			set_pmd_at(src_mm, addr, src_pmd, pmd);
 		}
+		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		atomic_long_inc(&dst_mm->nr_ptes);
+		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 		ret = 0;
 		goto out_unlock;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
