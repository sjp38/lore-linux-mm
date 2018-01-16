Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE09A6B0266
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:28:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 17so3482182wma.1
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:28:37 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 94si1666835edn.200.2018.01.16.08.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:21 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 12/16] x86/mm/pae: Populate the user page-table with user pgd's
Date: Tue, 16 Jan 2018 17:36:55 +0100
Message-Id: <1516120619-1159-13-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

This is the last part of the PAE page-table setup for PAE
before we can add the CR3 switch to the entry code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-3level.h | 3 +++
 arch/x86/mm/pti.c                     | 7 +++++++
 2 files changed, 10 insertions(+)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index bc4af5453802..910f0b35370e 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -98,6 +98,9 @@ static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pud.p4d.pgd = pti_set_user_pgd(&pudp->p4d.pgd, pud.p4d.pgd);
+#endif
 	set_64bit((unsigned long long *)(pudp), native_pud_val(pud));
 }
 
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 6b6bfd13350e..a561b5625d6c 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -122,6 +122,7 @@ pgd_t __pti_set_user_pgd(pgd_t *pgdp, pgd_t pgd)
 	 */
 	kernel_to_user_pgdp(pgdp)->pgd = pgd.pgd;
 
+#ifdef CONFIG_X86_64
 	/*
 	 * If this is normal user memory, make it NX in the kernel
 	 * pagetables so that, if we somehow screw up and return to
@@ -134,10 +135,16 @@ pgd_t __pti_set_user_pgd(pgd_t *pgdp, pgd_t pgd)
 	 *     may execute from it
 	 *  - we don't have NX support
 	 *  - we're clearing the PGD (i.e. the new pgd is not present).
+	 *  - We run on a 32 bit kernel. 2-level paging doesn't support NX at
+	 *    all and PAE paging does not support it on the PGD level. We can
+	 *    set it in the PMD level there in the future, but that means we
+	 *    need to unshare the PMDs between the kernel and the user
+	 *    page-tables.
 	 */
 	if ((pgd.pgd & (_PAGE_USER|_PAGE_PRESENT)) == (_PAGE_USER|_PAGE_PRESENT) &&
 	    (__supported_pte_mask & _PAGE_NX))
 		pgd.pgd |= _PAGE_NX;
+#endif
 
 	/* return the copy of the PGD we want the kernel to use: */
 	return pgd;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
