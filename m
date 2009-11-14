Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 295D06B007B
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:28 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAQel013630
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:26 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 13 of 25] special pmd_trans_* functions
Message-Id: <27da23d4cca21be97715.1258220311@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:31 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

These returns 0 at compile time when the config option is disabled, to allow
gcc to eliminate the transparent hugepage function calls at compile time
without additional #ifdefs (only the export of those functions have to be
visible to gcc but they won't be required at link time and huge_memory.o can be
not built at all).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -397,6 +397,24 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_PRESENT;
 }
 
+static inline int pmd_trans_frozen(pmd_t pmd)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return !pmd_present(pmd);
+#else
+	return 0;
+#endif
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return pmd_val(pmd) & _PAGE_PSE;
+#else
+	return 0;
+#endif
+}
+
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
