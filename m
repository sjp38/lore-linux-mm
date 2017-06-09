Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECD2D6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 09:58:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g76so8531466wrd.3
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 06:58:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 62si1291432wrg.43.2017.06.09.06.58.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 06:58:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] x86, mm: disable 1GB direct mapping when disabling 2MB mapping
Date: Fri,  9 Jun 2017 15:57:43 +0200
Message-Id: <20170609135743.9920-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

The kmemleak and debug_pagealloc features both disable using huge pages for
direct mapping so they can do cpa() on page level granularity in any context.
However they only do that for 2MB pages, which means 1GB pages can still be
used if the CPU supports it, unless disabled by a boot param, which is
non-obvious. Disable also 1GB pages when disabling 2MB pages.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/x86/mm/init.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index cbc87ea98751..20282dfce0fa 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -170,6 +170,10 @@ static void __init probe_page_size_mask(void)
 	 */
 	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled())
 		page_size_mask |= 1 << PG_LEVEL_2M;
+	else
+		direct_gbpages = 0;
+#else
+	direct_gbpages = 0;
 #endif
 
 	/* Enable PSE if available */
-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
