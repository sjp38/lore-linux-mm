Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86D51C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:19:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54D8C218AF
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:19:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54D8C218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 097DD6B02B2; Wed, 18 Sep 2019 09:19:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 049996B02B3; Wed, 18 Sep 2019 09:19:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA1E06B02B4; Wed, 18 Sep 2019 09:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id CB6196B02B2
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:19:38 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 64EAD1A4C7
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:19:38 +0000 (UTC)
X-FDA: 75948098436.16.frame27_70e66a0a72d26
X-HE-Tag: frame27_70e66a0a72d26
X-Filterd-Recvd-Size: 3323
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:19:35 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B4C21142F;
	Wed, 18 Sep 2019 06:19:34 -0700 (PDT)
Received: from localhost.localdomain (entos-thunderx2-02.shanghai.arm.com [10.169.40.54])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6AC7B3F575;
	Wed, 18 Sep 2019 06:19:29 -0700 (PDT)
From: Jia He <justin.he@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Marc Zyngier <maz@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Suzuki Poulose <Suzuki.Poulose@arm.com>
Cc: Punit Agrawal <punitagrawal@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Alex Van Brunt <avanbrunt@nvidia.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	hejianet@gmail.com,
	Kaly Xin <Kaly.Xin@arm.com>,
	Jia He <justin.he@arm.com>
Subject: [PATCH v4 1/3] arm64: cpufeature: introduce helper cpu_has_hw_af()
Date: Wed, 18 Sep 2019 21:19:12 +0800
Message-Id: <20190918131914.38081-2-justin.he@arm.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190918131914.38081-1-justin.he@arm.com>
References: <20190918131914.38081-1-justin.he@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We unconditionally set the HW_AFDBM capability and only enable it on
CPUs which really have the feature. But sometimes we need to know
whether this cpu has the capability of HW AF. So decouple AF from
DBM by new helper cpu_has_hw_af().

Signed-off-by: Jia He <justin.he@arm.com>
Suggested-by: Suzuki Poulose <Suzuki.Poulose@arm.com>
---
 arch/arm64/include/asm/cpufeature.h | 1 +
 arch/arm64/kernel/cpufeature.c      | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/arch/arm64/include/asm/cpufeature.h b/arch/arm64/include/asm/cpufeature.h
index c96ffa4722d3..206b6e3954cf 100644
--- a/arch/arm64/include/asm/cpufeature.h
+++ b/arch/arm64/include/asm/cpufeature.h
@@ -390,6 +390,7 @@ extern DECLARE_BITMAP(boot_capabilities, ARM64_NPATCHABLE);
 	for_each_set_bit(cap, cpu_hwcaps, ARM64_NCAPS)
 
 bool this_cpu_has_cap(unsigned int cap);
+bool cpu_has_hw_af(void);
 void cpu_set_feature(unsigned int num);
 bool cpu_have_feature(unsigned int num);
 unsigned long cpu_get_elf_hwcap(void);
diff --git a/arch/arm64/kernel/cpufeature.c b/arch/arm64/kernel/cpufeature.c
index b1fdc486aed8..c5097f58649d 100644
--- a/arch/arm64/kernel/cpufeature.c
+++ b/arch/arm64/kernel/cpufeature.c
@@ -1141,6 +1141,12 @@ static bool has_hw_dbm(const struct arm64_cpu_capabilities *cap,
 	return true;
 }
 
+/* Decouple AF from AFDBM. */
+bool cpu_has_hw_af(void)
+{
+	return (read_cpuid(ID_AA64MMFR1_EL1) & 0xf);
+}
+
 #endif
 
 #ifdef CONFIG_ARM64_VHE
-- 
2.17.1


