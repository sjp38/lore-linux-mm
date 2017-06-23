Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4725D6B03B1
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:53:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l34so10894347wrc.12
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:53:59 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id 53si4116040wru.4.2017.06.23.01.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:53:58 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id z45so10916902wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:53:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/6] MIPS: do not use __GFP_REPEAT for order-0 request
Date: Fri, 23 Jun 2017 10:53:40 +0200
Message-Id: <20170623085345.11304-2-mhocko@kernel.org>
In-Reply-To: <20170623085345.11304-1-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Alex Belits <alex.belits@cavium.com>, David Daney <david.daney@cavium.com>, Ralf Baechle <ralf@linux-mips.org>

From: Michal Hocko <mhocko@suse.com>

3377e227af44 ("MIPS: Add 48-bit VA space (and 4-level page tables) for
4K pages.") has added a new __GFP_REPEAT user but using this flag
doesn't really make any sense for order-0 request which is the case here
because PUD_ORDER is 0. __GFP_REPEAT has historically effect only on
allocation requests with order > PAGE_ALLOC_COSTLY_ORDER.

This doesn't introduce any functional change. This is a preparatory
patch for later work which renames the flag and redefines its semantic.

Cc: Alex Belits <alex.belits@cavium.com>
Cc: David Daney <david.daney@cavium.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/mips/include/asm/pgalloc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index a1bdb1ea5234..39b9f311c4ef 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -116,7 +116,7 @@ static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pud_t *pud;
 
-	pud = (pud_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PUD_ORDER);
+	pud = (pud_t *) __get_free_pages(GFP_KERNEL, PUD_ORDER);
 	if (pud)
 		pud_init((unsigned long)pud, (unsigned long)invalid_pmd_table);
 	return pud;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
