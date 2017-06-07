Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E83F6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 10:46:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 20so2770567qtq.2
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 07:46:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m56si2156939qtb.270.2017.06.07.07.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 07:46:27 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not freeing pud v2
Date: Wed,  7 Jun 2017 10:46:20 -0400
Message-Id: <1496846780-17393-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

With commit af2cf278ef4f we no longer free pud so that we do not
have synchronize all pgd on hotremove/vfree. But the new 5 level
page table patchset reverted that for 4 level page table.

This patch restore af2cf278ef4f and disable free_pud() if we are
in the 4 level page table case thus avoiding BUG_ON() after hot-
remove.

af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()

Changed since v1:
  - make free_pud() conditional on the number of page table
    level
  - improved commit message

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
> thus we now trigger a BUG_ON() l128 in sync_global_pgds()
>
> This patch remove free_pud() like in af2cf278ef4f
---
 arch/x86/mm/init_64.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 95651dc..61028bc 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -771,6 +771,16 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 	spin_unlock(&init_mm.page_table_lock);
 }
 
+/*
+ * For 4 levels page table we do not want to free puds but for 5 levels
+ * we should free them. This code also need to change to adapt for boot
+ * time switching between 4 and 5 level.
+ */
+#if CONFIG_PGTABLE_LEVELS == 4
+static inline void free_pud_table(pud_t *pud_start, p4d_t *p4d)
+{
+}
+#else /* CONFIG_PGTABLE_LEVELS == 4 */
 static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
 {
 	pud_t *pud;
@@ -788,6 +798,7 @@ static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
 	p4d_clear(p4d);
 	spin_unlock(&init_mm.page_table_lock);
 }
+#endif /* CONFIG_PGTABLE_LEVELS == 4 */
 
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
