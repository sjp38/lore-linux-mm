Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E36CB6B0256
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:04:29 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so1246160pac.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:04:29 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id bn11si2545962pdb.69.2015.08.27.02.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:04:29 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 05/11] ARCv2: mm: THP: boot validation/reporting
Date: Thu, 27 Aug 2015 14:33:08 +0530
Message-ID: <1440666194-21478-6-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/mm/tlb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index 337eebf0d6cf..211d59347047 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -706,7 +706,8 @@ char *arc_mmu_mumbojumbo(int cpu_id, char *buf, int len)
 
 	if (p_mmu->s_pg_sz_m)
 		scnprintf(super_pg, 64, "%dM Super Page%s, ",
-			  p_mmu->s_pg_sz_m, " (not used)");
+			  p_mmu->s_pg_sz_m,
+			  IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) ? "" : " (not used)");
 
 	n += scnprintf(buf + n, len - n,
 		      "MMU [v%x]\t: %dk PAGE, %sJTLB %d (%dx%d), uDTLB %d, uITLB %d %s\n",
@@ -741,6 +742,11 @@ void arc_mmu_init(void)
 	if (mmu->pg_sz_k != TO_KB(PAGE_SIZE))
 		panic("MMU pg size != PAGE_SIZE (%luk)\n", TO_KB(PAGE_SIZE));
 
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+	    mmu->s_pg_sz_m != TO_MB(HPAGE_PMD_SIZE))
+		panic("MMU Super pg size != Linux HPAGE_PMD_SIZE (%luM)\n",
+		      (unsigned long)TO_MB(HPAGE_PMD_SIZE));
+
 	/* Enable the MMU */
 	write_aux_reg(ARC_REG_PID, MMU_ENABLE);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
