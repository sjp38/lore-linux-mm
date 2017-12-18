Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9358A6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:06:59 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j4so9947070wrg.15
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:06:59 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id a126si13421wme.124.2017.12.18.11.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:06:58 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 03/18] kvm: x86: add kvm_arch_msr_intercept()
Date: Mon, 18 Dec 2017 21:06:27 +0200
Message-Id: <20171218190642.7790-4-alazar@bitdefender.com>
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

This function is used by the introspection subsytem to enable/disable
MSR register interception.

The patch adds back the __vmx_enable_intercept_for_msr() function
removed with the commit 40d8338d095e
("KVM: VMX: remove functions that enable msr intercepts").

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/include/asm/kvm_host.h |  4 ++++
 arch/x86/kvm/svm.c              | 11 +++++++++
 arch/x86/kvm/vmx.c              | 53 +++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c              |  7 ++++++
 4 files changed, 75 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 516798431328..8842d8e1e4ee 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1079,6 +1079,8 @@ struct kvm_x86_ops {
 	int (*pre_enter_smm)(struct kvm_vcpu *vcpu, char *smstate);
 	int (*pre_leave_smm)(struct kvm_vcpu *vcpu, u64 smbase);
 	int (*enable_smi_window)(struct kvm_vcpu *vcpu);
+
+	void (*msr_intercept)(struct kvm_vcpu *vcpu, unsigned int msr, bool enable);
 };
 
 struct kvm_arch_async_pf {
@@ -1451,4 +1453,6 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
 void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
 		unsigned long start, unsigned long end);
 
+void kvm_arch_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
+				bool enable);
 #endif /* _ASM_X86_KVM_HOST_H */
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index eb714f1cdf7e..5f7482851223 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5505,6 +5505,15 @@ static int enable_smi_window(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
+static void svm_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
+				bool enable)
+{
+	struct vcpu_svm *svm = to_svm(vcpu);
+	u32 *msrpm = svm->msrpm;
+
+	set_msr_interception(msrpm, msr, enable, enable);
+}
+
 static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = has_svm,
 	.disabled_by_bios = is_disabled,
@@ -5620,6 +5629,8 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.pre_enter_smm = svm_pre_enter_smm,
 	.pre_leave_smm = svm_pre_leave_smm,
 	.enable_smi_window = enable_smi_window,
+
+	.msr_intercept = svm_msr_intercept,
 };
 
 static int __init svm_init(void)
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 8eba631c4dbd..9c984bbe263e 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -12069,6 +12069,57 @@ static int enable_smi_window(struct kvm_vcpu *vcpu)
 	return 0;
 }
 
+static void __vmx_enable_intercept_for_msr(unsigned long *msr_bitmap,
+						u32 msr, int type)
+{
+	int f = sizeof(unsigned long);
+
+	if (!cpu_has_vmx_msr_bitmap())
+		return;
+
+	/*
+	 * See Intel PRM Vol. 3, 24.6.9 (MSR-Bitmap Address). Early manuals
+	 * have the write-low and read-high bitmap offsets the wrong way round.
+	 * We can control MSRs 0x00000000-0x00001fff and 0xc0000000-0xc0001fff.
+	 */
+	if (msr <= 0x1fff) {
+		if (type & MSR_TYPE_R)
+			/* read-low */
+			__set_bit(msr, msr_bitmap + 0x000 / f);
+
+		if (type & MSR_TYPE_W)
+			/* write-low */
+			__set_bit(msr, msr_bitmap + 0x800 / f);
+
+	} else if ((msr >= 0xc0000000) && (msr <= 0xc0001fff)) {
+		msr &= 0x1fff;
+		if (type & MSR_TYPE_R)
+			/* read-high */
+			__set_bit(msr, msr_bitmap + 0x400 / f);
+
+		if (type & MSR_TYPE_W)
+			/* write-high */
+			__set_bit(msr, msr_bitmap + 0xc00 / f);
+
+	}
+}
+
+static void vmx_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
+				bool enabled)
+{
+	if (enabled) {
+		__vmx_enable_intercept_for_msr(vmx_msr_bitmap_longmode, msr,
+					       MSR_TYPE_W);
+		__vmx_enable_intercept_for_msr(vmx_msr_bitmap_legacy, msr,
+					       MSR_TYPE_W);
+	} else {
+		__vmx_disable_intercept_for_msr(vmx_msr_bitmap_legacy, msr,
+						MSR_TYPE_W);
+		__vmx_disable_intercept_for_msr(vmx_msr_bitmap_longmode, msr,
+						MSR_TYPE_W);
+	}
+}
+
 static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = cpu_has_kvm_support,
 	.disabled_by_bios = vmx_disabled_by_bios,
@@ -12199,6 +12250,8 @@ static struct kvm_x86_ops vmx_x86_ops __ro_after_init = {
 	.pre_enter_smm = vmx_pre_enter_smm,
 	.pre_leave_smm = vmx_pre_leave_smm,
 	.enable_smi_window = enable_smi_window,
+
+	.msr_intercept = vmx_msr_intercept,
 };
 
 static int __init vmx_init(void)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 1cec2c62a0b0..e1a3c2c6ec08 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8871,6 +8871,13 @@ bool kvm_vector_hashing_enabled(void)
 }
 EXPORT_SYMBOL_GPL(kvm_vector_hashing_enabled);
 
+void kvm_arch_msr_intercept(struct kvm_vcpu *vcpu, unsigned int msr,
+				bool enable)
+{
+	kvm_x86_ops->msr_intercept(vcpu, msr, enable);
+}
+EXPORT_SYMBOL_GPL(kvm_arch_msr_intercept);
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_exit);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_fast_mmio);
 EXPORT_TRACEPOINT_SYMBOL_GPL(kvm_inj_virq);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
