Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04FF96B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:35:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p20so44097683pfj.2
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 10:35:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v14si766097pgc.31.2017.08.11.10.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 10:35:02 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7BHXXO1105648
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:35:01 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c9f6bcy26-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 13:35:01 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Fri, 11 Aug 2017 11:35:01 -0600
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: [RFC v7 26/25] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add sysfs interface
Date: Fri, 11 Aug 2017 14:34:43 -0300
In-Reply-To: <1501459946-11619-1-git-send-email-linuxram@us.ibm.com>
References: <1501459946-11619-1-git-send-email-linuxram@us.ibm.com>
Message-Id: <20170811173443.6227-1-bauerman@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: x86@kernel.org, linux-mm@kvack.org, Ram Pai <linuxram@us.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Haren Myneni <hbabu@us.ibm.com>, Michal Hocko <mhocko@kernel.org>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>

Expose useful information for programs using memory protection keys.
Provide implementation for powerpc and x86.

On a powerpc system with pkeys support, here is what is shown:

$ head /sys/kernel/mm/protection_keys/*
==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
true

==> /sys/kernel/mm/protection_keys/total_keys <==
32

==> /sys/kernel/mm/protection_keys/usable_keys <==
30

And on an x86 without pkeys support:

$ head /sys/kernel/mm/protection_keys/*
==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
false

==> /sys/kernel/mm/protection_keys/total_keys <==
1

==> /sys/kernel/mm/protection_keys/usable_keys <==
0

Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
---

Ram asked me to add a sysfs interface for the memory protection keys
feature. Here it is.

If you have suggestions on what should be exposed, please let me know.

 arch/powerpc/include/asm/pkeys.h   |  2 ++
 arch/powerpc/mm/pkeys.c            | 12 ++++++++
 arch/x86/include/asm/mmu_context.h | 34 +++++++++++-----------
 arch/x86/include/asm/pkeys.h       |  1 +
 arch/x86/mm/pkeys.c                |  5 ++++
 mm/mprotect.c                      | 58 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 96 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index e61ed6c332db..bbc5a34cc6d6 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -215,6 +215,8 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
+unsigned int arch_usable_pkeys(void);
+
 static inline bool arch_pkeys_enabled(void)
 {
 	return pkey_inited;
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 1424c79f45f6..54efbb133049 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -272,3 +272,15 @@ bool arch_vma_access_permitted(struct vm_area_struct *vma,
 
 	return pkey_access_permitted(pkey, write, execute);
 }
+
+unsigned int arch_usable_pkeys(void)
+{
+	unsigned int reserved;
+
+	if (!pkey_inited)
+		return 0;
+
+	reserved = hweight32(initial_allocation_mask);
+
+	return (pkeys_total > reserved) ? pkeys_total - reserved : 0;
+}
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 68b329d77b3a..d2eabedd583a 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -105,13 +105,30 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 #endif
 }
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+#define PKEY_INITIAL_ALLOCATION_MAP	1
+
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
+				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
+
+	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
+}
+#else
+static inline int vma_pkey(struct vm_area_struct *vma)
+{
+	return 0;
+}
+#endif
+
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
 	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
 		/* pkey 0 is the default and always allocated */
-		mm->context.pkey_allocation_map = 0x1;
+		mm->context.pkey_allocation_map = PKEY_INITIAL_ALLOCATION_MAP;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
 	}
@@ -205,21 +222,6 @@ static inline void arch_unmap(struct mm_struct *mm, struct vm_area_struct *vma,
 		mpx_notify_unmap(mm, vma, start, end);
 }
 
-#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
-				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
-
-	return (vma->vm_flags & vma_pkey_mask) >> VM_PKEY_SHIFT;
-}
-#else
-static inline int vma_pkey(struct vm_area_struct *vma)
-{
-	return 0;
-}
-#endif
-
 static inline bool __pkru_allows_pkey(u16 pkey, bool write)
 {
 	u32 pkru = read_pkru();
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index fa8279972ddf..e1b25aa60530 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -105,5 +105,6 @@ extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 extern void copy_init_pkru_to_fpregs(void);
+extern unsigned int arch_usable_pkeys(void);
 
 #endif /*_ASM_X86_PKEYS_H */
diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index 2dab69a706ec..a3acca15ff83 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -123,6 +123,11 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey
 	return vma_pkey(vma);
 }
 
+unsigned int arch_usable_pkeys(void)
+{
+	return arch_max_pkey() - hweight32(PKEY_INITIAL_ALLOCATION_MAP);
+}
+
 #define PKRU_AD_KEY(pkey)	(PKRU_AD_BIT << ((pkey) * PKRU_BITS_PER_PKEY))
 
 /*
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..855744b9f7d6 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -554,4 +554,62 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 	return ret;
 }
 
+#ifdef CONFIG_SYSFS
+
+#define PKEYS_ATTR_RO(_name)						\
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+
+static ssize_t total_keys_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", arch_max_pkey());
+}
+PKEYS_ATTR_RO(total_keys);
+
+static ssize_t usable_keys_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", arch_usable_pkeys());
+}
+PKEYS_ATTR_RO(usable_keys);
+
+static ssize_t disable_execute_supported_show(struct kobject *kobj,
+					      struct kobj_attribute *attr,
+					      char *buf)
+{
+#ifdef PKEY_DISABLE_EXECUTE
+	if (arch_pkeys_enabled()) {
+		strcpy(buf, "true\n");
+		return sizeof("true\n") - 1;
+	}
+#endif
+
+	strcpy(buf, "false\n");
+	return sizeof("false\n") - 1;
+}
+PKEYS_ATTR_RO(disable_execute_supported);
+
+static struct attribute *pkeys_attrs[] = {
+	&total_keys_attr.attr,
+	&usable_keys_attr.attr,
+	&disable_execute_supported_attr.attr,
+	NULL,
+};
+
+static const struct attribute_group pkeys_attr_group = {
+	.attrs = pkeys_attrs,
+	.name = "protection_keys",
+};
+
+static int __init pkeys_sysfs_init(void)
+{
+	int err;
+
+	err = sysfs_create_group(mm_kobj, &pkeys_attr_group);
+
+	return err;
+}
+late_initcall(pkeys_sysfs_init);
+#endif /* CONFIG_SYSFS */
+
 #endif /* CONFIG_ARCH_HAS_PKEYS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
