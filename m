Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89F10280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:33 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id z12so6752004qkb.12
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y194sor7434226qky.91.2017.11.06.00.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:32 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 26/51] powerpc: add sys_pkey_modify() system call
Date: Mon,  6 Nov 2017 00:57:18 -0800
Message-Id: <1509958663-18737-27-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

sys_pkey_modify()  is   powerpc  specific  system  call.  It
enables  the ability to modify *any* attribute of a key.

Since powerpc disallows modification of IAMR from user space
an application is unable to change a key's execute-attribute.

This system call helps accomplish the above.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/asm/unistd.h      |    2 +-
 arch/powerpc/include/uapi/asm/unistd.h |    1 +
 arch/powerpc/kernel/entry_64.S         |    9 +++++++++
 arch/powerpc/mm/pkeys.c                |   17 +++++++++++++++++
 5 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index d61f9c9..533cdc5 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -392,3 +392,4 @@
 SYSCALL(pkey_alloc)
 SYSCALL(pkey_free)
 SYSCALL(pkey_mprotect)
+PPC64ONLY(pkey_modify)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index daf1ba9..1e97086 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,7 +12,7 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		387
+#define NR_syscalls		388
 
 #define __NR__exit __NR_exit
 
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index 389c36f..318cd79 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -398,5 +398,6 @@
 #define __NR_pkey_alloc		384
 #define __NR_pkey_free		385
 #define __NR_pkey_mprotect	386
+#define __NR_pkey_modify	387
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
diff --git a/arch/powerpc/kernel/entry_64.S b/arch/powerpc/kernel/entry_64.S
index 4a0fd4f..47c85f9 100644
--- a/arch/powerpc/kernel/entry_64.S
+++ b/arch/powerpc/kernel/entry_64.S
@@ -455,6 +455,15 @@ _GLOBAL(ppc_switch_endian)
 	bl	sys_switch_endian
 	b	.Lsyscall_exit
 
+_GLOBAL(ppc_pkey_modify)
+	bl	save_nvgprs
+#ifdef  CONFIG_PPC_MEM_KEYS
+	bl	sys_pkey_modify
+#else
+	bl	sys_ni_syscall
+#endif
+	b	.Lsyscall_exit
+
 _GLOBAL(ret_from_fork)
 	bl	schedule_tail
 	REST_NVGPRS(r1)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 5047371..2612f61 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -420,3 +420,20 @@ bool arch_vma_access_permitted(struct vm_area_struct *vma, bool write,
 
 	return pkey_access_permitted(vma_pkey(vma), write, execute);
 }
+
+long sys_pkey_modify(int pkey, unsigned long new_val)
+{
+	bool ret;
+	/* Check for unsupported init values */
+	if (new_val & ~PKEY_ACCESS_MASK)
+		return -EINVAL;
+
+	down_write(&current->mm->mmap_sem);
+	ret = mm_pkey_is_allocated(current->mm, pkey);
+	up_write(&current->mm->mmap_sem);
+
+	if (!ret)
+		return -EINVAL;
+
+	return __arch_set_user_pkey_access(current, pkey, new_val);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
