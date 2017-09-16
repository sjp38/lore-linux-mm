Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A474E6B026D
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 21:21:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t184so5400518qke.0
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 18:21:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y194sor973044qky.46.2017.09.15.18.21.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 18:21:41 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH 4/6] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add sysfs interface
Date: Fri, 15 Sep 2017 18:21:08 -0700
Message-Id: <1505524870-4783-5-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org
Cc: arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

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
32

==> /sys/kernel/mm/protection_keys/usable_keys <==
29

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
 arch/powerpc/mm/pkeys.c            |   20 ++++++++
 arch/x86/include/asm/mmu_context.h |    4 +-
 arch/x86/include/asm/pkeys.h       |    1 +
 arch/x86/mm/pkeys.c                |    8 +++
 include/linux/pkeys.h              |    4 ++
 mm/mprotect.c                      |   88 ++++++++++++++++++++++++++++++++++++
 7 files changed, 126 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index baac435..5924325 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -244,6 +244,8 @@ static inline bool pkey_mmu_enabled(void)
 		return cpu_has_feature(CPU_FTR_PKEY);
 }
 
+extern bool arch_supports_pkeys(int cap);
+extern unsigned int arch_usable_pkeys(void);
 extern void thread_pkey_regs_save(struct thread_struct *thread);
 extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
 			struct thread_struct *old_thread);
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 07e76dc..33c9207 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -373,3 +373,23 @@ bool arch_vma_access_permitted(struct vm_area_struct *vma,
 
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
+	/* Reserve one more to account for the execute-only pkey. */
+	reserved = hweight32(initial_allocation_mask) + 1;
+
+	return pkeys_total > reserved ? pkeys_total - reserved : 0;
+}
+
+bool arch_supports_pkeys(int cap)
+{
+	if (cap & PKEY_DISABLE_EXECUTE)
+		return pkey_execute_disable_support;
+	return (cap & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+}
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 265c907..e960ab2 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -129,13 +129,15 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
 }
 
+#define PKEY_INITIAL_ALLOCATION_MAP	1
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
diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index fa82799..e1b25aa 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -105,5 +105,6 @@ extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val);
 extern void copy_init_pkru_to_fpregs(void);
+extern unsigned int arch_usable_pkeys(void);
 
 #endif /*_ASM_X86_PKEYS_H */
diff --git a/arch/x86/mm/pkeys.c b/arch/x86/mm/pkeys.c
index 2dab69a..6b7f4e1 100644
--- a/arch/x86/mm/pkeys.c
+++ b/arch/x86/mm/pkeys.c
@@ -123,6 +123,14 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey
 	return vma_pkey(vma);
 }
 
+unsigned int arch_usable_pkeys(void)
+{
+	/* Reserve one more to account for the execute-only pkey. */
+	unsigned int reserved = hweight32(PKEY_INITIAL_ALLOCATION_MAP) + 1;
+
+	return arch_max_pkey() > reserved ? arch_max_pkey() - reserved : 0;
+}
+
 #define PKRU_AD_KEY(pkey)	(PKRU_AD_BIT << ((pkey) * PKRU_BITS_PER_PKEY))
 
 /*
diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
index d120810..9350d44 100644
--- a/include/linux/pkeys.h
+++ b/include/linux/pkeys.h
@@ -43,6 +43,10 @@ static inline void copy_init_pkru_to_fpregs(void)
 {
 }
 
+unsigned int arch_usable_pkeys(void)
+{
+	return 0;
+}
 #endif /* ! CONFIG_ARCH_HAS_PKEYS */
 
 #endif /* _LINUX_PKEYS_H */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 1a8c9ca..2917b3e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -552,4 +552,92 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
