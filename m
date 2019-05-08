Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A6DC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2719F21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2719F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542376B02CE; Wed,  8 May 2019 10:46:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F3726B02D0; Wed,  8 May 2019 10:46:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F78E6B02D1; Wed,  8 May 2019 10:46:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECA326B02CE
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a8so12756163pgq.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X9QkOLXl8U4kOl6hj7oonvayj1eU917miOT+8zfFaek=;
        b=jIzWQRS8+QFHCBQLRudGMq96QzdIBRsUIrX52FSz7VJQiySeDh6P/eQmI8jNRMajDC
         /UEKMsZI5ZgbgC6SpRbRRxbajBIp/71Ml017O39aBjV+JceDQOmkYCi3JbGBHhq6s8xY
         a1VL6sPy6fLGuZM3udIu1kaS4vjhpnbmZctQj91k+V7HmvC4gK88NOrHNcXtIjhAVI9T
         ufT5USxFX9Iy4aHPfYufijgJ7YrMVryTlOAWHjSp2Euwk3lB2EM5EJKoNVjdKYliHJfG
         vZIJd5W9L2WboVPrYryg66jH57FhZG0Uuo+xZbaPw6BPhU29ALfG2coMeEx0Xo7bro4L
         97Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXtN+QqSTaEFkkM5Mr2Fsa7/8OCVwth4wc+/c0q5H3wcsWQtWAX
	6hgwHKqG317VDC5O2YQB85Ts83CrEKJXxYZ3zhXvopt4TkUbmSzTCX7n28o1VNQL32FkZ/L9Bgm
	1XuEVnpa+aCoAYyZBLt1ceP6ueNpjWJ4BunnoOaENAGnPG4Vlpd2h7n8RUvCxHUaKFA==
X-Received: by 2002:a63:5041:: with SMTP id q1mr47708733pgl.386.1557326799613;
        Wed, 08 May 2019 07:46:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjugaw7kVdR4h8rravtx3RIbF8E1V4it2giQ7Rt0X4RsCX5l3KJWNO3x5EZKi3AzbrneyN
X-Received: by 2002:a63:5041:: with SMTP id q1mr47696417pgl.386.1557326693817;
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326693; cv=none;
        d=google.com; s=arc-20160816;
        b=g7um2pu0rIEqNyouRp3lGMFyBWb5e+0gqoEHcs5lcx6jH3azG4i08OMndTnau+j5kC
         vLUd4Wi7u43yWF5jkl+QwNKc569THM/FJNd62ScDgi9dAZ81wqKeV3MhPuAfh/D0sYZ8
         7S6tlqCY5Bgsy7WChbNhF0CrfKBtUwLcRuSq2TPIHt/6FEj8IuL5WwUgmCXwrArN0HYR
         0grjP0pghXcGXN06kbjly4OFetdPH7P3hVw0pZa5UxBXnGmI4q5MuaMJ7LfOIFg7vUxw
         G/tMqop+QolXxQm8+IHlXPRQ0YLUwjkJhCZGEfbxJw9VaJ0Cfze+BK6S6GhdfyOJ12++
         VFYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X9QkOLXl8U4kOl6hj7oonvayj1eU917miOT+8zfFaek=;
        b=VKhYOnp5PkMtILTnTZDmiDxjhshd6uD87mSXm7KcH3xAOxfBX3RwLnSsmSKposkcLZ
         w1I0j9Gdz+v8s1I0NlLiGSDYcAYTMxmF7KmAMK4qvqD7joJmufbvGg8Ze46qOhfaRd2G
         IklqqvEbYZNwfCwpPM+1EQYDQqVvzc6I8UMv1C0dxHYOf52aQXAB7fdtCAvtjp5ObgkW
         RAOY/MNVMzB1taflAVPVuL+jUHUDIiiJcS4NMyBAZJhpM5QP1rD5U8FpJw9Gdw3k6FXZ
         kd8Ku/3eeoH2Ay7+rpZQZLMZxyzD0ZDzvqflOuV54NomAB9fT7mfKSa/WASoLuSKMAEl
         HE4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d11si23177393pgj.84.2019.05.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:53 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga001.fm.intel.com with ESMTP; 08 May 2019 07:44:48 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 721A41175; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 55/62] x86/mm: Disable MKTME if not all system memory supports encryption
Date: Wed,  8 May 2019 17:44:15 +0300
Message-Id: <20190508144422.13171-56-kirill.shutemov@linux.intel.com>
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

UEFI memory attribute EFI_MEMORY_CPU_CRYPTO indicates whether the memory
region supports encryption.

Kernel doesn't handle situation when only part of the system memory
supports encryption.

Disable MKTME if not all system memory supports encryption.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mktme.c        | 29 +++++++++++++++++++++++++++++
 drivers/firmware/efi/efi.c | 25 +++++++++++++------------
 include/linux/efi.h        |  1 +
 3 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 12f4266cf7ea..60b479686ea5 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,6 +1,7 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/rmap.h>
