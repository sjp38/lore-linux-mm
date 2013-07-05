Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5A9296B0038
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 16:56:09 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 21:51:23 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id E1DCD1B0805D
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 21:56:05 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r65KtsFi55574580
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 20:55:54 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r65Ku4BL020692
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 14:56:05 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/4] PF: Provide additional direct page notification
Date: Fri,  5 Jul 2013 22:55:53 +0200
Message-Id: <1373057754-59225-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1373057754-59225-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1373057754-59225-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

By setting a Kconfig option, the architecture can control when
guest notifications will be presented by the apf backend.
So there is the default batch mechanism, working as before, where the vcpu thread
should pull in this information. On the other hand there is now the direct
mechanism, this will directly push the information to the guest.

Still the vcpu thread should call check_completion to cleanup leftovers,
that leaves most of the common code untouched.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/x86/kvm/mmu.c       |  2 +-
 include/linux/kvm_host.h |  2 +-
 virt/kvm/Kconfig         |  4 ++++
 virt/kvm/async_pf.c      | 22 +++++++++++++++++++---
 4 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 0d094da..b8632e9 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3343,7 +3343,7 @@ static int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
 	arch.direct_map = vcpu->arch.mmu.direct_map;
 	arch.cr3 = vcpu->arch.mmu.get_cr3(vcpu);
 
-	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
+	return kvm_setup_async_pf(vcpu, gva, gfn_to_hva(vcpu->kvm, gfn), &arch);
 }
 
 static bool can_do_async_pf(struct kvm_vcpu *vcpu)
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 210f493..969d575 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -175,7 +175,7 @@ struct kvm_async_pf {
 
 void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
 void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
-int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
+int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 		       struct kvm_arch_async_pf *arch);
 int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
 #endif
diff --git a/virt/kvm/Kconfig b/virt/kvm/Kconfig
index 779262f..715e6b5 100644
--- a/virt/kvm/Kconfig
+++ b/virt/kvm/Kconfig
@@ -22,6 +22,10 @@ config KVM_MMIO
 config KVM_ASYNC_PF
        bool
 
+# Toggle to switch between direct notification and batch job
+config KVM_ASYNC_PF_DIRECT
+       bool
+
 config HAVE_KVM_MSI
        bool
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index ea475cd..b8df37a 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -28,6 +28,21 @@
 #include "async_pf.h"
 #include <trace/events/kvm.h>
 
+static inline void kvm_async_page_direct_present(struct kvm_vcpu *vcpu,
+						 struct kvm_async_pf *work)
+{
+#ifdef CONFIG_KVM_ASYNC_PF_DIRECT
+	kvm_arch_async_page_present(vcpu, work);
+#endif
+}
+static inline void kvm_async_page_batch_present(struct kvm_vcpu *vcpu,
+						struct kvm_async_pf *work)
+{
+#ifndef CONFIG_KVM_ASYNC_PF_DIRECT
+	kvm_arch_async_page_present(vcpu, work);
+#endif
+}
+
 static struct kmem_cache *async_pf_cache;
 
 int kvm_async_pf_init(void)
@@ -70,6 +85,7 @@ static void async_pf_execute(struct work_struct *work)
 	down_read(&mm->mmap_sem);
 	get_user_pages(current, mm, addr, 1, 1, 0, &page, NULL);
 	up_read(&mm->mmap_sem);
+	kvm_async_page_direct_present(vcpu, apf);
 	unuse_mm(mm);
 
 	spin_lock(&vcpu->async_pf.lock);
@@ -134,7 +150,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 
 		if (work->page)
 			kvm_arch_async_page_ready(vcpu, work);
-		kvm_arch_async_page_present(vcpu, work);
+		kvm_async_page_batch_present(vcpu, work);
 
 		list_del(&work->queue);
 		vcpu->async_pf.queued--;
@@ -144,7 +160,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 	}
 }
 
-int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
+int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 		       struct kvm_arch_async_pf *arch)
 {
 	struct kvm_async_pf *work;
@@ -166,7 +182,7 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
 	work->done = false;
 	work->vcpu = vcpu;
 	work->gva = gva;
-	work->addr = gfn_to_hva(vcpu->kvm, gfn);
+	work->addr = hva;
 	work->arch = *arch;
 	work->mm = current->mm;
 	atomic_inc(&work->mm->mm_count);
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
