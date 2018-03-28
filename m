Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 656746B0253
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so2092934plo.21
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y15si2730920pgr.167.2018.03.28.09.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:51 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 13/14] x86/mm: Implement prep_encrypted_page()
Date: Wed, 28 Mar 2018 19:55:39 +0300
Message-Id: <20180328165540.648-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The hardware/CPU does not enforce coherency between mappings of the same
physical page with different KeyIDs or encrypt ion keys.
We are responsible for cache management.

We flush cache before changing KeyID of the page. KeyID is preserved for
freed pages to avoid excessive cache flushing.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  3 +++
 arch/x86/mm/mktme.c          | 29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 5f440d57aa47..5b22ef0f0ae3 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -11,6 +11,9 @@ extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
 
+#define prep_encrypted_page prep_encrypted_page
+void prep_encrypted_page(struct page *page, int order, int keyid);
+
 #define vma_is_encrypted vma_is_encrypted
 bool vma_is_encrypted(struct vm_area_struct *vma);
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 3da25212a372..cebec794bae8 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <asm/mktme.h>
 
 phys_addr_t mktme_keyid_mask;
@@ -21,6 +22,34 @@ int vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
 
+void prep_encrypted_page(struct page *page, int order, int new_keyid)
+{
+	int i;
+	void *v;
+
+	/*
+	 * The hardware/CPU does not enforce coherency between mappings of the
+	 * same physical page with different KeyIDs or encrypt ion keys.
+	 * We are responsible for cache management.
+	 *
+	 * We flush cache before changing KeyID of the page. KeyID is preserved
+	 * for freed pages to avoid exessive cache flushing.
+	 */
+
+	for (i = 0; i < (1 << order); i++) {
+		int old_keyid = page_keyid(page);
+
+		if (old_keyid == new_keyid)
+			continue;
+
+		v = kmap_atomic(page + i);
+		clflush_cache_range(v, PAGE_SIZE);
+		kunmap_atomic(v);
+
+		lookup_page_ext(page)->keyid = new_keyid;
+	}
+}
+
 static bool need_page_mktme(void)
 {
 	/* Make sure keyid doesn't collide with extended page flags */
-- 
2.16.2
