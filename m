Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D85748D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:32:04 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1988717qwa.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:32:01 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 17:32:00 +0000
Message-ID: <AANLkTi=_nh6k03=1FX9rO4KAQ1MbfCvGPT-0t0AURHCe@mail.gmail.com>
Subject: [RFC][PATCH v2 03/23] (avr32) __vmalloc: add gfp flags variant of pte
 and pmd allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/avr32/include/asm/pgalloc.h |    8 +++++++-
1 files changed, 7 insertions(+), 1 deletions(-)
---
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
index bc7e8ae..cb88080 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -51,10 +51,16 @@ static inline void pgd_free(struct mm_struct *mm,
pgd_t *pgd)
 	quicklist_free(QUICK_PGD, NULL, pgd);
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long address, gfp_t gfp_mask)
+{
+	return quicklist_alloc(QUICK_PT, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEAT);
 }

 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
