Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3D19C41514
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BB34208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Z+QZrz8R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BB34208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 596CD8E0014; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51DE18E0013; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371DE8E0014; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D18D68E0013
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:28 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l24so33842226wrb.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BL5Bv5lW/jYayEJoRe2+9QezMkCC+60ESskc5jI43rc=;
        b=le1J/d63aAt1Lkx0RUHQbnvozs4lkZN/jqR4Facye04FWKP6Goeka7smlzdZ4zQtjw
         JQfgZ1lXs/y1/WIG6JhmfWnARWnbkYoUCuNZ2OJznrUDOQbDNuL3yqa4wwiMqWtpBCf2
         rsUcO/ghvXepUeGyq3CTK1UuHkZpe6PaLDKleHhc9gqPCFNYgkALs5BYB6gaMOU0O3dR
         11C3Hl22+cJnhpafuzTjMnd/GZmEkw2o6X6FWdrt757RLKZPB0QXpUYJn+c0YJPGvUDG
         YJF4EVL1x0WCZcjE8qN535m2/hcWe3R7dZLrWR0Lc50w2T2HAg3bC/5i56z03tXsBg+9
         txrg==
X-Gm-Message-State: APjAAAW++79EyI31Io3UYs2Z6oxoGSv0YpifHPL6KhAaPqHhR6HNJGNf
	M7svwaEzwv2lmBAgZC19Q8y2Hj/v0KtKTWV99JdqZNzxAlSiRPHOdGLOzBGoKx5luj6OVuLgjiF
	Z8+8MLSHG39I3/z7NPqX3VD+zt14+2GFrNs3fWxWu2Q2j4BpKF74mjLvW5VS9a/4=
X-Received: by 2002:adf:f206:: with SMTP id p6mr63698389wro.216.1564585708423;
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
X-Received: by 2002:adf:f206:: with SMTP id p6mr63698291wro.216.1564585707063;
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585707; cv=none;
        d=google.com; s=arc-20160816;
        b=qt1e6KtiWl4rhaAVSOVO71uNRZ6LMvg9BTVPHi/hMlKL2Nf++52mj2bWijTawh38sr
         725KV1W7LlcYlFlfcQXy5UPvCLW9FGnju2pQ794zG4PeQqoWL2Z9InNfNhVh5RsVGeSa
         eKaOLmi+tDUXzV7nD6QI8Ovg1m8D2PcXVrcxOdnkIXSaIppECXxTiXZZJ2ryjnLkTvqL
         xBttd+0fhnGvi8SCJZg0Itgc0EZJVKZYCBNJVkecbcjkZmJ82zYMKXwOLy122iYrkdSb
         tPVOLTn2OCYopG2n6YuaUsTAP64Sjs4oWGMKgFV6gR76pJJ4ivPnpMmSrEteGXT4mViO
         dr1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BL5Bv5lW/jYayEJoRe2+9QezMkCC+60ESskc5jI43rc=;
        b=dputc4W/uheZ8rQJ7sFYZo2hZSXWazTYB3L2EBGD3z0N66z+2N6fWXLIlFPXH26YVU
         lQsIxq+w4bKUcatCHGa1N9Y7EzgDVSxPo94mK6ARMcsyVN/pyL09MM0BYG3hAc1nSPL/
         SC5wPf/SBw35myfrO3ghAOZicRa8SuYupbKmkAF/xJbpt1XeAPfoMU+W97dLXelpmBAZ
         pgVHgBYDY/lnJL/2mmKp8eptw+vpGv0uWgARyNb+HFSTrUOB3VoIiUa0Z3c880l6fdvD
         xxgNddPRmlPDWEtvaYSn97g4qd+mK/FegNzfQEUK4UQE7rYn/+Dm6e2O0vhCaMz0hRRH
         g7xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z+QZrz8R;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b24sor22638971ejp.1.2019.07.31.08.08.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Z+QZrz8R;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=BL5Bv5lW/jYayEJoRe2+9QezMkCC+60ESskc5jI43rc=;
        b=Z+QZrz8RxaQVkEmqQR+P3He1RAcsz276GYydPQCrBvVFzTQKhJYu7NE41afsSGcW6+
         PEkJHs8N+UZO3AYfKlsxwVJLTOvBwiOb7PnAjByNuwdd5U2faK6XX8qM7PxvuCxO/mbu
         tGAo18iJgYPJ1Ot5DSRbXJIlTHuucTq2ZxCKM1dP5WZHTSE1FnneQRwt/g0J7LAxwo9y
         1kEtDf3Gtz6f8i1Dcl7z5jwv2Di5k2T62pCpUzzd1Hc8x6HKFWlkGzFRwJd9NLtmsaB8
         eZcrNUzOtJQwWsRlLRsolI/HegBB7F8KhoBR5T1awdNiOE/MGBOV2CCucAo20gDECZFx
         G0pA==
