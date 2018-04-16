Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4660E6B002B
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:25:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a38so11144828wra.10
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:25:47 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id d5si1139234edi.418.2018.04.16.08.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:25:46 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 16/35] x86/pgtable/pae: Unshare kernel PMDs when PTI is enabled
Date: Mon, 16 Apr 2018 17:25:04 +0200
Message-Id: <1523892323-14741-17-git-send-email-joro@8bytes.org>
In-Reply-To: <1523892323-14741-1-git-send-email-joro@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

With PTI we need to map the per-process LDT into the kernel
address-space for each process, so we need separate kernel
PMDs per PGD.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-3level_types.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
index 6a59a6d..78038e0 100644
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
