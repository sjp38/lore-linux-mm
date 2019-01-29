Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E9F9C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0974620844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0974620844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C39AE8E0011; Tue, 29 Jan 2019 13:50:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0E948E0003; Tue, 29 Jan 2019 13:50:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD9EF8E0011; Tue, 29 Jan 2019 13:50:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCE28E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so8352425edi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J3ZEvjd6iSwqW9/Lj+HAFuc9FVXfG+8GlKLDC1orXuM=;
        b=jkh9rqq8m6xZJEWCzneIRF7IMwrumF+WFN9opTcpkr2fk9rJwQtEDz2r2spV/jsuAZ
         WTKeWjSU8cCTLzgcRsiVQa2O2NB9pjqErZ/gFgEX9Dvak9cZY+W34Ed93b3Bj1BsrMZl
         FQdWmrpg+vLOMkIs6Hofmq+A+QXvRiKqqM4x0EfY88+8jqhu5VY4l0xtVMAwTAXbx32B
         j/C3ZpxC7ge7gjzgOo3rPJa4sD9+hZW09Zcdu8ujweylS9l86H44tB5DYOQaFthyI8OO
         wtwoQGG3KKKlxXc3HQNOGs1coQUtoUWzxF0h/YAgh53H61DriakSg4tqmsgizQyx6lZe
         uJbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdaGoxFDqcoqs8uejo4zU+DJ2C9Q3MnRtTix85bE2NzdC4nRECm
	mr+JzQLa2djmbl82tYwVUsh0KIgF4tNIcWFCcnD2lCsFSeyqfwCAac0KFs7iWZH6Fwdqm/b8oKU
	v8jBdRRTlkjuXFPXMjkV8kIhdfidoluatE/vTpPJOAIEuKw3GbWCrMrtEvOoWP1QDMQ==
X-Received: by 2002:a50:903c:: with SMTP id b57mr27265680eda.161.1548787821761;
        Tue, 29 Jan 2019 10:50:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4wLWVcS/8llm8P31KleUEd2+exS14mXQMuvzazJB8tv1hbAlFr10UvVZyEQe7oLRQln6pO
X-Received: by 2002:a50:903c:: with SMTP id b57mr27265611eda.161.1548787820554;
        Tue, 29 Jan 2019 10:50:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787820; cv=none;
        d=google.com; s=arc-20160816;
        b=RZd+YBSeZP5wGl/Y6c6akBXy9StCr4WXaij9LafSysmhblcDiRmPuBD94BXteM6BuQ
         8ENvjZGbxhqZypPG4N5nQg6BZnOrNIllXFqUE6OBWWjOlM3Vvsl3PnKpNcs307b9qX3S
         UJZCVnJBOeU8T0z/kEjfjRbuBuaCoW5Kl9PBgP4oHCKk9w7Z+jusjZ0PfQYNp67e/DEz
         oGqz7soB8D2So0psvguBRKvhPE4xr5RxbUaGDO2Qz+rEsWJ5+iSDsxADJrL2C8UuidNI
         /e1W5ljfTEbbPvWV+4Lsyo+n6k3pGMAg6jQNSs4OW6dyMTGSwXe3d+FCot6qDrff1rJl
         qhxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=J3ZEvjd6iSwqW9/Lj+HAFuc9FVXfG+8GlKLDC1orXuM=;
        b=qQ0fGkh37SgiHPeNCMAhn7pcm0EknXH7aycuOSjZEXtGxDepCZ2OyOKHqRVVYu8Feu
         OycCvwzhY7dxP/WoXPdNC8iL3Cz8ATaP/DMUPf/vx5BPUt0A5smrKGeb2RMP0QMEGmzo
         8cmvvfsSN96NNjGB2sfnqhp7IruWfuW+/FSzACxXhhKt33nnR1LyfZlwt8Wlj+5gbtQW
         WKm02Az+LZWjYC4zIQFTBdfRLtYjJL1dPdTZBznlrQAcPhOt1tMI7N01Qr4ueRyUNs7a
         JaNEJurJPs8UvhLF8GVBF7xxIIhTxiO/ExN4YtO+o+yQTOmZbRxzB0qEqVEzcQYIU8zr
         MKxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k1si854053ejv.2.2019.01.29.10.50.20
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:20 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8646515BF;
	Tue, 29 Jan 2019 10:50:19 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D8A3F3F557;
	Tue, 29 Jan 2019 10:50:16 -0800 (PST)
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
Subject: [PATCH v8 14/26] arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
Date: Tue, 29 Jan 2019 18:48:50 +0000
Message-Id: <20190129184902.102850-15-james.morse@arm.com>
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
in_nmi(). Add a helper to do the work and claim the notification.

