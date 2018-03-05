Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F97A6B0033
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id c16so7472279pgv.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:40 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q24si10299553pff.301.2018.03.05.08.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 17/22] x86/mm: Implement vma_is_encrypted() and vma_keyid()
Date: Mon,  5 Mar 2018 19:26:05 +0300
Message-Id: <20180305162610.37510-18-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We store KeyID in upper bits for vm_page_prot that match position of
KeyID in PTE. vma_keyid() extracts KeyID from vm_page_prot.

VMA is encrypted if KeyID is non-zero. vma_is_encrypted() checks that.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  9 +++++++++
 arch/x86/mm/mktme.c          | 17 +++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index df31876ec48c..08f613953207 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -3,10 +3,19 @@
 
 #include <linux/types.h>
 
+struct vm_area_struct;
+
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
+
+#define vma_is_encrypted vma_is_encrypted
+bool vma_is_encrypted(struct vm_area_struct *vma);
+
+#define vma_keyid vma_keyid
+int vma_keyid(struct vm_area_struct *vma);
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 467f1b26c737..3b2f28a21d99 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,5 +1,22 @@
+#include <linux/mm.h>
 #include <asm/mktme.h>
 
 phys_addr_t mktme_keyid_mask;
 int mktme_nr_keyids;
 int mktme_keyid_shift;
+
+bool vma_is_encrypted(struct vm_area_struct *vma)
+{
+	return pgprot_val(vma->vm_page_prot) & mktme_keyid_mask;
+}
+
+int vma_keyid(struct vm_area_struct *vma)
+{
+	pgprotval_t prot;
+
+	if (!vma_is_anonymous(vma))
+		return 0;
+
+	prot = pgprot_val(vma->vm_page_prot);
+	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
+}
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
