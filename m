Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56ADEC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10B8120C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="V5rpp3X2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B8120C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 522008E0010; Wed, 31 Jul 2019 11:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A9268E000D; Wed, 31 Jul 2019 11:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9C08E0010; Wed, 31 Jul 2019 11:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE0568E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so42623983ede.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=L4ZEjLjovYwhlc3sfcyK0re0l8xj15Oya4gREJZsXus=;
        b=Placrbti/KmWfwTynnYce8OlOJqrRwXRwuuMCcRVrDFvhGGqdMdTDWUrJ8Kipze8W/
         BM36uKPmdFyhCNNrMqXenr+2sr48QXfcGZ0G49MhHnGlgIy7a/sSIdJhj7mUQnqBewEj
         Gir2qPJckjeUPJtF57a7AxHeenNx+8PXpdJznpkLJaDxYT4ROqFQ43bsE/5lcmlwGlcc
         7ARlEIyq8sXhwU+0f8ynXQH+HfBuLZSqOeP+Y72+8Coaf6ZJVaj5flWYxHMhJAjCu+RT
         hgaJhxfN2kHpJVGcuLqu/I4GBhSz7fw34ESknLs/SeiM2RAhBx1zhEjqdCBMNquo8xzJ
         WIvw==
X-Gm-Message-State: APjAAAX3vjS/4xOxcuNSwFCMKI29LZpivb3i6feVytCdoy+ZuQsv8DwL
	LfpYVt/mlEJ+KedB++t2acDObajjWcd770eKEkJaUyKMmMnAWtlzCPZ3sGZYTQxM9gkLsg5V6FL
	N9b5921muVseV6r5W7VCYFzVXSU6/bfj8JN7gZVF5sHA5CxCGTwKwfgy7Y+bZCr0=
X-Received: by 2002:aa7:d64f:: with SMTP id v15mr107330034edr.132.1564585704353;
        Wed, 31 Jul 2019 08:08:24 -0700 (PDT)
X-Received: by 2002:aa7:d64f:: with SMTP id v15mr107329833edr.132.1564585702558;
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585702; cv=none;
        d=google.com; s=arc-20160816;
        b=Pxh6pw4MiVBkypPPObqC/nORfQQYmqIUNsRaZd28e9dx7uiFKHm+yYRpCsBq9jEyRJ
         3qhDqocnoKp+556802h5/yjXtKAjzfkYKD4p3J8XqIqPFT7TONil75e99XqL2qE5Dnx9
         Lphr25/ZZ9KJqJarVgort0m96YFwVcRgR4ihtTeF9hkhKVTG9Va9NKnrvkdjFYPzadE0
         W9SFGgCC33fzRoxA6pWSZAYGknRV6gcS+e97uZUeblx1AIv9u2zBPK9YcNCPbU3oIPEn
         hz/7PcZKmEEkNHbvsUr+FLoGKumsn2Ht+pk6iXR9ASAZQ2LDrPQmNGTSFfXjStx4G3h4
         fdoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=L4ZEjLjovYwhlc3sfcyK0re0l8xj15Oya4gREJZsXus=;
        b=Xllj2L6UKgsqEVos5kgrSk+TnSGhxu00D62gsATByUcirjymLL0V1N6+QtNyVFFd9L
         h3AJr73kCcr8od/4c+5pYPZL5KkMgaWQ5Va+r580u1MExsrihSq0D4tQHyuPnR7wtQV/
         ECqRX1aaOceYvCrYJ/3hmXRkmwF/TtuCCyTWd5amD8rVt0yoNJrZapYR0Oi8i0/ztfqe
         zRjk2SLBwvCp7wjHHkX2fLVbhv2GCMxhePwQJL/yO7sUtBnlPqA16LKCYVlT1BZu45qU
         wgBxL5NshCN2y6JbrDk1VuSkUdOyizDFGLUoUEYJ/Mqnod7H79abTTWJb4AhVtHbAfpd
         C+lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=V5rpp3X2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor13808011ejc.31.2019.07.31.08.08.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=V5rpp3X2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=L4ZEjLjovYwhlc3sfcyK0re0l8xj15Oya4gREJZsXus=;
        b=V5rpp3X2+p+VVm7FssSRodlU6DS9SwQLhXjimNRTkFMkTWsFbd7HkizFtVyE1zIrzy
         fPAuOPVVJeqlsLEhPRbCqOeRCbvW4JadhbicVgcow8yaygfiy6y17rqCfH03Rty6YhXj
         6s+mjRzfpE3alGhAXjgL2hhfWjPdDRz/hcRhXF1/iJC59vgvEz7fzn3mLdZt0saq8R+2
         YGro+1SRX76SodqfwZnA/6i9jWHWw9pBsAVy22+H2tRm7Z7bX/jkLZMKy9nrKbtBjbdn
         RE6jWJDgv80mFQO3CN2q3IrNNli2rX+pB/Xw9tJK/WnQpL2UfFVX1jHzcoNvANMfNeEh
         hhxA==
