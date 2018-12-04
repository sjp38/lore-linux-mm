Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6B2D6B6D90
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:37:26 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so13366870pfj.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:37:26 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 28si21308808pfm.50.2018.12.03.23.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:37:25 -0800 (PST)
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC v2 08/13] mm: Use reference counting for encrypted VMAs
Date: Mon,  3 Dec 2018 23:39:55 -0800
Message-Id: <985ba614d49986fdfc0397434fd1dd9eb5646c6f.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <cover.1543903910.git.alison.schofield@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

The MKTME (Multi-Key Total Memory Encryption) Key Service needs
a reference count on encrypted VMAs. This reference count is used
to determine when a hardware encryption keyid is in use, which in
turn, tells the key service what operations can be safely performed
with this keyid.

The approach is:
1) Increment/decrement the reference count during encrypt_mprotect()
system call for initial or updated encryption on a VMA.

2) Piggy back on the new vm_area_dup/free() helpers. If the VMAs being
duplicated, or freed are encrypted, adjust the reference count.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mktme.c | 2 ++
 kernel/fork.c       | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index facf08f9cb74..55d34beb9b81 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -145,10 +145,12 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
 	if (oldkeyid == newkeyid)
 		return;
 
+	vma_put_encrypt_ref(vma);
 	newprot = pgprot_val(vma->vm_page_prot);
 	newprot &= ~mktme_keyid_mask;
 	newprot |= (unsigned long)newkeyid << mktme_keyid_shift;
 	vma->vm_page_prot = __pgprot(newprot);
+	vma_get_encrypt_ref(vma);
 
 	/*
 	 * The VMA doesn't have any inherited pages.
diff --git a/kernel/fork.c b/kernel/fork.c
index 07cddff89c7b..d12d27b50966 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -341,12 +341,14 @@ struct vm_area_struct *vm_area_dup(struct vm_area_struct *orig)
 	if (new) {
 		*new = *orig;
 		INIT_LIST_HEAD(&new->anon_vma_chain);
+		vma_get_encrypt_ref(new);
 	}
 	return new;
 }
 
 void vm_area_free(struct vm_area_struct *vma)
 {
+	vma_put_encrypt_ref(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 }
 
-- 
2.14.1
