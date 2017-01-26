Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06CFF6B0038
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:40:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so328226387pfb.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:40:07 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x1si2577624pfa.171.2017.01.26.14.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:40:07 -0800 (PST)
Subject: [RFC][PATCH 1/4] x86, mpx: introduce per-mm MPX table size tracking
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 26 Jan 2017 14:40:06 -0800
References: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
In-Reply-To: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Message-Id: <20170126224006.DED9C8D3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>


Larger address spaces mean larger MPX bounds table sizes.  This
tracks which size tables we are using.

"MAWA" is what the hardware documentation calls this feature:
MPX Address-Width Adjust.  We will carry that nomenclature throughout
this series.

The new field will be optimized and get packed into 'bd_addr' in a later
patch.  But, leave it separate for now to make the series simpler.

---

 b/arch/x86/include/asm/mmu.h |    1 +
 b/arch/x86/include/asm/mpx.h |    9 +++++++++
 2 files changed, 10 insertions(+)

diff -puN arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa arch/x86/include/asm/mmu.h
--- a/arch/x86/include/asm/mmu.h~mawa-020-mmu_context-mawa	2017-01-26 14:31:32.643673297 -0800
+++ b/arch/x86/include/asm/mmu.h	2017-01-26 14:31:32.647673476 -0800
@@ -34,6 +34,7 @@ typedef struct {
 #ifdef CONFIG_X86_INTEL_MPX
 	/* address of the bounds directory */
 	void __user *bd_addr;
+	int mpx_mawa;
 #endif
 } mm_context_t;
 
diff -puN arch/x86/include/asm/mpx.h~mawa-020-mmu_context-mawa arch/x86/include/asm/mpx.h
--- a/arch/x86/include/asm/mpx.h~mawa-020-mmu_context-mawa	2017-01-26 14:31:32.644673342 -0800
+++ b/arch/x86/include/asm/mpx.h	2017-01-26 14:31:32.648673521 -0800
@@ -68,6 +68,15 @@ static inline void mpx_mm_init(struct mm
 	 * directory, so point this at an invalid address.
 	 */
 	mm->context.bd_addr = MPX_INVALID_BOUNDS_DIR;
+	/*
+	 * All processes start out in "legacy" MPX mode with
+	 * MAWA=0.
+	 */
+	mm->context.mpx_mawa = 0;
+}
+static inline int mpx_mawa_shift(struct mm_struct *mm)
+{
+	return mm->context.mpx_mawa;
 }
 void mpx_notify_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		      unsigned long start, unsigned long end);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
