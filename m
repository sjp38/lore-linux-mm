Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id C52D86B025E
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:34 -0400 (EDT)
Received: by obbda8 with SMTP id da8so20161644obb.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:34 -0700 (PDT)
Received: from g1t6220.austin.hp.com (g1t6220.austin.hp.com. [15.73.96.84])
        by mx.google.com with ESMTPS id xy6si2332593obc.95.2015.09.17.11.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:23 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 11/11] x86/mm: Fix no-change case in try_preserve_large_page()
Date: Thu, 17 Sep 2015 12:24:24 -0600
Message-Id: <1442514264-12475-12-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>

try_preserve_large_page() checks if new_prot is the same as
old_prot.  If so, it simply sets do_split to 0, and returns
with no-operation.  However, old_prot is set as a 4KB pgprot
value while new_prot is a large page pgprot value.

Now that old_prot is initially set from p?d_pgprot() as a
large page pgprot value, fix it by not overwriting old_prot
with a 4KB pgprot value.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
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
