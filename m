Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id EE5329003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:25 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so42082756obd.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:25 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id n4si2984826oek.87.2015.08.05.14.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:23 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 4/10] x86/asm: Add pud_pgprot() and pmd_pgprot()
Date: Wed,  5 Aug 2015 15:43:27 -0600
Message-Id: <1438811013-30983-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

pte_pgprot() returns a pgprot_t value by calling pte_flags().  Now
that pud_flags() and pmd_flags() work differently from pte_flags(),
define pud_pgprot() and pmd_pgprot() for PUD/PMD.  Also update
pte_pgprot() to remove the masking with PTE_FLAGS_MASK, which is
unnecessary since pte_flags() takes care of it.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/include/asm/pgtable.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0733ec7..59fc341 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -379,7 +379,9 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
 	return __pgprot(preservebits | addbits);
 }
 
-#define pte_pgprot(x) __pgprot(pte_flags(x) & PTE_FLAGS_MASK)
+#define pte_pgprot(x) __pgprot(pte_flags(x))
+#define pmd_pgprot(x) __pgprot(pmd_flags(x))
+#define pud_pgprot(x) __pgprot(pud_flags(x))
 
 #define canon_pgprot(p) __pgprot(massage_pgprot(p))
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
