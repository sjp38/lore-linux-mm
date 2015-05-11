Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A02D36B0071
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:52:55 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so31484989wic.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:52:55 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id j4si434575wix.18.2015.05.11.08.52.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:49 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:48 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8BA2C17D8069
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:33 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqkfp1507766
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:46 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqijY014726
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:45 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 04/15] mm: explicitly disable/enable preemption in kmap_atomic_*
Date: Mon, 11 May 2015 17:52:09 +0200
Message-Id: <1431359540-32227-5-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

The existing code relies on pagefault_disable() implicitly disabling
preemption, so that no schedule will happen between kmap_atomic() and
kunmap_atomic().

Let's make this explicit, to prepare for pagefault_disable() not
touching preemption anymore.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/arm/mm/highmem.c                | 3 +++
 arch/frv/mm/highmem.c                | 2 ++
 arch/metag/mm/highmem.c              | 4 +++-
 arch/microblaze/mm/highmem.c         | 4 +++-
 arch/mips/mm/highmem.c               | 5 ++++-
 arch/mn10300/include/asm/highmem.h   | 3 +++
 arch/parisc/include/asm/cacheflush.h | 2 ++
 arch/powerpc/mm/highmem.c            | 4 +++-
 arch/sparc/mm/highmem.c              | 4 +++-
 arch/tile/mm/highmem.c               | 3 ++-
 arch/x86/mm/highmem_32.c             | 3 ++-
 arch/x86/mm/iomap_32.c               | 2 ++
 arch/xtensa/mm/highmem.c             | 2 ++
 include/linux/highmem.h              | 2 ++
 include/linux/io-mapping.h           | 2 ++
 15 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/arch/arm/mm/highmem.c b/arch/arm/mm/highmem.c
index b98895d..ee8dfa7 100644
--- a/arch/arm/mm/highmem.c
+++ b/arch/arm/mm/highmem.c
@@ -59,6 +59,7 @@ void *kmap_atomic(struct page *page)
 	void *kmap;
 	int type;
 
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -121,6 +122,7 @@ void __kunmap_atomic(void *kvaddr)
 		kunmap_high(pte_page(pkmap_page_table[PKMAP_NR(vaddr)]));
 	}
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
@@ -130,6 +132,7 @@ void *kmap_atomic_pfn(unsigned long pfn)
 	int idx, type;
 	struct page *page = pfn_to_page(pfn);
 
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
diff --git a/arch/frv/mm/highmem.c b/arch/frv/mm/highmem.c
index bed9a9b..785344b 100644
--- a/arch/frv/mm/highmem.c
+++ b/arch/frv/mm/highmem.c
@@ -42,6 +42,7 @@ void *kmap_atomic(struct page *page)
 	unsigned long paddr;
 	int type;
 
+	preempt_disable();
 	pagefault_disable();
 	type = kmap_atomic_idx_push();
 	paddr = page_to_phys(page);
@@ -85,5 +86,6 @@ void __kunmap_atomic(void *kvaddr)
 	}
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/metag/mm/highmem.c b/arch/metag/mm/highmem.c
index d71f621..807f1b1 100644
--- a/arch/metag/mm/highmem.c
+++ b/arch/metag/mm/highmem.c
@@ -43,7 +43,7 @@ void *kmap_atomic(struct page *page)
 	unsigned long vaddr;
 	int type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -82,6 +82,7 @@ void __kunmap_atomic(void *kvaddr)
 	}
 
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
@@ -95,6 +96,7 @@ void *kmap_atomic_pfn(unsigned long pfn)
 	unsigned long vaddr;
 	int type;
 
+	preempt_disable();
 	pagefault_disable();
 
 	type = kmap_atomic_idx_push();
diff --git a/arch/microblaze/mm/highmem.c b/arch/microblaze/mm/highmem.c
index 5a92576..2fcc5a5 100644
--- a/arch/microblaze/mm/highmem.c
+++ b/arch/microblaze/mm/highmem.c
@@ -37,7 +37,7 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 	unsigned long vaddr;
 	int idx, type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -63,6 +63,7 @@ void __kunmap_atomic(void *kvaddr)
 
 	if (vaddr < __fix_to_virt(FIX_KMAP_END)) {
 		pagefault_enable();
+		preempt_enable();
 		return;
 	}
 
@@ -84,5 +85,6 @@ void __kunmap_atomic(void *kvaddr)
 #endif
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index da815d2..11661cb 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -47,7 +47,7 @@ void *kmap_atomic(struct page *page)
 	unsigned long vaddr;
 	int idx, type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -72,6 +72,7 @@ void __kunmap_atomic(void *kvaddr)
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
+		preempt_enable();
 		return;
 	}
 
@@ -92,6 +93,7 @@ void __kunmap_atomic(void *kvaddr)
 #endif
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
@@ -104,6 +106,7 @@ void *kmap_atomic_pfn(unsigned long pfn)
 	unsigned long vaddr;
 	int idx, type;
 
+	preempt_disable();
 	pagefault_disable();
 
 	type = kmap_atomic_idx_push();
diff --git a/arch/mn10300/include/asm/highmem.h b/arch/mn10300/include/asm/highmem.h
index 2fbbe4d..1ddea5a 100644
--- a/arch/mn10300/include/asm/highmem.h
+++ b/arch/mn10300/include/asm/highmem.h
@@ -75,6 +75,7 @@ static inline void *kmap_atomic(struct page *page)
 	unsigned long vaddr;
 	int idx, type;
 
