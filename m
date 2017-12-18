Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE8026B026D
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:08 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y15so9900439wrc.6
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:08 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id 30si10116548wrl.427.2017.12.18.11.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:07:07 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 13/18] kvm: x86: hook in kvmi_descriptor_event()
Date: Mon, 18 Dec 2017 21:06:37 +0200
Message-Id: <20171218190642.7790-14-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>, =?UTF-8?q?Nicu=C8=99or=20C=C3=AE=C8=9Bu?= <ncitu@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

Inform the guest introspection tool that a system table pointer register
(GDTR, IDTR, LDTR, TR) has been accessed.

Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
---
 arch/x86/kvm/svm.c | 41 +++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/vmx.c | 27 +++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 8903e0c58609..3b4911205081 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -4109,6 +4109,39 @@ static int avic_unaccelerated_access_interception(struct vcpu_svm *svm)
 	return ret;
 }
 
+static int descriptor_access_interception(struct vcpu_svm *svm)
+{
+	struct kvm_vcpu *vcpu = &svm->vcpu;
+	struct vmcb_control_area *c = &svm->vmcb->control;
+
+	switch (c->exit_code) {
+	case SVM_EXIT_IDTR_READ:
+	case SVM_EXIT_IDTR_WRITE:
+		kvmi_descriptor_event(vcpu, c->exit_info_1, 0,
+			KVMI_DESC_IDTR, c->exit_code == SVM_EXIT_IDTR_WRITE);
+		break;
+	case SVM_EXIT_GDTR_READ:
+	case SVM_EXIT_GDTR_WRITE:
+		kvmi_descriptor_event(vcpu, c->exit_info_1, 0,
+			KVMI_DESC_GDTR, c->exit_code == SVM_EXIT_GDTR_WRITE);
+		break;
+	case SVM_EXIT_LDTR_READ:
+	case SVM_EXIT_LDTR_WRITE:
+		kvmi_descriptor_event(vcpu, c->exit_info_1, 0,
+			KVMI_DESC_LDTR, c->exit_code == SVM_EXIT_LDTR_WRITE);
+		break;
+	case SVM_EXIT_TR_READ:
+	case SVM_EXIT_TR_WRITE:
+		kvmi_descriptor_event(vcpu, c->exit_info_1, 0,
+			KVMI_DESC_TR, c->exit_code == SVM_EXIT_TR_WRITE);
+		break;
+	default:
+		break;
+	}
+
+	return 1;
+}
+
 static int (*const svm_exit_handlers[])(struct vcpu_svm *svm) = {
 	[SVM_EXIT_READ_CR0]			= cr_interception,
 	[SVM_EXIT_READ_CR3]			= cr_interception,
@@ -4173,6 +4206,14 @@ static int (*const svm_exit_handlers[])(struct vcpu_svm *svm) = {
 	[SVM_EXIT_RSM]                          = emulate_on_interception,
 	[SVM_EXIT_AVIC_INCOMPLETE_IPI]		= avic_incomplete_ipi_interception,
 	[SVM_EXIT_AVIC_UNACCELERATED_ACCESS]	= avic_unaccelerated_access_interception,
+	[SVM_EXIT_IDTR_READ]			= descriptor_access_interception,
+	[SVM_EXIT_GDTR_READ]			= descriptor_access_interception,
+	[SVM_EXIT_LDTR_READ]			= descriptor_access_interception,
+	[SVM_EXIT_TR_READ]			= descriptor_access_interception,
+	[SVM_EXIT_IDTR_WRITE]			= descriptor_access_interception,
+	[SVM_EXIT_GDTR_WRITE]			= descriptor_access_interception,
+	[SVM_EXIT_LDTR_WRITE]			= descriptor_access_interception,
+	[SVM_EXIT_TR_WRITE]			= descriptor_access_interception,
 };
 
 static void dump_vmcb(struct kvm_vcpu *vcpu)
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index fbdfa8507d4f..ab744f04ae90 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -8047,6 +8047,31 @@ static int handle_preemption_timer(struct kvm_vcpu *vcpu)
 	return 1;
 }
 
+static int handle_descriptor_access(struct kvm_vcpu *vcpu)
+{
+	struct vcpu_vmx *vmx = to_vmx(vcpu);
+	u32 exit_reason = vmx->exit_reason;
+	unsigned long exit_qualification = vmcs_readl(EXIT_QUALIFICATION);
+	u32 vmx_instruction_info = vmcs_read32(VMX_INSTRUCTION_INFO);
+	unsigned char store = (vmx_instruction_info >> 29) & 0x1;
+	unsigned char descriptor = 0;
+
+	if (exit_reason == EXIT_REASON_GDTR_IDTR) {
+		if ((vmx_instruction_info >> 28) & 0x1)
+			descriptor = KVMI_DESC_IDTR;
+		else
+			descriptor = KVMI_DESC_GDTR;
+	} else {
+		if ((vmx_instruction_info >> 28) & 0x1)
+			descriptor = KVMI_DESC_TR;
+		else
+			descriptor = KVMI_DESC_LDTR;
+	}
+
+	return kvmi_descriptor_event(vcpu, vmx_instruction_info,
+				     exit_qualification, descriptor, store);
+}
+
 static bool valid_ept_address(struct kvm_vcpu *vcpu, u64 address)
 {
 	struct vcpu_vmx *vmx = to_vmx(vcpu);
@@ -8219,6 +8244,8 @@ static int (*const kvm_vmx_exit_handlers[])(struct kvm_vcpu *vcpu) = {
 	[EXIT_REASON_PML_FULL]		      = handle_pml_full,
 	[EXIT_REASON_VMFUNC]                  = handle_vmfunc,
 	[EXIT_REASON_PREEMPTION_TIMER]	      = handle_preemption_timer,
+	[EXIT_REASON_GDTR_IDTR]               = handle_descriptor_access,
+	[EXIT_REASON_LDTR_TR]                 = handle_descriptor_access,
 };
 
 static const int kvm_vmx_max_exit_handlers =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
