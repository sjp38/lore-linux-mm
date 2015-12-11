Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0AE6B0259
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:21:56 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so57971789pac.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:21:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id g14si160802pfd.164.2015.12.10.19.21.55
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:55 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 3/6] x86/vdso: Track each mm's loaded vdso image as well as its base
Date: Thu, 10 Dec 2015 19:21:44 -0800
Message-Id: <09f0c1f952c071b86b29cb39532a08851096e4b4.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

As we start to do more intelligent things with the vdso at runtime
(as opposed to just at mm initialization time), we'll need to know
which vdso is in use.

In principle, we could guess based on the mm type, but that's
over-complicated and error-prone.  Instead, just track it in the mmu
context.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vma.c  | 1 +
 arch/x86/include/asm/mmu.h | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index b8f69e264ac4..80b021067bd6 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -121,6 +121,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 
 	text_start = addr - image->sym_vvar_start;
 	current->mm->context.vdso = (void __user *)text_start;
+	current->mm->context.vdso_image = image;
 
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 55234d5e7160..1ea0baef1175 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -19,7 +19,8 @@ typedef struct {
 #endif
 
 	struct mutex lock;
-	void __user *vdso;
+	void __user *vdso;			/* vdso base address */
+	const struct vdso_image *vdso_image;	/* vdso image in use */
 
 	atomic_t perf_rdpmc_allowed;	/* nonzero if rdpmc is allowed */
 } mm_context_t;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
