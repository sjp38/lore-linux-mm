Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B67BA6B000D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:28 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q19-v6so14056133plr.22
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:28 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/17] x86/mm: Implement prep_encrypted_page() and arch_free_page()
Date: Tue, 12 Jun 2018 17:39:08 +0300
Message-Id: <20180612143915.68065-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
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
 arch/x86/include/asm/mktme.h |  6 ++++++
 arch/x86/mm/mktme.c          | 39 ++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 0fe0db424e48..ec7036abdb3f 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -11,6 +11,12 @@ extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
 
+#define prep_encrypted_page prep_encrypted_page
+void prep_encrypted_page(struct page *page, int order, int keyid, bool zero);
+
+#define HAVE_ARCH_FREE_PAGE
+void arch_free_page(struct page *page, int order);
+
 #define vma_is_encrypted vma_is_encrypted
 bool vma_is_encrypted(struct vm_area_struct *vma);
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index b02d5b9d4339..1821b87abb2f 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <asm/mktme.h>
 
 phys_addr_t mktme_keyid_mask;
@@ -30,6 +31,44 @@ int vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
 
+void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
+{
+	int i;
+
+	/*
+	 * The hardware/CPU does not enforce coherency between mappings of the
+	 * same physical page with different KeyIDs or encrypt ion keys.
+	 * We are responsible for cache management.
+	 *
+	 * We flush cache before allocating encrypted page
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE << order);
+
+	for (i = 0; i < (1 << order); i++) {
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
+		lookup_page_ext(page)->keyid = keyid;
+
+		/* Clear the page after the KeyID is set. */
+		if (zero)
+			clear_highpage(page);
+	}
+}
+
+void arch_free_page(struct page *page, int order)
+{
+	int i;
+
+	if (!page_keyid(page))
+		return;
+
+	for (i = 0; i < (1 << order); i++) {
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
+		lookup_page_ext(page)->keyid = 0;
+	}
+
+	clflush_cache_range(page_address(page), PAGE_SIZE << order);
+}
+
 static bool need_page_mktme(void)
 {
 	/* Make sure keyid doesn't collide with extended page flags */
-- 
2.17.1