When KVM or the arch code takes an exception that might be a RAS
notification, it asks the APEI firmware-first code whether it wants
to claim the exception. A future kernel-first mechanism may be queried
afterwards, and claim the notification, otherwise we fall through
to the existing default behaviour.

The NOTIFY_SEA code was merged before considering multiple, possibly
interacting, NMI-like notifications and the need to consider kernel
first in the future. Make the 'claiming' behaviour explicit.

Restructuring the APEI code to allow multiple NMI-like notifications
means any notification that might interrupt interrupts-masked
code must always be wrapped in nmi_enter()/nmi_exit(). This will
allow APEI to use in_nmi() to use the right fixmap entries.

Mask SError over this window to prevent an asynchronous RAS error
arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).

Signed-off-by: James Morse <james.morse@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>

---
Why does apei_claim_sea() take a pt_regs? This gets used later to take
APEI by the hand through NMI->IRQ context, depending on what we
interrupted.

Changes since v6:
 * Moved the voice of the commit message.
 * moved arch_local_save_flags() below the !IS_ENABLED drop-out
 * Moved the dummy declaration into the if-ACPI part of the header instead
   of if-APEI.

Changes since v4:
 * Made irqs-unmasked comment a lockdep assert.

Changes since v3:
 * Removed spurious whitespace change
 * Updated comment in acpi.c to cover SError masking

Changes since v2:
 * Added dummy definition for !ACPI and culled IS_ENABLED() checks.
---
 arch/arm64/include/asm/acpi.h      |  4 +++-
 arch/arm64/include/asm/daifflags.h |  1 +
 arch/arm64/include/asm/kvm_ras.h   | 16 ++++++++++++++-
 arch/arm64/kernel/acpi.c           | 31 ++++++++++++++++++++++++++++++
 arch/arm64/mm/fault.c              | 24 +++++------------------
 5 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 2def77ec14be..7628efbe6c12 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -18,6 +18,7 @@
 
 #include <asm/cputype.h>
 #include <asm/io.h>
+#include <asm/ptrace.h>
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
 
@@ -110,9 +111,10 @@ static inline u32 get_acpi_id_for_cpu(unsigned int cpu)
 
 static inline void arch_fix_phys_package_id(int num, u32 slot) { }
 void __init acpi_init_cpus(void);
-
+int apei_claim_sea(struct pt_regs *regs);
 #else
 static inline void acpi_init_cpus(void) { }
+static inline int apei_claim_sea(struct pt_regs *regs) { return -ENOENT; }
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ARM64_ACPI_PARKING_PROTOCOL
diff --git a/arch/arm64/include/asm/daifflags.h b/arch/arm64/include/asm/daifflags.h
index 8d91f2233135..fa90779fc752 100644
--- a/arch/arm64/include/asm/daifflags.h
+++ b/arch/arm64/include/asm/daifflags.h
@@ -20,6 +20,7 @@
 
 #define DAIF_PROCCTX		0
 #define DAIF_PROCCTX_NOIRQ	PSR_I_BIT
+#define DAIF_ERRCTX		(PSR_I_BIT | PSR_A_BIT)
 
 /* mask/save/unmask/restore all exceptions, including interrupts. */
 static inline void local_daif_mask(void)
diff --git a/arch/arm64/include/asm/kvm_ras.h b/arch/arm64/include/asm/kvm_ras.h
index 6096f0251812..8ac6ee77437c 100644
--- a/arch/arm64/include/asm/kvm_ras.h
+++ b/arch/arm64/include/asm/kvm_ras.h
@@ -4,8 +4,22 @@
 #ifndef __ARM64_KVM_RAS_H__
 #define __ARM64_KVM_RAS_H__
 