X-Google-Smtp-Source: APXvYqznZSrsxmfkB4pexMYFvT9i/MDUnejlA2skN/Nit1TPuevFqcmrEwStP937D+YpXbOTCbclHw==
X-Received: by 2002:a17:906:604c:: with SMTP id p12mr94494193ejj.26.1564585706687;
        Wed, 31 Jul 2019 08:08:26 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t16sm8546953ejr.83.2019.07.31.08.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 5011C101C44; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 14/59] x86/mm: Add hooks to allocate and free encrypted pages
Date: Wed, 31 Jul 2019 18:07:28 +0300
Message-Id: <20190731150813.26289-15-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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

The patch relies on page_address() to return virtual address of the page
mapping with the current KeyID. It will be implemented later in the
patchset.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 17 ++++++++
 arch/x86/mm/mktme.c          | 83 ++++++++++++++++++++++++++++++++++++
 2 files changed, 100 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 52b115b30a42..a61b45fca4b1 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -43,6 +43,23 @@ static inline int vma_keyid(struct vm_area_struct *vma)
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
 #define mktme_keyid_mask()	((phys_addr_t)0)
 #define mktme_nr_keyids()	0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index d02867212e33..8015e7822c9b 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,4 +1,5 @@
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <asm/mktme.h>
 
 /* Mask to extract KeyID from physical address. */
@@ -55,3 +56,85 @@ int __vma_keyid(struct vm_area_struct *vma)
 	pgprotval_t prot = pgprot_val(vma->vm_page_prot);
 	return (prot & mktme_keyid_mask()) >> mktme_keyid_shift();
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
+	 *
+	 * Flush cache lines with KeyID-0. page_address() returns virtual
+	 * address of the page mapping with the current (zero) KeyID.
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
+
+	for (i = 0; i < (1 << order); i++) {
+		/* All pages coming out of the allocator should have KeyID 0 */
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid);
+
+		/*
+		 * Change KeyID. From now on page_address() will return address
+		 * of the page mapping with the new KeyID.
+		 *
+		 * We don't need barrier() before the KeyID change because
+		 * clflush_cache_range() above stops compiler from reordring
+		 * past the point with mb().
+		 *
+		 * And we don't need a barrier() after the assignment because
+		 * any future reference of KeyID (i.e. from page_address())
+		 * will create address dependency and compiler is not allow to
+		 * mess with this.
+		 */
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
+	 *
+	 * Flush cache lines with non-0 KeyID. page_address() returns virtual
+	 * address of the page mapping with the current (non-zero) KeyID.
+	 */
+	clflush_cache_range(page_address(page), PAGE_SIZE * (1UL << order));
+
+	for (i = 0; i < (1 << order); i++) {
+		/* Check if the page has reasonable KeyID */
+		WARN_ON_ONCE(!lookup_page_ext(page)->keyid);
+		WARN_ON_ONCE(lookup_page_ext(page)->keyid > mktme_nr_keyids());
+
+		/*
+		 * Switch the page back to zero KeyID.
+		 *
+		 * We don't need barrier() before the KeyID change because
+		 * clflush_cache_range() above stops compiler from reordring
+		 * past the point with mb().
+		 *
+		 * And we don't need a barrier() after the assignment because
+		 * any future reference of KeyID (i.e. from page_address())
+		 * will create address dependency and compiler is not allow to
+		 * mess with this.
+		 */
+		lookup_page_ext(page)->keyid = 0;
+		page++;
+	}
+}
-- 
2.21.0

