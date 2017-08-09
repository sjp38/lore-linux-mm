Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB1D6B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 17:28:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o5so35599912qki.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 14:28:07 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w78si3833307qkb.454.2017.08.09.14.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 14:28:06 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v7 7/9] mm: Add address parameter to arch_validate_prot()
Date: Wed,  9 Aug 2017 15:26:00 -0600
Message-Id: <43c120f0cbbebd1398997b9521013ced664e5053.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1502219353.git.khalid.aziz@oracle.com>
References: <cover.1502219353.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, bsingharora@gmail.com, dja@axtens.net, tglx@linutronix.de, mgorman@suse.de, aarcange@redhat.com, kirill.shutemov@linux.intel.com, heiko.carstens@de.ibm.com, ak@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

A protection flag may not be valid across entire address space and
hence arch_validate_prot() might need the address a protection bit is
being set on to ensure it is a valid protection flag. For example, sparc
processors support memory corruption detection (as part of ADI feature)
flag on memory addresses mapped on to physical RAM but not on PFN mapped
pages or addresses mapped on to devices. This patch adds address to the
parameters being passed to arch_validate_prot() so protection bits can
be validated in the relevant context.

Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Khalid Aziz <khalid@gonehiking.org>
---
v7:
	- new patch

 arch/powerpc/include/asm/mman.h | 2 +-
 arch/powerpc/kernel/syscalls.c  | 2 +-
 include/linux/mman.h            | 2 +-
 mm/mprotect.c                   | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 30922f699341..bc74074304a2 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -40,7 +40,7 @@ static inline bool arch_validate_prot(unsigned long prot)
 		return false;
 	return true;
 }
-#define arch_validate_prot(prot) arch_validate_prot(prot)
+#define arch_validate_prot(prot, addr) arch_validate_prot(prot)
 
 #endif /* CONFIG_PPC64 */
 #endif	/* _ASM_POWERPC_MMAN_H */
diff --git a/arch/powerpc/kernel/syscalls.c b/arch/powerpc/kernel/syscalls.c
index a877bf8269fe..6d90ddbd2d11 100644
--- a/arch/powerpc/kernel/syscalls.c
+++ b/arch/powerpc/kernel/syscalls.c
@@ -48,7 +48,7 @@ static inline long do_mmap2(unsigned long addr, size_t len,
 {
 	long ret = -EINVAL;
 
-	if (!arch_validate_prot(prot))
+	if (!arch_validate_prot(prot, addr))
 		goto out;
 
 	if (shift) {
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 634c4c51fe3a..1693d95a88ee 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -49,7 +49,7 @@ static inline void vm_unacct_memory(long pages)
  *
  * Returns true if the prot flags are valid
  */
-static inline bool arch_validate_prot(unsigned long prot)
+static inline bool arch_validate_prot(unsigned long prot, unsigned long addr)
 {
 	return (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM)) == 0;
 }
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..beac2dfbb5fa 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -396,7 +396,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	end = start + len;
 	if (end <= start)
 		return -ENOMEM;
-	if (!arch_validate_prot(prot))
+	if (!arch_validate_prot(prot, start))
 		return -EINVAL;
 
 	reqprot = prot;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