+#include <linux/efi.h>
 #include <asm/mktme.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
@@ -33,9 +34,37 @@ void mktme_disable(void)
 
 static bool need_page_mktme(void)
 {
+	int nid;
+
 	/* Make sure keyid doesn't collide with extended page flags */
 	BUILD_BUG_ON(__NR_PAGE_EXT_FLAGS > 16);
 
+	for_each_node_state(nid, N_MEMORY) {
+		const efi_memory_desc_t *md;
+		unsigned long node_start, node_end;
+
+		node_start = node_start_pfn(nid) << PAGE_SHIFT;
+		node_end = node_end_pfn(nid) << PAGE_SHIFT;
+
+		for_each_efi_memory_desc(md) {
+			u64 efi_start = md->phys_addr;
+			u64 efi_end = md->phys_addr + PAGE_SIZE * md->num_pages;
+
+			if (md->attribute & EFI_MEMORY_CPU_CRYPTO)
+				continue;
+			if (efi_start > node_end)
+				continue;
+			if (efi_end  < node_start)
+				continue;
+
+			printk("Memory range %#llx-%#llx: doesn't support encryption\n",
+					efi_start, efi_end);
+			printk("Disable MKTME\n");
+			mktme_disable();
+			break;
+		}
+	}
+
 	return !!mktme_nr_keyids;
 }
 
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 55b77c576c42..239b2edc78d3 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -848,25 +848,26 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
 	if (attr & ~(EFI_MEMORY_UC | EFI_MEMORY_WC | EFI_MEMORY_WT |
 		     EFI_MEMORY_WB | EFI_MEMORY_UCE | EFI_MEMORY_RO |
 		     EFI_MEMORY_WP | EFI_MEMORY_RP | EFI_MEMORY_XP |
-		     EFI_MEMORY_NV |
+		     EFI_MEMORY_NV | EFI_MEMORY_CPU_CRYPTO |
 		     EFI_MEMORY_RUNTIME | EFI_MEMORY_MORE_RELIABLE))
 		snprintf(pos, size, "|attr=0x%016llx]",
 			 (unsigned long long)attr);
 	else
 		snprintf(pos, size,
-			 "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
+			 "|%3s|%2s|%2s|%2s|%2s|%2s|%2s|%2s|%3s|%2s|%2s|%2s|%2s]",
 			 attr & EFI_MEMORY_RUNTIME ? "RUN" : "",
 			 attr & EFI_MEMORY_MORE_RELIABLE ? "MR" : "",
-			 attr & EFI_MEMORY_NV      ? "NV"  : "",
-			 attr & EFI_MEMORY_XP      ? "XP"  : "",
-			 attr & EFI_MEMORY_RP      ? "RP"  : "",
-			 attr & EFI_MEMORY_WP      ? "WP"  : "",
-			 attr & EFI_MEMORY_RO      ? "RO"  : "",
-			 attr & EFI_MEMORY_UCE     ? "UCE" : "",
-			 attr & EFI_MEMORY_WB      ? "WB"  : "",
-			 attr & EFI_MEMORY_WT      ? "WT"  : "",
-			 attr & EFI_MEMORY_WC      ? "WC"  : "",
-			 attr & EFI_MEMORY_UC      ? "UC"  : "");
+			 attr & EFI_MEMORY_NV         ? "NV"  : "",
+			 attr & EFI_MEMORY_CPU_CRYPTO ? "CR"  : "",
+			 attr & EFI_MEMORY_XP         ? "XP"  : "",
+			 attr & EFI_MEMORY_RP         ? "RP"  : "",
+			 attr & EFI_MEMORY_WP         ? "WP"  : "",
+			 attr & EFI_MEMORY_RO         ? "RO"  : "",
+			 attr & EFI_MEMORY_UCE        ? "UCE" : "",
+			 attr & EFI_MEMORY_WB         ? "WB"  : "",
+			 attr & EFI_MEMORY_WT         ? "WT"  : "",
+			 attr & EFI_MEMORY_WC         ? "WC"  : "",
+			 attr & EFI_MEMORY_UC         ? "UC"  : "");
 	return buf;
 }
 
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 6ebc2098cfe1..4b2d0b1a75dc 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -112,6 +112,7 @@ typedef	struct {
 #define EFI_MEMORY_MORE_RELIABLE \
 				((u64)0x0000000000010000ULL)	/* higher reliability */
 #define EFI_MEMORY_RO		((u64)0x0000000000020000ULL)	/* read-only */
+#define EFI_MEMORY_CPU_CRYPTO 	((u64)0x0000000000080000ULL)	/* memory encryption supported */
 #define EFI_MEMORY_RUNTIME	((u64)0x8000000000000000ULL)	/* range requires runtime mapping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
 
-- 
2.20.1

