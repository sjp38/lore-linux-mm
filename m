Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1ED16B0266
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c82so7818770wme.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:08 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id u8si15462wmf.95.2017.12.18.11.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:07 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 12/18] kvm: x86: hook in kvmi_breakpoint_event()
Date: Mon, 18 Dec 2017 21:06:36 +0200
Message-Id: <20171218190642.7790-13-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Inform the guest introspection tool that a breakpoint instruction (INT3)
is being executed. These one-byte intructions are placed in the slack
space of various functions and used as notification for when the OS or
an application has reached a certain state or is trying to perform a
certain operation (like creating a process).

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/svm.c |  6 ++++++
 arch/x86/kvm/vmx.c | 15 +++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index f41e4d7008d7..8903e0c58609 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -18,6 +18,7 @@
 #define pr_fmt(fmt) "SVM: " fmt
 
 #include <linux/kvm_host.h>
+#include <linux/kvmi.h>
 
 #include "irq.h"
 #include "mmu.h"
@@ -45,6 +46,7 @@
 #include <asm/debugreg.h>
 #include <asm/kvm_para.h>
 #include <asm/irq_remapping.h>
+#include <asm/kvmi.h>
 
 #include <asm/virtext.h>
 #include "trace.h"
@@ -2194,6 +2196,10 @@ static int bp_interception(struct vcpu_svm *svm)
 {
 	struct kvm_run *kvm_run = svm->vcpu.run;
 
+	if (kvmi_breakpoint_event(&svm->vcpu,
+		svm->vmcb->save.cs.base + svm->vmcb->save.rip))
+		return 1;
+
 	kvm_run->exit_reason = KVM_EXIT_DEBUG;
 	kvm_run->debug.arch.pc = svm->vmcb->save.cs.base + svm->vmcb->save.rip;
 	kvm_run->debug.arch.exception = BP_VECTOR;
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index c03580abf9e8..fbdfa8507d4f 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -51,6 +51,7 @@
 #include <asm/apic.h>
 #include <asm/irq_remapping.h>
 #include <asm/mmu_context.h>
+#include <asm/kvmi.h>
 
 #include "trace.h"
 #include "pmu.h"
@@ -5904,7 +5905,7 @@ static int handle_exception(struct kvm_vcpu *vcpu)
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
 	struct kvm_run *kvm_run = vcpu->run;
 	u32 intr_info, ex_no, error_code;
-	unsigned long cr2, rip, dr6;
+	unsigned long cr2, dr6;
 	u32 vect_info;
 	enum emulation_result er;
 
@@ -5978,7 +5979,13 @@ static int handle_exception(struct kvm_vcpu *vcpu)
 		kvm_run->debug.arch.dr6 = dr6 | DR6_FIXED_1;
 		kvm_run->debug.arch.dr7 = vmcs_readl(GUEST_DR7);
 		/* fall through */
-	case BP_VECTOR:
+	case BP_VECTOR: {
+		unsigned long gva = vmcs_readl(GUEST_CS_BASE) +
+			kvm_rip_read(vcpu);
+
+		if (kvmi_breakpoint_event(vcpu, gva))
+			return 1;
+
 		/*
 		 * Update instruction length as we may reinject #BP from
 		 * user space while in guest debugging mode. Reading it for
@@ -5987,10 +5994,10 @@ static int handle_exception(struct kvm_vcpu *vcpu)
 		vmx->vcpu.arch.event_exit_inst_len =
 			vmcs_read32(VM_EXIT_INSTRUCTION_LEN);
 		kvm_run->exit_reason = KVM_EXIT_DEBUG;
-		rip = kvm_rip_read(vcpu);
-		kvm_run->debug.arch.pc = vmcs_readl(GUEST_CS_BASE) + rip;
+		kvm_run->debug.arch.pc = gva;
 		kvm_run->debug.arch.exception = ex_no;
 		break;
+	}
 	default:
 		kvm_run->exit_reason = KVM_EXIT_EXCEPTION;
 		kvm_run->ex.exception = ex_no;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
