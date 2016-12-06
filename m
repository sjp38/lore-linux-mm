Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE846B0261
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 18:51:10 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p16so252498007qta.5
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:10 -0800 (PST)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com. [209.85.220.181])
        by mx.google.com with ESMTPS id c11si12959679qtb.224.2016.12.06.15.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 15:51:09 -0800 (PST)
Received: by mail-qk0-f181.google.com with SMTP id n21so397662398qka.3
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 15:51:09 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv5 02/11] mm/cma: Cleanup highmem check
Date: Tue,  6 Dec 2016 15:50:48 -0800
Message-Id: <1481068257-6367-3-git-send-email-labbott@redhat.com>
In-Reply-To: <1481068257-6367-1-git-send-email-labbott@redhat.com>
References: <1481068257-6367-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org


6b101e2a3ce4 ("mm/CMA: fix boot regression due to physical address of
high_memory") added checks to use __pa_nodebug on x86 since
CONFIG_DEBUG_VIRTUAL complains about high_memory not being linearlly
mapped. arm64 is now getting support for CONFIG_DEBUG_VIRTUAL as well.
Rather than add an explosion of arches to the #ifdef, switch to an
alternate method to calculate the physical start of highmem using
the page before highmem starts. This avoids the need for the #ifdef and
extra __pa_nodebug calls.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v5: No changes
---
 mm/cma.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index c960459..94b3460 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -235,18 +235,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	phys_addr_t highmem_start;
 	int ret = 0;
 
-#ifdef CONFIG_X86
 	/*
-	 * high_memory isn't direct mapped memory so retrieving its physical
-	 * address isn't appropriate.  But it would be useful to check the
-	 * physical address of the highmem boundary so it's justifiable to get
-	 * the physical address from it.  On x86 there is a validation check for
-	 * this case, so the following workaround is needed to avoid it.
+	 * We can't use __pa(high_memory) directly, since high_memory
+	 * isn't a valid direct map VA, and DEBUG_VIRTUAL will (validly)
+	 * complain. Find the boundary by adding one to the last valid
+	 * address.
 	 */
-	highmem_start = __pa_nodebug(high_memory);
-#else
-	highmem_start = __pa(high_memory);
-#endif
+	highmem_start = __pa(high_memory - 1) + 1;
 	pr_debug("%s(size %pa, base %pa, limit %pa alignment %pa)\n",
 		__func__, &size, &base, &limit, &alignment);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
