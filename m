Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 192AEC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA353205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA353205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96D106B0010; Wed,  8 May 2019 10:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C6116B026C; Wed,  8 May 2019 10:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 060F66B0010; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0AF36B026A
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a8so12752857pgq.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sEAdbNfbRTCjC9a0sD0Qg1cJEdXEvR4Mo/Vl8HfdoKs=;
        b=BlIApVnySu83nJ7PtM98wedTjQ2wGmlO5OpC79HJt1JEpJzaT8KFeSX5HiU84egK+o
         rGvlQplGeltvwiuyNKNg2caaJzPL8x1naPY5t2uGej1hUZYL/pXg9gSYWsVKtt+3OW6m
         9CVVxi0cDSI6teysOUnPIX//yJmY0N3Ue6luLfaRjq0NDG07AOlO2BwXsBZIyCcnqyvf
         NfrcuWmC7o6YG3wyqdsE3ihsEOveWt92UswQcNxpfwi3Y54vR/n6E9GAzoaTwfvxpgax
         uXIzylSjUFqecmohqIp7017k1wn7WoYBHpwz29ejCYGUtTyGkq7tVn/moa2WzIh9pzMa
         3qgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWxKQ5EvfuKegLbJXdrKHIcCYtMxUUAeo8TEtIRuqtkAYhAY+lL
	dSY0Qilke8sGGVj8dueEtLKJrflu1HwlRWEi0/t8KpKv143Z83MqzHRG8TFc5dYKfUojU/St0IF
	dqha6wdC8rtgo2risEWjexLZPVy3HRSPrvxQzW8EnuRLXzmDYDQMutkTnkiPnuMWCRQ==
X-Received: by 2002:a17:902:6842:: with SMTP id f2mr48111884pln.189.1557326681323;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJY5rjeaNDErnCt6n9U8z//3bbC9rmaY5UrxTmRH0IBDhF0Q+ZWSc3aj2ddriI1jYZpAqo
X-Received: by 2002:a17:902:6842:: with SMTP id f2mr48111741pln.189.1557326679954;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=yB2jH2njjzpKFC7yjA9fiv8GwUUN7jqV1wShp4rfoSO+DZ0o2EWUzzgjZ+ewzChzz6
         LH+JZhm5ZKtXnDe4jozZiQchuzlvO+zGkFkm5dWGPyDdLTZJhJDQ6w5EgtRlssP7ku9w
         Vqu92Z4jqtMjGM0Yywwhs8kSbJ0XIGmUUqcPhLJJpMY/jTWPKooP/9zz4zjeoQB7HFXu
         h4x5/x9WJaL2uZ1BfrsrudK17yUACn5lkushCgls5yaUaicng58j2NxZA1A4ezzXId7R
         NpgY84kU0JoQvT/fNCcc4K4CtzrFwOwTsUN7GwnUKlKVS8DPqdQOt7sgQpl7vhB7STx0
         9/9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sEAdbNfbRTCjC9a0sD0Qg1cJEdXEvR4Mo/Vl8HfdoKs=;
        b=GUcVFIWzmrl80VmRdo2gvoubRHClC6zBlAaU3raUmANqoPI1ZZtaDd0h4C4X4bdjuQ
         A/bGJBEvnxYd10QP4T1lkoyq9DCIVF3kev32z9+P9KzyKUFcSooHifmXramk2ng7jqKs
         4dyikzMJ93h/acFMHoaZ9rQVrZM/myxTWOuXKtX9Yg6wGMEnhIf8nGH7m9qYGAVQ7iRz
         I3Tv1LdrM1PzWnFu+xi5qpgHX30fItLbeYH3MytwcEQoBQPJiqzJ4pI1hhm3d1GT3akU
         PhI5KTQwT6Z/gZP2t/rvayO+o9OdV0YPqxMwDl0wSNTWR6BNDTrJlJrVqSlzl3jDveFG
         1dBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w14si24148884ply.226.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656527"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 4C59F79C; Wed,  8 May 2019 17:44:29 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free encrypted pages
Date: Wed,  8 May 2019 17:43:33 +0300
Message-Id: <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hook up into page allocator to allocate and free encrypted page
properly.

The hardware/CPU does not enforce coherency between mappings of the same
physical page with different KeyIDs or encryption keys.
We are responsible for cache management.

Flush cache on allocating encrypted page and on returning the page to
the free pool.

prep_encrypted_page() also takes care about zeroing the page. We have to
do this after KeyID is set for the page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 17 +++++++++++++
 arch/x86/mm/mktme.c          | 49 ++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index b5afa31b4526..6e604126f0bc 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -40,6 +40,23 @@ static inline int vma_keyid(struct vm_area_struct *vma)
 	return __vma_keyid(vma);
 }
 
+#define prep_encrypted_page prep_encrypted_page
+void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero);
+static inline void prep_encrypted_page(struct page *page, int order,
+		int keyid, bool zero)
+{
+	if (keyid)
+		__prep_encrypted_page(page, order, keyid, zero);
+}
+
+#define HAVE_ARCH_FREE_PAGE
+void free_encrypted_page(struct page *page, int order);
+static inline void arch_free_page(struct page *page, int order)
+{
+	if (page_keyid(page))
+		free_encrypted_page(page, order);
+}
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index d4a1a9e9b1c0..43489c098e60 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <asm/mktme.h>
 
 /* Mask to extract KeyID from physical address. */
@@ -37,3 +38,51 @@ int __vma_keyid(struct vm_area_struct *vma)
 	pgprotval_t prot = pgprot_val(vma->vm_page_prot);
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
 }
+
+/* Prepare page to be used for encryption. Called from page allocator. */
+void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
+{
+	int i;
+
+	/*
+	 * The hardware/CPU does not enforce coherency between mappings
+	 * of the same physical page with different KeyIDs or
+	 * encryption keys. We are responsible for cache management.
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
+
+	for (i = 0; i < (1 << order); i++) {
+		/* All pages coming out of the allocator should have KeyID 0 */
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
+		lookup_page_ext(page)->keyid = keyid;
+
+		/* Clear the page after the KeyID is set. */
+		if (zero)
+			clear_highpage(page);
+
+		page++;
+	}
+}
+
+/*
+ * Handles freeing of encrypted page.
+ * Called from page allocator on freeing encrypted page.
+ */
+void free_encrypted_page(struct page *page, int order)
+{
+	int i;
+
+	/*
+	 * The hardware/CPU does not enforce coherency between mappings
+	 * of the same physical page with different KeyIDs or
+	 * encryption keys. We are responsible for cache management.
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
+
+	for (i = 0; i < (1 << order); i++) {
+		/* Check if the page has reasonable KeyID */
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids);
+		lookup_page_ext(page)->keyid = 0;
+		page++;
+	}
+}
-- 
2.20.1

