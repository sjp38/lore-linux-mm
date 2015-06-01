Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA5C6B0074
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:56:30 -0400 (EDT)
Received: by obew15 with SMTP id w15so112315968obe.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:56:30 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id b186si23305oih.121.2015.06.01.12.56.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:56:29 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v12 7/10] x86, mm, pat: Add pgprot_writethrough() for WT
Date: Mon,  1 Jun 2015 13:36:30 -0600
Message-Id: <1433187393-22688-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

This patch adds pgprot_writethrough() for setting WT to a given
pgprot_t.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable_types.h |    3 +++
 arch/x86/mm/pat.c                    |    7 +++++++
 include/asm-generic/pgtable.h        |    4 ++++
 3 files changed, 14 insertions(+)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 78f0c8c..13f310b 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -367,6 +367,9 @@ extern int nx_enabled;
 #define pgprot_writecombine	pgprot_writecombine
 extern pgprot_t pgprot_writecombine(pgprot_t prot);
 
+#define pgprot_writethrough	pgprot_writethrough
+extern pgprot_t pgprot_writethrough(pgprot_t prot);
+
 /* Indicate that x86 has its own track and untrack pfn vma functions */
 #define __HAVE_PFNMAP_TRACKING
 
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 56c8b4d..a89bcde 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -999,6 +999,13 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
 }
 EXPORT_SYMBOL_GPL(pgprot_writecombine);
 
+pgprot_t pgprot_writethrough(pgprot_t prot)
+{
+	return __pgprot(pgprot_val(prot) |
+				cachemode2protval(_PAGE_CACHE_MODE_WT));
+}
+EXPORT_SYMBOL_GPL(pgprot_writethrough);
+
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_PAT)
 
 static struct memtype *memtype_get_idx(loff_t pos)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 39f1d6a..bd910ce 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -262,6 +262,10 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
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
