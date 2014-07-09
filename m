Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C8C77900003
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 02:22:48 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so8750923pad.9
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 23:22:48 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id p10si6954049pds.252.2014.07.08.23.22.46
        for <linux-mm@kvack.org>;
        Tue, 08 Jul 2014 23:22:47 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v12 5/8] s390: add pmd_[dirty|mkclean] for THP
Date: Wed,  9 Jul 2014 15:22:26 +0900
Message-Id: <1404886949-17695-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1404886949-17695-1-git-send-email-minchan@kernel.org>
References: <1404886949-17695-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-s390@vger.kernel.org

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
Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/s390/include/asm/pgtable.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index fcba5e03839f..9862fcb0592b 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1586,6 +1586,18 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
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
