Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7079CC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FDD1216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FDD1216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C5F26B02A1; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 173256B02A0; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92E86B029C; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A43906B02A1
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so12730844pfm.18
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BbRKBk6FDhssMTthMgesHoFT8llPZqMEa6iuWKGU9/Q=;
        b=RBIEit0RNNNQSImofE9kI5uyAg/f8N+/dkLhWP1IutPVskQ/Ki8uVkArfIIOIfsPBx
         +gBitre6yIT/mkpGaCKV6gDfa01kkPybHEKLFaMyqnjMkSTJ3yYIXeV734BuVIqZMhUA
         XpU3taJPjombXny/jHQW7MuioycN5Vb75Pr/mrS/Dn3k+1AD+h66dGS6nPqcF9tDRnwp
         IckzdEN4dGbBTxayDRC9N48zJAorL8Ykl+b6tL5AdBwityS42q1ym3xs07OanhvF0VjC
         vBGBPA8NWbbmOHTowCavfhPoiq1Tdxxcb3r2fnyLPzr3Y1IK3HpFIGigJaFrobKeqQ6D
         LFUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXPY1+tYMffRvVpfjMH2X1OlTSCs9qZyLoMnC/XxFhMuhzKrMIB
	rgtHvaD18ETc50TVZWt1XmVZx6DhZ/kFih2n37575DkpYbqGckZUaFdqgU7Y+iuY8BS+r+AbPsg
	LI2/WJ2dnGH44qXPS+uo2nX7P2JryWHQpC4sNPQUYdQB7nlpFo1YgstoRsEyr/PtnGw==
X-Received: by 2002:a17:902:1e3:: with SMTP id b90mr28139124plb.182.1557326691305;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+8S54XKq7/Xq+tmshq6qtnT7XP3gM/iTwf8irD6j4xEPjXUmdqQ43WZNWNvuXhp/mu5M7
X-Received: by 2002:a17:902:1e3:: with SMTP id b90mr28139011plb.182.1557326690100;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326690; cv=none;
        d=google.com; s=arc-20160816;
        b=praNAy6Yikr9OJP74VF7KYarMQ0Wpwqy/c7cMaaJLDHA3/ziAbywpGiz0kR9uhV31b
         aaZyBdNnjtl2oH5UbOPG64bC67kVMNLmDMQXgEWxPLeKUhhf2C7QzmUI+kAEmSUFD7sH
         JeP+TuZe2u6vd6g6h7tifdwjHD844xO7C6TXTwwg5h1ViAK7VUMoXzDeyIcMD2XSktRK
         I6De1z8hUt6MBWV0qqG/gdAehpfWZcrSlva0jQrd/mk9W0kVqviyZBvnJ66ke7GI8OaO
         whmO0bSrsD5j0CdiztTDz7zEOWOi3cmLZA7wbmV/4NqZyONU53rGAgVz/WUl532xmRk2
         eUJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BbRKBk6FDhssMTthMgesHoFT8llPZqMEa6iuWKGU9/Q=;
        b=Od5cW9xySNoa7fCVY1Lnm0FimO4x20RFAlp+ok9MePmjE0ke9Crcughv0p4Yw0IZ3J
         S58cZxbUViP2aO+O12NYxejs02kZzDzMAOY9Xsxyoja8xQ2mpud/875N+IPwRMC2HzGc
         S12xIDuUVAZBI7+atRBbkcuT6zikUp+HGWHE5pPGWEPoiUoj5bXf3xdWkwcTXFjn7bSQ
         nhJHgyOPbUd6ELMwAUPMEtPps9dS0toReB3uBD1ByNHCsv+79hUQZi6bRPDNWfpIwXBj
         xMjmvSpNmUQnN6u5FlSe960oWqAqQPgSCIGKFxsU7q9aoxwqumwQ9NCEUrBzjG8ofr9o
         OsNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t16si6593003plm.65.2019.05.08.07.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:49 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id E5DBEEAA; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
Date: Wed,  8 May 2019 17:44:04 +0300
Message-Id: <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
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
index bd6707e73219..0e6df07f1921 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -12,6 +12,10 @@ extern phys_addr_t mktme_keyid_mask;
 extern int mktme_nr_keyids;
 extern int mktme_keyid_shift;
 
+/* Set the encryption keyid bits in a VMA */
+extern void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid,
+				unsigned long start, unsigned long end);
+
 DECLARE_STATIC_KEY_FALSE(mktme_enabled_key);
 static inline bool mktme_enabled(void)
 {
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 024165c9c7f3..91b49e88ca3f 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
+#include <linux/rmap.h>
 #include <asm/mktme.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
@@ -53,6 +54,31 @@ int __vma_keyid(struct vm_area_struct *vma)
 	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;
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
+	newprot &= ~mktme_keyid_mask;
+	newprot |= (unsigned long)newkeyid << mktme_keyid_shift;
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
index 2684245f8503..c027044de9bf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2825,5 +2825,11 @@ void __init setup_nr_node_ids(void);
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
2.20.1