+	preempt_disable();
 	pagefault_disable();
 	if (page < highmem_start_page)
 		return page_address(page);
@@ -98,6 +99,7 @@ static inline void __kunmap_atomic(unsigned long vaddr)
 
 	if (vaddr < FIXADDR_START) { /* FIXME */
 		pagefault_enable();
+		preempt_enable();
 		return;
 	}
 
@@ -122,6 +124,7 @@ static inline void __kunmap_atomic(unsigned long vaddr)
 
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 #endif /* __KERNEL__ */
 
diff --git a/arch/parisc/include/asm/cacheflush.h b/arch/parisc/include/asm/cacheflush.h
index de65f66..ec2df4b 100644
--- a/arch/parisc/include/asm/cacheflush.h
+++ b/arch/parisc/include/asm/cacheflush.h
@@ -142,6 +142,7 @@ static inline void kunmap(struct page *page)
 
 static inline void *kmap_atomic(struct page *page)
 {
+	preempt_disable();
 	pagefault_disable();
 	return page_address(page);
 }
@@ -150,6 +151,7 @@ static inline void __kunmap_atomic(void *addr)
 {
 	flush_kernel_dcache_page_addr(addr);
 	pagefault_enable();
+	preempt_enable();
 }
 
 #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
diff --git a/arch/powerpc/mm/highmem.c b/arch/powerpc/mm/highmem.c
index e7450bd..e292c8a 100644
--- a/arch/powerpc/mm/highmem.c
+++ b/arch/powerpc/mm/highmem.c
@@ -34,7 +34,7 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 	unsigned long vaddr;
 	int idx, type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -59,6 +59,7 @@ void __kunmap_atomic(void *kvaddr)
 
 	if (vaddr < __fix_to_virt(FIX_KMAP_END)) {
 		pagefault_enable();
+		preempt_enable();
 		return;
 	}
 
@@ -82,5 +83,6 @@ void __kunmap_atomic(void *kvaddr)
 
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/sparc/mm/highmem.c b/arch/sparc/mm/highmem.c
index 449f864..a454ec5 100644
--- a/arch/sparc/mm/highmem.c
+++ b/arch/sparc/mm/highmem.c
@@ -53,7 +53,7 @@ void *kmap_atomic(struct page *page)
 	unsigned long vaddr;
 	long idx, type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -91,6 +91,7 @@ void __kunmap_atomic(void *kvaddr)
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
+		preempt_enable();
 		return;
 	}
 
@@ -126,5 +127,6 @@ void __kunmap_atomic(void *kvaddr)
 
 	kmap_atomic_idx_pop();
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/tile/mm/highmem.c b/arch/tile/mm/highmem.c
index 6aa2f26..fcd5450 100644
--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -201,7 +201,7 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 	int idx, type;
 	pte_t *pte;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 
 	/* Avoid icache flushes by disallowing atomic executable mappings. */
@@ -259,6 +259,7 @@ void __kunmap_atomic(void *kvaddr)
 	}
 
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 4500142..eecb207a 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -35,7 +35,7 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 	unsigned long vaddr;
 	int idx, type;
 
-	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
+	preempt_disable();
 	pagefault_disable();
 
 	if (!PageHighMem(page))
@@ -100,6 +100,7 @@ void __kunmap_atomic(void *kvaddr)
 #endif
 
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 9ca35fc..2b7ece0 100644
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -59,6 +59,7 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 	unsigned long vaddr;
 	int idx, type;
 
+	preempt_disable();
 	pagefault_disable();
 
 	type = kmap_atomic_idx_push();
@@ -117,5 +118,6 @@ iounmap_atomic(void __iomem *kvaddr)
 	}
 
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL_GPL(iounmap_atomic);
diff --git a/arch/xtensa/mm/highmem.c b/arch/xtensa/mm/highmem.c
index 8cfb71e..184cead 100644
--- a/arch/xtensa/mm/highmem.c
+++ b/arch/xtensa/mm/highmem.c
@@ -42,6 +42,7 @@ void *kmap_atomic(struct page *page)
 	enum fixed_addresses idx;
 	unsigned long vaddr;
 
+	preempt_disable();
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
@@ -79,6 +80,7 @@ void __kunmap_atomic(void *kvaddr)
 	}
 
 	pagefault_enable();
+	preempt_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 9286a46..6aefcd0 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -65,6 +65,7 @@ static inline void kunmap(struct page *page)
 
 static inline void *kmap_atomic(struct page *page)
 {
+	preempt_disable();
 	pagefault_disable();
 	return page_address(page);
 }
@@ -73,6 +74,7 @@ static inline void *kmap_atomic(struct page *page)
 static inline void __kunmap_atomic(void *addr)
 {
 	pagefault_enable();
+	preempt_enable();
 }
 
 #define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index 657fab4..c27dde7 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -141,6 +141,7 @@ static inline void __iomem *
 io_mapping_map_atomic_wc(struct io_mapping *mapping,
 			 unsigned long offset)
 {
+	preempt_disable();
 	pagefault_disable();
 	return ((char __force __iomem *) mapping) + offset;
 }
@@ -149,6 +150,7 @@ static inline void
 io_mapping_unmap_atomic(void __iomem *vaddr)
 {
 	pagefault_enable();
+	preempt_enable();
 }
 
 /* Non-atomic map/unmap */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
