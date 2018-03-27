Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B14C6B0028
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:09:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j8so14813179qti.23
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:09:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s6sor772276qtb.127.2018.03.27.02.09.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 02:09:51 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 2/3] mm, powerpc, x86: introduce an additional vma bit for powerpc pkey
Date: Tue, 27 Mar 2018 02:09:27 -0700
Message-Id: <1522141768-25485-3-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1522141768-25485-1-git-send-email-linuxram@us.ibm.com>
References: <1522141768-25485-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de

Currently only 4bits are allocated in the vma flags to hold 16
keys. This is sufficient for x86. PowerPC  supports  32  keys,
which needs 5bits. This patch allocates an  additional bit.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Michael Ellermen <mpe@ellerman.id.au>
cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 fs/proc/task_mmu.c |    1 +
 include/linux/mm.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 6b996d0..6d83bb7 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -685,6 +685,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_PKEY_BIT1)]	= "",
 		[ilog2(VM_PKEY_BIT2)]	= "",
 		[ilog2(VM_PKEY_BIT3)]	= "",
+		[ilog2(VM_PKEY_BIT4)]	= "",
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 	};
 	size_t i;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad207ad..d534f46 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -231,9 +231,10 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #ifdef CONFIG_ARCH_HAS_PKEYS
 # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
 # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
-# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
+# define VM_PKEY_BIT1	VM_HIGH_ARCH_1	/* on x86 and 5-bit value on ppc64   */
 # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
 # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
+# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 
 #if defined(CONFIG_X86)
-- 
1.7.1
