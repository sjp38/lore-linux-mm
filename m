Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id A7DFE6B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:58:06 -0400 (EDT)
Received: by igfj19 with SMTP id j19so22591537igf.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:58:06 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id l6si2101919igv.47.2015.08.25.14.57.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:32 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 11/11] x86/mm: Fix no-change case in try_preserve_large_page()
Date: Tue, 25 Aug 2015 15:55:11 -0600
Message-Id: <1440539711-2985-12-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
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
index b64a451..97735f4 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -536,7 +536,7 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
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
