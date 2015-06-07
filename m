Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC816B0072
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:40:40 -0400 (EDT)
Received: by padev16 with SMTP id ev16so22887911pad.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:40:39 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id z1si347366pda.165.2015.06.07.10.40.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:40:39 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:40:03 -0700
From: tip-bot for Borislav Petkov <tipbot@zytor.com>
Message-ID: <tip-7202fdb1b3299ec78dc1e7702260947ec20dd9e9@git.kernel.org>
Reply-To: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org,
        peterz@infradead.org, bp@suse.de, mcgrof@suse.com, linux-mm@kvack.org,
        torvalds@linux-foundation.org, toshi.kani@hp.com, hpa@zytor.com,
        linux-kernel@vger.kernel.org, luto@amacapital.net
In-Reply-To: <1433436928-31903-4-git-send-email-bp@alien8.de>
References: <1433436928-31903-4-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Remove pat_enabled() checks
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, bp@suse.de, peterz@infradead.org, mcgrof@suse.com, linux-mm@kvack.org, torvalds@linux-foundation.org, toshi.kani@hp.com, hpa@zytor.com, linux-kernel@vger.kernel.org, luto@amacapital.net

Commit-ID:  7202fdb1b3299ec78dc1e7702260947ec20dd9e9
Gitweb:     http://git.kernel.org/tip/7202fdb1b3299ec78dc1e7702260947ec20dd9e9
Author:     Borislav Petkov <bp@suse.de>
AuthorDate: Thu, 4 Jun 2015 18:55:11 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:53 +0200

x86/mm/pat: Remove pat_enabled() checks

Now that we emulate a PAT table when PAT is disabled, there's no
need for those checks anymore as the PAT abstraction will handle
those cases too.

Based on a conglomerate patch from Toshi Kani.

Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-4-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/iomap_32.c | 12 ++++++------
 arch/x86/mm/ioremap.c  |  5 +----
 arch/x86/mm/pageattr.c |  3 ---
 arch/x86/mm/pat.c      | 13 +++----------
 4 files changed, 10 insertions(+), 23 deletions(-)

diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 3a2ec87..a9dc7a3 100644
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -77,13 +77,13 @@ void __iomem *
 iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	/*
-	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
-	 * PAGE_KERNEL_WC maps to PWT, which translates to uncached if the
-	 * MTRR is UC or WC.  UC_MINUS gets the real intention, of the
-	 * user, which is "WC if the MTRR is WC, UC if you can't do that."
+	 * For non-PAT systems, translate non-WB request to UC- just in
+	 * case the caller set the PWT bit to prot directly without using
+	 * pgprot_writecombine(). UC- translates to uncached if the MTRR
+	 * is UC or WC. UC- gets the real intention, of the user, which is
+	 * "WC if the MTRR is WC, UC if you can't do that."
 	 */
-	if (!pat_enabled() && pgprot_val(prot) ==
-	    (__PAGE_KERNEL | cachemode2protval(_PAGE_CACHE_MODE_WC)))
+	if (!pat_enabled() && pgprot2cachemode(prot) != _PAGE_CACHE_MODE_WB)
 		prot = __pgprot(__PAGE_KERNEL |
 				cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS));
 
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index b0da358..cc0f17c 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -292,11 +292,8 @@ EXPORT_SYMBOL_GPL(ioremap_uc);
  */
 void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
 {
-	if (pat_enabled())
-		return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WC,
+	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WC,
 					__builtin_return_address(0));
-	else
-		return ioremap_nocache(phys_addr, size);
 }
 EXPORT_SYMBOL(ioremap_wc);
 
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index fae3c53..31b4f3f 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1572,9 +1572,6 @@ int set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
 
-	if (!pat_enabled())
-		return set_memory_uc(addr, numpages);
-
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 6dc7826..f89e460 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -438,12 +438,8 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 
 	if (!pat_enabled()) {
 		/* This is identical to page table setting without PAT */
-		if (new_type) {
-			if (req_type == _PAGE_CACHE_MODE_WC)
-				*new_type = _PAGE_CACHE_MODE_UC_MINUS;
-			else
-				*new_type = req_type;
-		}
+		if (new_type)
+			*new_type = req_type;
 		return 0;
 	}
 
@@ -947,11 +943,8 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 
 pgprot_t pgprot_writecombine(pgprot_t prot)
 {
-	if (pat_enabled())
-		return __pgprot(pgprot_val(prot) |
+	return __pgprot(pgprot_val(prot) |
 				cachemode2protval(_PAGE_CACHE_MODE_WC));
-	else
-		return pgprot_noncached(prot);
 }
 EXPORT_SYMBOL_GPL(pgprot_writecombine);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
