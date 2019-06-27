Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A495C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AA5B20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:49:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AA5B20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9801F8E0006; Thu, 27 Jun 2019 08:49:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9309F8E0002; Thu, 27 Jun 2019 08:49:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F8A38E0006; Thu, 27 Jun 2019 08:49:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 32B1E8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:49:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so5933747eds.14
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:49:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=x6XANZwp5VZn+8KE2+iRF2A5g4k87x82PXIrGcZQQkE=;
        b=j2ElNvuIWIuCA1y95I2poQwql9Zacxm5slmDJAlhoHrZLecDd7LkqVtRWl7j9k28ak
         vZc8dUV2AR/PnhGq4tfmOtZccNfNTFGMlU0ShkkIDXP28dTzz+fO6pP03py+xapQKEJ5
         L+iTHoonL5skX5TOy3ZE99B7oNrZtuOLiet+HNMf7pxfmqdcO+1e4c8FFunPALuluRY4
         HxRCw701QEkuWXlwCY6cJVFd5K56U1I0DjZrq49rhNwL70EFyxdki72dKKhBzJi06itQ
         HCHHXmotwMvGQECs9+3OjvXcwvvza6u7Lo0sLgbLB0Ywqfl5t4tTjTRBiZERdkHIiwnE
         GWCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUnevzwjHHrkHx8ZzMGxITDdee4zAPM9JWgQv2okK2ypxRvhGvP
	Gh8mYEkSMX+MkoVR2sG2+X1qsfdZelS7WyqcpcdHT3yoWHsU3mzcVuCJayEP2QK1Jui1X/qGmy+
	6LDftuGNI297bksiqVWQtW3gT8bTIaVxiwE3VWvfSuYMRyJBCSfRaw27v743ecos4uw==
X-Received: by 2002:a17:906:1510:: with SMTP id b16mr2940991ejd.25.1561639744768;
        Thu, 27 Jun 2019 05:49:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyObDSQMYNJcFwI/jc+7ME5vlR7bOmPgo/ZWsBLuNloq/u0VhjJGr8DgoD1ahl1ao8Rk7ig
X-Received: by 2002:a17:906:1510:: with SMTP id b16mr2940943ejd.25.1561639743892;
        Thu, 27 Jun 2019 05:49:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561639743; cv=none;
        d=google.com; s=arc-20160816;
        b=Mw9VTWhZjitknx8KpC/ogVPLvr21ayc1c03zciz+3Tvy/Kvy8H6cvrlTeofEALj/ZD
         kb3cp1yQowC7LKeH8sjXQNDNRC8yEsA7fB4cmb1MM585TvVECt3cS7K8nBRy1qjQC6y7
         js+XoGde3z/ldQR7soBqhH+jnw1q+muqbI3Uu5WBBCJsVXuMAFEaeov6XLsGGqUgGWF3
         lZKhSWcF7eLeHRHzCVY1Y++XaQMVH35eYRy78BLXmpZgSRHgB6b8vUoQQpFZG/lQOmNB
         UhupgI6NFV1fVIprNEofE8/uU7MeBv3rO4d8JxrweDaOhOB8vcm/VgQmyA/g4Od1D8lS
         UsdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=x6XANZwp5VZn+8KE2+iRF2A5g4k87x82PXIrGcZQQkE=;
        b=I/3lJ75p+nmqB0rRSRykM+qcQqYigyfa14ofdL+Z+EKFP42RZitXGlcSl2z9B+bxBs
         RbCDjIvTb5RCkO+Fh9Ei6eTdbkcgZlpm1/95s94IKpd0brlWOB99bKlrgeIcbGQOlIcL
         fCqZu14m5FoIzs/ltrnxzpN8+qfBt5OflalP+TV4Oxo4ITrTxeJr0sk2NtqPINQJX7I0
         0DpCUpxb/qEXxeKcwmRd710oYxcMqt14Ne4dxIDNVySaPYmxgwgGzt26BxSPlrCuhw/x
         QlSwMM8Gpk68i5Tv0OOVsYA85FZAz86lu7D47uPlHKHlqsDOfqFzb2sRvfKJRl3DiItj
         TczQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id op8si1374184ejb.193.2019.06.27.05.49.03
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 05:49:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 13BFD2B;
	Thu, 27 Jun 2019 05:49:03 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.20])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id C121B3F718;
	Thu, 27 Jun 2019 05:48:59 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Suzuki Poulose <suzuki.poulose@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 2/2] arm64/mm: Enable THP migration without split
Date: Thu, 27 Jun 2019 18:18:16 +0530
Message-Id: <1561639696-16361-3-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
References: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In certain page migration situations a THP page can be migrated without
being split into it's constituent normal pages. This not only saves time
required to split the THP page later to be put back when required but also
saves an wider address range translation from the existing huge TLB entry
reducing future page fault costs.

The previous patch changed the THP helper functions which now complies with
the generic MM semantics clearing the path for THP migration support. Hence
just enable it.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: Suzuki Poulose <suzuki.poulose@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig               | 4 ++++
 arch/arm64/include/asm/pgtable.h | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 0758d89..27bd8c4 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1589,6 +1589,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 	def_bool y
 	depends on HUGETLB_PAGE && MIGRATION
 
+config ARCH_ENABLE_THP_MIGRATION
+	def_bool y
+	depends on TRANSPARENT_HUGEPAGE
+
 menu "Power management options"
 
 source "kernel/power/Kconfig"
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 90d4e24..4860573 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -851,6 +851,11 @@ static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(swp)	((pte_t) { (swp).val })
 
+#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
+#define __pmd_to_swp_entry(pmd)        ((swp_entry_t) { pmd_val(pmd) })
+#define __swp_entry_to_pmd(swp)        __pmd((swp).val)
+#endif
+
 /*
  * Ensure that there are not more swap files than can be encoded in the kernel
  * PTEs.
-- 
2.7.4

