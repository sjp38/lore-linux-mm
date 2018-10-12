Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3789E6B0279
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:11:04 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n1-v6so12763455qtb.17
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:11:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t31-v6si1452802qtd.113.2018.10.12.11.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:11:03 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/thp: fix call to mmu_notifier in set_pmd_migration_entry() v2
Date: Fri, 12 Oct 2018 14:10:56 -0400
Message-Id: <20181012181056.7864-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Inside set_pmd_migration_entry() we are holding page table locks and
thus we can not sleep so we can not call invalidate_range_start/end()

So remove call to mmu_notifier_invalidate_range_start/end() because
they are call inside the function calling set_pmd_migration_entry()
(see try_to_unmap_one()).

Changed since v1:
    - removed call to invalidate_range() and updated commit message

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: David Nellans <dnellans@nvidia.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: stable@vger.kernel.org
---
 mm/huge_memory.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 533f9b00147d..a5b28547e321 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2885,9 +2885,6 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	if (!(pvmw->pmd && !pvmw->pte))
 		return;
 
-	mmu_notifier_invalidate_range_start(mm, address,
-			address + HPAGE_PMD_SIZE);
-
 	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
 	pmdval = *pvmw->pmd;
 	pmdp_invalidate(vma, address, pvmw->pmd);
@@ -2900,9 +2897,6 @@ void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
 	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
 	page_remove_rmap(page, true);
 	put_page(page);
-
-	mmu_notifier_invalidate_range_end(mm, address,
-			address + HPAGE_PMD_SIZE);
 }
 
 void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
-- 
2.17.2
