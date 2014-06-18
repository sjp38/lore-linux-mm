Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id A33A46B0071
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 01:49:13 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so361457pbb.35
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 22:49:13 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ie10si985610pad.64.2014.06.17.22.49.11
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 22:49:12 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RFC PATCH 1/1] Move two pinned pages to non-movable node in kvm.
Date: Wed, 18 Jun 2014 13:50:00 +0800
Message-ID: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gleb@kernel.org, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org
Cc: isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi,

I met a problem when offlining memory with a kvm guest running.


[Problem]
When qemu creates vpus, it will call the following two functions
to allocate two pages:
1. alloc_apic_access_page(): allocate apic access page for FlexPriority in intel cpu.
2. alloc_identity_pagetable(): allocate ept identity pagetable for real mode.

And unfortunately, these two pages will be pinned in memory, and they cannot
be migrated. As a result, they cannot be offlined. And memory hot-remove will fail.



[The way I tried]
I tried to migrate these two pages, but I think I cannot find a proper way
to migrate them.

Let's take ept identity pagetable for example:
In my opinion, since it is pagetable, CPU will access this page every time the guest
read/write memory. For example, the following code will access memory:
	int a;
	a = 0;
So this ept identity pagetable page can be accessed at any time by CPU automatically.



[Solution]
I have a basic idea to solve this problem: allocate these two pages in non-movable nodes.
(For now, we can only hot-remove memory in movable nodes.)

alloc_identity_pagetable()
|-> __kvm_set_memory_region()
|   |-> kvm_arch_prepare_memory_region()
|       |-> userspace_addr = vm_mmap();
|       |-> memslot->userspace_addr = userspace_addr;  /* map usespace address (qemu) */
|
|   /*
|    * Here, set memory policy for the mapped but not allocated page,
|    * make it can only be allocated in non-movable nodes.
|    * (We can reuse "numa_kernel_nodes" node mask in movable_node functionality.)
|    */
|
|-> page = gfn_to_page()  /* allocate and pin page */

Please refer to the attached patch for detail.
I did some basic test for the patch, and it will make memory offline succeed.



[Questions]
And by the way, would you guys please answer the following questions for me ?

1. What's the ept identity pagetable for ?  Only one page is enough ?

2. Is the ept identity pagetable only used in realmode ?
   Can we free it once the guest is up (vcpu in protect mode)?

3. Now, ept identity pagetable is allocated in qemu userspace.
   Can we allocate it in kernel space ?

4. If I want to migrate these two pages, what do you think is the best way ?

Thanks.


Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/numa.h | 1 +
 arch/x86/kvm/vmx.c          | 5 +++++
 arch/x86/kvm/x86.c          | 1 +
 arch/x86/mm/numa.c          | 3 ++-
 include/linux/mempolicy.h   | 6 ++++++
 mm/mempolicy.c              | 9 +++++++++
 6 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
index 4064aca..6312577 100644
--- a/arch/x86/include/asm/numa.h
+++ b/arch/x86/include/asm/numa.h
@@ -30,6 +30,7 @@ extern int numa_off;
  */
 extern s16 __apicid_to_node[MAX_LOCAL_APIC];
 extern nodemask_t numa_nodes_parsed __initdata;
+extern nodemask_t numa_kernel_nodes;
 
 extern int __init numa_add_memblk(int nodeid, u64 start, u64 end);
 extern void __init numa_set_distance(int from, int to, int distance);
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 801332e..4a3b5b5 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -32,6 +32,7 @@
 #include <linux/slab.h>
 #include <linux/tboot.h>
 #include <linux/hrtimer.h>
+#include <linux/mempolicy.h>
 #include "kvm_cache_regs.h"
 #include "x86.h"
 
@@ -3988,6 +3989,8 @@ static int alloc_apic_access_page(struct kvm *kvm)
 	if (r)
 		goto out;
 
+	numa_bind_non_movable(kvm_userspace_mem.userspace_addr, PAGE_SIZE);
+
 	page = gfn_to_page(kvm, 0xfee00);
 	if (is_error_page(page)) {
 		r = -EFAULT;
@@ -4018,6 +4021,8 @@ static int alloc_identity_pagetable(struct kvm *kvm)
 	if (r)
 		goto out;
 
+	numa_bind_non_movable(kvm_userspace_mem.userspace_addr, PAGE_SIZE);
+
 	page = gfn_to_page(kvm, kvm->arch.ept_identity_map_addr >> PAGE_SHIFT);
 	if (is_error_page(page)) {
 		r = -EFAULT;
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index f32a025..3962a23 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7295,6 +7295,7 @@ int kvm_arch_prepare_memory_region(struct kvm *kvm,
 			return PTR_ERR((void *)userspace_addr);
 
 		memslot->userspace_addr = userspace_addr;
+		mem->userspace_addr = userspace_addr;
 	}
 
 	return 0;
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a32b706..d706148 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -22,6 +22,8 @@
 
 int __initdata numa_off;
 nodemask_t numa_nodes_parsed __initdata;
+nodemask_t numa_kernel_nodes;
+EXPORT_SYMBOL(numa_kernel_nodes);
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
@@ -557,7 +559,6 @@ static void __init numa_init_array(void)
 static void __init numa_clear_kernel_node_hotplug(void)
 {
 	int i, nid;
-	nodemask_t numa_kernel_nodes = NODE_MASK_NONE;
 	unsigned long start, end;
 	struct memblock_region *r;
 
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index f230a97..14f3f04 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -140,6 +140,7 @@ bool vma_policy_mof(struct task_struct *task, struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
+extern long numa_bind_non_movable(unsigned long start, unsigned long len);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
@@ -243,6 +244,11 @@ static inline void numa_default_policy(void)
 {
 }
 
+static inline long numa_bind_non_movable(unsigned long start, unsigned long len)
+{
+	return -EINVAL;
+}
+
 static inline void mpol_rebind_task(struct task_struct *tsk,
 				const nodemask_t *new,
 				enum mpol_rebind_step step)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2849742..20065a9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -97,6 +97,7 @@
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
+#include <asm/numa.h>
 #include <linux/random.h>
 
 #include "internal.h"
@@ -2663,6 +2664,14 @@ void numa_default_policy(void)
 	do_set_mempolicy(MPOL_DEFAULT, 0, NULL);
 }
 
+/* Bind a memory range to non-movable nodes. */
+long numa_bind_non_movable(unsigned long start, unsigned long len)
+{
+	return do_mbind(start, len, MPOL_BIND, MPOL_MODE_FLAGS,
+			&numa_kernel_nodes, MPOL_MF_STRICT);
+}
+EXPORT_SYMBOL(numa_bind_non_movable);
+
 /*
  * Parse and format mempolicy from/to strings
  */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
