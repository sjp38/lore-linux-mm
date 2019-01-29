Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C1B2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBDAF20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDAF20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D48688E0010; Tue, 29 Jan 2019 13:50:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFC6B8E0003; Tue, 29 Jan 2019 13:50:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEA538E0010; Tue, 29 Jan 2019 13:50:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1448E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8358439edd.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eKJBvj1T0IZPPUl7daGGreUupnxLX0+68N6RW9VrUHc=;
        b=E4y2itbuoKV7mVub++EOC71bXRLa0/D9SXBxwbO+GhJTKHyfBU7BRH+mtvDc84Xy0d
         lrFgBPKi/nHPqafhHLaTuizZbxck67+0CS1Tzw2+r1cQmd3CB6g938z4W7dsTiRmn8EE
         814mfycyR294DhFjEy62FF9/pFl1LWHuFxuk1CI77Mg2jR1EZnDppQxPlduBAW1rOJam
         Ea0b0MYzoxfT9Qdbh/wgnY9WsfVgkZaa0hcsEGq8xw/qf7BPGJ2tWe9G10T0lbhaGxH7
         bS7rQ7P5spZMTM6Yc0OhuuV/0/qBdrZQCBRZ27fOAuXLhy3zCc/rW4oxzTV6I4wQD7Rt
         aSrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukc3LvMdYTD0aEfJnJcZ9wwwzO4150jzjb4kWjyXYxphkx95hX42
	rRghfR92m23mdjX5DGQecYdTHBMCHj5mt/LOJDR1WVCDpQVCP+ruA/BrNP12mlqpvCQeTuZHF4F
	qOHmHlB9PrCH/6tUvWptRmA4kKIn+1eklRcoVbyYferZ8EohHjutqp7QyxFbJ5lVeWw==
X-Received: by 2002:a17:906:66c2:: with SMTP id k2-v6mr23751891ejp.152.1548787818849;
        Tue, 29 Jan 2019 10:50:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5zOeyM/8Hff6IqS+KRfZlCGnzX9WJAp8D6VvdysD6HAyaBYlUVOTfaGNcyhYSr+1SVaRzU
X-Received: by 2002:a17:906:66c2:: with SMTP id k2-v6mr23751839ejp.152.1548787817657;
        Tue, 29 Jan 2019 10:50:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787817; cv=none;
        d=google.com; s=arc-20160816;
        b=uFzT+Q9nk1ierPGz2r6aY5kbq+D5gksABDAYuCYy+lzBQHGgSmPCr2IPfTvrDvc40N
         TTCiR5q3tOh48d5H83I9qgUge+XoDvjyD+IzpgDhetc2wchNotiTFEfWz3On+H8UyQlG
         4NXdYcK2QDroPAvQk4IzTrn9PnIlLfw3dfKAm9jko5awb0f7MYeorMV7np5o/oGK1xFH
         abKwFXImwasZZUrtcL6xes2EA/3vKnkwZD679X8XIp8/MgcspxMC12abuMZXrUz7oena
         obqdqkjzBxniQpsworYa8YyxWv4FwNCreVrey5RUOooROJAGKc3r4ZFyRY90ONaeHzja
         dbPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eKJBvj1T0IZPPUl7daGGreUupnxLX0+68N6RW9VrUHc=;
        b=MEczMeChOU/Vyz5zZPBYoPB81LbPbGySyiKwl66RhW4PFhXzsfhIrvepURWARZ0Nct
         nYlf0Ric8EHYBxCiLJ5ZpHtX0EDtppcVZe9+rcHRfEc7LMQxUbcrn9VHUmX9XhDlYHk/
         ZH72oH1Q/rVPPW2bYgvn3qGPYC2KO54mJmbkbhjQDxaEahypeH3vawDMft9FDLgQKE9B
         7RNiQ5n1P1Oy67zMjZygEyZtUbNSnFkMWvFWdUe6/XLVS3sO08yD1KLiU4lO1OUUAa/S
         jFnjh34kzNr74xc3jkkt9xni3Qskt6UWUosb7SSoL6fVDxx/IJsj/ex2pVguQU/6780k
         ubMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t5si581924ejq.44.2019.01.29.10.50.17
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:17 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9B54EA78;
	Tue, 29 Jan 2019 10:50:16 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ECE583F557;
	Tue, 29 Jan 2019 10:50:13 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 13/26] KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
Date: Tue, 29 Jan 2019 18:48:49 +0000
Message-Id: <20190129184902.102850-14-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To split up APEIs in_nmi() path, the caller needs to always be
in_nmi(). KVM shouldn't have to know about this, pull the RAS plumbing
out into a header file.

Currently guest synchronous external aborts are claimed as RAS
notifications by handle_guest_sea(), which is hidden in the arch codes
mm/fault.c. 32bit gets a dummy declaration in system_misc.h.

