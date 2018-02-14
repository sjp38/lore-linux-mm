Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBAC56B0010
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e12so2175542pgu.11
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:54 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k131si980928pgc.101.2018.02.14.10.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:53 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/9] x86/mm: Initialize vmemmap_base at boot-time
Date: Wed, 14 Feb 2018 21:25:38 +0300
Message-Id: <20180214182542.69302-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

vmemmap area has different placement depending on paging mode.
Let's adjust it during early boot accodring to machine capability.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64_types.h | 9 +++------
 arch/x86/kernel/head64.c                | 3 ++-
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 686329994ade..68909a68e5b9 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -108,11 +108,8 @@ extern unsigned int ptrs_per_p4d;
 #define VMALLOC_SIZE_TB_L4	32UL
 #define VMALLOC_SIZE_TB_L5	12800UL
 
-#ifdef CONFIG_X86_5LEVEL
-# define __VMEMMAP_BASE		_AC(0xffd4000000000000, UL)
-#else
-# define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
-#endif
+#define __VMEMMAP_BASE_L4	0xffffea0000000000
+#define __VMEMMAP_BASE_L5	0xffd4000000000000
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 # define VMALLOC_START		vmalloc_base
@@ -121,7 +118,7 @@ extern unsigned int ptrs_per_p4d;
 #else
 # define VMALLOC_START		__VMALLOC_BASE_L4
 # define VMALLOC_SIZE_TB	VMALLOC_SIZE_TB_L4
-# define VMEMMAP_START		__VMEMMAP_BASE
+# define VMEMMAP_START		__VMEMMAP_BASE_L4
 #endif /* CONFIG_DYNAMIC_MEMORY_LAYOUT */
 
 #define VMALLOC_END		(VMALLOC_START + (VMALLOC_SIZE_TB << 40) - 1)
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 22bf2015254c..795e762f3c66 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -53,7 +53,7 @@ unsigned long page_offset_base __ro_after_init = __PAGE_OFFSET_BASE_L4;
 EXPORT_SYMBOL(page_offset_base);
 unsigned long vmalloc_base __ro_after_init = __VMALLOC_BASE_L4;
 EXPORT_SYMBOL(vmalloc_base);
-unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE;
+unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE_L4;
 EXPORT_SYMBOL(vmemmap_base);
 #endif
 
@@ -88,6 +88,7 @@ static void __head check_la57_support(unsigned long physaddr)
 	*fixup_int(&ptrs_per_p4d, physaddr) = 512;
 	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE_L5;
 	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE_L5;
+	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE_L5;
 }
 #else
 static void __head check_la57_support(unsigned long physaddr) {}
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
