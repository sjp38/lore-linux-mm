Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7166B00C1
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:18:53 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id v63so7812256oia.9
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:18:53 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id uk5si147043oeb.0.2014.11.04.14.18.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:18:52 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 5/8] x86, mm, pat: Add pgprot_writethrough() for WT
Date: Tue,  4 Nov 2014 15:04:35 -0700
Message-Id: <1415138678-22958-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
References: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
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
index af447f9..1a2033c 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -407,6 +407,9 @@ extern int nx_enabled;
 #define pgprot_writecombine	pgprot_writecombine
 extern pgprot_t pgprot_writecombine(pgprot_t prot);
 
+#define pgprot_writethrough	pgprot_writethrough
+extern pgprot_t pgprot_writethrough(pgprot_t prot);
+
 /* Indicate that x86 has its own track and untrack pfn vma functions */
 #define __HAVE_PFNMAP_TRACKING
 
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 2b69db8..da7a93b 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -956,6 +956,16 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
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
index 752e30d..9ad756e 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -249,6 +249,10 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #define pgprot_writecombine pgprot_noncached
 #endif
 
+#ifndef pgprot_writethrough
+#define pgprot_writethrough pgprot_noncached
+#endif
+
 #ifndef pgprot_device
 #define pgprot_device pgprot_noncached
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
