Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3DDB69003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:39 -0400 (EDT)
Received: by obnw1 with SMTP id w1so41917828obn.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:39 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id sa7si3023178oeb.3.2015.08.05.14.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:29 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 10/10] x86/mm: Fix the same pgprot handling in try_preserve_large_page()
Date: Wed,  5 Aug 2015 15:43:33 -0600
Message-Id: <1438811013-30983-11-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

try_preserve_large_page() checks if new_prot is the same as
old_prot.  If so, it simply sets do_split to 0, and returns
with no-operation.  However, old_prot is set as a 4KB pgprot
value while new_prot is a large page pgprot value.

Now that old_prot is initially set from p?d_pgprot() as a
large page pgprot value, fix it by not overwriting old_prot
with a 4KB pgprot value.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/pageattr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index d0e40ed..6f9b885 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -519,7 +519,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
 	 * up accordingly.
 	 */
 	old_pte = *kpte;
-	old_prot = req_prot = pgprot_large_2_4k(old_prot);
+	req_prot = pgprot_large_2_4k(old_prot);
 
 	pgprot_val(req_prot) &= ~pgprot_val(cpa->mask_clr);
 	pgprot_val(req_prot) |= pgprot_val(cpa->mask_set);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
