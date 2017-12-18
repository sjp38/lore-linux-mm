Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DABA86B025E
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:00 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j4so9947091wrg.15
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:00 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id m64si18082wmc.77.2017.12.18.11.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:06:59 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 05/18] kvm: x86: add kvm_arch_vcpu_set_regs()
Date: Mon, 18 Dec 2017 21:06:29 +0200
Message-Id: <20171218190642.7790-6-alazar@bitdefender.com>
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

This is a version of kvm_arch_vcpu_ioctl_set_regs() which does not touch
the exceptions vector.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
---
 arch/x86/kvm/x86.c       | 34 ++++++++++++++++++++++++++++++++++
 include/linux/kvm_host.h |  1 +
 2 files changed, 35 insertions(+)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e1a3c2c6ec08..4b0c3692386d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7389,6 +7389,40 @@ int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
 	return 0;
 }
 
+/*
+ * Similar to kvm_arch_vcpu_ioctl_set_regs() but it does not reset
+ * the exceptions
+ */
+void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs)
+{
+	vcpu->arch.emulate_regs_need_sync_from_vcpu = true;
+	vcpu->arch.emulate_regs_need_sync_to_vcpu = false;
+
+	kvm_register_write(vcpu, VCPU_REGS_RAX, regs->rax);
+	kvm_register_write(vcpu, VCPU_REGS_RBX, regs->rbx);
+	kvm_register_write(vcpu, VCPU_REGS_RCX, regs->rcx);
+	kvm_register_write(vcpu, VCPU_REGS_RDX, regs->rdx);
+	kvm_register_write(vcpu, VCPU_REGS_RSI, regs->rsi);
+	kvm_register_write(vcpu, VCPU_REGS_RDI, regs->rdi);
+	kvm_register_write(vcpu, VCPU_REGS_RSP, regs->rsp);
+	kvm_register_write(vcpu, VCPU_REGS_RBP, regs->rbp);
+#ifdef CONFIG_X86_64
+	kvm_register_write(vcpu, VCPU_REGS_R8, regs->r8);
+	kvm_register_write(vcpu, VCPU_REGS_R9, regs->r9);
+	kvm_register_write(vcpu, VCPU_REGS_R10, regs->r10);
+	kvm_register_write(vcpu, VCPU_REGS_R11, regs->r11);
+	kvm_register_write(vcpu, VCPU_REGS_R12, regs->r12);
+	kvm_register_write(vcpu, VCPU_REGS_R13, regs->r13);
+	kvm_register_write(vcpu, VCPU_REGS_R14, regs->r14);
+	kvm_register_write(vcpu, VCPU_REGS_R15, regs->r15);
+#endif
+
+	kvm_rip_write(vcpu, regs->rip);
+	kvm_set_rflags(vcpu, regs->rflags);
+
+	kvm_make_request(KVM_REQ_EVENT, vcpu);
+}
+
 void kvm_get_cs_db_l_bits(struct kvm_vcpu *vcpu, int *db, int *l)
 {
 	struct kvm_segment cs;
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 6bdd4b9f6611..68e4d756f5c9 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -767,6 +767,7 @@ int kvm_arch_vcpu_ioctl_translate(struct kvm_vcpu *vcpu,
 
 int kvm_arch_vcpu_ioctl_get_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
 int kvm_arch_vcpu_ioctl_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
+void kvm_arch_vcpu_set_regs(struct kvm_vcpu *vcpu, struct kvm_regs *regs);
 int kvm_arch_vcpu_ioctl_get_sregs(struct kvm_vcpu *vcpu,
 				  struct kvm_sregs *sregs);
 int kvm_arch_vcpu_ioctl_set_sregs(struct kvm_vcpu *vcpu,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
