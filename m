Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC6EB6B03A1
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 13:11:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v77so12581840pgb.15
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:11:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r20si4379342pfl.571.2017.08.10.10.11.28
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 10:11:28 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v6 9/9] arm64: hugetlb: Cleanup setup_hugepagesz
Date: Thu, 10 Aug 2017 18:09:06 +0100
Message-Id: <20170810170906.30772-10-punit.agrawal@arm.com>
In-Reply-To: <20170810170906.30772-1-punit.agrawal@arm.com>
References: <20170810170906.30772-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, mark.rutland@arm.com, David Woods <dwoods@mellanox.com>, stable@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>

From: Steve Capper <steve.capper@arm.com>

Replace a lot of if statements with switch and case labels to make it
much clearer which huge page sizes are supported.

Also, we prevent PUD_SIZE from being used on systems not running with
4KB PAGE_SIZE. Before if one supplied PUD_SIZE in these circumstances,
then unusuable huge page sizes would be in use.

Fixes: 084bd29810a5 ("ARM64: mm: HugeTLB support.")
Cc: David Woods <dwoods@mellanox.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Reviewed-by: Mark Rutland <mark.rutland@arm.com>
---
 arch/arm64/mm/hugetlbpage.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 273f126072e4..2c9913121bfd 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -399,20 +399,20 @@ static __init int setup_hugepagesz(char *opt)
 {
 	unsigned long ps = memparse(opt, &opt);
 
-	if (ps == PMD_SIZE) {
-		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
-	} else if (ps == PUD_SIZE) {
-		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
-	} else if (ps == (PAGE_SIZE * CONT_PTES)) {
-		hugetlb_add_hstate(CONT_PTE_SHIFT);
-	} else if (ps == (PMD_SIZE * CONT_PMDS)) {
-		hugetlb_add_hstate((PMD_SHIFT + CONT_PMD_SHIFT) - PAGE_SHIFT);
-	} else {
-		hugetlb_bad_size();
-		pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
-		return 0;
+	switch (ps) {
+#ifdef CONFIG_ARM64_4K_PAGES
+	case PUD_SIZE:
+#endif
+	case PMD_SIZE * CONT_PMDS:
+	case PMD_SIZE:
+	case PAGE_SIZE * CONT_PTES:
+		hugetlb_add_hstate(ilog2(ps) - PAGE_SHIFT);
+		return 1;
 	}
-	return 1;
+
+	hugetlb_bad_size();
+	pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
+	return 0;
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