+#include <linux/acpi.h>
+#include <linux/errno.h>
 #include <linux/types.h>
 
-int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr);
+#include <asm/acpi.h>
+
+/*
+ * Was this synchronous external abort a RAS notification?
+ * Returns '0' for errors handled by some RAS subsystem, or -ENOENT.
+ */
+static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
+{
+	/* apei_claim_sea(NULL) expects to mask interrupts itself */
+	lockdep_assert_irqs_enabled();
+
+	return apei_claim_sea(NULL);
+}
 
 #endif /* __ARM64_KVM_RAS_H__ */
diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index 44e3c351e1ea..803f0494dd3e 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -27,8 +27,10 @@
 #include <linux/smp.h>
 #include <linux/serial_core.h>
 
+#include <acpi/ghes.h>
 #include <asm/cputype.h>
 #include <asm/cpu_ops.h>
+#include <asm/daifflags.h>
 #include <asm/pgtable.h>
 #include <asm/smp_plat.h>
 
@@ -256,3 +258,32 @@ pgprot_t __acpi_get_mem_attribute(phys_addr_t addr)
 		return __pgprot(PROT_NORMAL_NC);
 	return __pgprot(PROT_DEVICE_nGnRnE);
 }
+
+/*
+ * Claim Synchronous External Aborts as a firmware first notification.
+ *
+ * Used by KVM and the arch do_sea handler.
+ * @regs may be NULL when called from process context.
+ */
+int apei_claim_sea(struct pt_regs *regs)
+{
+	int err = -ENOENT;
+	unsigned long current_flags;
+
+	if (!IS_ENABLED(CONFIG_ACPI_APEI_GHES))
+		return err;
+
+	current_flags = arch_local_save_flags();
+
+	/*
+	 * SEA can interrupt SError, mask it and describe this as an NMI so
+	 * that APEI defers the handling.
+	 */
+	local_daif_restore(DAIF_ERRCTX);
+	nmi_enter();
+	err = ghes_notify_sea();
+	nmi_exit();
+	local_daif_restore(current_flags);
+
+	return err;
+}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index c76dc981e3fc..e1c84c2e1cab 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -18,6 +18,7 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 
+#include <linux/acpi.h>
 #include <linux/extable.h>
 #include <linux/signal.h>
 #include <linux/mm.h>
@@ -33,6 +34,7 @@
 #include <linux/preempt.h>
 #include <linux/hugetlb.h>
 
+#include <asm/acpi.h>
 #include <asm/bug.h>
 #include <asm/cmpxchg.h>
 #include <asm/cpufeature.h>
@@ -47,8 +49,6 @@
 #include <asm/tlbflush.h>
 #include <asm/traps.h>
 
-#include <acpi/ghes.h>
-
 struct fault_info {
 	int	(*fn)(unsigned long addr, unsigned int esr,
 		      struct pt_regs *regs);
@@ -643,19 +643,10 @@ static int do_sea(unsigned long addr, unsigned int esr, struct pt_regs *regs)
 	inf = esr_to_fault_info(esr);
 
 	/*
-	 * Synchronous aborts may interrupt code which had interrupts masked.
-	 * Before calling out into the wider kernel tell the interested
-	 * subsystems.
+	 * Return value ignored as we rely on signal merging.
+	 * Future patches will make this more robust.
 	 */
-	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA)) {
-		if (interrupts_enabled(regs))
-			nmi_enter();
-
-		ghes_notify_sea();
-
-		if (interrupts_enabled(regs))
-			nmi_exit();
-	}
+	apei_claim_sea(regs);
 
 	if (esr & ESR_ELx_FnV)
 		siaddr = NULL;
@@ -733,11 +724,6 @@ static const struct fault_info fault_info[] = {
 	{ do_bad,		SIGKILL, SI_KERNEL,	"unknown 63"			},
 };
 
-int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
-{
-	return ghes_notify_sea();
-}
-
 asmlinkage void __exception do_mem_abort(unsigned long addr, unsigned int esr,
 					 struct pt_regs *regs)
 {
-- 
2.20.1

