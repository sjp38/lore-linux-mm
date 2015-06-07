Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4D96B0075
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:43:07 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so48360881pdj.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:43:07 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id h8si378476pdn.89.2015.06.07.10.43.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:43:05 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:42:19 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-d1b4bfbfac32da43bfc8425be1c4303548e20527@git.kernel.org>
Reply-To: bp@suse.de, tglx@linutronix.de, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, hpa@zytor.com, luto@amacapital.net,
        toshi.kani@hp.com, torvalds@linux-foundation.org, mingo@kernel.org,
        mcgrof@suse.com, akpm@linux-foundation.org, peterz@infradead.org
In-Reply-To: <1433436928-31903-11-git-send-email-bp@alien8.de>
References: <1433436928-31903-11-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Add pgprot_writethrough()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: bp@suse.de, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, luto@amacapital.net, toshi.kani@hp.com, torvalds@linux-foundation.org, mingo@kernel.org, mcgrof@suse.com, akpm@linux-foundation.org, peterz@infradead.org

Commit-ID:  d1b4bfbfac32da43bfc8425be1c4303548e20527
Gitweb:     http://git.kernel.org/tip/d1b4bfbfac32da43bfc8425be1c4303548e20527
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:18 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:58 +0200

x86/mm/pat: Add pgprot_writethrough()

Add pgprot_writethrough() for setting page protection flags to
Write-Through mode.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-11-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable_types.h | 3 +++
 arch/x86/mm/pat.c                    | 7 +++++++
 include/asm-generic/pgtable.h        | 4 ++++
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
index 6311193..076187c 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -1000,6 +1000,13 @@ pgprot_t pgprot_writecombine(pgprot_t prot)
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
