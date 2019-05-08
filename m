Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3968C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D812216C4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D812216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 377156B0269; Wed,  8 May 2019 10:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28E926B026E; Wed,  8 May 2019 10:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8FC6B026C; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF836B0010
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 13so12764222pfo.15
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SVmYwDv3j5Zqu2stWHOAZhr/mhJK4ly92EXT5VclcOA=;
        b=UQ9XBwvLLHW8tugJovCQ9XE8tJlLamcmqyGghTRt0WuNWKJ2w3KdVqnMiGU0npz6+D
         7LX+2zl0i8cavwPxe4bY16RWigdestI3Gtp60rl97+3Hu5GubIkTkqE+ZzJ20ns8z1Os
         8UZ1sCLzD/4gn4AxNEbLqq8+b60DoqqfNaBi5GS9x3C3+FCSiYOBp3wpoKZ7D9aohUCa
         ZMEQFTRfKAR4lAQiJUNceHXueaivd4pQmSmd/hruQ9uja+YwsyS/jMw1QoPcXpFnr+Bs
         +VseHYfWaIgmOWP+ri13BXAFY8T/0x4wG362h1hrTld8kAfiXMhftY3z7EbSnFPkWQ+X
         t+vQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVKuYy2vfIYcdellukLN01djqaNGEGLSwbsQXqZfoc4BX6NGdR1
	cMO0ZBCVVTag3Oz33hdjtpRlGIssC0U5hwdGWxFAwHiV2sqvZm8fcLJveYl4v+PzpKYebK6XC7W
	dt8jXSdV3CYbwUu1jPjJohHbdeDcPzgbtC9JWMpr1XCAQR6jQCKWnJ9t+fPZMmviWbA==
X-Received: by 2002:a63:9dc8:: with SMTP id i191mr46263963pgd.91.1557326681116;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyq81PTSsHGVCzswobthbkq/K8TB/ITNQwQ9ww4MLZpg/MQsRNl9JlqNLruxDXDXpxIksS6
X-Received: by 2002:a63:9dc8:: with SMTP id i191mr46263848pgd.91.1557326679978;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=kTgSJlNn8kCuu6K42ct3SZqV6cGwugKw+3o2LBunvkrb5An86yIQ7USoIXc2qwR/vb
         HB8KtD/HSm/kwHXMSQrwLT8JuwSVCJgbAc2t1A8Y1lumRNwqL4Hghm2njLaDNLtKaadL
         N2HsfGra2K/hXyKGLvB/jTE5Vt29Se6crcWkmPrB+5dU8k57CUN1k+R895eXasDgGtRc
         xmIyEGTRVY6WNcTH0sE7RhHu1ppyuwIubXLHeXlTvlmkwZgaT3ugmIdXE7W24GHO3LuS
         K0Pir1F6jWBHgaZF/E68KoGEVNV2fKA69n5zLdgSW0O9JiYFrChIbRzy9ESZBpJ4e2qq
         9f1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SVmYwDv3j5Zqu2stWHOAZhr/mhJK4ly92EXT5VclcOA=;
        b=1I8kiHQQukB6/4FaU9WG/e3PfxVryeo1mY0UmohVhopGQDl6DDmzxvGZF1R+GGtlxC
         fInfHpM6XpbBVNjCEKkdzsqQ8pDVeuELqHX+ystX7ekZRuc54jIWMd9QL2dbJ84TrjYo
         S1ygyP62Q/VUCh0wLyWO0QLFjjPY5wGiIe59ZrI/mFcsaw+9Pf+6zXX3UP3wg/+6V8S1
         FFbK/JT7f8BuQfe3iDwwiOmh+CUDJwsBTJIIY32i24OyrmVsLcXH9jmaZ7Otfu7TqqeF
         JQpNa84QUvphxqUkG6KB6POTa+B54f0TidAprEPlTf6kRMTrsquWRhkm7ttSrSBqu6Dl
         O66A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j1si22102151pgp.557.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga004.fm.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 58DEC858; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 14/62] x86/mm: Map zero pages into encrypted mappings correctly
Date: Wed,  8 May 2019 17:43:34 +0300
Message-Id: <20190508144422.13171-15-kirill.shutemov@linux.intel.com>
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

Zero pages are never encrypted. Keep KeyID-0 for them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 50b3e2d963c9..59c3dd50b8d5 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -803,6 +803,19 @@ static inline unsigned long pmd_index(unsigned long address)
  */
 #define mk_pte(page, pgprot)   pfn_pte(page_to_pfn(page), (pgprot))
 
+#define mk_zero_pte mk_zero_pte
+static inline pte_t mk_zero_pte(unsigned long addr, pgprot_t prot)
+{
+	extern unsigned long zero_pfn;
+	pte_t entry;
+
+	prot.pgprot &= ~mktme_keyid_mask;
+	entry = pfn_pte(zero_pfn, prot);
+	entry = pte_mkspecial(entry);
+
+	return entry;
+}
+
 /*
  * the pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
  *
@@ -1133,6 +1146,12 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm,
 
 #define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
 
+#define mk_zero_pmd(zero_page, prot)					\
+({									\
+	prot.pgprot &= ~mktme_keyid_mask;				\
+	pmd_mkhuge(mk_pmd(zero_page, prot));				\
+})
+
 #define  __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
-- 
2.20.1

