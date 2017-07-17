Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D9B916B04BC
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:12:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i128so542317qkc.11
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:12:58 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0050.outbound.protection.outlook.com. [104.47.33.50])
        by mx.google.com with ESMTPS id k124si239972qkd.259.2017.07.17.14.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:12:56 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 31/38] x86/mm, kexec: Allow kexec to be used with SME
Date: Mon, 17 Jul 2017 16:10:28 -0500
Message-Id: <b95ff075db3e7cd545313f2fb609a49619a09625.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, kexec@lists.infradead.org

Provide support so that kexec can be used to boot a kernel when SME is
enabled.

Support is needed to allocate pages for kexec without encryption.  This
is needed in order to be able to reboot in the kernel in the same manner
as originally booted.

Additionally, when shutting down all of the CPUs we need to be sure to
flush the caches and then halt. This is needed when booting from a state
where SME was not active into a state where SME is active (or vice-versa).
Without these steps, it is possible for cache lines to exist for the same
physical location but tagged both with and without the encryption bit. This
can cause random memory corruption when caches are flushed depending on
which cacheline is written last.

Cc: <kexec@lists.infradead.org>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/init.h          |  1 +
 arch/x86/include/asm/kexec.h         |  8 ++++++++
 arch/x86/include/asm/pgtable_types.h |  1 +
 arch/x86/kernel/machine_kexec_64.c   | 22 +++++++++++++++++++++-
 arch/x86/kernel/process.c            | 17 +++++++++++++++--
 arch/x86/mm/ident_map.c              | 12 ++++++++----
 include/linux/kexec.h                |  8 ++++++++
 kernel/kexec_core.c                  | 12 +++++++++++-
 8 files changed, 73 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/init.h b/arch/x86/include/asm/init.h
index 474eb8c..05c4aa0 100644
--- a/arch/x86/include/asm/init.h
+++ b/arch/x86/include/asm/init.h
@@ -7,6 +7,7 @@ struct x86_mapping_info {
 	unsigned long page_flag;	 /* page flag for PMD or PUD entry */
 	unsigned long offset;		 /* ident mapping offset */
 	bool direct_gbpages;		 /* PUD level 1GB page support */
+	unsigned long kernpg_flag;	 /* kernel pagetable flag override */
 };
 
 int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index 70ef205..e8183ac 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -207,6 +207,14 @@ struct kexec_entry64_regs {
 	uint64_t r15;
 	uint64_t rip;
 };
+
+extern int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages,
+				       gfp_t gfp);
+#define arch_kexec_post_alloc_pages arch_kexec_post_alloc_pages
+
+extern void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages);
+#define arch_kexec_pre_free_pages arch_kexec_pre_free_pages
+
 #endif
 
 typedef void crash_vmclear_fn(void);
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 32095af..830992f 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -213,6 +213,7 @@ enum page_cache_mode {
 #define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
 #define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
 #define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
+#define PAGE_KERNEL_EXEC_NOENC	__pgprot(__PAGE_KERNEL_EXEC)
 #define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
 #define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
 #define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
index cb0a304..9cf8daa 100644
--- a/arch/x86/kernel/machine_kexec_64.c
+++ b/arch/x86/kernel/machine_kexec_64.c
@@ -87,7 +87,7 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
 		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
 	}
 	pte = pte_offset_kernel(pmd, vaddr);
-	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
+	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC_NOENC));
 	return 0;
 err:
 	free_transition_pgtable(image);
@@ -115,6 +115,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
 		.alloc_pgt_page	= alloc_pgt_page,
 		.context	= image,
 		.page_flag	= __PAGE_KERNEL_LARGE_EXEC,
+		.kernpg_flag	= _KERNPG_TABLE_NOENC,
 	};
 	unsigned long mstart, mend;
 	pgd_t *level4p;
@@ -602,3 +603,22 @@ void arch_kexec_unprotect_crashkres(void)
 {
 	kexec_mark_crashkres(false);
 }
+
+int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp)
+{
+	/*
+	 * If SME is active we need to be sure that kexec pages are
+	 * not encrypted because when we boot to the new kernel the
+	 * pages won't be accessed encrypted (initially).
+	 */
+	return set_memory_decrypted((unsigned long)vaddr, pages);
+}
+
+void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages)
+{
+	/*
+	 * If SME is active we need to reset the pages back to being
+	 * an encrypted mapping before freeing them.
+	 */
+	set_memory_encrypted((unsigned long)vaddr, pages);
+}
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 3ca1980..bd6b85f 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -355,6 +355,7 @@ bool xen_set_default_idle(void)
 	return ret;
 }
 #endif
