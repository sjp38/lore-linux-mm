Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA1A6B002A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h193so9984218pfe.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:31 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j13si8542257pgv.110.2018.03.05.08.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 19/22] x86/mm: Implement free_encrypt_page()
Date: Mon,  5 Mar 2018 19:26:07 +0300
Message-Id: <20180305162610.37510-20-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As on allocation of encrypted page, we need to flush cache before
returning page to free pool. Failing to do this may lead to data
corruption.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mktme.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 1129ad25b22a..ef0eb1eb8d6e 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -45,6 +45,19 @@ void prep_encrypt_page(struct page *page, gfp_t gfp, unsigned int order)
 	WARN_ONCE(gfp & __GFP_ZERO, "__GFP_ZERO is useless for encrypted pages");
 }
 
+void free_encrypt_page(struct page *page, int keyid, unsigned int order)
+{
+	int i;
+	void *v;
+
+	for (i = 0; i < (1 << order); i++) {
+		v = kmap_atomic_keyid(page, keyid + i);
+		/* See comment in prep_encrypt_page() */
+		clflush_cache_range(v, PAGE_SIZE);
+		kunmap_atomic(v);
+	}
+}
+
 struct page *__alloc_zeroed_encrypted_user_highpage(gfp_t gfp,
 		struct vm_area_struct *vma, unsigned long vaddr)
 {
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
