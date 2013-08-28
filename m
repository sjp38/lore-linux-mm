Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5B6D26B003B
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:38:28 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id lb1so5929683pab.40
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:38:27 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 05/13] powerpc: Prepare to support kernel handling of IOMMU map/unmap
Date: Wed, 28 Aug 2013 18:37:42 +1000
Message-Id: <1377679070-3515-6-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

The current VFIO-on-POWER implementation supports only user mode
driven mapping, i.e. QEMU is sending requests to map/unmap pages.
However this approach is really slow, so we want to move that to KVM.
Since H_PUT_TCE can be extremely performance sensitive (especially with
network adapters where each packet needs to be mapped/unmapped) we chose
to implement that as a "fast" hypercall directly in "real
mode" (processor still in the guest context but MMU off).

To be able to do that, we need to provide some facilities to
access the struct page count within that real mode environment as things
like the sparsemem vmemmap mappings aren't accessible.

This adds an API function realmode_pfn_to_page() to get page struct when
MMU is off.

This adds to MM a new function put_page_unless_one() which drops a page
if counter is bigger than 1. It is going to be used when MMU is off
(for example, real mode on PPC64) and we want to make sure that page
release will not happen in real mode as it may crash the kernel in
a horrible way.

CONFIG_SPARSEMEM_VMEMMAP and CONFIG_FLATMEM are supported.

Cc: linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

---

Changes:
2013/07/25 (v7):
* removed realmode_put_page and added put_page_unless_one() instead.
The name has been chosen to conform the already existing
get_page_unless_zero().
* removed realmode_get_page. Instead, get_page_unless_zero() should be used

2013/07/10:
* adjusted comment (removed sentence about virtual mode)
* get_page_unless_zero replaced with atomic_inc_not_zero to minimize
effect of a possible get_page_unless_zero() rework (if it ever happens).

2013/06/27:
* realmode_get_page() fixed to use get_page_unless_zero(). If failed,
the call will be passed from real to virtual mode and safely handled.
* added comment to PageCompound() in include/linux/page-flags.h.

2013/05/20:
* PageTail() is replaced by PageCompound() in order to have the same checks
for whether the page is huge in realmode_get_page() and realmode_put_page()
---
 arch/powerpc/include/asm/pgtable-ppc64.h |  2 ++
 arch/powerpc/mm/init_64.c                | 50 +++++++++++++++++++++++++++++++-
 include/linux/mm.h                       | 14 +++++++++
 include/linux/page-flags.h               |  4 ++-
 4 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 46db094..4a191c4 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -394,6 +394,8 @@ static inline void mark_hpte_slot_valid(unsigned char *hpte_slot_array,
 	hpte_slot_array[index] = hidx << 4 | 0x1 << 3;
 }
 
+struct page *realmode_pfn_to_page(unsigned long pfn);
+
 static inline char *get_hpte_slot_array(pmd_t *pmdp)
 {
 	/*
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index d0cd9e4..8cf345a 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -300,5 +300,53 @@ void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 
-#endif /* CONFIG_SPARSEMEM_VMEMMAP */
+/*
+ * We do not have access to the sparsemem vmemmap, so we fallback to
+ * walking the list of sparsemem blocks which we already maintain for
+ * the sake of crashdump. In the long run, we might want to maintain
+ * a tree if performance of that linear walk becomes a problem.
+ *
+ * realmode_pfn_to_page functions can fail due to:
+ * 1) As real sparsemem blocks do not lay in RAM continously (they
+ * are in virtual address space which is not available in the real mode),
+ * the requested page struct can be split between blocks so get_page/put_page
+ * may fail.
+ * 2) When huge pages are used, the get_page/put_page API will fail
+ * in real mode as the linked addresses in the page struct are virtual
+ * too.
+ */
+struct page *realmode_pfn_to_page(unsigned long pfn)
+{
+	struct vmemmap_backing *vmem_back;
+	struct page *page;
+	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
+	unsigned long pg_va = (unsigned long) pfn_to_page(pfn);
 
+	for (vmem_back = vmemmap_list; vmem_back; vmem_back = vmem_back->list) {
+		if (pg_va < vmem_back->virt_addr)
+			continue;
+
+		/* Check that page struct is not split between real pages */
+		if ((pg_va + sizeof(struct page)) >
+				(vmem_back->virt_addr + page_size))
+			return NULL;
+
+		page = (struct page *) (vmem_back->phys + pg_va -
+				vmem_back->virt_addr);
+		return page;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(realmode_pfn_to_page);
+
+#elif defined(CONFIG_FLATMEM)
+
+struct page *realmode_pfn_to_page(unsigned long pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+	return page;
+}
+EXPORT_SYMBOL_GPL(realmode_pfn_to_page);
+
+#endif /* CONFIG_SPARSEMEM_VMEMMAP/CONFIG_FLATMEM */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..dcc99b5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -290,12 +290,26 @@ static inline int put_page_testzero(struct page *page)
 /*
  * Try to grab a ref unless the page has a refcount of zero, return false if
  * that is the case.
+ * This can be called when MMU is off so it must not access
+ * any of the virtual mappings.
  */
 static inline int get_page_unless_zero(struct page *page)
 {
 	return atomic_inc_not_zero(&page->_count);
 }
 
+/*
+ * Try to drop a ref unless the page has a refcount of one, return false if
+ * that is the case.
+ * This is to make sure that the refcount won't become zero after this drop.
+ * This can be called when MMU is off so it must not access
+ * any of the virtual mappings.
+ */
+static inline int put_page_unless_one(struct page *page)
+{
+	return atomic_add_unless(&page->_count, -1, 1);
+}
+
 extern int page_is_ram(unsigned long pfn);
 
 /* Support for virtually mapped pages */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..98ada58 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -329,7 +329,9 @@ static inline void set_page_writeback(struct page *page)
  * System with lots of page flags available. This allows separate
  * flags for PageHead() and PageTail() checks of compound pages so that bit
  * tests can be used in performance sensitive paths. PageCompound is
- * generally not used in hot code paths.
+ * generally not used in hot code paths except arch/powerpc/mm/init_64.c
+ * and arch/powerpc/kvm/book3s_64_vio_hv.c which use it to detect huge pages
+ * and avoid handling those in real mode.
  */
 __PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
 __PAGEFLAG(Tail, tail)
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
