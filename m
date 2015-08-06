Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 789786B0254
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 19:58:21 -0400 (EDT)
Received: by qged69 with SMTP id d69so64825147qge.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 16:58:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v72si14714675qge.61.2015.08.06.16.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 16:58:20 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V2 1/3] mm: add utility for early copy from unmapped ram
Date: Thu,  6 Aug 2015 17:41:37 -0400
Message-Id: <1438897299-2266-2-git-send-email-msalter@redhat.com>
In-Reply-To: <1438897299-2266-1-git-send-email-msalter@redhat.com>
References: <1438897299-2266-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

In some early boot circumstances, it may be necessary to copy
from RAM outside the kernel linear mapping to mapped RAM. The
need to relocate an initrd is one example in the x86 code. This
patch creates a helper function based on current x86 code.

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 include/asm-generic/early_ioremap.h |  6 ++++++
 mm/early_ioremap.c                  | 22 ++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/asm-generic/early_ioremap.h b/include/asm-generic/early_ioremap.h
index a5de55c..e539f27 100644
--- a/include/asm-generic/early_ioremap.h
+++ b/include/asm-generic/early_ioremap.h
@@ -33,6 +33,12 @@ extern void early_ioremap_setup(void);
  */
 extern void early_ioremap_reset(void);
 
+/*
+ * Early copy from unmapped memory to kernel mapped memory.
+ */
+extern void copy_from_early_mem(void *dest, phys_addr_t src,
+				unsigned long size);
+
 #else
 static inline void early_ioremap_init(void) { }
 static inline void early_ioremap_setup(void) { }
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index e10ccd2..acba804 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -217,6 +217,28 @@ early_memremap(resource_size_t phys_addr, unsigned long size)
 	return (__force void *)__early_ioremap(phys_addr, size,
 					       FIXMAP_PAGE_NORMAL);
 }
+
+#define MAX_MAP_CHUNK	(NR_FIX_BTMAPS << PAGE_SHIFT)
+
+void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
+{
+	unsigned long slop, clen;
+	char *p;
+
+	while (size) {
+		slop = src & ~PAGE_MASK;
+		clen = size;
+		if (clen > MAX_MAP_CHUNK - slop)
+			clen = MAX_MAP_CHUNK - slop;
+		p = early_memremap(src & PAGE_MASK, clen + slop);
+		memcpy(dest, p + slop, clen);
+		early_iounmap(p, clen + slop);
+		dest += clen;
+		src += clen;
+		size -= clen;
+	}
+}
+
 #else /* CONFIG_MMU */
 
 void __init __iomem *
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
