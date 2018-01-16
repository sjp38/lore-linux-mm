Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 09564280244
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:28:40 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id c10so1222718uae.23
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:28:40 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id l89si2576173ede.122.2018.01.16.08.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:21 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 10/16] x86/mm/pti: Populate valid user pud entries
Date: Tue, 16 Jan 2018 17:36:53 +0100
Message-Id: <1516120619-1159-11-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

With PAE paging we don't have PGD and P4D levels in the
page-table, instead the PUD level is the highest one.

In PAE page-tables at the top-level most bits we usually set
with _KERNPG_TABLE are reserved, resulting in a #GP when
they are loaded by the processor.

Work around this by populating PUD entries in the user
page-table only with _PAGE_PRESENT set.

I am pretty sure there is a cleaner way to do this, but
until I find it use this #ifdef solution.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 20be21301a59..6b6bfd13350e 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -202,8 +202,12 @@ static __init pmd_t *pti_user_pagetable_walk_pmd(unsigned long address)
 		unsigned long new_pmd_page = __get_free_page(gfp);
 		if (!new_pmd_page)
 			return NULL;
-
+#ifdef CONFIG_X86_PAE
+		/* TODO: There must be a cleaner way to do this */
+		set_pud(pud, __pud(_PAGE_PRESENT | __pa(new_pmd_page)));
+#else
 		set_pud(pud, __pud(_KERNPG_TABLE | __pa(new_pmd_page)));
+#endif
 	}
 
 	return pmd_offset(pud, address);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
