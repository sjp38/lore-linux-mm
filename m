Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F97C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4421208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="yNcUiWdQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4421208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6548C8E0025; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 591D88E0022; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6548E0028; Wed, 31 Jul 2019 11:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB5A48E0025
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so42570457edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZkftAsGdSxojE0fJOOOF/MZdp7LK73Cocd1bOG6H+X8=;
        b=BbCW7s26ZHt7E6sBLz4U7oHLI3yD3yPSR4XehKTUGfzPdAVVxf8zDFvhBdeDLpq/RF
         wOfyOCFibJEqlbypMG69B5RCiZxAP32aJEj4P0/7Fcpi1qptOoFemDKJ47bsN/8EaZDN
         eN+MNs/GYuKk5VmZUOGEgVRiIKDeVjVXM3qywXqaLEfwL8WuCPOrC4PXMgwgd2siH7+6
         R2sqpLxMeZGzTu756WsL3+CENzdSPNmEa2nHQDdL2//ejawtPAO67G8Asr5Qq+48/Yvn
         L1J1xNDiFokO8QUfQsHTru7M75uCbfNXT15jk1ZAcQ2DitO7gk1FZ9ZUJnjBSZxitnYo
         h3Jg==
X-Gm-Message-State: APjAAAUHr6MiaOHmxazFPTaUr7yjBRF2b/kYFjACdDN9py/0CTmQb6NK
	ohjG+lvfHKFblbyLNIf9gD5Pq8jXiNVu0cuavXtiDe8tmP63cAaevXwu6tbXD5/granchInisgj
	nytluawxbriNg8cIwK/VzGc7Z+tE65ZTzOv13yHNRP+h+nAE80tbxRrzm2mjGeqI=
X-Received: by 2002:a50:b566:: with SMTP id z35mr110218097edd.129.1564586033376;
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
X-Received: by 2002:a50:b566:: with SMTP id z35mr110217952edd.129.1564586031850;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586031; cv=none;
        d=google.com; s=arc-20160816;
        b=lc66uVx0frc943fBhNeE0yV5ijpjp9p4dNMQLnxhIIr6s40q2Q9KktyIZZPwQzqG57
         aBHwsS7gpolPi1jw0pTzrx9bZmuRZbVWyWFOPhL3vnwHdsP+MGa4LVirpQdFntj7drbJ
         bwkNHB3Bq7fZFMcqNV+ujZIevSwM0uDl/KZ2UcJ19hHocbN2bfbechr7QofEqpbLS+yh
         lH3s8xzw+M6O93ZzdEOuhxrw8qySYsJXWyuHdmDDTTPhvNFk8JvzkQ4qRrq687Ng2t05
         9FsUWzgPupBLUObyJZxIn6FY+Di0glS0Uo2JX8An0etBf+H5/dcwrhiY+iIEyNxFisN+
         FLLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ZkftAsGdSxojE0fJOOOF/MZdp7LK73Cocd1bOG6H+X8=;
        b=kEVxJLvF9z0S8geLTW/HlO9jQeiIIFNvGDhkruOswxTF1hTeyf9M5btg6T7MwHOFbn
         zpoeA8eNRDNaeBBIvMXUWUK/Tvpa3M3GwFZql5l4WMEymMHx+4q86oYz9fK+78IhiF3V
         RDkSEv53kf1oiE6J6Lbrz8L/jZNTzEAeYouN6dM+oOYzg7NusaVbhP3yme7feeRaXPOn
         7iU7FL5Wx/2xPImgLrA1ClB9b1yBvvRV72CNpDxNhTxiqC9JGsZMYoUOD5LSAjU2Eo1f
         f/JLguc+yL/u8XRWKixzCa0MK3fdX6AlVVne6s1onGH1gnDEb1hDIe/wtaLMir7mbPz0
         Gbww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=yNcUiWdQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id oy17sor22054001ejb.16.2019.07.31.08.13.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=yNcUiWdQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZkftAsGdSxojE0fJOOOF/MZdp7LK73Cocd1bOG6H+X8=;
        b=yNcUiWdQFKls9CJ+s1kmqNYTq4HAt/+z4PQnyTb2R/O/QG4HejvHYbZEnDpZkx4u6m
         rYryPmrZZw5X0yVl9cqTObJ/vAbi3N2kcWUJTn/nS5m7u0j1NeO76bPx86u5y6/FFXzG
         GwvkGwtp3dVrAmLGNQwceerYEf8lbhe3A3hpQ9jH6pM/+5oR2hB1poc9BJZ/qpFk3lFg
         AVoV+a8D/wx7gKubBM5x0ly/CpnY4m7riIc5gECoUZ1ttMWB61O3sn/gxcaUYdZYR3rm
         riJBLh8bckwgmhvRhWjFVk43K9z3429hxlIIgWZDxIvHcCVj0zmgN7kgBdEg+aubIbZF
         aYoA==
