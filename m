Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 6B27E6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 08:29:04 -0400 (EDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [PATCH] x86: add phys addr validity check for /dev/mem mmap
Date: Tue,  2 Apr 2013 14:28:53 +0200
Message-Id: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

When CR4.PAE is set, the 64b PTE's are used(ARCH_PHYS_ADDR_T_64BIT is set for
X86_64 || X86_PAE). According to [1] Chapter 4 Paging, some higher bits in 64b
PTE are reserved and have to be set to zero. For example, for IA-32e and 4KB
page [1] 4.5 IA-32e Paging: Table 4-19, bits 51-M(MAXPHYADDR) are reserved. So
for a CPU with e.g. 48bit phys addr width, bits 51-48 have to be zero. If one of
the reserved bits is set, [1] 4.7 Page-Fault Exceptions, the #PF is generated
with RSVD error code.

<quote>
RSVD flag (bit 3).
This flag is 1 if there is no valid translation for the linear address because a
reserved bit was set in one of the paging-structure entries used to translate
that address. (Because reserved bits are not checked in a paging-structure entry
whose P flag is 0, bit 3 of the error code can be set only if bit 0 is also
set.)
</quote>

In mmap_mem() the first check is valid_mmap_phys_addr_range(), but it always
returns 1 on x86. So it's possible to use any pgoff we want and to set the PTE's
reserved bits in remap_pfn_range(). Meaning there is a possibility to use mmap
on /dev/mem and cause system panic. It's probably not that serious, because
access to /dev/mem is limited and the system has to have panic_on_oops set, but
still I think we should check this and return error.

This patch adds check for x86 when ARCH_PHYS_ADDR_T_64BIT is set, the same way
as it is already done in e.g. ioremap. With this fix mmap returns -EINVAL if the
requested phys addr is bigger then the supported phys addr width.

[1] Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 3A

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/include/asm/io.h |  4 ++++
 arch/x86/mm/mmap.c        | 13 +++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index d8e8eef..39607c6 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -242,6 +242,10 @@ static inline void flush_write_buffers(void)
 #endif
 }
 
+#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
+extern int valid_phys_addr_range(phys_addr_t addr, size_t count);
+extern int valid_mmap_phys_addr_range(unsigned long pfn, size_t count);
+
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 845df68..92ec31c 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -31,6 +31,8 @@
 #include <linux/sched.h>
 #include <asm/elf.h>
 
+#include "physaddr.h"
+
 struct __read_mostly va_alignment va_align = {
 	.flags = -1,
 };
@@ -122,3 +124,14 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		mm->unmap_area = arch_unmap_area_topdown;
 	}
 }
+
+int valid_phys_addr_range(phys_addr_t addr, size_t count)
+{
+	return addr + count <= __pa(high_memory);
+}
+
+int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
+{
+	resource_size_t addr = (pfn << PAGE_SHIFT) + count;
+	return phys_addr_valid(addr);
+}
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
