Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C66CD4403D7
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:41 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h4so6593191qtk.4
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u78sor1763863qkl.123.2017.11.06.00.59.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:40 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add sysfs interface
Date: Mon,  6 Nov 2017 00:57:21 -0800
Message-Id: <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>

Expose useful information for programs using memory protection keys.
Provide implementation for powerpc and x86.

On a powerpc system with pkeys support, here is what is shown:

$ head /sys/kernel/mm/protection_keys/*
==> /sys/kernel/mm/protection_keys/disable_access_supported <==
true

==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
true

==> /sys/kernel/mm/protection_keys/disable_write_supported <==
true

==> /sys/kernel/mm/protection_keys/total_keys <==
31

==> /sys/kernel/mm/protection_keys/usable_keys <==
27

And on an x86 without pkeys support:

$ head /sys/kernel/mm/protection_keys/*
==> /sys/kernel/mm/protection_keys/disable_access_supported <==
false

==> /sys/kernel/mm/protection_keys/disable_execute_supported <==
false

==> /sys/kernel/mm/protection_keys/disable_write_supported <==
false

==> /sys/kernel/mm/protection_keys/total_keys <==
1

==> /sys/kernel/mm/protection_keys/usable_keys <==
0

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h   |    2 +
 arch/powerpc/mm/pkeys.c            |   24 ++++++++++
 arch/x86/include/asm/mmu_context.h |    4 +-
 arch/x86/include/asm/pkeys.h       |    1 +
 arch/x86/mm/pkeys.c                |    9 ++++
 include/linux/pkeys.h              |    2 +-
 mm/mprotect.c                      |   88 ++++++++++++++++++++++++++++++++++++
 7 files changed, 128 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 333fb28..6d70b1a 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -237,6 +237,8 @@ static inline void pkey_mmu_values(int total_data, int total_execute)
 	pkeys_total = total_data;
 }
 
+extern bool arch_supports_pkeys(int cap);
+extern unsigned int arch_usable_pkeys(void);
 extern void thread_pkey_regs_save(struct thread_struct *thread);
 extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
 				     struct thread_struct *old_thread);
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 2612f61..7e8468f 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -421,6 +421,30 @@ bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write,
 	return pkey_access_permitted(vma_pkey(vma), write, execute);
 }
 
+unsigned int arch_usable_pkeys(void)
+{
+	unsigned int reserved;
+
+	if (static_branch_likely(&pkey_disabled))
+		return 0;
+
+	/* Reserve one more to account for the execute-only pkey. */
+	reserved = hweight32(initial_allocation_mask) + 1;
+
+	return pkeys_total > reserved ? pkeys_total - reserved : 0;
+}
+
+bool arch_supports_pkeys(int cap)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return false;
+
+	if (cap & PKEY_DISABLE_EXECUTE)
+		return pkey_execute_disable_supported;
+
+	return (cap & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+}
+
 long sys_pkey_modify(int pkey, unsigned long new_val)
 {
 	bool ret;
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 6699fc4..e3efabb 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -129,6 +129,8 @@ static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
 
 void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk);
 
+#define PKEY_INITIAL_ALLOCATION_MAP	1
+
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
@@ -138,7 +140,7 @@ static inline int init_new_context(struct task_struct *tsk,
 	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
 		/* pkey 0 is the default and always allocated */
-		mm->context.pkey_allocation_map = 0x1;
+		mm->context.pkey_allocation_map = PKEY_INITIAL_ALLOCATION_MAP;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
 	}
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index f6c287b..6807288 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -106,5 +106,6 @@ extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 extern void copy_init_pkru_to_fpregs(void);
+extern unsigned int arch_usable_pkeys(void);
 
 #endif /*_ASM_X86_PKEYS_H */
diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index d7bc0ee..3083a59 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -122,6 +122,15 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey
 	return vma_pkey(vma);
 }
 
+unsigned int arch_usable_pkeys(void)
+{
+	/* Reserve one more to account for the execute-only pkey. */
+	unsigned int reserved = (boot_cpu_has(X86_FEATURE_OSPKE) ?
+			hweight32(PKEY_INITIAL_ALLOCATION_MAP) : 0) + 1;
+
+	return arch_max_pkey() > reserved ? arch_max_pkey() - reserved : 0;
+}
+
 #define PKRU_AD_KEY(pkey)	(PKRU_AD_BIT << ((pkey) * PKRU_BITS_PER_PKEY))
 
 /*
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index 3ca2e44..0784f20 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -11,6 +11,7 @@
 #define arch_max_pkey() (1)
 #define execute_only_pkey(mm) (0)
 #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
+#define arch_usable_pkeys() (0)
 #define PKEY_DEDICATED_EXECUTE_ONLY 0
 #define ARCH_VM_PKEY_FLAGS 0
 
@@ -43,7 +44,6 @@ static inline bool arch_pkeys_enabled(void)
 static inline void copy_init_pkru_to_fpregs(void)
 {
 }
-
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 #endif /* _LINUX_PKEYS_H */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f73..43a4584 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -568,4 +568,92 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
+static ssize_t disable_access_supported_show(struct kobject *kobj,
+					      struct kobj_attribute *attr,
+					      char *buf)
+{
+	if (arch_pkeys_enabled()) {
+		strcpy(buf, "true\n");
+		return sizeof("true\n") - 1;
+	}
+
+	strcpy(buf, "false\n");
+	return sizeof("false\n") - 1;
+}
+PKEYS_ATTR_RO(disable_access_supported);
+
+static ssize_t disable_write_supported_show(struct kobject *kobj,
+					     struct kobj_attribute *attr,
+					     char *buf)
+{
+	if (arch_pkeys_enabled()) {
+		strcpy(buf, "true\n");
+		return sizeof("true\n") - 1;
+	}
+
+	strcpy(buf, "false\n");
+	return sizeof("false\n") - 1;
+}
+PKEYS_ATTR_RO(disable_write_supported);
+
+static ssize_t disable_execute_supported_show(struct kobject *kobj,
+					      struct kobj_attribute *attr,
+					      char *buf)
+{
+#ifdef PKEY_DISABLE_EXECUTE
+	if (arch_supports_pkeys(PKEY_DISABLE_EXECUTE)) {
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
+	&disable_access_supported_attr.attr,
+	&disable_write_supported_attr.attr,
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
