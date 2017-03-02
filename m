Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8A876B03C0
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:19:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so85507639pfb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:19:06 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0058.outbound.protection.outlook.com. [104.47.34.58])
        by mx.google.com with ESMTPS id j77si7684600pfj.127.2017.03.02.07.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:19:05 -0800 (PST)
Subject: [RFC PATCH v2 32/32] x86: kvm: Pin the guest memory when SEV is
 active
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:18:57 -0500
Message-ID: <148846793743.2349.8478208161427437950.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The SEV memory encryption engine uses a tweak such that two identical
plaintexts at different location will have a different ciphertexts.
So swapping or moving ciphertexts of two pages will not result in
plaintexts being swapped. Relocating (or migrating) a physical backing pages
for SEV guest will require some additional steps. The current SEV key
management spec [1] does not provide commands to swap or migrate (move)
ciphertexts. For now we pin the memory allocated for the SEV guest. In
future when SEV key management spec provides the commands to support the
page migration we can update the KVM code to remove the pinning logical
without making any changes into userspace (qemu).

The patch pins userspace memory when a new slot is created and unpin the
memory when slot is removed.

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    6 +++
 arch/x86/kvm/svm.c              |   93 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c              |    3 +
 3 files changed, 102 insertions(+)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index fcc4710..9dc59f0 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -723,6 +723,7 @@ struct kvm_sev_info {
 	unsigned int handle;	/* firmware handle */
 	unsigned int asid;	/* asid for this guest */
 	int sev_fd;		/* SEV device fd */
+	struct list_head pinned_memory_slot;
 };
 
 struct kvm_arch {
@@ -1043,6 +1044,11 @@ struct kvm_x86_ops {
 	void (*setup_mce)(struct kvm_vcpu *vcpu);
 
 	int (*memory_encryption_op)(struct kvm *kvm, void __user *argp);
+
+	void (*prepare_memory_region)(struct kvm *kvm,
+			struct kvm_memory_slot *memslot,
+			const struct kvm_userspace_memory_region *mem,
+			enum kvm_mr_change change);
 };
 
 struct kvm_arch_async_pf {
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 13996d6..ab973f9 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -498,12 +498,21 @@ static inline bool gif_set(struct vcpu_svm *svm)
 }
 
 /* Secure Encrypted Virtualization */
+struct kvm_sev_pinned_memory_slot {
+	struct list_head list;
+	unsigned long npages;
+	struct page **pages;
+	unsigned long userspace_addr;
+	short id;
+};
+
 static unsigned int max_sev_asid;
 static unsigned long *sev_asid_bitmap;
 static void sev_deactivate_handle(struct kvm *kvm);
 static void sev_decommission_handle(struct kvm *kvm);
 static int sev_asid_new(void);
 static void sev_asid_free(int asid);
+static void sev_unpin_memory(struct page **pages, unsigned long npages);
 #define __sev_page_pa(x) ((page_to_pfn(x) << PAGE_SHIFT) | sme_me_mask)
 
 static bool kvm_sev_enabled(void)
@@ -1544,9 +1553,25 @@ static inline int avic_free_vm_id(int id)
 
 static void sev_vm_destroy(struct kvm *kvm)
 {
+	struct list_head *pos, *q;
+	struct kvm_sev_pinned_memory_slot *pinned_slot;
+	struct list_head *head = &kvm->arch.sev_info.pinned_memory_slot;
+
 	if (!sev_guest(kvm))
 		return;
 
+	/* if guest memory is pinned then unpin it now */
+	if (!list_empty(head)) {
+		list_for_each_safe(pos, q, head) {
+			pinned_slot = list_entry(pos,
+				struct kvm_sev_pinned_memory_slot, list);
+			sev_unpin_memory(pinned_slot->pages,
+					pinned_slot->npages);
+			list_del(pos);
+			kfree(pinned_slot);
+		}
+	}
+
 	/* release the firmware resources */
 	sev_deactivate_handle(kvm);
 	sev_decommission_handle(kvm);
@@ -5663,6 +5688,8 @@ static int sev_pre_start(struct kvm *kvm, int *asid)
 		}
 		*asid = ret;
 		ret = 0;
+
+		INIT_LIST_HEAD(&kvm->arch.sev_info.pinned_memory_slot);
 	}
 
 	return ret;
@@ -6189,6 +6216,71 @@ static int sev_launch_measure(struct kvm *kvm, struct kvm_sev_cmd *argp)
 	return ret;
 }
 
+static struct kvm_sev_pinned_memory_slot *sev_find_pinned_memory_slot(
+		struct kvm *kvm, struct kvm_memory_slot *slot)
+{
+	struct kvm_sev_pinned_memory_slot *i;
+	struct list_head *head = &kvm->arch.sev_info.pinned_memory_slot;
+
+	list_for_each_entry(i, head, list) {
+		if (i->userspace_addr == slot->userspace_addr &&
+			i->id == slot->id)
+			return i;
+	}
+
+	return NULL;
+}
+
+static void amd_prepare_memory_region(struct kvm *kvm,
+				struct kvm_memory_slot *memslot,
+				const struct kvm_userspace_memory_region *mem,
+				enum kvm_mr_change change)
+{
+	struct kvm_sev_pinned_memory_slot *pinned_slot;
+	struct list_head *head = &kvm->arch.sev_info.pinned_memory_slot;
+
+	mutex_lock(&kvm->lock);
+
+	if (!sev_guest(kvm))
+		goto unlock;
+
+	if (change == KVM_MR_CREATE) {
+
+		if (!mem->memory_size)
+			goto unlock;
+
+		pinned_slot = kmalloc(sizeof(*pinned_slot), GFP_KERNEL);
+		if (pinned_slot == NULL)
+			goto unlock;
+
+		pinned_slot->pages = sev_pin_memory(mem->userspace_addr,
+				mem->memory_size, &pinned_slot->npages);
+		if (pinned_slot->pages == NULL) {
+			kfree(pinned_slot);
+			goto unlock;
+		}
+
+		sev_clflush_pages(pinned_slot->pages, pinned_slot->npages);
+
+		pinned_slot->id = memslot->id;
+		pinned_slot->userspace_addr = mem->userspace_addr;
+		list_add_tail(&pinned_slot->list, head);
+
+	} else if  (change == KVM_MR_DELETE) {
+
+		pinned_slot = sev_find_pinned_memory_slot(kvm, memslot);
+		if (!pinned_slot)
+			goto unlock;
+
+		sev_unpin_memory(pinned_slot->pages, pinned_slot->npages);
+		list_del(&pinned_slot->list);
+		kfree(pinned_slot);
+	}
+
+unlock:
+	mutex_unlock(&kvm->lock);
+}
+
 static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 {
 	int r = -ENOTTY;
@@ -6355,6 +6447,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.update_pi_irte = svm_update_pi_irte,
 
 	.memory_encryption_op = amd_memory_encryption_cmd,
+	.prepare_memory_region = amd_prepare_memory_region,
 };
 
 static int __init svm_init(void)
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 6a737e9..e05069d 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8195,6 +8195,9 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 				const struct kvm_userspace_memory_region *mem,
 				enum kvm_mr_change change)
 {
+	if (kvm_x86_ops->prepare_memory_region)
+		kvm_x86_ops->prepare_memory_region(kvm, memslot, mem, change);
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
