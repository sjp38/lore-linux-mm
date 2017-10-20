Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA516B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 12:58:53 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id c28so6695019uaa.17
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:58:53 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t7si230973vkt.312.2017.10.20.09.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 09:58:52 -0700 (PDT)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [PATCH v9 07/10] mm: Add address parameter to arch_validate_prot()
Date: Fri, 20 Oct 2017 10:58:00 -0600
Message-Id: <24966e414aa0e3e6b6b1b8df6d680f32736b86d5.1508364660.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1508364660.git.khalid.aziz@oracle.com>
References: <cover.1508364660.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1508364660.git.khalid.aziz@oracle.com>
References: <cover.1508364660.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, bsingharora@gmail.com, nborisov@suse.com, aarcange@redhat.com, tj@kernel.org, mgorman@suse.de, vbabka@suse.cz, nadav.amit@gmail.com, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, heiko.carstens@de.ibm.com, ak@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

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
v8:
	- Added addr parameter to powerpc arch_validate_prot() (suggested
	  by Michael Ellerman)
v7:
	- new patch

 arch/powerpc/include/asm/mman.h | 4 ++--
 arch/powerpc/kernel/syscalls.c  | 2 +-
 include/linux/mman.h            | 2 +-
 mm/mprotect.c                   | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index 30922f699341..1d129f4521ac 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -32,7 +32,7 @@ static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
 }
 #define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
 
-static inline bool arch_validate_prot(unsigned long prot)
+static inline bool arch_validate_prot(unsigned long prot, unsigned long addr)
 {
 	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_SAO))
 		return false;
@@ -40,7 +40,7 @@ static inline bool arch_validate_prot(unsigned long prot)
 		return false;
 	return true;
 }
-#define arch_validate_prot(prot) arch_validate_prot(prot)
+#define arch_validate_prot arch_validate_prot
 
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
index c8367041fafd..b42ad5c9d6a2 100644
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
index bd0f409922cb..4f0e46bb1797 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -395,7 +395,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
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
