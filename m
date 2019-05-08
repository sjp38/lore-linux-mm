Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0203BC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3EA2205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3EA2205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65C726B026D; Wed,  8 May 2019 10:44:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 525946B0271; Wed,  8 May 2019 10:44:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E94526B026D; Wed,  8 May 2019 10:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89D5D6B0269
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so12815854pgc.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2a86XFpPB1yBdakeeQxjTF554iXKWdzVOx15RcYIa0M=;
        b=XbRDuLLWs4WbcU39gTME1U7a9HTb6mbooqx89lZZ88AcO58NWuNw3eusT7s1woYove
         kDyOduQ5Ce8Q+MIs2SuMMtTYzu26snipV0bPh6x3ZocY9yuYRxFMAtpVdewGr3exz/jS
         TxG7COk6D7GiNQMRMzGtMc65d92HtgzbkrKLg30UqjXIwa4EU4lo7+12YpjxlxsX0DtZ
         CCtEZNdUYr0fOlDJB3YTwTNbyOxGWEjSdAS3TF6jI6bP/rWzrYiIgp1jil0h4qetXhcG
         t/ER7cOJoxredR50QwVdS9h5mG591ApUF62qRYghFd8W/Pmcbr2e48Qm2bndKNNrKOkI
         rz+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYwhffc1Xx+Bh1t7pJuhNFoXSoMR3td90FHUbyB/18k519v9r2
	A5PCXMwP0eLWxuaOrxLz80heDhoB900azzOyykUEcODc4oL+Q1iHnIuduU5m0vrm+8hDCkI78Ud
	mAVM2aO4gOWcKiu854O3WrQfmem3URssH5A2L1UpZJaPiQ+h5VGfVFKhyfaPkroaL9Q==
X-Received: by 2002:a63:dd58:: with SMTP id g24mr46966768pgj.161.1557326681177;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpMsNC2ASFzuS87qNgE9rkH8OiBdn7WrIAnt+MlUnMVC3kiCBaWilS1JnMNpPV6vLMXrif
X-Received: by 2002:a63:dd58:: with SMTP id g24mr46966607pgj.161.1557326679725;
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326679; cv=none;
        d=google.com; s=arc-20160816;
        b=uxP/fZMKN8NGbUwsmyT2Jz2MJJ33Oqgdom2ixN7eqWJJesHL3A0K1AuGJi0wA1jUdp
         +W4YcWV9URC6g/AX/UxDOdsIQVZZuP4Cdh+xX8WtT1Su/PKiN5aCXXfi0SDigKHp3QIh
         4pEM+NI2YQcAh7o2lFaGxpErxzslYzHdwYepAMRTOueOcH9slNSwR2o6YGkyUsEv14Hh
         LlSemXEtAnt3CIK4mnuSnmZd5k5YhL+u5g7zvpzIRIv7uKFPn/Tzs6IO66rfDbnNCTfS
         30DD3RacQ/WXVskeJ8OV1BxD2Wo1PNmkl8BZQCn+uSDYEJck2wsTjLDS3vubyVrYs6i+
         YdpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2a86XFpPB1yBdakeeQxjTF554iXKWdzVOx15RcYIa0M=;
        b=aNfYTo97ZOdTosLyp6XTG92Q6vcBQaDV4AYcCeDLLLtNUOXsblTgrCTybVGu/FxxD/
         Jww5zfe9y/Ptk173lGQBGeT6sVMAYyXp9f6wRzaradJedT15H5fUPRCgESP+CGctmk7j
         OuvNu3UPMKYYi6+SRasH1I7SwnsHhoMkUb8TEMUsaxWX+SwgTpBoLU1IkYs5YkkHYKHU
         O9EjWL0JMcT4dA4rTrKB+D9ouilp8uv4ATZCn3n7MYfrVsIoCknjQ7HIvd26NAzZM3+u
         Nefw4GEwSaovey6encyJ02d/QtvK8kYl7d6mKSst6b7y4tgjI7gdXQ/gQPU7kYccf/vF
         aeAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:39 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga006.jf.intel.com with ESMTP; 08 May 2019 07:44:34 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id DC7154AB; Wed,  8 May 2019 17:44:28 +0300 (EEST)
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
Subject: [PATCH, RFC 06/62] mm/khugepaged: Handle encrypted pages
Date: Wed,  8 May 2019 17:43:26 +0300
Message-Id: <20190508144422.13171-7-kirill.shutemov@linux.intel.com>
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

For !NUMA khugepaged allocates page in advance, before we found a VMA
for collapse. We don't yet know which KeyID to use for the allocation.

The page is allocated with KeyID-0. Once we know that the VMA is
suitable for collapsing, we prepare the page for KeyID we need, based on
vma_keyid().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 449044378782..96326a7e9d61 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1055,6 +1055,16 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock_write(vma->anon_vma);
 
+	/*
+	 * At this point new_page is allocated as non-encrypted.
+	 * If VMA's KeyID is non-zero, we need to prepare it to be encrypted
+	 * before coping data.
+	 */
+	if (vma_keyid(vma)) {
+		prep_encrypted_page(new_page, HPAGE_PMD_ORDER,
+				vma_keyid(vma), false);
+	}
+
 	__collapse_huge_page_copy(pte, new_page, vma, address, pte_ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
-- 
2.20.1