X-Google-Smtp-Source: APXvYqxJ9S0tGP2IpyXLxIjktlIQlFGvLsty4aUseBEocKbxQZsdfbX5PxHe1B3ZlzdQoz5XJNRh9g==
X-Received: by 2002:a17:906:4d88:: with SMTP id s8mr92464687eju.225.1564585702235;
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q11sm268380ejt.74.2019.07.31.08.08.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 2CA2A101320; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 09/59] x86/mm: Store bitmask of the encryption algorithms supported by MKTME
Date: Wed, 31 Jul 2019 18:07:23 +0300
Message-Id: <20190731150813.26289-10-kirill.shutemov@linux.intel.com>
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

Store bitmask of the supported encryption algorithms in 'mktme_algs'.
This will be used by key management service.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 2 ++
 arch/x86/kernel/cpu/intel.c  | 6 +++++-
 arch/x86/mm/mktme.c          | 2 ++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index b9ba2ea5b600..42a3b1b44669 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -10,6 +10,8 @@ extern int __mktme_keyid_shift;
 extern int mktme_keyid_shift(void);
 extern int __mktme_nr_keyids;
 extern int mktme_nr_keyids(void);
+extern unsigned int mktme_algs;
+
 #else
 #define mktme_keyid_mask()	((phys_addr_t)0)
 #define mktme_nr_keyids()	0
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 7ba44825be42..991bdcb2a55a 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -553,6 +553,8 @@ static void detect_vmx_virtcap(struct cpuinfo_x86 *c)
 #define TME_ACTIVATE_CRYPTO_ALGS(x)	((x >> 48) & 0xffff)	/* Bits 63:48 */
 #define TME_ACTIVATE_CRYPTO_AES_XTS_128	1
 
+#define TME_ACTIVATE_CRYPTO_KNOWN_ALGS	TME_ACTIVATE_CRYPTO_AES_XTS_128
+
 /* Values for mktme_status (SW only construct) */
 #define MKTME_ENABLED			0
 #define MKTME_DISABLED			1
@@ -596,7 +598,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		pr_warn("x86/tme: Unknown policy is active: %#llx\n", tme_policy);
 
 	tme_crypto_algs = TME_ACTIVATE_CRYPTO_ALGS(tme_activate);
-	if (!(tme_crypto_algs & TME_ACTIVATE_CRYPTO_AES_XTS_128)) {
+	if (!(tme_crypto_algs & TME_ACTIVATE_CRYPTO_KNOWN_ALGS)) {
 		pr_err("x86/mktme: No known encryption algorithm is supported: %#llx\n",
 				tme_crypto_algs);
 		mktme_status = MKTME_DISABLED;
@@ -631,6 +633,8 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		__mktme_keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, mktme_keyid_shift());
 		physical_mask &= ~mktme_keyid_mask();
 
+		tme_crypto_algs = TME_ACTIVATE_CRYPTO_ALGS(tme_activate);
+		mktme_algs = tme_crypto_algs & TME_ACTIVATE_CRYPTO_KNOWN_ALGS;
 	} else {
 		/*
 		 * Reset __PHYSICAL_MASK.
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 0f48ef2720cc..755afc6935b5 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -25,3 +25,5 @@ int mktme_nr_keyids(void)
 {
 	return __mktme_nr_keyids;
 }
+
+unsigned int mktme_algs;
-- 
2.21.0

