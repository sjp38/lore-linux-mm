Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 83D236B0039
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 21:53:29 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so674252pde.10
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 18:53:29 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ts5si2768997pac.201.2014.08.13.18.53.26
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 18:53:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v14 5/8] s390: add pmd_[dirty|mkclean] for THP
Date: Thu, 14 Aug 2014 10:53:29 +0900
Message-Id: <1407981212-17818-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1407981212-17818-1-git-send-email-minchan@kernel.org>
References: <1407981212-17818-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-s390@vger.kernel.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
overwrite of the contents since MADV_FREE syscall is called for
THP page but for s390 pmds only referenced bit is available
because there is no free bit left in the pmd entry for the
software dirty bit so this patch adds dumb pmd_dirty which
returns always true by suggesting by Martin.

They finally find a solution in future.
http://marc.info/?l=linux-api&m=140440328820808&w=2

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/s390/include/asm/pgtable.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index b76317c1f3eb..ad4c855b026d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1612,6 +1612,18 @@ static inline pmd_t pmd_mkhuge(pmd_t pmd)
 	return pmd;
 }
 
+static inline int pmd_dirty(pmd_t pmd)
+{
+	/* No dirty bit in the segment table entry */
+	return 1;
+}
+
+static inline pmd_t pmd_mkclean(pmd_t pmd)
+{
+	/* No dirty bit in the segment table entry */
+	return pmd;
+}
+
 #define __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
 static inline int pmdp_test_and_clear_young(struct vm_area_struct *vma,
 					    unsigned long address, pmd_t *pmdp)
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
