Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 455CA6B0036
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:59 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 10 Jun 2013 12:59:46 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 90AAC2190023
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:07:13 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5AC3iqW34865206
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 12:03:44 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5AC3sSW012988
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:54 -0400
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 4/4] PF: Intial async page fault support on s390x
Date: Mon, 10 Jun 2013 14:03:48 +0200
Message-Id: <1370865828-2053-5-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

This patch adds the handling for async page faults to s390x code.
It provides the userspace API to enable, disable or get the
status of this feature.
Also it includes the diagnose code, called by the guest, to enable
async page faults by pfault or disable them.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/kvm_host.h | 22 ++++++++++
 arch/s390/include/uapi/asm/kvm.h | 10 +++++
 arch/s390/kvm/Kconfig            |  1 +
 arch/s390/kvm/Makefile           |  2 +-
 arch/s390/kvm/diag.c             | 46 ++++++++++++++++++++
 arch/s390/kvm/interrupt.c        | 40 ++++++++++++++----
 arch/s390/kvm/kvm-s390.c         | 90 +++++++++++++++++++++++++++++++++++++++-
 arch/s390/kvm/kvm-s390.h         |  4 ++
 include/uapi/linux/kvm.h         |  2 +
 9 files changed, 207 insertions(+), 10 deletions(-)

diff --git a/arch/s390/include/asm/kvm_host.h b/arch/s390/include/asm/kvm_host.h
index e014bba..18b5492 100644
--- a/arch/s390/include/asm/kvm_host.h
+++ b/arch/s390/include/asm/kvm_host.h
@@ -260,6 +260,10 @@ struct kvm_vcpu_arch {
 		u64		stidp_data;
 	};
 	struct gmap *gmap;
