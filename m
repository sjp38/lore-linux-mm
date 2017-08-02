Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01ED76B05C5
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 05:51:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 24so41850612pfk.5
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 02:51:24 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y69si12908614plh.106.2017.08.02.02.51.23
        for <linux-mm@kvack.org>;
        Wed, 02 Aug 2017 02:51:24 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 8/9] arm64: Re-enable support for contiguous hugepages
Date: Wed,  2 Aug 2017 10:49:03 +0100
Message-Id: <20170802094904.27749-9-punit.agrawal@arm.com>
In-Reply-To: <20170802094904.27749-1-punit.agrawal@arm.com>
References: <20170802094904.27749-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, steve.capper@arm.com, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com

also known as -

Revert "Revert "Revert "arm64: hugetlb: partial revert of 66b3923a1a0f"""

Now that our hugetlb implementation is compliant with the
break-before-make requirements of the architecture and we have addressed
some of the issues in core code required for properly dealing with
hardware poisoning of contiguous hugepages let's re-enable support for
contiguous hugepages.

This reverts commit 6ae979ab39a368c18ceb0424bf824d172d6ab56f.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 3e78673b1bcb..a10dfbd0ffd5 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -385,6 +385,10 @@ static __init int setup_hugepagesz(char *opt)
 		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
 	} else if (ps == PUD_SIZE) {
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+	} else if (ps == (PAGE_SIZE * CONT_PTES)) {
+		hugetlb_add_hstate(CONT_PTE_SHIFT);
+	} else if (ps == (PMD_SIZE * CONT_PMDS)) {
+		hugetlb_add_hstate((PMD_SHIFT + CONT_PMD_SHIFT) - PAGE_SHIFT);
 	} else {
 		hugetlb_bad_size();
 		pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
@@ -393,3 +397,13 @@ static __init int setup_hugepagesz(char *opt)
 	return 1;
 }
 __setup("hugepagesz=", setup_hugepagesz);
+
+#ifdef CONFIG_ARM64_64K_PAGES
+static __init int add_default_hugepagesz(void)
+{
+	if (size_to_hstate(CONT_PTES * PAGE_SIZE) == NULL)
+		hugetlb_add_hstate(CONT_PTE_SHIFT);
+	return 0;
+}
+arch_initcall(add_default_hugepagesz);
+#endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
