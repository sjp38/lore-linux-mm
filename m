Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD1D6B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 09:11:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x25so112379971pgc.10
        for <linux-mm@kvack.org>; Wed, 24 May 2017 06:11:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 31si24032070plk.66.2017.05.24.06.11.50
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 06:11:51 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 1/9] arm64: hugetlb: set_huge_pte_at Add WARN_ON on !pte_present
Date: Wed, 24 May 2017 14:11:14 +0100
Message-Id: <20170524131122.5309-2-punit.agrawal@arm.com>
In-Reply-To: <20170524131122.5309-1-punit.agrawal@arm.com>
References: <20170524131122.5309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, linux-mm@kvack.org, David Woods <dwoods@mellanox.com>, Punit Agrawal <punit.agrawal@arm.com>

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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
