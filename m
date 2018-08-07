Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11FFD6B0005
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 06:24:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f8-v6so5227794eds.6
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 03:24:37 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id t18-v6si664794edf.80.2018.08.07.03.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 03:24:35 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 2/3] x86/mm/pti: Don't clear permissions in pti_clone_pmd()
Date: Tue,  7 Aug 2018 12:24:30 +0200
Message-Id: <1533637471-30953-3-git-send-email-joro@8bytes.org>
In-Reply-To: <1533637471-30953-1-git-send-email-joro@8bytes.org>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The function sets the global-bit on cloned PMD entries,
which only makes sense when the permissions are identical
between the user and the kernel page-table.

Further, only write-permissions are cleared for entry-text
and kernel-text sections, which are not writeable anyway.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 113ba14..5164c98 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -291,7 +291,7 @@ static void __init pti_setup_vsyscall(void) { }
 #endif
 
 static void
-pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
+pti_clone_pmds(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -352,7 +352,7 @@ pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
 		 * tables will share the last-level page tables of this
 		 * address range
 		 */
-		*target_pmd = pmd_clear_flags(*pmd, clear);
+		*target_pmd = *pmd;
 	}
 }
 
@@ -398,7 +398,7 @@ static void __init pti_clone_user_shared(void)
 	start = CPU_ENTRY_AREA_BASE;
 	end   = start + (PAGE_SIZE * CPU_ENTRY_AREA_PAGES);
 
-	pti_clone_pmds(start, end, 0);
+	pti_clone_pmds(start, end);
 }
 #endif /* CONFIG_X86_64 */
 
@@ -418,8 +418,7 @@ static void __init pti_setup_espfix64(void)
 static void pti_clone_entry_text(void)
 {
 	pti_clone_pmds((unsigned long) __entry_text_start,
-			(unsigned long) __irqentry_text_end,
-		       _PAGE_RW);
+		       (unsigned long) __irqentry_text_end);
 }
 
 /*
@@ -501,7 +500,7 @@ static void pti_clone_kernel_text(void)
 	 * pti_set_kernel_image_nonglobal() did to clear the
 	 * global bit.
 	 */
-	pti_clone_pmds(start, end_clone, _PAGE_RW);
+	pti_clone_pmds(start, end_clone);
 
 	/*
 	 * pti_clone_pmds() will set the global bit in any PMDs
-- 
2.7.4
