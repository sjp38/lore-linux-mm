Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4730A6B0269
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:29 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s3-v6so12708669plp.21
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:29 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l5-v6si295495pls.360.2018.06.12.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/17] x86/mm: Implement page_keyid() using page_ext
Date: Tue, 12 Jun 2018 17:39:07 +0300
Message-Id: <20180612143915.68065-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Store KeyID in bits 31:16 of extended page flags. These bits are unused.

We don't yet set KeyID for the page. It will come in the following
patch that implements prep_encrypted_page(). All pages have KeyID-0 for
now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  6 ++++++
 arch/x86/include/asm/page.h  |  1 +
 arch/x86/mm/mktme.c          | 21 +++++++++++++++++++++
 include/linux/page_ext.h     | 11 ++++++++++-
 mm/page_ext.c                |  3 +++
 5 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 08f613953207..0fe0db424e48 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -2,6 +2,7 @@
 #define	_ASM_X86_MKTME_H
 
 #include <linux/types.h>
+#include <linux/page_ext.h>
 
 struct vm_area_struct;
 
@@ -16,6 +17,11 @@ bool vma_is_encrypted(struct vm_area_struct *vma);
 #define vma_keyid vma_keyid
 int vma_keyid(struct vm_area_struct *vma);
 
+extern struct page_ext_operations page_mktme_ops;
+
+#define page_keyid page_keyid
+int page_keyid(const struct page *page);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 7555b48803a8..39af59487d5f 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -19,6 +19,7 @@
 struct page;
 
 #include <linux/range.h>
+#include <asm/mktme.h>
 extern struct range pfn_mapped[];
 extern int nr_pfn_mapped;
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 3b2f28a21d99..b02d5b9d4339 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -5,6 +5,15 @@ phys_addr_t mktme_keyid_mask;
 int mktme_nr_keyids;
 int mktme_keyid_shift;
 
+int page_keyid(const struct page *page)
+{
+	if (mktme_status != MKTME_ENABLED)
+		return 0;
+
+	return lookup_page_ext(page)->keyid;
+}
+EXPORT_SYMBOL(page_keyid);
+
 bool vma_is_encrypted(struct vm_area_struct *vma)
 {
 	return pgprot_val(vma->vm_page_prot) & mktme_keyid_mask;
@@ -20,3 +29,15 @@ int vma_keyid(struct vm_area_struct *vma)
 	prot = pgprot_val(vma->vm_page_prot);
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
+
+static bool need_page_mktme(void)
+{
+	/* Make sure keyid doesn't collide with extended page flags */
+	BUILD_BUG_ON(__NR_PAGE_EXT_FLAGS > 16);
+
+	return true;
+}
+
+struct page_ext_operations page_mktme_ops = {
+	.need = need_page_mktme,
+};
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index f84f167ec04c..d9c5aae9523f 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -23,6 +23,7 @@ enum page_ext_flags {
 	PAGE_EXT_YOUNG,
 	PAGE_EXT_IDLE,
 #endif
+	__NR_PAGE_EXT_FLAGS
 };
 
 /*
@@ -33,7 +34,15 @@ enum page_ext_flags {
  * then the page_ext for pfn always exists.
  */
 struct page_ext {
-	unsigned long flags;
+	union {
+		unsigned long flags;
+#ifdef CONFIG_X86_INTEL_MKTME
+		struct {
+			unsigned short __pad;
+			unsigned short keyid;
+		};
+#endif
+	};
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/mm/page_ext.c b/mm/page_ext.c
index a9826da84ccb..036658229842 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -68,6 +68,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
+#ifdef CONFIG_X86_INTEL_MKTME
+	&page_mktme_ops,
+#endif
 };
 
 static unsigned long total_usage;
-- 
2.17.1