X-Google-Smtp-Source: APXvYqxlBWhD79QJcY6LnrhxwdW4BCeLIylkUAMRGP9j6V32DYMCll5/WusJdm6IK3xrXEoHhQo02A==
X-Received: by 2002:a17:906:94ce:: with SMTP id d14mr97075606ejy.251.1564586031480;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j37sm17791942ede.23.2019.07.31.08.13.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 251F0104601; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 43/59] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
Date: Wed, 31 Jul 2019 18:07:57 +0300
Message-Id: <20190731150813.26289-44-kirill.shutemov@linux.intel.com>
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

From: Alison Schofield <alison.schofield@intel.com>

MKTME architecture requires the KeyID to be placed in PTE bits 51:46.
To create an encrypted VMA, place the KeyID in the upper bits of
vm_page_prot that matches the position of those PTE bits.

When the VMA is assigned a KeyID it is always considered a KeyID
change. The VMA is either going from not encrypted to encrypted,
or from encrypted with any KeyID to encrypted with any other KeyID.
To make the change safely, remove the user pages held by the VMA
and unlink the VMA's anonymous chain.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  4 ++++
 arch/x86/mm/mktme.c          | 26 ++++++++++++++++++++++++++
 include/linux/mm.h           |  6 ++++++
 3 files changed, 36 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index d26ada6b65f7..e8f7f80bb013 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -16,6 +16,10 @@ extern int __mktme_nr_keyids;
 extern int mktme_nr_keyids(void);
 extern unsigned int mktme_algs;
 
+/* Set the encryption keyid bits in a VMA */
+extern void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
+				unsigned long start, unsigned long end);
+
 DECLARE_STATIC_KEY_FALSE(mktme_enabled_key);
 static inline bool mktme_enabled(void)
 {
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index ed13967bb543..05bbf5058ade 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
+#include <linux/rmap.h>
 #include <asm/mktme.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
@@ -71,6 +72,31 @@ int __vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask()) >> mktme_keyid_shift();
 }
 
+/* Set the encryption keyid bits in a VMA */
+void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
+			  unsigned long start, unsigned long end)
+{
+	int oldkeyid = vma_keyid(vma);
+	pgprotval_t newprot;
+
+	/* Unmap pages with old KeyID if there's any. */
+	zap_page_range(vma, start, end - start);
+
+	if (oldkeyid == newkeyid)
+		return;
+
+	newprot = pgprot_val(vma->vm_page_prot);
+	newprot &= ~mktme_keyid_mask();
+	newprot |= (unsigned long)newkeyid << mktme_keyid_shift();
+	vma->vm_page_prot = __pgprot(newprot);
+
+	/*
+	 * The VMA doesn't have any inherited pages.
+	 * Start anon VMA tree from scratch.
+	 */
+	unlink_anon_vmas(vma);
+}
+
 /* Prepare page to be used for encryption. Called from page allocator. */
 void __prep_encrypted_page(struct page *page, int order, int keyid, bool zero)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3f9640f388ac..98a6d2bd66a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2905,5 +2905,11 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifndef CONFIG_X86_INTEL_MKTME
+static inline void mprotect_set_encrypt(struct vm_area_struct *vma,
+					int newkeyid,
+					unsigned long start,
+					unsigned long end) {}
+#endif /* CONFIG_X86_INTEL_MKTME */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
-- 
2.21.0

