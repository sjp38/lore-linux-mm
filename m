Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B26C8E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:11:03 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so7071106pgi.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:11:03 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n187si6618677pfn.83.2019.01.10.13.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:11:02 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 14/16] EXPERIMENTAL: xpfo, mm: optimize spin lock usage in xpfo_kmap
Date: Thu, 10 Jan 2019 14:09:46 -0700
Message-Id: <7e8e17f519ae87a91fc6cbb57b8b27094c96305c.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>, Marco Benatto <marco.antonio.780@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Khalid Aziz <khalid.aziz@oracle.com>

From: Julian Stecklina <jsteckli@amazon.de>

We can reduce spin lock usage in xpfo_kmap to the 0->1 transition of
the mapcount. This means that xpfo_kmap() can now race and that we
get spurious page faults.

The page fault handler helps the system make forward progress by
fixing the page table instead of allowing repeated page faults until
the right xpfo_kmap went through.

Model-checked with up to 4 concurrent callers with Spin.

Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Cc: x86@kernel.org
Cc: kernel-hardening@lists.openwall.com
Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
Cc: Tycho Andersen <tycho@docker.com>
Cc: Marco Benatto <marco.antonio.780@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/x86/mm/fault.c  |  4 ++++
 include/linux/xpfo.h |  4 ++++
 mm/xpfo.c            | 50 +++++++++++++++++++++++++++++++++++++-------
 3 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index ba51652fbd33..207081dcd572 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -18,6 +18,7 @@
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
 #include <linux/efi.h>			/* efi_recover_from_page_fault()*/
 #include <linux/mm_types.h>
+#include <linux/xpfo.h>
 
 #include <asm/cpufeature.h>		/* boot_cpu_has, ...		*/
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
@@ -1218,6 +1219,9 @@ do_kern_addr_fault(struct pt_regs *regs, unsigned long hw_error_code,
 	if (kprobes_fault(regs))
 		return;
 
+	if (xpfo_spurious_fault(address))
+		return;
+
 	/*
 	 * Note, despite being a "bad area", there are quite a few
 	 * acceptable reasons to get here, such as erratum fixups
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index ea5188882f49..58dd243637d2 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -54,6 +54,8 @@ bool xpfo_enabled(void);
 
 phys_addr_t user_virt_to_phys(unsigned long addr);
 
+bool xpfo_spurious_fault(unsigned long addr);
+
 #else /* !CONFIG_XPFO */
 
 static inline void xpfo_init_single_page(struct page *page) { }
@@ -81,6 +83,8 @@ static inline bool xpfo_enabled(void) { return false; }
 
 static inline phys_addr_t user_virt_to_phys(unsigned long addr) { return 0; }
 
+static inline bool xpfo_spurious_fault(unsigned long addr) { return false; }
+
 #endif /* CONFIG_XPFO */
 
 #endif /* _LINUX_XPFO_H */
diff --git a/mm/xpfo.c b/mm/xpfo.c
index dbf20efb0499..85079377c91d 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -119,6 +119,16 @@ void xpfo_free_pages(struct page *page, int order)
 	}
 }
 
+static void xpfo_do_map(void *kaddr, struct page *page)
+{
+	spin_lock(&page->xpfo_lock);
+	if (PageXpfoUnmapped(page)) {
+		set_kpte(kaddr, page, PAGE_KERNEL);
+		ClearPageXpfoUnmapped(page);
+	}
+	spin_unlock(&page->xpfo_lock);
+}
+
 void xpfo_kmap(void *kaddr, struct page *page)
 {
 	if (!static_branch_unlikely(&xpfo_inited))
@@ -127,17 +137,12 @@ void xpfo_kmap(void *kaddr, struct page *page)
 	if (!PageXpfoUser(page))
 		return;
 
-	spin_lock(&page->xpfo_lock);
-
 	/*
 	 * The page was previously allocated to user space, so map it back
 	 * into the kernel. No TLB flush required.
 	 */
-	if ((atomic_inc_return(&page->xpfo_mapcount) == 1) &&
-	    TestClearPageXpfoUnmapped(page))
-		set_kpte(kaddr, page, PAGE_KERNEL);
-
-	spin_unlock(&page->xpfo_lock);
+	if (atomic_inc_return(&page->xpfo_mapcount) == 1)
+		xpfo_do_map(kaddr, page);
 }
 EXPORT_SYMBOL(xpfo_kmap);
 
@@ -204,3 +209,34 @@ void xpfo_temp_unmap(const void *addr, size_t size, void **mapping,
 			kunmap_atomic(mapping[i]);
 }
 EXPORT_SYMBOL(xpfo_temp_unmap);
+
+bool xpfo_spurious_fault(unsigned long addr)
+{
+	struct page *page;
+	bool spurious;
+	int mapcount;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return false;
+
+	/* XXX Is this sufficient to guard against calling virt_to_page() on a
+	 * virtual address that has no corresponding struct page? */
+	if (!virt_addr_valid(addr))
+		return false;
+
+	page = virt_to_page(addr);
+	mapcount = atomic_read(&page->xpfo_mapcount);
+	spurious = PageXpfoUser(page) && mapcount;
+
+	/* Guarantee forward progress in case xpfo_kmap() raced. */
+	if (spurious && PageXpfoUnmapped(page)) {
+		xpfo_do_map((void *)(addr & PAGE_MASK), page);
+	}
+
+	if (unlikely(!spurious))
+		printk("XPFO non-spurious fault %lx user=%d unmapped=%d mapcount=%d\n",
+			addr, PageXpfoUser(page), PageXpfoUnmapped(page),
+			mapcount);
+
+	return spurious;
+}
-- 
2.17.1
