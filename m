Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBF226B03AF
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:17:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 6so85326242pfd.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:17:19 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0066.outbound.protection.outlook.com. [104.47.34.66])
        by mx.google.com with ESMTPS id c21si7685475pgi.128.2017.03.02.07.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:17:18 -0800 (PST)
Subject: [RFC PATCH v2 23/32] kvm: introduce KVM_MEMORY_ENCRYPT_OP ioctl
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:17:11 -0500
Message-ID: <148846783136.2349.9362218518503742320.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

If hardware supports encrypting then KVM_MEMORY_ENCRYPT_OP ioctl can
be used by qemu to issue platform specific memory encryption commands.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    2 ++
 arch/x86/kvm/x86.c              |   12 ++++++++++++
 include/uapi/linux/kvm.h        |    2 ++
 3 files changed, 16 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index bff1f15..62651ad 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1033,6 +1033,8 @@ struct kvm_x86_ops {
 	void (*cancel_hv_timer)(struct kvm_vcpu *vcpu);
 
 	void (*setup_mce)(struct kvm_vcpu *vcpu);
+
+	int (*memory_encryption_op)(struct kvm *kvm, void __user *argp);
 };
 
 struct kvm_arch_async_pf {
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 2099df8..6a737e9 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -3926,6 +3926,14 @@ static int kvm_vm_ioctl_enable_cap(struct kvm *kvm,
 	return r;
 }
 
+static int kvm_vm_ioctl_memory_encryption_op(struct kvm *kvm, void __user *argp)
+{
+	if (kvm_x86_ops->memory_encryption_op)
+		return kvm_x86_ops->memory_encryption_op(kvm, argp);
+
+	return -ENOTTY;
+}
+
 long kvm_arch_vm_ioctl(struct file *filp,
 		       unsigned int ioctl, unsigned long arg)
 {
@@ -4189,6 +4197,10 @@ long kvm_arch_vm_ioctl(struct file *filp,
 		r = kvm_vm_ioctl_enable_cap(kvm, &cap);
 		break;
 	}
+	case KVM_MEMORY_ENCRYPT_OP: {
+		r = kvm_vm_ioctl_memory_encryption_op(kvm, argp);
+		break;
+	}
 	default:
 		r = kvm_vm_ioctl_assigned_device(kvm, ioctl, arg);
 	}
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index cac48ed..fef7d83 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -1281,6 +1281,8 @@ struct kvm_s390_ucas_mapping {
 #define KVM_S390_GET_IRQ_STATE	  _IOW(KVMIO, 0xb6, struct kvm_s390_irq_state)
 /* Available with KVM_CAP_X86_SMM */
 #define KVM_SMI                   _IO(KVMIO,   0xb7)
+/* Memory Encryption Commands */
+#define KVM_MEMORY_ENCRYPT_OP	  _IOWR(KVMIO, 0xb8, unsigned long)
 
 #define KVM_DEV_ASSIGN_ENABLE_IOMMU	(1 << 0)
 #define KVM_DEV_ASSIGN_PCI_2_3		(1 << 1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
