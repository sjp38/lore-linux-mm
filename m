Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBF51C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A426D20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="bRpitEYF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A426D20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B36EA8E0032; Wed, 31 Jul 2019 11:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABF558E0030; Wed, 31 Jul 2019 11:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 988058E0032; Wed, 31 Jul 2019 11:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9F38E0030
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:14:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so42671222edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:14:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k+U6VIHmZ/fZHykv9hSZy3hTFPe14uQwWZPNGVQf9Wg=;
        b=RhZxOufNCNUZwmuV6m5uq02qVaxM46Khz6Wg5Bs3JSQXmQFdDgKIVy24EoUzZnKggo
         6Ga32yv/znLRw/i3xfbEBlkxt9Z8idmBjspRahB4q/DXizXeAy/BmA0msjC3xg7tRBr8
         iU6+nsZldd0KJPtYuFI4ZBOLAe28O3Mj/NuK4bJ65k47ACLN0hHgxEt8W/F0wNBS3Dap
         AcJ936WcIoclktuAQQUicdXRA0XOY1SJNa3qQJ3xE46Q+9Bk/2IukrHStk9wxZjAEFgr
         rred+sHnOQWYEOOs1Bo6ulmWQ6sVBxjsuOAdRrEzMVkeFeFu1bcnK21CvhKmGx+4ay7P
         XIXg==
X-Gm-Message-State: APjAAAVBuR99h1pffrKTNWhmQ7C6BPKXrZN5YH23vMC9dGp8j324SUNE
	5xqEm/vhznnfKsk+JVagsCzmRX5GYYedNLQv2U6VAbZuRvaf3rqidNn1fI7z9KlazMFte8D38kH
	hxgZzh9qeT2ll5LJ+8T9Wng3fSXKnhN0rxLq+hvnGoCf195jy6O1QL1u9xpiJbHY=
X-Received: by 2002:aa7:d918:: with SMTP id a24mr106262129edr.235.1564586039902;
        Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
X-Received: by 2002:aa7:d918:: with SMTP id a24mr106262030edr.235.1564586038903;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586038; cv=none;
        d=google.com; s=arc-20160816;
        b=jpZs0Fd91yEusDyeQBMN4B7szA12cDRpl/gF09kMWHWtBrS5rd/PQ5kKdKa5LJH976
         2viaSj8pZWD4HS3LPfEUMMBK0GeYqfIwMXHi8q2KioN8jICX6z74OSnZ559RN/gM8SXs
         AOlYiNIRKdeenlODBt2QyoNCXMdon0DPzNzOSogl4JOnnuRPazXUM/WPw4iV4o6+7l35
         cVirGxJnty01pYng5qsAlceWMBEpppfnrnsAzy3huh9sc/Z+vxCktCy7UToxvk0ghRK+
         y8Pd4tYSJn5k3DhiwCQw3ZuizTeBkTOGH5F0BFesquuJ3PVblxW0+TPhGNoBwl4So71t
         7V9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=k+U6VIHmZ/fZHykv9hSZy3hTFPe14uQwWZPNGVQf9Wg=;
        b=a96zW6Pox9g+KTelq6vZSawmgMBGFBlPyoKFR8HQGmP/CLFD2iR07dUc/T2UBN/OuT
         M/6t0AYMuZydk4WZiaOBd70Ka+ajryHy1T1BIfm8bRIwm1PhoAUFIDVfITV2XzAeXWNK
         SEc+9wCSnqgRArmvQI2BQfKD1sMAINGbMjrmIbHo3It0lOlObwjArCNAt0gC0SUcCxGc
         iEPPueA+uLimQFSqcxS4HHEr8ooJn2VDbLxGiCl+qJjSYwNQqeh3rktBjwduo9610AlJ
         IdWofr3awVL/aQQT93gdeqze46USvQvklXtsKtAkTf8tfQaOyuEpIu28aaV2XBQKMTkF
         bhsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bRpitEYF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor52307231ede.5.2019.07.31.08.13.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=bRpitEYF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=k+U6VIHmZ/fZHykv9hSZy3hTFPe14uQwWZPNGVQf9Wg=;
        b=bRpitEYFAw0iw9F4lWLWOaj8uAivovFwyv4AWNZf1NY1sGLxSiCLjNDzw6evzISUMa
         GHJXwwWF7WOifVXGeInd0STe8yx3ZYQIBXHrbJkyF+Rm71XJH0Uqn7KhiVn6RKSVi/NH
         GnIdsyLQWF+U1/Hz7RYNsNvOWkWTR+mduMkRXQK/n0AYcfSL5nkUiUeRr88V6rdddNZa
         NnYZWfhk4GFsXaFANiQNQQqJaMiCdDw2sC/yGDEkK8d34cXt5u306IrMfDI46uU39c0H
         ulh3gI4vz6iIiS8U4HduYh7aIdHho4vvV2rbd58qJxpeTNRRIu4peFugSAhril4FyF28
         DzHw==
X-Google-Smtp-Source: APXvYqx+v4/Pbf2jShDF7c6rephC3qv4nn7vrbh6ErmrX7qhFi1sSZ2Ot8M2CUcvWdStTREYbHHJ+Q==
X-Received: by 2002:a50:9468:: with SMTP id q37mr106511363eda.163.1564586038381;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id e43sm17445027ede.62.2019.07.31.08.13.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 41659104605; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 47/59] kvm, x86, mmu: setup MKTME keyID to spte for given PFN
Date: Wed, 31 Jul 2019 18:08:01 +0300
Message-Id: <20190731150813.26289-48-kirill.shutemov@linux.intel.com>
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
index 8f72526e2f68..b8742e6219f6 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2936,6 +2936,22 @@ static bool kvm_is_mmio_pfn(kvm_pfn_t pfn)
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
+	return ((u64)page_keyid(page)) << mktme_keyid_shift();
+#else
+	return shadow_me_mask;
+#endif
+}
+
 static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		    unsigned pte_access, int level,
 		    gfn_t gfn, kvm_pfn_t pfn, bool speculative,
@@ -2982,7 +2998,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		pte_access &= ~ACC_WRITE_MASK;
 
 	if (!kvm_is_mmio_pfn(pfn))
-		spte |= shadow_me_mask;
+		spte |= get_phys_encryption_mask(pfn);
 
 	spte |= (u64)pfn << PAGE_SHIFT;
 
-- 
2.21.0

