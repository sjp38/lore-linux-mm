Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 681F06B0261
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 21:21:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q77so5375255qke.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 18:21:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m123sor973180qkc.82.2017.09.15.18.21.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 18:21:33 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH 1/6] mm: introduce an additional vma bit for powerpc pkey
Date: Fri, 15 Sep 2017 18:21:05 -0700
Message-Id: <1505524870-4783-2-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org
Cc: arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Currently only 4bits are allocated in the vma flags to hold 16
keys. This is sufficient for x86. PowerPC  supports  32  keys,
which needs 5bits. This patch allocates an  additional bit.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 fs/proc/task_mmu.c |    6 ++++--
 include/linux/mm.h |   16 ++++++++++------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b836fd6..cf25306 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -661,13 +661,15 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_MERGEABLE)]	= "mg",
 		[ilog2(VM_UFFD_MISSING)]= "um",
 		[ilog2(VM_UFFD_WP)]	= "uw",
-#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+#ifdef CONFIG_ARCH_HAS_PKEYS
 		/* These come out via ProtectionKey: */
 		[ilog2(VM_PKEY_BIT0)]	= "",
 		[ilog2(VM_PKEY_BIT1)]	= "",
 		[ilog2(VM_PKEY_BIT2)]	= "",
 		[ilog2(VM_PKEY_BIT3)]	= "",
-#endif
+		/* Additional bit used by ppc64 */
+		[ilog2(VM_PKEY_BIT4)]	= "",
+#endif /* CONFIG_ARCH_HAS_PKEYS */
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5..6d72ec0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -208,21 +208,25 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #define VM_HIGH_ARCH_BIT_1	33	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
+#define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
-#if defined(CONFIG_X86)
-# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
-#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
+#ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
-# define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
-# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
+# define VM_PKEY_BIT0	VM_HIGH_ARCH_0 /* A protection key is a 4-bit value */
+# define VM_PKEY_BIT1	VM_HIGH_ARCH_1 /* on x86 and 5-bit value on ppc64   */
 # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
 # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
-#endif
+# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
+#endif /* CONFIG_ARCH_HAS_PKEYS */
+
+#if defined(CONFIG_X86)
+# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
 # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
 #elif defined(CONFIG_PARISC)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
