Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1228C6B02D0
	for <linux-mm@kvack.org>; Tue, 15 May 2018 17:40:50 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so1010292pld.11
        for <linux-mm@kvack.org>; Tue, 15 May 2018 14:40:50 -0700 (PDT)
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com. [15.233.44.27])
        by mx.google.com with ESMTPS id d21-v6si939533pll.147.2018.05.15.14.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 14:40:48 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 1/3] x86/mm: disable ioremap free page handling on x86-PAE
Date: Tue, 15 May 2018 15:39:29 -0600
Message-Id: <20180515213931.23885-2-toshi.kani@hpe.com>
In-Reply-To: <20180515213931.23885-1-toshi.kani@hpe.com>
References: <20180515213931.23885-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, Joerg Roedel <joro@8bytes.org>, stable@vger.kernel.org

ioremap() supports pmd mappings on x86-PAE.  However, kernel's pmd
tables are not shared among processes on x86-PAE.  Therefore, any
update to sync'd pmd entries need re-syncing.  Freeing a pte page
also leads to a vmalloc fault and hits the BUG_ON in vmalloc_sync_one().

Disable free page handling on x86-PAE.  pud_free_pmd_page() and
pmd_free_pte_page() simply return 0 if a given pud/pmd entry is present.
This assures that ioremap() does not update sync'd pmd entries at the
cost of falling back to pte mappings.

Fixes: 28ee90fe6048 ("x86/mm: implement free pmd/pte page interfaces")
Reported-by: Joerg Roedel <joro@8bytes.org>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: <stable@vger.kernel.org>
---
 arch/x86/mm/pgtable.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index ffc8c13c50e4..08cdd7c13619 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -715,6 +715,7 @@ int pmd_clear_huge(pmd_t *pmd)
 	return 0;
 }
 
+#ifdef CONFIG_X86_64
 /**
  * pud_free_pmd_page - Clear pud entry and free pmd page.
  * @pud: Pointer to a PUD.
@@ -762,4 +763,22 @@ int pmd_free_pte_page(pmd_t *pmd)
 
 	return 1;
 }
+
+#else /* !CONFIG_X86_64 */
+
+int pud_free_pmd_page(pud_t *pud, unsigned long addr)
+{
+	return pud_none(*pud);
+}
+
+/*
+ * Disable free page handling on x86-PAE. This assures that ioremap()
+ * does not update sync'd pmd entries. See vmalloc_sync_one().
+ */
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
+{
+	return pmd_none(*pmd);
+}
+
+#endif /* CONFIG_X86_64 */
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
