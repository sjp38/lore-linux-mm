Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 067546B0039
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 15:59:34 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id r5so3094403qcx.14
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 12:59:34 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id u67si15915394yhc.60.2014.09.17.12.59.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 12:59:34 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 4/5] x86, mm, pat: Add pgprot_writethrough() for WT
Date: Wed, 17 Sep 2014 13:48:40 -0600
Message-Id: <1410983321-15162-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1410983321-15162-1-git-send-email-toshi.kani@hp.com>
References: <1410983321-15162-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch adds pgprot_writethrough() for setting WT to a given
pgprot_t.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/include/asm/pgtable_types.h |    3 +++
 arch/x86/mm/pat.c                    |   10 ++++++++++
 include/asm-generic/pgtable.h        |    4 ++++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index bd2f50f..cc7c65d 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -394,6 +394,9 @@ extern int nx_enabled;
 #define pgprot_writecombine	pgprot_writecombine
 extern pgprot_t pgprot_writecombine(pgprot_t prot);
 
+#define pgprot_writethrough	pgprot_writethrough
+extern pgprot_t pgprot_writethrough(pgprot_t prot);
+
 /* Indicate that x86 has its own track and untrack pfn vma functions */
 #define __HAVE_PFNMAP_TRACKING
 
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index a214f5a..a0264d3 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -896,6 +896,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
 }
 EXPORT_SYMBOL_GPL(pgprot_writecombine);
 
+pgprot_t pgprot_writethrough(pgprot_t prot)
+{
+	if (pat_enabled)
+		return __pgprot(pgprot_val(prot) |
+				cachemode2protval(_PAGE_CACHE_MODE_WT));
+	else
+		return pgprot_noncached(prot);
+}
+EXPORT_SYMBOL_GPL(pgprot_writethrough);
+
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_PAT)
 
 static struct memtype *memtype_get_idx(loff_t pos)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 53b2acc..1af0ed9 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -249,6 +249,10 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #define pgprot_writecombine pgprot_noncached
 #endif
 
+#ifndef pgprot_writethrough
+#define pgprot_writethrough pgprot_noncached
+#endif
+
 /*
  * When walking page tables, get the address of the next boundary,
  * or the end address of the range if that comes earlier.  Although no

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
