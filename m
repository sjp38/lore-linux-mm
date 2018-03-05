Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBDE76B002B
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 73so9153957pfz.22
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:31 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id v77si4239219pfa.108.2018.03.05.08.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 21/22] x86/mm: Introduce page_keyid() and page_encrypted()
Date: Mon,  5 Mar 2018 19:26:09 +0300
Message-Id: <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new helpers checks if page is encrypted and with which keyid.
They use anon_vma get the information.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 14 ++++++++++++++
 arch/x86/mm/mktme.c          | 17 +++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 56c7e9b14ab6..dd81fe167e25 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -33,10 +33,24 @@ bool anon_vma_encrypted(struct anon_vma *anon_vma);
 
 #define anon_vma_keyid anon_vma_keyid
 int anon_vma_keyid(struct anon_vma *anon_vma);
+
+int page_keyid(struct page *page);
 #else
+
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
 #define mktme_keyid_shift	0
+
+static inline int page_keyid(struct page *page)
+{
+	return 0;
+}
 #endif
 
+static inline bool page_encrypted(struct page *page)
+{
+	/* All pages with non-zero KeyID are encrypted */
+	return page_keyid(page) != 0;
+}
+
 #endif
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 69172aabc07c..0ab795dfb1a4 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -39,6 +39,23 @@ int anon_vma_keyid(struct anon_vma *anon_vma)
 	return anon_vma->arch_anon_vma.keyid;
 }
 
+int page_keyid(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	int keyid = 0;
+
+	if (!PageAnon(page))
+		return 0;
+
+	anon_vma = page_get_anon_vma(page);
+	if (anon_vma) {
+		keyid = anon_vma_keyid(anon_vma);
+		put_anon_vma(anon_vma);
+	}
+
+	return keyid;
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
