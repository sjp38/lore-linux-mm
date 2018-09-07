Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA688E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:36:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so7819018pgq.5
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:36:52 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z71-v6si9411933pff.223.2018.09.07.15.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:36:51 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:37:10 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 07/12] x86/mm: Add helper functions to track encrypted VMA's
Message-ID: <d98252fe105f2e948e2f585914a61b32c1902889.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

In order to safely manage the usage of memory encryption keys, VMA's
using each keyid need to be tracked. This tracking allows the Kernel
Key Service to know when the keyid resource is actually in use, or
when it is idle and may be considered for reuse.

Define a global atomic encrypt_count array to track the number of VMA's
oustanding for each encryption keyid.

Implement helper functions to manipulate this encrypt_count array.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 arch/x86/include/asm/mktme.h |  7 +++++++
 arch/x86/mm/mktme.c          | 39 +++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h           |  2 ++
 3 files changed, 48 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index b707f800b68f..5f3fa0c39c1c 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -16,6 +16,13 @@ extern int mktme_keyid_shift;
 /* Set the encryption keyid bits in a VMA */
 extern void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid);
 
+/* Manage the references to outstanding VMA's per encryption key */
+extern int vma_alloc_encrypt_array(void);
+extern void vma_free_encrypt_array(void);
+extern int vma_read_encrypt_ref(int keyid);
+extern void vma_get_encrypt_ref(struct vm_area_struct *vma);
+extern void vma_put_encrypt_ref(struct vm_area_struct *vma);
+
 /* Manage mappings between hardware keyids and userspace keys */
 extern int mktme_map_alloc(void);
 extern void mktme_map_free(void);
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 5ee7f37e9cd0..5690ef51a79a 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -163,6 +163,45 @@ int mktme_map_get_free_keyid(void)
 	return 0;
 }
 
+/*
+ *  Helper functions manage the encrypt_count[] array that tracks the
+ *  VMA's outstanding for each encryption keyid. The gets & puts are
+ *  used in core mm code that allocates and free's VMA's. The alloc,
+ *  free, and read functions are used by the MKTME key service to
+ *  manage key allocation and programming.
+ */
+atomic_t *encrypt_count;
+
+int vma_alloc_encrypt_array(void)
+{
+	encrypt_count = kcalloc(mktme_nr_keyids, sizeof(atomic_t), GFP_KERNEL);
+	if (!encrypt_count)
+		return -ENOMEM;
+	return 0;
+}
+
+void vma_free_encrypt_array(void)
+{
+	kfree(encrypt_count);
+}
+
+int vma_read_encrypt_ref(int keyid)
+{
+	return atomic_read(&encrypt_count[keyid]);
+}
+
+void vma_get_encrypt_ref(struct vm_area_struct *vma)
+{
+	if (vma_keyid(vma))
+		atomic_inc(&encrypt_count[vma_keyid(vma)]);
+}
+
+void vma_put_encrypt_ref(struct vm_area_struct *vma)
+{
+	if (vma_keyid(vma))
+		atomic_dec(&encrypt_count[vma_keyid(vma)]);
+}
+
 void prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 {
 	int i;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0f9422c7841e..b217c699dbab 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2803,6 +2803,8 @@ static inline void setup_nr_node_ids(void) {}
 #ifndef CONFIG_X86_INTEL_MKTME
 static inline void mprotect_set_encrypt(struct vm_area_struct *vma,
 					int newkeyid) {}
+static inline void vma_get_encrypt_ref(struct vm_area_struct *vma) {}
+static inline void vma_put_encrypt_ref(struct vm_area_struct *vma) {}
 #endif /* CONFIG_X86_INTEL_MKTME */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
-- 
2.14.1
