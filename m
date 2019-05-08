Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4216CC04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06442216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06442216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F08B86B029E; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93246B02A5; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D7866B02A0; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6BC6B029E
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c7so6537792pfp.14
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JpFf7qOa/lilxcHmFkzrT9z3goapRz8s5p1AyEi8zXs=;
        b=KTBKYD+jhJXYTStgAJKQ2srSCRGiDyud+tUlySCFpXMGYFMsci66EZqoK5sXhvT21/
         odwlipFnaURuDTV2NCarIyXypmD9kViz5ex1UPtzKb/dqtgKN6sX0tA17kZuUKu2EctH
         vSPbXRTgIc8IQsFgvHxESg65AJ85RA8henD6VQCclmd/001KbZx8wjiYdAdNU90q6nRg
         yRSYiVtVFiCUC6+4oDLKyFr0E2y6cwiRpZ5+9+oFEvpcE0ZV4W3IDPmVewaGFjhVVlGH
         0LFbWIx/bGE203NQ+s5w4nOvgSZ8ZYImr5Ger1KDB5RGBtWXKGn8wyJRt0rXKUbGIahH
         nw7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVskAd+qQey+f8KJFRpNOHdmwnT3Ze9lQFPAyw5l4g6kqwwd/Ai
	y5bjUQbCdgkOCmwldilxQYT2guCPiP4ODm2s+mEOtdusWP3Pyg913qJKHEf/kGx8Ex3zyrjXGTz
	2NZpOimRYKEfSHTrhWcR53mWVE3Y8hjbes2f/4SiLQioz9s5RXXFxNYRy25c0TKzPnQ==
X-Received: by 2002:a63:2b4c:: with SMTP id r73mr48619338pgr.181.1557326691892;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyncGI0Ea/wIdNQkV3npGq2GtEyDXPkl8TR2suFN3Sg7qoLBbNPMD0mhuWeO12Vb3wu6mJS
X-Received: by 2002:a63:2b4c:: with SMTP id r73mr48619263pgr.181.1557326691235;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326691; cv=none;
        d=google.com; s=arc-20160816;
        b=H2wPKdBEj//zYLpIJ2xrHGuCZoyQ0pdeROaJrD31NTYBtZvRtO3g9LGwBGXfhFGvbA
         etVhmseRLmBxqML5SLv80M7vB0ADHmShzNPybB+1J2bitu+4E4uweoUYLbSOTd3aHJzn
         B7N3tu1pN3vCUkMRAksrGYb5v8KVHz1b45MHxWEOK2e/RgiaMgUU1aTdFhzftF7ATWJT
         V6Bfz2eXqutdAjjLouf81G76VqrG0f21mlvA20qJHpEnZxTSBwM0UUXEqvy2KCI6MbYD
         WNRKIIZhnpsyJP4VOorl1cS7d65TdIR16MVlcS2uWKtA63RkCCiECyfkSJ0nd/AUbK3c
         gkng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JpFf7qOa/lilxcHmFkzrT9z3goapRz8s5p1AyEi8zXs=;
        b=k8MLdP88oGmBY8VU+UytIzwH5XDZ6LvdxDnYwvlzLVdHiIP1XE5aZF+rzJ1wsCbNUs
         30XsSyMfSZm5UbEdUhwOXBq9CHF2NCyLbDaGQzzDOStBfk8PLK164LLj+NcQVVe1csmR
         gJq/zCH53I4DoOle2veL/l2wDDBeCeDKUlXIt+ksyLK2UAGJNjHk+myEOae7MPNM/1EB
         +oUx/bjHOwz02mrlePXQ0wnUbb/Bw0kMUOx2gMusAbLw7U9oPQ/QiBLqQiWkeF6EiggT
         rgZoXpDCugAhKlSt0ldi2yKhNQ2AuJVcCKn2rlDZq2X2k/Iw7JPpNGXKifF2rchNhtiI
         +93g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:50 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga007.jf.intel.com with ESMTP; 08 May 2019 07:44:46 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 3BB8410AA; Wed,  8 May 2019 17:44:31 +0300 (EEST)
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
Subject: [PATCH, RFC 50/62] kvm, x86, mmu: setup MKTME keyID to spte for given PFN
Date: Wed,  8 May 2019 17:44:10 +0300
Message-Id: <20190508144422.13171-51-kirill.shutemov@linux.intel.com>
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

From: Kai Huang <kai.huang@linux.intel.com>

Setup keyID to SPTE, which will be eventually programmed to shadow MMU
or EPT table, according to page's associated keyID, so that guest is
able to use correct keyID to access guest memory.

Note current shadow_me_mask doesn't suit MKTME's needs, since for MKTME
there's no fixed memory encryption mask, but can vary from keyID 1 to
maximum keyID, therefore shadow_me_mask remains 0 for MKTME.

Signed-off-by: Kai Huang <kai.huang@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kvm/mmu.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index d9c7b45d231f..bfee0c194161 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2899,6 +2899,22 @@ static bool kvm_is_mmio_pfn(kvm_pfn_t pfn)
 #define SET_SPTE_WRITE_PROTECTED_PT	BIT(0)
 #define SET_SPTE_NEED_REMOTE_TLB_FLUSH	BIT(1)
 
+static u64 get_phys_encryption_mask(kvm_pfn_t pfn)
+{
+#ifdef CONFIG_X86_INTEL_MKTME
+	struct page *page;
+
+	if (!pfn_valid(pfn))
+		return 0;
+
+	page = pfn_to_page(pfn);
+
+	return ((u64)page_keyid(page)) << mktme_keyid_shift;
+#else
+	return shadow_me_mask;
+#endif
+}
+
 static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		    unsigned pte_access, int level,
 		    gfn_t gfn, kvm_pfn_t pfn, bool speculative,
@@ -2945,7 +2961,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		pte_access &= ~ACC_WRITE_MASK;
 
 	if (!kvm_is_mmio_pfn(pfn))
-		spte |= shadow_me_mask;
+		spte |= get_phys_encryption_mask(pfn);
 
 	spte |= (u64)pfn << PAGE_SHIFT;
 
-- 
2.20.1

