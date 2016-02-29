Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DBAC96B026A
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:44 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so40036606wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:44 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id p8si15365238wmb.73.2016.02.29.06.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:43 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id l68so61617253wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:43 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 9/9] mm: replace open coded page to virt conversion with page_to_virt()
Date: Mon, 29 Feb 2016 15:44:44 +0100
Message-Id: <1456757084-1078-10-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The open coded conversion from struct page address to virtual address in
lowmem_page_address() involves an intermediate conversion step to pfn
number/physical address. Since the placement of the struct page array
relative to the linear mapping may be completely independent from the
placement of physical RAM (as is that case for arm64 after commit
dfd55ad85e 'arm64: vmemmap: use virtual projection of linear region'),
the conversion to physical address and back again should factor out of
the equation, but unfortunately, the shifting and pointer arithmetic
involved prevent this from happening, and the resulting calculation
essentially subtracts the address of the start of physical memory and
adds it back again, in a way that prevents the compiler from optimizing
it away.

Since the start of physical memory is not a build time constant on arm64,
the resulting conversion involves an unnecessary memory access, which
we would like to get rid of. So replace the open coded conversion with
a call to page_to_virt(), and use the open coded conversion as its
default definition, to be overriden by the architecture, if desired.
The existing arch specific definitions of page_to_virt are all equivalent
to this default definition, so by itself this patch is a no-op.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 include/linux/mm.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 516e14944339..82cb74a3b158 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -71,6 +71,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
 
+#ifndef page_to_virt
+#define page_to_virt(x)	__va(PFN_PHYS(page_to_pfn(x)))
+#endif
+
 /*
  * To prevent common memory management code establishing
  * a zero page mapping on a read fault.
@@ -927,7 +931,7 @@ static inline void set_page_memcg(struct page *page, struct mem_cgroup *memcg)
 
 static __always_inline void *lowmem_page_address(const struct page *page)
 {
-	return __va(PFN_PHYS(page_to_pfn(page)));
+	return page_to_virt(page);
 }
 
 #if defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