+#define KVM_S390_PFAULT_TOKEN_INVALID (-1UL)
+	unsigned long pfault_token;
+	unsigned long pfault_select;
+	unsigned long pfault_compare;
 };
 
 struct kvm_vm_stat {
@@ -280,6 +284,24 @@ struct kvm_arch{
 #define KVM_HVA_ERR_BAD		(-1UL)
 #define KVM_HVA_ERR_RO_BAD	(-1UL)
 
+#define ASYNC_PF_PER_VCPU	64
+struct kvm_vcpu;
+struct kvm_async_pf;
+struct kvm_arch_async_pf {
+	unsigned long pfault_token;
+};
+
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu);
+
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work);
+
+void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
+				     struct kvm_async_pf *work);
+
+void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
+				 struct kvm_async_pf *work);
+
 static inline bool kvm_is_error_hva(unsigned long addr)
 {
 	/*
diff --git a/arch/s390/include/uapi/asm/kvm.h b/arch/s390/include/uapi/asm/kvm.h
index d25da59..b995abe 100644
--- a/arch/s390/include/uapi/asm/kvm.h
+++ b/arch/s390/include/uapi/asm/kvm.h
@@ -57,4 +57,14 @@ struct kvm_sync_regs {
 #define KVM_REG_S390_EPOCHDIFF	(KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x2)
 #define KVM_REG_S390_CPU_TIMER  (KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x3)
 #define KVM_REG_S390_CLOCK_COMP (KVM_REG_S390 | KVM_REG_SIZE_U64 | 0x4)
+
+/* ioctls used by userspace for setting/getting status of APF on s390x */
+#define KVM_S390_APF_ENABLE	1
+#define KVM_S390_APF_DISABLE	2
+#define KVM_S390_APF_STATUS	3
+#define KVM_S390_APF_DISABLED_NON_PENDING	0
+#define KVM_S390_APF_DISABLED_PENDING		1
+#define KVM_S390_APF_ENABLED_NON_PENDING	2
+#define KVM_S390_APF_ENABLED_PENDING		3
+
 #endif
diff --git a/arch/s390/kvm/Kconfig b/arch/s390/kvm/Kconfig
index 60f9f8a..67f154e 100644
--- a/arch/s390/kvm/Kconfig
+++ b/arch/s390/kvm/Kconfig
@@ -22,6 +22,7 @@ config KVM
 	select PREEMPT_NOTIFIERS
 	select ANON_INODES
 	select HAVE_KVM_CPU_RELAX_INTERCEPT
+	select KVM_ASYNC_PF
 	---help---
 	  Support hosting paravirtualized guest machines using the SIE
 	  virtualization capability on the mainframe. This should work
diff --git a/arch/s390/kvm/Makefile b/arch/s390/kvm/Makefile
index 3975722..5bcea24 100644
--- a/arch/s390/kvm/Makefile
+++ b/arch/s390/kvm/Makefile
@@ -6,7 +6,7 @@
 # it under the terms of the GNU General Public License (version 2 only)
 # as published by the Free Software Foundation.
 
-common-objs = $(addprefix ../../../virt/kvm/, kvm_main.o)
+common-objs = $(addprefix ../../../virt/kvm/, kvm_main.o async_pf.o)
 
 ccflags-y := -Ivirt/kvm -Iarch/s390/kvm
 
diff --git a/arch/s390/kvm/diag.c b/arch/s390/kvm/diag.c
index 744cd9c..2c56824 100644
--- a/arch/s390/kvm/diag.c
+++ b/arch/s390/kvm/diag.c
@@ -17,6 +17,7 @@
 #include "kvm-s390.h"
 #include "trace.h"
 #include "trace-s390.h"
+#include "gaccess.h"
 
 static int diag_release_pages(struct kvm_vcpu *vcpu)
 {
@@ -107,6 +108,49 @@ static int __diag_ipl_functions(struct kvm_vcpu *vcpu)
 	return -EREMOTE;
 }
 
+static int __diag_page_ref_service(struct kvm_vcpu *vcpu)
+{
+	struct prs_parm {
+		u16 code;
+		u16 subcode;
+		u16 parm_len;
+		u16 parm_version;
+		u64 token_addr;
+		u64 select_mask;
+		u64 compare_mask;
+		u64 zarch;
+	};
+	struct prs_parm parm;
+	int rc;
+	u16 rx = (vcpu->arch.sie_block->ipa & 0xf0) >> 4;
+	u16 ry = (vcpu->arch.sie_block->ipa & 0x0f);
+	if (copy_from_guest_absolute(vcpu, &parm, vcpu->run->s.regs.gprs[rx],
+				     sizeof(parm)))
+		return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
+
+	if (parm.parm_version != 2)
+		return 0;
+
+	switch (parm.subcode) {
+	case 0: /* TOKEN */
+		vcpu->arch.pfault_token = parm.token_addr;
+		vcpu->arch.pfault_select = parm.select_mask;
+		vcpu->arch.pfault_compare = parm.compare_mask;
+		vcpu->run->s.regs.gprs[ry] = 0;
+		rc = 0;
+		break;
+	case 1: /* CANCEL */
+		vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
+		vcpu->run->s.regs.gprs[ry] = 0;
+		rc = 0;
+		break;
+	default:
+		rc = -EOPNOTSUPP;
+		break;
+	}
+	return rc;
+}
+
 int kvm_s390_handle_diag(struct kvm_vcpu *vcpu)
 {
 	int code = (vcpu->arch.sie_block->ipb & 0xfff0000) >> 16;
@@ -119,6 +163,8 @@ int kvm_s390_handle_diag(struct kvm_vcpu *vcpu)
 		return __diag_time_slice_end(vcpu);
 	case 0x9c:
 		return __diag_time_slice_end_directed(vcpu);
+	case 0x258:
+		return __diag_page_ref_service(vcpu);
 	case 0x308:
 		return __diag_ipl_functions(vcpu);
 	default:
diff --git a/arch/s390/kvm/interrupt.c b/arch/s390/kvm/interrupt.c
index 7f35cb3..9d6a9a3 100644
--- a/arch/s390/kvm/interrupt.c
+++ b/arch/s390/kvm/interrupt.c
@@ -31,7 +31,7 @@ static int is_ioint(u64 type)
 	return ((type & 0xfffe0000u) != 0xfffe0000u);
 }
 
-static int psw_extint_disabled(struct kvm_vcpu *vcpu)
+int psw_extint_disabled(struct kvm_vcpu *vcpu)
 {
 	return !(vcpu->arch.sie_block->gpsw.mask & PSW_MASK_EXT);
 }
@@ -78,11 +78,8 @@ static int __interrupt_is_deliverable(struct kvm_vcpu *vcpu,
 			return 1;
 		return 0;
 	case KVM_S390_INT_SERVICE:
-		if (psw_extint_disabled(vcpu))
-			return 0;
-		if (vcpu->arch.sie_block->gcr[0] & 0x200ul)
-			return 1;
-		return 0;
+	case KVM_S390_INT_PFAULT_INIT:
+	case KVM_S390_INT_PFAULT_DONE:
 	case KVM_S390_INT_VIRTIO:
 		if (psw_extint_disabled(vcpu))
 			return 0;
@@ -150,6 +147,8 @@ static void __set_intercept_indicator(struct kvm_vcpu *vcpu,
 	case KVM_S390_INT_EXTERNAL_CALL:
 	case KVM_S390_INT_EMERGENCY:
 	case KVM_S390_INT_SERVICE:
+	case KVM_S390_INT_PFAULT_INIT:
+	case KVM_S390_INT_PFAULT_DONE:
 	case KVM_S390_INT_VIRTIO:
 		if (psw_extint_disabled(vcpu))
 			__set_cpuflag(vcpu, CPUSTAT_EXT_INT);
@@ -223,6 +222,28 @@ static void __do_deliver_interrupt(struct kvm_vcpu *vcpu,
 		rc |= put_guest(vcpu, inti->ext.ext_params,
 				(u32 __user *)__LC_EXT_PARAMS);
 		break;
+	case KVM_S390_INT_PFAULT_INIT:
+		/* TODO add event, stat and trace */
+		rc  = put_guest(vcpu, 0x2603, (u16 __user *)__LC_EXT_INT_CODE);
+		rc |= put_guest(vcpu, 0x0600, (u16 __user *)__LC_EXT_CPU_ADDR);
+		rc |= copy_to_guest(vcpu, __LC_EXT_OLD_PSW,
+				    &vcpu->arch.sie_block->gpsw, sizeof(psw_t));
+		rc |= copy_from_guest(vcpu, &vcpu->arch.sie_block->gpsw,
+				      __LC_EXT_NEW_PSW, sizeof(psw_t));
+		rc |= put_guest(vcpu, inti->ext.ext_params2,
+				(u64 __user *)__LC_EXT_PARAMS2);
+		break;
+	case KVM_S390_INT_PFAULT_DONE:
+		/* TODO add event, stat and trace */
+		rc  = put_guest(vcpu, 0x2603, (u16 __user *)__LC_EXT_INT_CODE);
+		rc |= put_guest(vcpu, 0x0680, (u16 __user *)__LC_EXT_CPU_ADDR);
+		rc |= copy_to_guest(vcpu, __LC_EXT_OLD_PSW,
+				    &vcpu->arch.sie_block->gpsw, sizeof(psw_t));
+		rc |= copy_from_guest(vcpu, &vcpu->arch.sie_block->gpsw,
+				      __LC_EXT_NEW_PSW, sizeof(psw_t));
+		rc |= put_guest(vcpu, inti->ext.ext_params2,
+				(u64 __user *)__LC_EXT_PARAMS2);
+		break;
 	case KVM_S390_INT_VIRTIO:
 		VCPU_EVENT(vcpu, 4, "interrupt: virtio parm:%x,parm64:%llx",
 			   inti->ext.ext_params, inti->ext.ext_params2);
@@ -357,7 +378,7 @@ static int __try_deliver_ckc_interrupt(struct kvm_vcpu *vcpu)
 	return 1;
 }
 
-static int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu)
+int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu)
 {
 	struct kvm_s390_local_interrupt *li = &vcpu->arch.local_int;
 	struct kvm_s390_float_interrupt *fi = vcpu->arch.local_int.float_int;
@@ -811,6 +832,11 @@ int kvm_s390_inject_vcpu(struct kvm_vcpu *vcpu,
 		inti->type = s390int->type;
 		inti->mchk.mcic = s390int->parm64;
 		break;
+	case KVM_S390_INT_PFAULT_INIT:
+	case KVM_S390_INT_PFAULT_DONE:
+		inti->type = s390int->type;
+		inti->ext.ext_params2 = s390int->parm64;
+		break;
 	case KVM_S390_INT_VIRTIO:
 	case KVM_S390_INT_SERVICE:
 	case KVM_S390_INT_IO_MIN...KVM_S390_INT_IO_MAX:
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index c2ae2c4..72b4dbe 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/compiler.h>
+#include <linux/mmu_context.h>
 #include <linux/err.h>
 #include <linux/fs.h>
 #include <linux/hrtimer.h>
@@ -146,6 +147,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 #ifdef CONFIG_KVM_S390_UCONTROL
 	case KVM_CAP_S390_UCONTROL:
 #endif
+	case KVM_CAP_ASYNC_PF:
 	case KVM_CAP_SYNC_REGS:
 	case KVM_CAP_ONE_REG:
 	case KVM_CAP_ENABLE_CAP:
@@ -195,6 +197,31 @@ long kvm_arch_vm_ioctl(struct file *filp,
 		r = kvm_s390_inject_vm(kvm, &s390int);
 		break;
 	}
+	case KVM_S390_APF_ENABLE:
+		set_bit(PFAULT_EN, &current->thread.gmap_pfault);
+		r = 0;
+		break;
+	case KVM_S390_APF_DISABLE:
+		clear_bit(PFAULT_EN, &current->thread.gmap_pfault);
+		r = 0;
+		break;
+	case KVM_S390_APF_STATUS: {
+		bool pfaults_pending = false;
+		unsigned int i;
+		struct kvm_vcpu *vcpu;
+		r = 0;
+		if (test_bit(PFAULT_EN, &current->thread.gmap_pfault))
+			r += 2;
+
+		kvm_for_each_vcpu(i, vcpu, kvm) {
+			spin_lock(&vcpu->async_pf.lock);
+			if (vcpu->async_pf.queued > 0)
+				pfaults_pending = true;
+		}
+		if (pfaults_pending)
+			r += 1;
+		break;
+	}
 	default:
 		r = -ENOTTY;
 	}
@@ -264,6 +291,7 @@ void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
 	VCPU_EVENT(vcpu, 3, "%s", "free cpu");
 	trace_kvm_s390_destroy_vcpu(vcpu->vcpu_id);
+	kvm_clear_async_pf_completion_queue(vcpu);
 	if (!kvm_is_ucontrol(vcpu->kvm)) {
 		clear_bit(63 - vcpu->vcpu_id,
 			  (unsigned long *) &vcpu->kvm->arch.sca->mcn);
@@ -317,6 +345,9 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
 /* Section: vcpu related */
 int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
 {
+	vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
+	kvm_clear_async_pf_completion_queue(vcpu);
+	kvm_async_pf_wakeup_all(vcpu);
 	if (kvm_is_ucontrol(vcpu->kvm)) {
 		vcpu->arch.gmap = gmap_alloc(current->mm);
 		if (!vcpu->arch.gmap)
@@ -711,12 +742,66 @@ static void kvm_arch_fault_in_sync(struct kvm_vcpu *vcpu)
 	hva_t fault_addr;
 	/* TODO let current->thread.gmap_pfault indicate read or write fault */
 	struct mm_struct *mm = current->mm;
+	fault_addr = gmap_fault(current->thread.gmap_addr, vcpu->arch.gmap);
 	down_read(&mm->mmap_sem);
-	fault_addr = __gmap_fault(current->thread.gmap_addr, vcpu->arch.gmap);
 	get_user_pages(current, mm, fault_addr, 1, 1, 0, NULL, NULL);
 	up_read(&mm->mmap_sem);
 }
 
+static void __kvm_inject_pfault_token(struct kvm_vcpu *vcpu, bool is_init,
+				      unsigned long token)
+{
+	struct kvm_s390_interrupt inti;
+	inti.type = is_init ? KVM_S390_INT_PFAULT_INIT :
+			       KVM_S390_INT_PFAULT_DONE;
+	inti.parm64 = token;
+	if (kvm_s390_inject_vcpu(vcpu, &inti))
+		WARN(1, "pfault interrupt injection failed");
+}
+
+void kvm_arch_async_page_not_present(struct kvm_vcpu *vcpu,
+				     struct kvm_async_pf *work)
+{
+	__kvm_inject_pfault_token(vcpu, true, work->arch.pfault_token);
+}
+
+void kvm_arch_async_page_present(struct kvm_vcpu *vcpu,
+				 struct kvm_async_pf *work)
+{
+	__kvm_inject_pfault_token(vcpu, false, work->arch.pfault_token);
+}
+
+void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu,
+			       struct kvm_async_pf *work)
+{
+	return; /* s390x will always inject the page directly */
+}
+
+bool kvm_arch_can_inject_async_page_present(struct kvm_vcpu *vcpu)
+{
+	return false; /* s390x will always inject the page directly */
+}
+
+static int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu)
+{
+	hva_t hva = gmap_fault(current->thread.gmap_addr, vcpu->arch.gmap);
+	struct kvm_arch_async_pf arch;
+	unsigned long pfault_token;
+
+	if (vcpu->arch.pfault_token == KVM_S390_PFAULT_TOKEN_INVALID)
+		return 0;
+	if (psw_extint_disabled(vcpu))
+		return 0;
+	if (kvm_cpu_has_interrupt(vcpu))
+		return 0;
+	if (!(vcpu->arch.sie_block->gcr[0] & 0x200ul))
+		return 0;
+
+	copy_from_guest(vcpu, &pfault_token, vcpu->arch.pfault_token, 8);
+	arch.pfault_token = pfault_token;
+	return kvm_setup_async_pf(vcpu, hva, -1, &arch, true);
+}
+
 static int __vcpu_run(struct kvm_vcpu *vcpu)
 {
 	int rc;
@@ -752,7 +837,8 @@ static int __vcpu_run(struct kvm_vcpu *vcpu)
 			rc = SIE_INTERCEPT_UCONTROL;
 		} else if (test_bit(PFAULT_PEND,
 				    &current->thread.gmap_pfault)) {
-			kvm_arch_fault_in_sync(vcpu);
+			if (!kvm_arch_setup_async_pf(vcpu))
+				kvm_arch_fault_in_sync(vcpu);
 			rc = 0;
 		} else {
 			VCPU_EVENT(vcpu, 3, "%s", "fault in sie instruction");
diff --git a/arch/s390/kvm/kvm-s390.h b/arch/s390/kvm/kvm-s390.h
index 884b198..03cb1e8 100644
--- a/arch/s390/kvm/kvm-s390.h
+++ b/arch/s390/kvm/kvm-s390.h
@@ -148,5 +148,9 @@ void exit_sie_sync(struct kvm_vcpu *vcpu);
 bool kvm_enabled_cmma(void);
 /* implemented in diag.c */
 int kvm_s390_handle_diag(struct kvm_vcpu *vcpu);
+/* implemented in interrupt.c */
+int kvm_cpu_has_interrupt(struct kvm_vcpu *vcpu);
+int psw_extint_disabled(struct kvm_vcpu *vcpu);
+
 
 #endif
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index 3c56ba3..6a64ca1 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -413,6 +413,8 @@ struct kvm_s390_psw {
 #define KVM_S390_PROGRAM_INT		0xfffe0001u
 #define KVM_S390_SIGP_SET_PREFIX	0xfffe0002u
 #define KVM_S390_RESTART		0xfffe0003u
+#define KVM_S390_INT_PFAULT_INIT	0xfffe0004u
+#define KVM_S390_INT_PFAULT_DONE	0xfffe0005u
 #define KVM_S390_MCHK			0xfffe1000u
 #define KVM_S390_INT_VIRTIO		0xffff2603u
 #define KVM_S390_INT_SERVICE		0xffff2401u
-- 
1.8.1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
