Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id B79766B0055
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:45:09 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id uy5so6181568obc.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:45:09 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id q6si24123303oel.22.2014.07.15.12.45.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:45:09 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 11/11] x86, fbdev: Cleanup PWT/PCD bit manipulation in fbdev
Date: Tue, 15 Jul 2014 13:34:44 -0600
Message-Id: <1405452884-25688-12-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

This patch cleans up the PWT & PCD bit manipulation in fbdev,
and uses _PAGE_CACHE_<type> macros, instead.  This keeps the
fbdev code independent from the PAT slot assignment.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/fb.h                 |    3 ++-
 drivers/video/fbdev/gbefb.c               |    3 ++-
 drivers/video/fbdev/vermilion/vermilion.c |    4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/fb.h b/arch/x86/include/asm/fb.h
index 2519d06..05fa937 100644
--- a/arch/x86/include/asm/fb.h
+++ b/arch/x86/include/asm/fb.h
@@ -9,7 +9,8 @@ static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
 {
 	if (boot_cpu_data.x86 > 3)
-		pgprot_val(vma->vm_page_prot) |= _PAGE_PCD;
+		vma->vm_page_prot = pgprot_set_cache(vma->vm_page_prot,
+						     _PAGE_CACHE_UC_MINUS);
 }
 
 extern int fb_is_primary_device(struct fb_info *info);
diff --git a/drivers/video/fbdev/gbefb.c b/drivers/video/fbdev/gbefb.c
index 4aa56ba..4af9ec7 100644
--- a/drivers/video/fbdev/gbefb.c
+++ b/drivers/video/fbdev/gbefb.c
@@ -54,7 +54,8 @@ struct gbefb_par {
 #endif
 #endif
 #ifdef CONFIG_X86
-#define pgprot_fb(_prot) ((_prot) | _PAGE_PCD)
+/* NOTE: use _PAGE_CACHE_WT if desired */
+#define pgprot_fb(_prot) (((_prot) & ~_PAGE_CACHE_MASK) | _PAGE_CACHE_UC_MINUS)
 #endif
 
 /*
diff --git a/drivers/video/fbdev/vermilion/vermilion.c b/drivers/video/fbdev/vermilion/vermilion.c
index 048a666..6a7c744 100644
--- a/drivers/video/fbdev/vermilion/vermilion.c
+++ b/drivers/video/fbdev/vermilion/vermilion.c
@@ -1009,8 +1009,8 @@ static int vmlfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 	if (ret)
 		return -EINVAL;
 
-	pgprot_val(vma->vm_page_prot) |= _PAGE_PCD;
-	pgprot_val(vma->vm_page_prot) &= ~_PAGE_PWT;
+	vma->vm_page_prot = pgprot_set_cache(vma->vm_page_prot,
+					     _PAGE_CACHE_UC_MINUS);
 
 	return vm_iomap_memory(vma, vinfo->vram_start,
 			vinfo->vram_contig_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
