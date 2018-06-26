Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB1F6B0281
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:23:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c6-v6so10156144pll.4
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:23:05 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id w61-v6si1638713plb.502.2018.06.26.07.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 10/18] x86/mm: Implement vma_keyid()
Date: Tue, 26 Jun 2018 17:22:37 +0300
Message-Id: <20180626142245.82850-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We store KeyID in upper bits for vm_page_prot that match position of
KeyID in PTE. vma_keyid() extracts KeyID from vm_page_prot.

With KeyID in vm_page_prot we don't need to modify any page table helper
to propagate the KeyID to page table entires.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  5 +++++
 arch/x86/mm/mktme.c          | 12 ++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 7266494b4f0a..f0b7844e36a4 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -4,6 +4,8 @@
 #include <linux/types.h>
 #include <linux/page_ext.h>
 
+struct vm_area_struct;
+
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
@@ -14,6 +16,9 @@ extern struct page_ext_operations page_mktme_ops;
 #define page_keyid page_keyid
 int page_keyid(const struct page *page);
 
+#define vma_keyid vma_keyid
+int vma_keyid(struct vm_area_struct *vma);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 09cbff678b9f..a1f40ee61b25 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,3 +1,4 @@
+#include <linux/mm.h>
 #include <asm/mktme.h>
 
 phys_addr_t mktme_keyid_mask;
@@ -37,3 +38,14 @@ struct page_ext_operations page_mktme_ops = {
 	.need = need_page_mktme,
 	.init = init_page_mktme,
 };
+
+int vma_keyid(struct vm_area_struct *vma)
+{
+	pgprotval_t prot;
+
+	if (!mktme_enabled())
+		return 0;
+
+	prot = pgprot_val(vma->vm_page_prot);
+	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
+}
-- 
2.18.0
