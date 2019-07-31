Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66462C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CAAE20659
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:24:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="JWeiHziH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CAAE20659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA4CF8E003B; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2CAB8E003F; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9345D8E003B; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39CA68E003D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:23:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21so42638016edc.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:23:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XA7E5KeaJUbYeM2K2rhZVp4Ezd7kZRGT8yUA9YU5Vno=;
        b=ZkHHPuWKzGBGY7cP8il2+v7vf8lgtebw3cDX7dBuYIc/qmIq4vFDySnghP3yOAHW3g
         4UcKvsHCPLqbyIYYzC8XoNldsMM16SX9DKFdzpRjYextyl2Sg0ERDnMXFzTfEFN/pvd8
         313+nnvqkfxH5U5aXHTz9oJpXsfSXL8o8c4mLV+j7c0MzbBylfjlp6O0bNWaNHW6xPFR
         BUpM6ZIL2YknzYm8T7VodHFmw6WEk+ZMOyyt8MDELf7riWAwEBX8iYr4DbNU+u5G+Mfb
         dOmF5p4fPC6GNK11ney5EPsvsbP/TOoqAQ5s6zG7MJ2WcYsT0m3cvN4nTphHdqNH412U
         BZ3A==
X-Gm-Message-State: APjAAAWy3aUCyIzjRGvJWRZIfYvdJiEvDTai3mq2tUJyyf8f/5XvPz4e
	OEeogscolnqRsYDcJEsC3Emm/KOKb3CbOej+InkbAIEUbvh/4VfU5PIqk+WQi9p9iLZ12dR5Lhj
	vinstnUZTbZv6zE+rmRVF2GJco5ubvAq8AccOWnvXoFRRaNOyR50At0OBrxEDYvM=
X-Received: by 2002:a50:8974:: with SMTP id f49mr105463421edf.95.1564586631804;
        Wed, 31 Jul 2019 08:23:51 -0700 (PDT)
X-Received: by 2002:a50:8974:: with SMTP id f49mr105463322edf.95.1564586630626;
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586630; cv=none;
        d=google.com; s=arc-20160816;
        b=NyuKSAFuvJWFqyOZycPBL4h7GPZsXuFPDhYQJl1CFcQR8aTx7TVDfgrOk5saT5ezSF
         ivG09gUkGy0XzHObuMw3StjMXu7LBCvLBl/TyiBsf3pmOmkOuw8WiGWJby0n3IXigF9W
         gvhhldc1QYQC76sxcshH8m3aLGIzLLop8ir/PUAaRPUkJVym7ZfDQsYDGfLECPuIz16y
         FiFnPoT5a5zh+p734YVal4dJhvVPF6pnT9GOBQB6lulBWuR1vcuZrLcR2Q59oaYgjtR7
         dbtbyw5IfcPlFwEK+7kQdFHIiAkvOWDFMXUkV4Z8eS6QLQXzoS78Tw7AQGw1D2R+XIyy
         oDQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XA7E5KeaJUbYeM2K2rhZVp4Ezd7kZRGT8yUA9YU5Vno=;
        b=vyKxzgyPtYRoWy5JeeIR+FpGPeT8J4O+YSdfT9tD/0d90TKoso6FokBW8r3X9bhzP9
         vhdYU777DCSCPuXc2QnuA4vjGGIaJjuIhWSMudX2wCHIDQ4uFYAOvoo+yIhdZJ1EHabt
         WqApLaKxPDzLXyQL6P7MFd5UZUx3umB0dsoGhvB/975VKuzWwz+07WozLA8mk+81sGGc
         S/A8tPafWU/+vT/KxAczXg4cc9jmMnnI8otKnBx8NkANgO7kQ+WkA7A7RLJ2CGshD3QL
         Zp1qWUCOHg/L1L26uyO4De7vbesYgQmkOJVDMix/MYYmMYo4POmwC6l7KLdCvto2t2pI
         3fLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=JWeiHziH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor52376319edn.29.2019.07.31.08.23.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=JWeiHziH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XA7E5KeaJUbYeM2K2rhZVp4Ezd7kZRGT8yUA9YU5Vno=;
        b=JWeiHziHkn6XUi3iIplmGfT52a/0zxqWGFzXmszrNQRkV2LwyrAs/kin1BCvzl8D2g
         yPo5Vx4EKfuDM4BYN6yW2Wq+cCpZxizYwv7iwcWbuGnSIxyXHRUGoae6uIuCDrK7mVIH
         xzTngkApmdVD8IRLep9RK8d9L9t//qm1rGPEilmeOZ4y8P3K0gF5VP3e4kA4nP4Iu/SI
         H3wU+PfBV2o5YEK4noOFw3jff/xt6DObnFczx9D9SKtfMQvKeaTS3TZeAEnh1z2iouOI
         znt+q/4tcd/EsPVDW/3K93NZpgDh60EwOqhnnuSAuZpsWbtKZkMkfICwoaZYcdqaS/CB
         gGRw==
