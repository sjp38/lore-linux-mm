Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84145C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42C222175B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42C222175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A25D46B026F; Wed,  8 May 2019 10:44:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF0C6B0271; Wed,  8 May 2019 10:44:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 876BB6B0272; Wed,  8 May 2019 10:44:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAC66B026F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y1so5441672plr.13
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=14T31bfznPI+LnnwAYK8Vb1jSm85ESHn0/2GAcqthOk=;
        b=Lq9RKnTYR8/XpRQm6N0BayklSqIF7sZUjbsLsa3ELEXHPGfb73Q/lvI6iro/o6XYB5
         aI0fhSimv4aqvDmYZV966h6VZBD6sMy91HwZzASDJ5mTDuzXNOtJZ2DVmEA0N7Ux03FU
         h/kt/E7e6nxwzP/n1LxEx3dh2n/509OVgawNDdICweqhNWh7bIOtDxcJY6fkQpQkGY5P
         rhzoI0dGI8nstBSsTEDbiqFt7GEe98fgEE/3YRQEeWpce1J0MVKRa+sJWbNQ7KRugzu7
         5pVD0KhyEHVTcWtR2CxsyXJtbEhqZU4fInbCMy3JnnealSULe9kCVS+3oPcktJJx6aSh
         OgDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmHV5StiF9eDJs8/Chq/Q7eR/sT4vf6Pu6sn/HSs5nVnisbRnk
	OwbsXX9jh82NFxekZgIEH5Hb5D+v3kxzBeQPiL01z99oLvvBy43wMvYH6Dwy2pLi9XZU0i+TiiH
	ANubMf8PAJ4uHnGYAZ+d9Egfv7+q7S8rcuROWKrUHjO224S6lnL4yiu7OuLofRu1odg==
X-Received: by 2002:a63:d408:: with SMTP id a8mr46373303pgh.184.1557326682862;
        Wed, 08 May 2019 07:44:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAOAs3G2UmbZ6cQZ9dSRYaJxkh7GLPTEhkwQu7DGABPzoB3jwLUrh10s2c+akN5to5TgWC
X-Received: by 2002:a63:d408:: with SMTP id a8mr46373181pgh.184.1557326681552;
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326681; cv=none;
        d=google.com; s=arc-20160816;
        b=qJlu8AUy2qLjnKhsww7UTmjJG2zROsvnsQqPZLuJHQpQVElCtl+TX9+IejHo8RlkFP
         /1KyQsS1hV3/GsoYEiFyEeVqfIxvAIk6NacjOa7opIPtoKubVMHzA0yfOFNrpfhFO/Xh
         Srd24Dx0CmNQ7iheKboAoo5nfcAlKUkMMzYqpBhNCd+mQS1WxjZPgeUyq5cr/Y4FVJWl
         W+1UIwUO8bFeYbXNm4bFE3dgy6Mfrs6DKX3UqdMlsuOBVF76Bz5q1ZqDpzo7PetEKryy
         RH96zWLN7VdnkIgAbLlUI7yAqPeuAsBq7axTC0OlWN+f1JgvgzasUak7OEmqBNda4VaQ
         Qjlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=14T31bfznPI+LnnwAYK8Vb1jSm85ESHn0/2GAcqthOk=;
        b=Vu5bJwcr4uXlKrXUBYnbUvOXRDVWzZI63QUUWnsVfWoai5SBNV0FUYXZY7alCR5TFJ
         gDJCcc6GOUo0+A4sCW8BeFYuXrZDPW5SC+cvrbNPru3aGsA54gdOD5LNvbqrJ6vBUjmJ
         wek49xAm9isTCvO+vSNwdeNl6pz5BghwuCLXsujXSRLlMVeJS4GnXC6hIEGpfMA84SNS
         a4xIJG1uiF4mMBsKkAXZK5Wn26nk3xSsnu6zaa7zKGJmzG8MX5SjR9YOjGdBSYWAy3Jb
         cLOUmLdKCsiIK38tw3mgeBXx6wU46cxS/osbBFtD7OqRk9P/4KipbnKcyUd8DqOdDBTL
         59pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b11si666839pge.440.2019.05.08.07.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:40 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga003.jf.intel.com with ESMTP; 08 May 2019 07:44:35 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 3EF8574A; Wed,  8 May 2019 17:44:29 +0300 (EEST)
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
Subject: [PATCH, RFC 12/62] x86/mm: Add a helper to retrieve KeyID for a VMA
Date: Wed,  8 May 2019 17:43:32 +0300
Message-Id: <20190508144422.13171-13-kirill.shutemov@linux.intel.com>
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

We store KeyID in upper bits for vm_page_prot that match position of
KeyID in PTE. vma_keyid() extracts KeyID from vm_page_prot.

With KeyID in vm_page_prot we don't need to modify any page table helper
to propagate the KeyID to page table entires.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h | 12 ++++++++++++
 arch/x86/mm/mktme.c          |  7 +++++++
 2 files changed, 19 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 51f831b94179..b5afa31b4526 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -5,6 +5,8 @@
 #include <linux/page_ext.h>
 #include <linux/jump_label.h>
 
+struct vm_area_struct;
+
 #ifdef CONFIG_X86_INTEL_MKTME
 extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
@@ -28,6 +30,16 @@ static inline int page_keyid(const struct page *page)
 }
 
 
+#define vma_keyid vma_keyid
+int __vma_keyid(struct vm_area_struct *vma);
+static inline int vma_keyid(struct vm_area_struct *vma)
+{
+	if (!mktme_enabled())
+		return 0;
+
+	return __vma_keyid(vma);
+}
+
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 9dc256e3654b..d4a1a9e9b1c0 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,3 +1,4 @@
+#include <linux/mm.h>
 #include <asm/mktme.h>
 
 /* Mask to extract KeyID from physical address. */
@@ -30,3 +31,9 @@ struct page_ext_operations page_mktme_ops = {
 	.need = need_page_mktme,
 	.init = init_page_mktme,
 };
+
+int __vma_keyid(struct vm_area_struct *vma)
+{
+	pgprotval_t prot = pgprot_val(vma->vm_page_prot);
+	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
+}
-- 
2.20.1

