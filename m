Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFBFC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B767B208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:23:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="1WGj7wJ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B767B208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317CC8E003A; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A1718E003C; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A7EE8E003A; Wed, 31 Jul 2019 11:23:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A38CA8E003B
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so42592537edx.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UJ4hP1jpsdk64Bv8Sf387CJe/yf6g4uoo14C+HjaYmc=;
        b=gOwieCgGd9x+ZHQwaJfj+XiMfXNkBSxx6jqLXGy1uygu8I+wKe2sX/DHdv5Dnqw1fU
         CyNLBiQVEUGjiBe+dzk+eoiZjAueZxI0g1oUNB9Y1MID3bIxSOCPVTYL0S0qvrgCD8V1
         Rp1NyHaST7HS1TfvSJfJlDih7tnN7pFvJHrdCP4sAOakjznMjjfVRRj8lVbBiYiewKZ4
         kYDZwJ64jgSkTTL0UIhvP2+1EK454U9LtJGMLwqk/GO+uUsOFBhiuxJ/W+vQJW2gson+
         mbSLVMBznZbmgAysRkk19L4E0M0VEc6IKBcdUBCy4PGHHGlQNACkF4RVYyGlfzhIQ0ee
         xALw==
X-Gm-Message-State: APjAAAUA03U1sxQck3JbHSQC9lpXBzPYAqs1UhotVpVoDUYhj34vJbya
	iO2AdJJoqO7ue2jeEGlbsBFICUNVbBqmEtao24fFpnUHiCYvy0tOlYwkbUroUTyTSXKidliyVc/
	ZEndhlW12V57fCjD7IAWsGduE3nBjR8OYY9U2VPmT22a0CZeKa9VSJdjeLLfmhXA=
X-Received: by 2002:a17:906:a39a:: with SMTP id k26mr46335202ejz.82.1564586630179;
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
X-Received: by 2002:a17:906:a39a:: with SMTP id k26mr46335105ejz.82.1564586628824;
        Wed, 31 Jul 2019 08:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586628; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1GT9JGrcKMftk3efa41rbNhjUq4HAOe4g3tvS4QjnNcUblqX7ZE18jI52ua3bmIlf
         zPuvyxElvgBafKULc+BiVY1oej3gLFfoz1Y9XgWgcy18Kb1j35kJaLkQrSp0MnjdwOx6
         3LbnBZG7nwDcuoGzEpbcC1TAPjLp/4o06C5Shiwt0VBY7LcexYm8qXKpV7o+rQPGXq/F
         jGvk79uScZ7eiWC7QSFX6Dxs5DATq/MucolvxhcStuygWIZjKeeiyqPUCU8Zm3w5s06b
         rf2IsL+53d6/VtrkgX11Z9XM5DaC3ZZQ6kCgEr9zOmp2ZxRtUXQO7GPE+HVn/dqVgu4/
         VF5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UJ4hP1jpsdk64Bv8Sf387CJe/yf6g4uoo14C+HjaYmc=;
        b=oU/PUK+BRjgrF9NWAPZ8nA+3dM9FTG1Rf/YnHHMFU45/MU7OYj8sW2V+6nLTl8ex7P
         5xYUIg2Y0HH7ryCBTE2FAo895aqkW2PhKBHkLWjDHLf+e1V7sfa/ulOZIAFtQcwjvDmP
         Kjo0z/KsltyaVVogwk9oDcjx1YhvAUvtCVwWv0i+d3NQu8aTO5MTyOF6MdvEEC/qAsao
         I0a1OGvrYzuu9xeO8Z30F4bhugAZAvbtf0uXe1T9PE2QgmfUxtlJnA6+tlhZVo4vcXaS
         VWJssWO8FxbO2UsV9jOHZqs3b3t5ZIuKLGbOPIbOipSmBb07gegsJNKwgXaEO2OuB0xI
         QBEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=1WGj7wJ1;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor52303209edx.26.2019.07.31.08.23.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:48 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=1WGj7wJ1;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UJ4hP1jpsdk64Bv8Sf387CJe/yf6g4uoo14C+HjaYmc=;
        b=1WGj7wJ1Xlp3fgcH7vRPMztYr6U5tkfbscC1DOrRMnOQVJ19MV2EFmQ3dnX/uhMZZn
         +9L8x0NHV+iAuJ5WNvg45vfgpudSqJX8d/cH7WzdQ31ED8yVQqTnWs55ok0ywoT/cwgf
         LRqfk29P9c2a6t2n4GX6Zecm1hTDG8T8yRuJTxwS4MxO8xCaa30nlcP9NO9vMwzhD2/o
         jqb8W3AN4/5jM2qm735SpdYqlgeo8FHpUWhX0TEFnQDL0Nc2/fTIBdSXwohDdZnHEMKC
         JwVVXHl6iKII+YD7dMq1HoHGHE4mMuXMCZtypv68y+qEBnZs7tcFjmgIVrRdiTc9lYx6
         gpdw==
X-Google-Smtp-Source: APXvYqyzPuIoVNHRDVYCIgZPGv2mkwSHT27TYRbjUfR28hqJRIWgt4niZw9djMR/+XyBoAXfW/QEEA==
X-Received: by 2002:a50:a5ec:: with SMTP id b41mr104531465edc.52.1564586628484;
        Wed, 31 Jul 2019 08:23:48 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id k20sm17485239ede.66.2019.07.31.08.23.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 6575C1048A4; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 52/59] x86/mm: Disable MKTME if not all system memory supports encryption
Date: Wed, 31 Jul 2019 18:08:06 +0300
Message-Id: <20190731150813.26289-53-kirill.shutemov@linux.intel.com>
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

UEFI memory attribute EFI_MEMORY_CPU_CRYPTO indicates whether the memory
region supports encryption.

Kernel doesn't handle situation when only part of the system memory
supports encryption.

Disable MKTME if not all system memory supports encryption.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/mktme.c        | 35 +++++++++++++++++++++++++++++++++++
 drivers/firmware/efi/efi.c | 25 +++++++++++++------------
 include/linux/efi.h        |  1 +
 3 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 17366d81c21b..4e00c244478b 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,9 +1,11 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/rmap.h>
+#include <linux/efi.h>
 #include <asm/mktme.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
+#include <asm/e820/api.h>
 
 /* Mask to extract KeyID from physical address. */
 phys_addr_t __mktme_keyid_mask;
@@ -48,9 +50,42 @@ void mktme_disable(void)
 
 static bool need_page_mktme(void)
 {
+	int nid;
+
 	/* Make sure keyid doesn't collide with extended page flags */
 	BUILD_BUG_ON(__NR_PAGE_EXT_FLAGS > 16);
 
+	if (!mktme_nr_keyids())
+		return 0;
+
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
+			if (!e820__mapped_any(efi_start, efi_end, E820_TYPE_RAM))
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
 	return !!mktme_nr_keyids();
 }
 
diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index ad3b1f4866b3..fc19da5da3e8 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -852,25 +852,26 @@ char * __init efi_md_typeattr_format(char *buf, size_t size,
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
index f87fabea4a85..4ac54a168ffe 100644
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
2.21.0

