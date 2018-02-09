Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D79E6B0022
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:26:01 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s18so4235130wrg.5
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:26:01 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id w8si550638edw.148.2018.02.09.01.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:59 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 14/31] x86/pgtable/pae: Unshare kernel PMDs when PTI is enabled
Date: Fri,  9 Feb 2018 10:25:23 +0100
Message-Id: <1518168340-9392-15-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

With PTI we need to map the per-process LDT into the kernel
address-space for each process, so we need separate kernel
PMDs per PGD.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-3level_types.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
index 876b4c7..ed8a200 100644
--- a/arch/x86/include/asm/pgtable-3level_types.h
+++ b/arch/x86/include/asm/pgtable-3level_types.h
@@ -21,9 +21,10 @@ typedef union {
 #endif	/* !__ASSEMBLY__ */
 
 #ifdef CONFIG_PARAVIRT
-#define SHARED_KERNEL_PMD	(pv_info.shared_kernel_pmd)
+#define SHARED_KERNEL_PMD	((!static_cpu_has(X86_FEATURE_PTI) &&	\
+				 (pv_info.shared_kernel_pmd)))
 #else
-#define SHARED_KERNEL_PMD	1
+#define SHARED_KERNEL_PMD	(!static_cpu_has(X86_FEATURE_PTI))
 #endif
 
 /*
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
