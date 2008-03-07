From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [3/13] Make kvm bad_page symbol static
Message-Id: <20080307090713.90A1C1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:13 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: avi@qumranet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Avoids global namespace clash with later patch that exports page_alloc's 
bad_page. bad_page is not used outside kvm_main.c, so making it static is fine.

Cc: avi@qumranet.com

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/kvm_host.h |    2 --
 virt/kvm/kvm_main.c      |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

Index: linux/include/linux/kvm_host.h
===================================================================
--- linux.orig/include/linux/kvm_host.h
+++ linux/include/linux/kvm_host.h
@@ -150,8 +150,6 @@ void kvm_exit(void);
 static inline int is_error_hpa(hpa_t hpa) { return hpa >> HPA_MSB; }
 struct page *gva_to_page(struct kvm_vcpu *vcpu, gva_t gva);
 
-extern struct page *bad_page;
-
 int is_error_page(struct page *page);
 int kvm_is_error_hva(unsigned long addr);
 int kvm_set_memory_region(struct kvm *kvm,
Index: linux/virt/kvm/kvm_main.c
===================================================================
--- linux.orig/virt/kvm/kvm_main.c
+++ linux/virt/kvm/kvm_main.c
@@ -52,6 +52,8 @@ MODULE_LICENSE("GPL");
 DEFINE_SPINLOCK(kvm_lock);
 LIST_HEAD(vm_list);
 
+static struct page *bad_page;
+
 static cpumask_t cpus_hardware_enabled;
 
 struct kmem_cache *kvm_vcpu_cache;
@@ -1271,8 +1273,6 @@ static struct sys_device kvm_sysdev = {
 	.cls = &kvm_sysdev_class,
 };
 
-struct page *bad_page;
-
 static inline
 struct kvm_vcpu *preempt_notifier_to_vcpu(struct preempt_notifier *pn)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