+
 void stop_this_cpu(void *dummy)
 {
 	local_irq_disable();
@@ -365,8 +366,20 @@ void stop_this_cpu(void *dummy)
 	disable_local_APIC();
 	mcheck_cpu_clear(this_cpu_ptr(&cpu_info));
 
-	for (;;)
-		halt();
+	for (;;) {
+		/*
+		 * Use wbinvd followed by hlt to stop the processor. This
+		 * provides support for kexec on a processor that supports
+		 * SME. With kexec, going from SME inactive to SME active
+		 * requires clearing cache entries so that addresses without
+		 * the encryption bit set don't corrupt the same physical
+		 * address that has the encryption bit set when caches are
+		 * flushed. To achieve this a wbinvd is performed followed by
+		 * a hlt. Even if the processor is not in the kexec/SME
+		 * scenario this only adds a wbinvd to a halting processor.
+		 */
+		asm volatile("wbinvd; hlt" : : : "memory");
+	}
 }
 
 /*
diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index adab159..31cea98 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -51,7 +51,7 @@ static int ident_pud_init(struct x86_mapping_info *info, pud_t *pud_page,
 		if (!pmd)
 			return -ENOMEM;
 		ident_pmd_init(info, pmd, addr, next);
-		set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE));
+		set_pud(pud, __pud(__pa(pmd) | info->kernpg_flag));
 	}
 
 	return 0;
@@ -79,7 +79,7 @@ static int ident_p4d_init(struct x86_mapping_info *info, p4d_t *p4d_page,
 		if (!pud)
 			return -ENOMEM;
 		ident_pud_init(info, pud, addr, next);
-		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
+		set_p4d(p4d, __p4d(__pa(pud) | info->kernpg_flag));
 	}
 
 	return 0;
@@ -93,6 +93,10 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 	unsigned long next;
 	int result;
 
+	/* Set the default pagetable flags if not supplied */
+	if (!info->kernpg_flag)
+		info->kernpg_flag = _KERNPG_TABLE;
+
 	for (; addr < end; addr = next) {
 		pgd_t *pgd = pgd_page + pgd_index(addr);
 		p4d_t *p4d;
@@ -116,14 +120,14 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 		if (result)
 			return result;
 		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-			set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
+			set_pgd(pgd, __pgd(__pa(p4d) | info->kernpg_flag));
 		} else {
 			/*
 			 * With p4d folded, pgd is equal to p4d.
 			 * The pgd entry has to point to the pud page table in this case.
 			 */
 			pud_t *pud = pud_offset(p4d, 0);
-			set_pgd(pgd, __pgd(__pa(pud) | _KERNPG_TABLE));
+			set_pgd(pgd, __pgd(__pa(pud) | info->kernpg_flag));
 		}
 	}
 
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index dd056fa..2b7590f 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -327,6 +327,14 @@ static inline void *boot_phys_to_virt(unsigned long entry)
 	return phys_to_virt(boot_phys_to_phys(entry));
 }
 
+#ifndef arch_kexec_post_alloc_pages
+static inline int arch_kexec_post_alloc_pages(void *vaddr, unsigned int pages, gfp_t gfp) { return 0; }
+#endif
+
+#ifndef arch_kexec_pre_free_pages
+static inline void arch_kexec_pre_free_pages(void *vaddr, unsigned int pages) { }
+#endif
+
 #else /* !CONFIG_KEXEC_CORE */
 struct pt_regs;
 struct task_struct;
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 1ae7c41..20fef1a 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -301,7 +301,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page *pages;
 
-	pages = alloc_pages(gfp_mask, order);
+	pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
 	if (pages) {
 		unsigned int count, i;
 
@@ -310,6 +310,13 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
 		count = 1 << order;
 		for (i = 0; i < count; i++)
 			SetPageReserved(pages + i);
+
+		arch_kexec_post_alloc_pages(page_address(pages), count,
+					    gfp_mask);
+
+		if (gfp_mask & __GFP_ZERO)
+			for (i = 0; i < count; i++)
+				clear_highpage(pages + i);
 	}
 
 	return pages;
@@ -321,6 +328,9 @@ static void kimage_free_pages(struct page *page)
 
 	order = page_private(page);
 	count = 1 << order;
+
+	arch_kexec_pre_free_pages(page_address(page), count);
+
 	for (i = 0; i < count; i++)
 		ClearPageReserved(page + i);
 	__free_pages(page, order);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
