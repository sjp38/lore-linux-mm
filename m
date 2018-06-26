Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBF806B0280
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:23:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so10135749plp.21
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:23:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y16-v6si1608398pfl.11.2018.06.26.07.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 11/18] x86/mm: Implement prep_encrypted_page() and arch_free_page()
Date: Tue, 26 Jun 2018 17:22:38 +0300
Message-Id: <20180626142245.82850-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The hardware/CPU does not enforce coherency between mappings of the same
physical page with different KeyIDs or encryption keys.
We are responsible for cache management.

Flush cache on allocating encrypted page and on returning the page to
the free pool.

prep_encrypted_page() also takes care about zeroing the page. We have to
do this after KeyID is set for the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  6 +++++
 arch/x86/mm/mktme.c          | 49 ++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index f0b7844e36a4..44409b8bbaca 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -19,6 +19,12 @@ int page_keyid(const struct page *page);
 #define vma_keyid vma_keyid
 int vma_keyid(struct vm_area_struct *vma);
 
+#define prep_encrypted_page prep_encrypted_page
+void prep_encrypted_page(struct page *page, int order, int keyid, bool zero);
+
+#define HAVE_ARCH_FREE_PAGE
+void arch_free_page(struct page *page, int order);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index a1f40ee61b25..1194496633ce 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <asm/mktme.h>
 
 phys_addr_t mktme_keyid_mask;
@@ -49,3 +50,51 @@ int vma_keyid(struct vm_area_struct *vma)
 	prot = pgprot_val(vma->vm_page_prot);
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
+
+void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
+{
+	int i;
+
+	/* It's not encrypted page: nothing to do */
+	if (!keyid)
+		return;
+
+	/*
+	 * The hardware/CPU does not enforce coherency between mappings of the
+	 * same physical page with different KeyIDs or encryption keys.
+	 * We are responsible for cache management.
+	 *
+	 * We flush cache before allocating encrypted page
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE << order);
+
+	for (i = 0; i < (1 << order); i++) {
+		/* All pages coming out of the allocator should have KeyID 0 */
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
+		lookup_page_ext(page)->keyid = keyid;
+
+		/* Clear the page after the KeyID is set. */
+		if (zero)
+			clear_highpage(page);
+
+		page++;
+	}
+}
+
+void arch_free_page(struct page *page, int order)
+{
+	int i;
+
+	/* It's not encrypted page: nothing to do */
+	if (!page_keyid(page))
+		return;
+
+	clflush_cache_range(page_address(page), PAGE_SIZE << order);
+
+	for (i = 0; i < (1 << order); i++) {
+		/* Check if the page has reasonable KeyID */
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
+		lookup_page_ext(page)->keyid = 0;
+		page++;
+	}
+}
-- 
2.18.0
