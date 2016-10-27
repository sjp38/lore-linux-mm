Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A043280255
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hm5so27208920pac.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:57 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id b190si8872791pfa.34.2016.10.27.10.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:56 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 6/8] powerpc/vdso: switch from legacy_special_mapping_vmops
Date: Thu, 27 Oct 2016 20:09:46 +0300
Message-ID: <20161027170948.8279-7-dsafonov@virtuozzo.com>
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

This will allow to handle vDSO vma like special_mapping, that has
it's name and hooks. Needed for mremap hook, which will replace
arch_mremap helper, also for removing arch_vma_name.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/powerpc/kernel/vdso.c        | 19 +++++++++++--------
 arch/powerpc/kernel/vdso_common.c |  8 ++++++--
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index e68601ffc9ad..9ee3fd65c6e9 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -51,7 +51,7 @@
 #define VDSO_ALIGNMENT	(1 << 16)
 
 static unsigned int vdso32_pages;
-static struct page **vdso32_pagelist;
+static struct vm_special_mapping vdso32_mapping;
 unsigned long vdso32_sigtramp;
 unsigned long vdso32_rt_sigtramp;
 
@@ -64,7 +64,7 @@ static void *vdso32_kbase;
 extern char vdso64_start, vdso64_end;
 static void *vdso64_kbase = &vdso64_start;
 static unsigned int vdso64_pages;
-static struct page **vdso64_pagelist;
+static struct vm_special_mapping vdso64_mapping;
 unsigned long vdso64_rt_sigtramp;
 #endif /* CONFIG_PPC64 */
 
@@ -143,10 +143,11 @@ struct lib64_elfinfo
 	unsigned long	text;
 };
 
-static int map_vdso(struct page **vdso_pagelist, unsigned long vdso_pages,
+static int map_vdso(struct vm_special_mapping *vsm, unsigned long vdso_pages,
 		unsigned long vdso_base)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	int ret = 0;
 
 	mm->context.vdso_base = 0;
@@ -198,12 +199,14 @@ static int map_vdso(struct page **vdso_pagelist, unsigned long vdso_pages,
 	 * It's fine to use that for setting breakpoints in the vDSO code
 	 * pages though.
 	 */
-	ret = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
+	vma = _install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
 				     VM_READ|VM_EXEC|
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				     vdso_pagelist);
-	if (ret)
+				     vsm);
+	if (IS_ERR(vma)) {
+		ret = PTR_ERR(vma);
 		current->mm->context.vdso_base = 0;
+	}
 
 out_up_mmap_sem:
 	up_write(&mm->mmap_sem);
@@ -220,7 +223,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		return 0;
 
 	if (is_32bit_task())
-		return map_vdso(vdso32_pagelist, vdso32_pages, VDSO32_MBASE);
+		return map_vdso(&vdso32_mapping, vdso32_pages, VDSO32_MBASE);
 #ifdef CONFIG_PPC64
 	else
 		/*
@@ -228,7 +231,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		 * allows get_unmapped_area to find an area near other mmaps
 		 * and most likely share a SLB entry.
 		 */
-		return map_vdso(vdso64_pagelist, vdso64_pages, 0);
+		return map_vdso(&vdso64_mapping, vdso64_pages, 0);
 #endif
 	WARN_ONCE(1, "task is not 32-bit on non PPC64 kernel");
 	return -1;
diff --git a/arch/powerpc/kernel/vdso_common.c b/arch/powerpc/kernel/vdso_common.c
index c97c30606b3f..047f6b8b230f 100644
--- a/arch/powerpc/kernel/vdso_common.c
+++ b/arch/powerpc/kernel/vdso_common.c
@@ -14,7 +14,7 @@
 #define VDSO_LBASE	CONCAT3(VDSO, BITS, _LBASE)
 #define vdso_kbase	CONCAT3(vdso, BITS, _kbase)
 #define vdso_pages	CONCAT3(vdso, BITS, _pages)
-#define vdso_pagelist	CONCAT3(vdso, BITS, _pagelist)
+#define vdso_mapping	CONCAT3(vdso, BITS, _mapping)
 
 #undef pr_fmt
 #define pr_fmt(fmt)	"vDSO" __stringify(BITS) ": " fmt
@@ -207,6 +207,7 @@ static __init int vdso_setup(struct lib_elfinfo *v)
 static __init void init_vdso_pagelist(void)
 {
 	int i;
+	struct page **vdso_pagelist;
 
 	/* Make sure pages are in the correct state */
 	vdso_pagelist = kzalloc(sizeof(struct page *) * (vdso_pages + 2),
@@ -221,6 +222,9 @@ static __init void init_vdso_pagelist(void)
 	}
 	vdso_pagelist[i++] = virt_to_page(vdso_data);
 	vdso_pagelist[i] = NULL;
+
+	vdso_mapping.pages = vdso_pagelist;
+	vdso_mapping.name = "[vdso]";
 }
 
 #undef find_section
@@ -236,7 +240,7 @@ static __init void init_vdso_pagelist(void)
 #undef VDSO_LBASE
 #undef vdso_kbase
 #undef vdso_pages
-#undef vdso_pagelist
+#undef vdso_mapping
 #undef lib_elfinfo
 #undef BITS
 #undef _CONCAT3
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
