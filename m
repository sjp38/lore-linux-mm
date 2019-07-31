Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2BCCC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA73208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="gQI/TJw+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA73208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF9998E0016; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D87BC8E0015; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B877C8E0016; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6788E8E0015
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so42546561ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3Khe0ucVPgmVgmnJxVPmTI2qFbR46a/XU3GbaeIl9uc=;
        b=o8pNKTFX70Le8eKmPSCRaPgkjaQ3UbX6uzugicDt6ou8ySqswashzeENu0UHO0JA3d
         v81w6BgFByxh1VWwJTOiZ7/HrX//u4Smn+5r7fU/wQ1cCdrRhUfDZIJ5FVcdcqltvcF+
         8JWtu7Jm9dMS3wTWRi5iowd6KZhPytT3g8lyLp5hhA6sP9QCIukG75eDbSr00q6p12xp
         R2LIb5DcOTzuy+L+hqBhD65oyZp22rUHl4nKt2W9OwQTpk7Zk2NEYsBEnWaMY9arx5XB
         vrGEjFFpPNrCgZhHVDRcsM2cq8uuiWtRI0xRquGZIl8lmtPUErRZljX/802bSK71sHQN
         FIww==
X-Gm-Message-State: APjAAAUMPIjiJ0TGuH7JZpH6F0EPDwTnR8nwnKAfipCthiPszkIyvjo1
	SnXPDw2QdfdQhs+0kVINzULcT5rNvJj3S+Fjt4GQut5epFXDfg/PjW0XB/EQzZ1XlItRTYsa8GC
	2BIpLUNZvC7fv4Bw7rUArz3k4SUp9vWS6leGVanVjq6tBy3V5j9I6V0QYAY5cLIY=
X-Received: by 2002:a50:b803:: with SMTP id j3mr105078544ede.208.1564585709004;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
X-Received: by 2002:a50:b803:: with SMTP id j3mr105078410ede.208.1564585707763;
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585707; cv=none;
        d=google.com; s=arc-20160816;
        b=YeGS6yFMAO8Pq9VYaoXX8yWBGdxK4Nky2fSmrQrVIq8bI21RTDCIxqLV685kWuEfNd
         aOX13ak4FXV7Pyjgtcn6nLWFgJRJ8rdY/7LvJGUnwBgvaBjdxUCq2HzetaVnzPUwLn8B
         YJ1RnqcVqEmBE1to4n+WRE8H1/yveZ96qQnnFF3jFUirOkSLMjdn/Gx+6wqSrboTaPHq
         dyxev0Y2zVfFmvlamPOUaPcNftEnOefzVgcM7F77arLzKejklVv1mlqObhHaveBaE9b5
         pQxyDZUeWa2TKyMiMLVTh7u5eVmTovX0Oqg6adKxkpqKbFnfQ/kQXdMzSTst7q6ZlR14
         37tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3Khe0ucVPgmVgmnJxVPmTI2qFbR46a/XU3GbaeIl9uc=;
        b=g9TvYCIrjiHDWcS/FRxX/efiXzKW/oYkQ1IDVbcT5MfFAmNj+pWNghO5YphlzHkLio
         IgAP7jS2MU1hBYLkyUl5vk6Ky3IBxKS/ZK0RGlpFXCu4+BPH3u+a8lGlbWc1b7U+TAY0
         RqUhTAZJ7K0z5OZAmeK7/ZyETcfqBqBPHuvSe+ldJpumJKWU1cRuXqXgGXU6ANkaelGF
         QOVILdgxlYL/VWYY/Shvl93WFkuCuDicvHBvQhqHndEDcPevr1JMbpVsnvxDe4EWeDCn
         MBtcAY2a5BFH+uoG04u88PMIGKhC+Msc8tPs+kS95JGPhDcAQU/KZJkcwDAi1SXl8fV9
         FHBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="gQI/TJw+";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y14sor52038568edu.28.2019.07.31.08.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="gQI/TJw+";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3Khe0ucVPgmVgmnJxVPmTI2qFbR46a/XU3GbaeIl9uc=;
        b=gQI/TJw+wOqQw6LekNivfnNF6fibSqE/4WRzpwQ/xFvdfdzWIOKXpHhUn1bQVL5jdd
         s8R19Qps0QXcAPV0lO52UPBPITRDjAjDh/SdNDwu3XRjm5lsTT8qIamQcIZguTQYJIiB
         yIDfiSG+yNKGj0VjCG1RwhE4MWsax7zVXdKlnNwaiqDH/+nGjkdysfv6DFMPxlgpyJ3M
         o4jOiLhIl2Dn3zA6LPYDjCqNEtUQXPdGkN8q+07zTnoXPf13J7sXjetyVxHr4kSOq0fX
         pfmdMsUgm3rA6XWvbZ6saiZTASDDzRaVlogKfpNeKQARtiXGKhBjMKlIiR+9TtiOMwHK
         UhzQ==
X-Google-Smtp-Source: APXvYqyYETJB0gBc/rsdzF8ujwDgg52+44KLAYVNOsjGpZelFLVDgZMEkF6ZatMWv69FcpZwOd/juw==
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr105394092edc.300.1564585707403;
        Wed, 31 Jul 2019 08:08:27 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id b30sm17643661ede.88.2019.07.31.08.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 56F3C1023AA; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 15/59] x86/mm: Map zero pages into encrypted mappings correctly
Date: Wed, 31 Jul 2019 18:07:29 +0300
Message-Id: <20190731150813.26289-16-kirill.shutemov@linux.intel.com>
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

Zero pages are never encrypted. Keep KeyID-0 for them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0bc530c4eb13..f0dd80a920a9 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -820,6 +820,19 @@ static inline unsigned long pmd_index(unsigned long address)
  */
 #define mk_pte(page, pgprot)   pfn_pte(page_to_pfn(page), (pgprot))
 
+#define mk_zero_pte mk_zero_pte
+static inline pte_t mk_zero_pte(unsigned long addr, pgprot_t prot)
+{
+	extern unsigned long zero_pfn;
+	pte_t entry;
+
+	prot.pgprot &= ~mktme_keyid_mask();
+	entry = pfn_pte(zero_pfn, prot);
+	entry = pte_mkspecial(entry);
+
+	return entry;
+}
+
 /*
  * the pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
  *
@@ -1153,6 +1166,12 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
 
 #define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
 
+#define mk_zero_pmd(zero_page, prot)					\
+({									\
+	prot.pgprot &= ~mktme_keyid_mask();				\
+	pmd_mkhuge(mk_pmd(zero_page, prot));				\
+})
+
 #define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
-- 
2.21.0

