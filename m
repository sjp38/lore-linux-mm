Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7E4C6B0029
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o8-v6so18713782wra.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:55 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p14si1489198edi.24.2018.04.23.08.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:54 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 22/37] x86/mm/pae: Populate the user page-table with user pgd's
Date: Mon, 23 Apr 2018 17:47:25 +0200
Message-Id: <1524498460-25530-23-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

When we populate a PGD entry, make sure we populate it in
the user page-table too.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-3level.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
index f24df59..f2ca313 100644
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -98,6 +98,9 @@ static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 
 static inline void native_set_pud(pud_t *pudp, pud_t pud)
 {
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pud.p4d.pgd = pti_set_user_pgtbl(&pudp->p4d.pgd, pud.p4d.pgd);
+#endif
 	set_64bit((unsigned long long *)(pudp), native_pud_val(pud));
 }
 
@@ -229,6 +232,10 @@ static inline pud_t native_pudp_get_and_clear(pud_t *pudp)
 {
 	union split_pud res, *orig = (union split_pud *)pudp;
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+	pti_set_user_pgtbl(&pudp->p4d.pgd, __pgd(0));
+#endif
+
 	/* xchg acts as a barrier before setting of the high bits */
 	res.pud_low = xchg(&orig->pud_low, 0);
 	res.pud_high = orig->pud_high;
-- 
2.7.4
