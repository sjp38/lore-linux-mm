Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71FEC6B0069
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:11 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so505808166pgf.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s5si15694846pgj.385.2017.02.01.15.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:10 -0800 (PST)
Subject: [RFC][PATCH 1/7] x86, mpx: introduce per-mm MPX table size tracking
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:09 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232409.B089D5ED@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


Larger address spaces mean larger MPX bounds table sizes.  This
tracks which size tables we are using.

"MAWA" is what the hardware documentation calls this feature: MPX
Address-Width Adjust.

---

 b/arch/x86/include/asm/mmu.h |    1 +
 b/arch/x86/include/asm/mpx.h |    6 ++++++
 2 files changed, 7 insertions(+)

diff -puN arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa	2017-02-01 15:12:15.699124140 -0800
+++ b/arch/x86/include/asm/mmu.h	2017-02-01 15:12:15.702124275 -0800
@@ -34,6 +34,7 @@ typedef struct {
 #ifdef CONFIG_X86_INTEL_MPX
 	/* address of the bounds directory */
 	void __user *bd_addr;
+	int mpx_bd_shift;
 #endif
 } mm_context_t;
 
diff -puN arch/x86/include/asm/mpx.h~mawa-020-mmu_context-mawa arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-020-mmu_context-mawa	2017-02-01 15:12:15.700124185 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-02-01 15:12:15.702124275 -0800
@@ -68,6 +68,12 @@ static inline void mpx_mm_init(struct mm
 	 * directory, so point this at an invalid address.
 	 */
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
+	/*
+	 * All processes start out in "legacy" MPX mode with
+	 * the old bounds directory size.  This corresponds to
+	 * what the specs call MAWA=0.
+	 */
+	mm->context.mpx_bd_shift = 0;
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		      unsigned long start, unsigned long end);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
