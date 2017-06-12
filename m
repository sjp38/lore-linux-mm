Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 483C86B0279
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 03:21:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id s4so21014603wrc.15
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 00:21:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s70si6416937wme.6.2017.06.12.00.21.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Jun 2017 00:21:31 -0700 (PDT)
Subject: Re: [PATCH] x86, mm: disable 1GB direct mapping when disabling 2MB
 mapping
References: <20170609135743.9920-1-vbabka@suse.cz>
 <20170611075759.aiesval452dbgfpr@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2be70c78-6130-855d-3dfa-d87bd1dd4fda@suse.cz>
Date: Mon, 12 Jun 2017 09:21:30 +0200
MIME-Version: 1.0
In-Reply-To: <20170611075759.aiesval452dbgfpr@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>

On 06/11/2017 09:57 AM, Ingo Molnar wrote:
> So I agree with the fix, but I think it would be much cleaner to eliminate the 
> outer #ifdef:
> 
> 	#if !defined(CONFIG_KMEMCHECK)
> 
> and put it into the condition, like this:
> 
> 	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled() && !IS_ENABLED(CONFIG_KMEMCHECK))

Right, that's better, thanks.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 9 Jun 2017 15:41:22 +0200
Subject: [PATCH v2] x86, mm: disable 1GB direct mapping when disabling 2MB
 mapping

The kmemleak and debug_pagealloc features both disable using huge pages for
direct mapping so they can do cpa() on page level granularity in any context.
However they only do that for 2MB pages, which means 1GB pages can still be
used if the CPU supports it, unless disabled by a boot param, which is
non-obvious. Disable also 1GB pages when disabling 2MB pages.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/x86/mm/init.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index cbc87ea98751..b11afaf04c9d 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -161,16 +161,17 @@ static int page_size_mask;
 
 static void __init probe_page_size_mask(void)
 {
-#if !defined(CONFIG_KMEMCHECK)
 	/*
 	 * For CONFIG_KMEMCHECK or pagealloc debugging, identity mapping will
 	 * use small pages.
 	 * This will simplify cpa(), which otherwise needs to support splitting
 	 * large pages into small in interrupt context, etc.
 	 */
-	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled())
+	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled() &&
+						!IS_ENABLED(CONFIG_KMEMCHECK))
 		page_size_mask |= 1 << PG_LEVEL_2M;
-#endif
+	else
+		direct_gbpages = 0;
 
 	/* Enable PSE if available */
 	if (boot_cpu_has(X86_FEATURE_PSE))
-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
