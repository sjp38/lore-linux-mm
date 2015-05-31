From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 4/4] x86/pat: Remove pat_enabled() checks
Date: Sun, 31 May 2015 11:48:06 +0200
Message-ID: <1433065686-20922-4-git-send-email-bp@alien8.de>
References: <20150531094655.GA20440@pd.tnic>
 <1433065686-20922-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433065686-20922-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com
List-Id: linux-mm.kvack.org

From: Borislav Petkov <bp@suse.de>

Now that we emulate a PAT table when PAT is disabled, there's no need
for those checks anymore as the PAT abstraction will handle those cases
too.

Based on a conglomerate patch from Toshi Kani.

Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: arnd@arndb.de
Cc: Elliott@hp.com
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: stefan.bader@canonical.com
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: x86-ml <x86@kernel.org>
Cc: yigal@plexistor.com
---
 arch/x86/mm/iomap_32.c | 12 ++++++------
 arch/x86/mm/ioremap.c  |  5 +----
 arch/x86/mm/pageattr.c |  3 ---
 arch/x86/mm/pat.c      | 13 +++----------
 4 files changed, 10 insertions(+), 23 deletions(-)

diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 3a2ec8790ca7..a9dc7a37e6a2 100644
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
index b0da3588b452..cc0f17c5ad9f 100644
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
index 70d221fe2eb4..94aae76a5e06 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1571,9 +1571,6 @@ int set_memory_wc(unsigned long addr, int numpages)
 {
 	int ret;
 
-	if (!pat_enabled())
-		return set_memory_uc(addr, numpages);
-
 	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
 		_PAGE_CACHE_MODE_WC, NULL);
 	if (ret)
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 62171cb2b0cb..e65555e0fe3d 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -432,12 +432,8 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 
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
 
@@ -941,11 +937,8 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 
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
2.3.5
