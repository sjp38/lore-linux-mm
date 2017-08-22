Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6C792803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:44:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r62so68024475pfj.1
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:44:00 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s2si8495417pgd.508.2017.08.22.03.43.59
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:43:59 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v7 1/9] arm64: hugetlb: set_huge_pte_at Add WARN_ON on !pte_present
Date: Tue, 22 Aug 2017 11:42:41 +0100
Message-Id: <20170822104249.2189-2-punit.agrawal@arm.com>
In-Reply-To: <20170822104249.2189-1-punit.agrawal@arm.com>
References: <20170822104249.2189-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

This patch adds a WARN_ON to set_huge_pte_at as the accessor assumes
that entries to be written down are all present. (There are separate
accessors to clear huge ptes).

We will need to handle the !pte_present case where memory offlining
is used on hugetlb pages. swap and migration entries will be supplied
to set_huge_pte_at in this case.

Cc: David Woods <dwoods@mellanox.com>
Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 656e0ece2289..7b61e4833432 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -67,6 +67,12 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 	unsigned long pfn;
 	pgprot_t hugeprot;
 
+	/*
+	 * Code needs to be expanded to handle huge swap and migration
+	 * entries. Needed for HUGETLB and MEMORY_FAILURE.
+	 */
+	WARN_ON(!pte_present(pte));
+
 	if (!pte_cont(pte)) {
 		set_pte_at(mm, addr, ptep, pte);
 		return;
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
