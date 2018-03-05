Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5986B027D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:57 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j21so11067624wre.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:57 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id a24si316790edn.426.2018.03.05.02.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:18 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 26/34] x86/mm/pti: Clone CPU_ENTRY_AREA on PMD level on x86_32
Date: Mon,  5 Mar 2018 11:25:55 +0100
Message-Id: <1520245563-8444-27-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Cloning on the P4D level would clone the complete kernel
address space into the user-space page-tables for PAE
kernels. Cloning on PMD level is fine for PAE and legacy
paging.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 96a690e..3ffd923 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -312,6 +312,7 @@ pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
 	}
 }
 
+#ifdef CONFIG_X86_64
 /*
  * Clone a single p4d (i.e. a top-level entry on 4-level systems and a
  * next-level entry on 5-level systems.
@@ -335,6 +336,25 @@ static void __init pti_clone_user_shared(void)
 	pti_clone_p4d(CPU_ENTRY_AREA_BASE);
 }
 
+#else /* CONFIG_X86_64 */
+
+/*
+ * On 32 bit PAE systems with 1GB of Kernel address space there is only
+ * one pgd/p4d for the whole kernel. Cloning that would map the whole
+ * address space into the user page-tables, making PTI useless. So clone
+ * the page-table on the PMD level to prevent that.
+ */
+static void __init pti_clone_user_shared(void)
+{
+	unsigned long start, end;
+
+	start = CPU_ENTRY_AREA_BASE;
+	end   = start + (PAGE_SIZE * CPU_ENTRY_AREA_PAGES);
+
+	pti_clone_pmds(start, end, _PAGE_GLOBAL);
+}
+#endif /* CONFIG_X86_64 */
+
 /*
  * Clone the ESPFIX P4D into the user space visinble page table
  */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
