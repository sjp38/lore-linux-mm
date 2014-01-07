Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6326B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:35:38 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so8231749ead.36
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:35:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v6si86936111eel.112.2014.01.06.18.35.36
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:35:37 -0800 (PST)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH v2 4/5] arm64: initialize pgprot info earlier in boot
Date: Mon,  6 Jan 2014 21:35:19 -0500
Message-Id: <1389062120-31896-5-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, Mark Salter <msalter@redhat.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

Presently, paging_init() calls init_mem_pgprot() to initialize pgprot
values used by macros such as PAGE_KERNEL, PAGE_KERNEL_EXEC, etc. The
new fixmap and early_ioremap support also needs to use these macros
before paging_init() is called. This patch moves the init_mem_pgprot()
call out of paging_init() and into setup_arch() so that pgprot_default
gets initialized in time for fixmap and early_ioremap.

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: linux-arm-kernel@lists.infradead.org
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/include/asm/mmu.h | 1 +
 arch/arm64/kernel/setup.c    | 2 ++
 arch/arm64/mm/mmu.c          | 3 +--
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index 2494fc0..f600d40 100644
--- a/arch/arm64/include/asm/mmu.h
+++ b/arch/arm64/include/asm/mmu.h
@@ -27,5 +27,6 @@ typedef struct {
 extern void paging_init(void);
 extern void setup_mm_for_reboot(void);
 extern void __iomem *early_io_map(phys_addr_t phys, unsigned long virt);
+extern void init_mem_pgprot(void);
 
 #endif
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index bd9bbd0..029ecfe 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -221,6 +221,8 @@ void __init setup_arch(char **cmdline_p)
 
 	*cmdline_p = boot_command_line;
 
+	init_mem_pgprot();
+
 	parse_early_param();
 
 	arm64_memblock_init();
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index f557ebb..541c782 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -125,7 +125,7 @@ early_param("cachepolicy", early_cachepolicy);
 /*
  * Adjust the PMD section entries according to the CPU in use.
  */
-static void __init init_mem_pgprot(void)
+void __init init_mem_pgprot(void)
 {
 	pteval_t default_pgprot;
 	int i;
@@ -349,7 +349,6 @@ void __init paging_init(void)
 {
 	void *zero_page;
 
-	init_mem_pgprot();
 	map_mem();
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
