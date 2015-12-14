Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 76D4E6B0256
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:31:28 -0500 (EST)
Received: by pff63 with SMTP id 63so15312038pff.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:31:28 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id v1si18634560pfa.242.2015.12.14.10.31.27
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 10:31:27 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 3/6] x86/vdso: Track each mm's loaded vdso image as well as its base
Date: Mon, 14 Dec 2015 10:31:15 -0800
Message-Id: <69bab428e0db14fc1bc1add051d2a294760137dc.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
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