X-Google-Smtp-Source: APXvYqygZ5MBpQtdpZUq0Kg4NNTneIlpIbVYF7hlIaO8yQtO6FOtK69pmeSCoz1g6SVwfQ5huucSCQ==
X-Received: by 2002:a50:b1db:: with SMTP id n27mr108755394edd.62.1564586630295;
        Wed, 31 Jul 2019 08:23:50 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j7sm17555887eda.97.2019.07.31.08.23.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:23:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 64D3C1028A2; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 17/59] x86/mm: Allow to disable MKTME after enumeration
Date: Wed, 31 Jul 2019 18:07:31 +0300
Message-Id: <20190731150813.26289-18-kirill.shutemov@linux.intel.com>
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

The new helper mktme_disable() allows to disable MKTME even if it's
enumerated successfully. MKTME initialization may fail and this
functionality allows system to boot regardless of the failure.

MKTME needs per-KeyID direct mapping. It requires a lot more virtual
address space which may be a problem in 4-level paging mode. If the
system has more physical memory than we can handle with MKTME the
feature allows to fail MKTME, but boot the system successfully.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |  5 +++++
 arch/x86/kernel/cpu/intel.c  |  5 +----
 arch/x86/mm/mktme.c          | 10 ++++++++++
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index a61b45fca4b1..3fc246acc279 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -22,6 +22,8 @@ static inline bool mktme_enabled(void)
 	return static_branch_unlikely(&mktme_enabled_key);
 }
 
+void mktme_disable(void);
+
 extern struct page_ext_operations page_mktme_ops;
 
 #define page_keyid page_keyid
@@ -71,6 +73,9 @@ static inline bool mktme_enabled(void)
 {
 	return false;
 }
+
+static inline void mktme_disable(void) {}
+
 #endif
 
 #endif
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 4c2d70287eb4..9852580340b9 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -650,10 +650,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		 * We must not allow onlining secondary CPUs with non-matching
 		 * configuration.
 		 */
-		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
-		__mktme_keyid_mask = 0;
-		__mktme_keyid_shift = 0;
-		__mktme_nr_keyids = 0;
+		mktme_disable();
 	}
 #endif
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 8015e7822c9b..1e8d662e5bff 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -33,6 +33,16 @@ unsigned int mktme_algs;
 DEFINE_STATIC_KEY_FALSE(mktme_enabled_key);
 EXPORT_SYMBOL_GPL(mktme_enabled_key);
 
+void mktme_disable(void)
+{
+	physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	__mktme_keyid_mask = 0;
+	__mktme_keyid_shift = 0;
+	__mktme_nr_keyids = 0;
+	if (mktme_enabled())
+		static_branch_disable(&mktme_enabled_key);
+}
+
 static bool need_page_mktme(void)
 {
 	/* Make sure keyid doesn't collide with extended page flags */
-- 
2.21.0