There is going to be more of this in the future if/when the kernel
supports the SError-based firmware-first notification mechanism and/or
kernel-first notifications for both synchronous external abort and
SError. Each of these will come with some Kconfig symbols and a
handful of header files.

Create a header file for all this.

This patch gives handle_guest_sea() a 'kvm_' prefix, and moves the
declarations to kvm_ras.h as preparation for a future patch that moves
the ACPI-specific RAS code out of mm/fault.c.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>

---
Changes since v6:
 * Tinkered with the commit message
---
 arch/arm/include/asm/kvm_ras.h       | 14 ++++++++++++++
 arch/arm/include/asm/system_misc.h   |  5 -----
 arch/arm64/include/asm/kvm_ras.h     | 11 +++++++++++
 arch/arm64/include/asm/system_misc.h |  2 --
 arch/arm64/mm/fault.c                |  2 +-
 virt/kvm/arm/mmu.c                   |  4 ++--
 6 files changed, 28 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm/include/asm/kvm_ras.h
 create mode 100644 arch/arm64/include/asm/kvm_ras.h

diff --git a/arch/arm/include/asm/kvm_ras.h b/arch/arm/include/asm/kvm_ras.h
new file mode 100644
index 000000000000..e9577292dfe4
--- /dev/null
+++ b/arch/arm/include/asm/kvm_ras.h
@@ -0,0 +1,14 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Copyright (C) 2018 - Arm Ltd */
+
+#ifndef __ARM_KVM_RAS_H__
+#define __ARM_KVM_RAS_H__
+
+#include <linux/types.h>
+
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	return -1;
+}
+
+#endif /* __ARM_KVM_RAS_H__ */
diff --git a/arch/arm/include/asm/system_misc.h b/arch/arm/include/asm/system_misc.h
index 8e76db83c498..66f6a3ae68d2 100644
--- a/arch/arm/include/asm/system_misc.h
+++ b/arch/arm/include/asm/system_misc.h
@@ -38,11 +38,6 @@ static inline void harden_branch_predictor(void)
 
 extern unsigned int user_debug;
 
-static inline int handle_guest_sea(phys_addr_t addr, unsigned int esr)
-{
-	return -1;
-}
-
 #endif /* !__ASSEMBLY__ */
 
 #endif /* __ASM_ARM_SYSTEM_MISC_H */
diff --git a/arch/arm64/include/asm/kvm_ras.h b/arch/arm64/include/asm/kvm_ras.h
new file mode 100644
index 000000000000..6096f0251812
--- /dev/null
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -0,0 +1,11 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Copyright (C) 2018 - Arm Ltd */
+
+#ifndef __ARM64_KVM_RAS_H__
+#define __ARM64_KVM_RAS_H__
+
+#include <linux/types.h>
+
+int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr);
+
+#endif /* __ARM64_KVM_RAS_H__ */
diff --git a/arch/arm64/include/asm/system_misc.h b/arch/arm64/include/asm/system_misc.h
index 0e2a0ecaf484..32693f34f431 100644
--- a/arch/arm64/include/asm/system_misc.h
+++ b/arch/arm64/include/asm/system_misc.h
@@ -46,8 +46,6 @@ extern void __show_regs(struct pt_regs *);
 
 extern void (*arm_pm_restart)(enum reboot_mode reboot_mode, const char *cmd);
 
-int handle_guest_sea(phys_addr_t addr, unsigned int esr);
-
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __ASM_SYSTEM_MISC_H */
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index efb7b2cbead5..c76dc981e3fc 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -733,7 +733,7 @@ static const struct fault_info fault_info[] = {
 	{ do_bad,		SIGKILL, SI_KERNEL,	"unknown 63"			},
 };
 
-int handle_guest_sea(phys_addr_t addr, unsigned int esr)
+int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
 {
 	return ghes_notify_sea();
 }
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index fbdf3ac2f001..600e0cc74ea4 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -27,10 +27,10 @@
 #include <asm/kvm_arm.h>
 #include <asm/kvm_mmu.h>
 #include <asm/kvm_mmio.h>
+#include <asm/kvm_ras.h>
 #include <asm/kvm_asm.h>
 #include <asm/kvm_emulate.h>
 #include <asm/virt.h>
-#include <asm/system_misc.h>
 
 #include "trace.h"
 
@@ -1903,7 +1903,7 @@ int kvm_handle_guest_abort(struct kvm_vcpu *vcpu, struct kvm_run *run)
 		 * For RAS the host kernel may handle this abort.
 		 * There is no need to pass the error into the guest.
 		 */
-		if (!handle_guest_sea(fault_ipa, kvm_vcpu_get_hsr(vcpu)))
+		if (!kvm_handle_guest_sea(fault_ipa, kvm_vcpu_get_hsr(vcpu)))
 			return 1;
 
 		if (unlikely(!is_iabt)) {
-- 
2.20.1

