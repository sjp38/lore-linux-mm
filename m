Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2FD6B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 14:16:32 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id td3so47121727pab.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:16:32 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id lq6si7799634pab.140.2016.03.10.11.16.31
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 11:16:31 -0800 (PST)
Subject: [PATCH] x86, pmem: use memcpy_mcsafe() for memcpy_from_pmem()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Mar 2016 11:15:53 -0800
Message-ID: <20160310191507.29771.46591.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Ingo Molnar <mingo@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

Update the definition of memcpy_from_pmem() to return 0 or -EIO on
error.  Implement x86::arch_memcpy_from_pmem() with memcpy_mcsafe().

Cc: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Andrew, now that all the pre-requisites for this patch are in -next
(tip/core/ras, tip/x86/asm, nvdimm/libnvdimm-for-next) may I ask you to
carry it in -mm?

Alternatively I can do an octopus merge and post a branch, but that
seems messy/risky for me to be merging 3 branches that are still subject
to a merge window disposition.

 arch/x86/include/asm/pmem.h |    9 +++++++++
 drivers/nvdimm/pmem.c       |    4 ++--
 include/linux/pmem.h        |   14 ++++++++------
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
index bf8b35d2035a..4df3820535c6 100644
--- a/arch/x86/include/asm/pmem.h
+++ b/arch/x86/include/asm/pmem.h
@@ -47,6 +47,15 @@ static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src,
 		BUG();
 }
 
+static inline int arch_memcpy_from_pmem(void *dst, const void __pmem *src,
+		size_t n)
+{
+	if (static_cpu_has(X86_FEATURE_MCE_RECOVERY))
+		return memcpy_mcsafe(dst, (void __force *) src, n) ? 0 : -EIO;
+	memcpy(dst, (void __force *) src, n);
+	return 0;
+}
+
 /**
  * arch_wmb_pmem - synchronize writes to persistent memory
  *
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index adc387236fe7..2022d08c60ce 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -98,7 +98,7 @@ static int pmem_do_bvec(struct pmem_device *pmem, struct page *page,
 		if (unlikely(bad_pmem))
 			rc = -EIO;
 		else {
-			memcpy_from_pmem(mem + off, pmem_addr, len);
+			rc = memcpy_from_pmem(mem + off, pmem_addr, len);
 			flush_dcache_page(page);
 		}
 	} else {
@@ -295,7 +295,7 @@ static int pmem_rw_bytes(struct nd_namespace_common *ndns,
 
 		if (unlikely(is_bad_pmem(&pmem->bb, offset / 512, sz_align)))
 			return -EIO;
-		memcpy_from_pmem(buf, pmem->virt_addr + offset, size);
+		return memcpy_from_pmem(buf, pmem->virt_addr + offset, size);
 	} else {
 		memcpy_to_pmem(pmem->virt_addr + offset, buf, size);
 		wmb_pmem();
diff --git a/include/linux/pmem.h b/include/linux/pmem.h
index 3ec5309e29f3..c46c5cf6538e 100644
--- a/include/linux/pmem.h
+++ b/include/linux/pmem.h
@@ -66,14 +66,16 @@ static inline void arch_invalidate_pmem(void __pmem *addr, size_t size)
 #endif
 
 /*
- * Architectures that define ARCH_HAS_PMEM_API must provide
- * implementations for arch_memcpy_to_pmem(), arch_wmb_pmem(),
- * arch_copy_from_iter_pmem(), arch_clear_pmem(), arch_wb_cache_pmem()
- * and arch_has_wmb_pmem().
+ * memcpy_from_pmem - read from persistent memory with error handling
+ * @dst: destination buffer
+ * @src: source buffer
+ *
+ * Returns 0 on success -EIO on failure.
  */
-static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t size)
+static inline int memcpy_from_pmem(void *dst, void __pmem const *src,
+		size_t size)
 {
-	memcpy(dst, (void __force const *) src, size);
+	return arch_memcpy_from_pmem(dst, src, size);
 }
 
 static inline bool arch_has_pmem_api(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
