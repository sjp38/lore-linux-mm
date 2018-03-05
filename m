Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3096B002B
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:31 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id b2-v6so2007701plz.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:31 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z134si10365594pfc.27.2018.03.05.08.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 20/22] x86/mm: Implement anon_vma_encrypted() and anon_vma_keyid()
Date: Mon,  5 Mar 2018 19:26:08 +0300
Message-Id: <20180305162610.37510-21-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch implements helpers to check if given VMA is encrypted and
with which KeyID.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 14 ++++++++++++++
 arch/x86/mm/mktme.c          | 11 +++++++++++
 2 files changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index c8f41837351a..56c7e9b14ab6 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -4,11 +4,20 @@
 #include <linux/types.h>
 
 struct vm_area_struct;
+struct anon_vma;
 
 struct page *__alloc_zeroed_encrypted_user_highpage(gfp_t gfp,
 		struct vm_area_struct *vma, unsigned long vaddr);
 
 #ifdef CONFIG_X86_INTEL_MKTME
+#define arch_anon_vma arch_anon_vma
+struct arch_anon_vma {
+	int keyid;
+};
+
+#define arch_anon_vma_init(anon_vma, vma) \
+	anon_vma->arch_anon_vma.keyid = vma_keyid(vma);
+
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
@@ -19,6 +28,11 @@ bool vma_is_encrypted(struct vm_area_struct *vma);
 #define vma_keyid vma_keyid
 int vma_keyid(struct vm_area_struct *vma);
 
+#define anon_vma_encrypted anon_vma_encrypted
+bool anon_vma_encrypted(struct anon_vma *anon_vma);
+
+#define anon_vma_keyid anon_vma_keyid
+int anon_vma_keyid(struct anon_vma *anon_vma);
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index ef0eb1eb8d6e..69172aabc07c 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/rmap.h>
 #include <linux/highmem.h>
 #include <asm/mktme.h>
 
@@ -28,6 +29,16 @@ int vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
 
+bool anon_vma_encrypted(struct anon_vma *anon_vma)
+{
+	return anon_vma_keyid(anon_vma);
+}
+
+int anon_vma_keyid(struct anon_vma *anon_vma)
+{
+	return anon_vma->arch_anon_vma.keyid;
+}
+
 void prep_encrypt_page(struct page *page, gfp_t gfp, unsigned int order)
 {
 	void *v = page_to_virt(page);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
