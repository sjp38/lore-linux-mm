Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B453B6B0062
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v14so1543596pgq.11
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:51 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j61-v6si4080591plb.317.2018.03.28.09.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/14] x86/mm: Implement vma_is_encrypted() and vma_keyid()
Date: Wed, 28 Mar 2018 19:55:37 +0300
Message-Id: <20180328165540.648-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
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
2.16.2
