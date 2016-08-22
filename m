Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB226B0264
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:24:05 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i144so32031867oib.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:24:05 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0040.outbound.protection.outlook.com. [104.47.38.40])
        by mx.google.com with ESMTPS id s187si132072ois.291.2016.08.22.16.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:24:05 -0700 (PDT)
Subject: [RFC PATCH v1 02/28] kvm: svm: Add kvm_fast_pio_in support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:23:54 -0400
Message-ID: <147190823395.9523.16184607551630730040.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Update the I/O interception support to add the kvm_fast_pio_in function
to speed up the in instruction similar to the out instruction.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/kvm/svm.c              |    5 +++--
 arch/x86/kvm/x86.c              |   43 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 3f05d36..c38f878 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1133,6 +1133,7 @@ int kvm_set_msr(struct kvm_vcpu *vcpu, struct msr_data *msr);
 struct x86_emulate_ctxt;
 
 int kvm_fast_pio_out(struct kvm_vcpu *vcpu, int size, unsigned short port);
+int kvm_fast_pio_in(struct kvm_vcpu *vcpu, int size, unsigned short port);
 void kvm_emulate_cpuid(struct kvm_vcpu *vcpu);
 int kvm_emulate_halt(struct kvm_vcpu *vcpu);
 int kvm_vcpu_halt(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index d8b9c8c..fd5a9a8 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -2131,7 +2131,7 @@ static int io_interception(struct vcpu_svm *svm)
 	++svm->vcpu.stat.io_exits;
 	string = (io_info & SVM_IOIO_STR_MASK) != 0;
 	in = (io_info & SVM_IOIO_TYPE_MASK) != 0;
-	if (string || in)
+	if (string)
 		return emulate_instruction(vcpu, 0) == EMULATE_DONE;
 
 	port = io_info >> 16;
@@ -2139,7 +2139,8 @@ static int io_interception(struct vcpu_svm *svm)
 	svm->next_rip = svm->vmcb->control.exit_info_2;
 	skip_emulated_instruction(&svm->vcpu);
 
-	return kvm_fast_pio_out(vcpu, size, port);
+	return in ? kvm_fast_pio_in(vcpu, size, port)
+		  : kvm_fast_pio_out(vcpu, size, port);
 }
 
 static int nmi_interception(struct vcpu_svm *svm)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index d432894..78295b0 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5579,6 +5579,49 @@ int kvm_fast_pio_out(struct kvm_vcpu *vcpu, int size, unsigned short port)
 }
 EXPORT_SYMBOL_GPL(kvm_fast_pio_out);
 
+static int complete_fast_pio_in(struct kvm_vcpu *vcpu)
+{
+	unsigned long val;
+
+	/* We should only ever be called with arch.pio.count equal to 1 */
+	BUG_ON(vcpu->arch.pio.count != 1);
+
+	/* For size less than 4 we merge, else we zero extend */
+	val = (vcpu->arch.pio.size < 4) ? kvm_register_read(vcpu, VCPU_REGS_RAX)
+					: 0;
+
+	/*
+	 * Since vcpu->arch.pio.count == 1 let emulator_pio_in_emulated perform
+	 * the copy and tracing
+	 */
+	emulator_pio_in_emulated(&vcpu->arch.emulate_ctxt, vcpu->arch.pio.size,
+				 vcpu->arch.pio.port, &val, 1);
+	kvm_register_write(vcpu, VCPU_REGS_RAX, val);
+
+	return 1;
+}
+
+int kvm_fast_pio_in(struct kvm_vcpu *vcpu, int size, unsigned short port)
+{
+	unsigned long val;
+	int ret;
+
+	/* For size less than 4 we merge, else we zero extend */
+	val = (size < 4) ? kvm_register_read(vcpu, VCPU_REGS_RAX) : 0;
+
+	ret = emulator_pio_in_emulated(&vcpu->arch.emulate_ctxt, size, port,
+				       &val, 1);
+	if (ret) {
+		kvm_register_write(vcpu, VCPU_REGS_RAX, val);
+		return ret;
+	}
+
+	vcpu->arch.complete_userspace_io = complete_fast_pio_in;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(kvm_fast_pio_in);
+
 static int kvmclock_cpu_down_prep(unsigned int cpu)
 {
 	__this_cpu_write(cpu_tsc_khz, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
