Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D09016B0008
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:53:07 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id a143so2610661qkg.4
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:53:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n39sor2332028qtn.14.2018.02.21.15.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 15:53:06 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v12 1/3] mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS is enabled
Date: Wed, 21 Feb 2018 15:52:16 -0800
Message-Id: <1519257138-23797-2-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

VM_PKEY_BITx are defined only if CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
is enabled. Powerpc also needs these bits. Hence lets define the
VM_PKEY_BITx bits for any architecture that enables
CONFIG_ARCH_HAS_PKEYS.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Michael Ellermen <mpe@ellerman.id.au>
cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c |    4 ++--
 include/linux/mm.h |    9 +++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ec6d298..6b996d0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -679,13 +679,13 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
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
+#endif /* CONFIG_ARCH_HAS_PKEYS */
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..ad207ad 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -228,15 +228,16 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
-#if defined(CONFIG_X86)
-# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
-#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
+#ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
 # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
 # define VM_PKEY_BIT1	VM_HIGH_ARCH_1
 # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
 # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
-#endif
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
