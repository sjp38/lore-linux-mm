Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 185CA6B026A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i64so4404297wmd.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:41 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 20si5485615edt.82.2018.03.05.02.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:19 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 23/34] x86/mm/legacy: Populate the user page-table with user pgd's
Date: Mon,  5 Mar 2018 11:25:52 +0100
Message-Id: <1520245563-8444-24-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Also populate the user-spage pgd's in the user page-table.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-2level.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 685ffe8..c399ea5 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -19,6 +19,9 @@ static inline void native_set_pte(pte_t *ptep , pte_t pte)
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pmd.pud.p4d.pgd = pti_set_user_pgtbl(&pmdp->pud.p4d.pgd, pmd.pud.p4d.pgd);
+#endif
 	*pmdp = pmd;
 }
 
@@ -58,6 +61,9 @@ static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 #ifdef CONFIG_SMP
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pti_set_user_pgtbl(&xp->pud.p4d.pgd, __pgd(0));
+#endif
 	return __pmd(xchg((pmdval_t *)xp, 0));
 }
 #else
@@ -67,6 +73,9 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 #ifdef CONFIG_SMP
 static inline pud_t native_pudp_get_and_clear(pud_t *xp)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pti_set_user_pgtbl(&xp->p4d.pgd, __pgd(0));
+#endif
 	return __pud(xchg((pudval_t *)xp, 0));
 }
 #else
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
