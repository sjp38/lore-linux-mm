Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECBC6B003A
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:33:37 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id n8so8501818qaq.8
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 04:33:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u8si13233097qas.58.2014.09.29.04.33.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 04:33:36 -0700 (PDT)
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [RESEND PATCH 2/4] x86: add phys addr validity check for /dev/mem mmap
Date: Mon, 29 Sep 2014 13:33:00 +0200
Message-Id: <1411990382-11902-3-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

Prevent possible PTE corruption while calling mmap on /dev/mem with large
offset.

oops info, please note the PTE value 8008000000000225.
---------------------------------8<--------------------------------------
[85739.124496] rep: Corrupted page table at address 7f63852f8000
[85739.130242] PGD ba2eb067 PUD b99c1067 PMD a2fa5067 PTE 8008000000000225
[85739.136941] Bad pagetable: 000d [#1] SMP
[85739.141002] Modules linked in: cfg80211 rfkill x86_pkg_temp_thermal coretemp
kvm_intel kvm bnx2 crct10dif_pclmul crc32_pclmul crc32c_intel
ghash_clmulni_intel microcode iTCO_wdt ipmi_si i2c_i801 iTCO_vendor_support
ipmi_msghandler dcdbas shpchp lpc_ich mfd_core nfsd auth_rpcgss nfs_acl lockd
sunrpc mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core
[85739.172620] CPU: 3 PID: 21900 Comm: rep Not tainted 3.15.8-200.fc20.x86_64 #1
[85739.179768] Hardware name: Dell Inc. PowerEdge R210 II/09T7VV, BIOS 2.0.4 02/29/2012
[85739.187512] task: ffff8800b9b3b160 ti: ffff8800ba270000 task.ti: ffff8800ba270000
[85739.194988] RIP: 0033:[<0000000000400773>]  [<0000000000400773>] 0x400773
[85739.201799] RSP: 002b:00007fffe4ca3c80  EFLAGS: 00010213
[85739.207119] RAX: 00007f63852f8000 RBX: 0000000000000000 RCX: 00007f6384e0b8ca
[85739.214249] RDX: 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
[85739.221407] RBP: 00007fffe4ca3cc0 R08: 0000000000000003 R09: 0008000000000000
[85739.228545] R10: 0000000000000001 R11: 0000000000000206 R12: 00000000004005b0
[85739.235676] R13: 00007fffe4ca3da0 R14: 0000000000000000 R15: 0000000000000000
[85739.242835] FS:  00007f63852ea740(0000) GS:ffff88013fcc0000(0000) knlGS:0000000000000000
[85739.250925] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[85739.256669] CR2: 00007f63852f8000 CR3: 00000000b9ba0000 CR4: 00000000001407e0
---------------------------------8<--------------------------------------

According to [1] Chapter 4 Paging, some higher bits in 64bit
PTE(X86_64 || X86_32_PAE) are reserved and have to be set to zero. For example,
for IA-32e and 4KB page [1] 4.5 IA-32e Paging: Table 4-19, bits 51-M(MAXPHYADDR)
are reserved. So for a CPU with e.g. 48bit phys addr width, bits 51-48 have to
be zero. If one of the reserved bits is set, [1] 4.7 Page-Fault Exceptions,
the #PF is generated with RSVD error code.

<quote>
RSVD flag (bit 3).
This flag is 1 if there is no valid translation for the linear address because a
reserved bit was set in one of the paging-structure entries used to translate
that address. (Because reserved bits are not checked in a paging-structure entry
whose P flag is 0, bit 3 of the error code can be set only if bit 0 is also
set.)
</quote>

In mmap_mem() the first check is valid_mmap_phys_addr_range(), but it always
returns 1 for x86. So it's possible to use any pgoff we want and
to set the PTE's reserved bits in remap_pfn_range(). Meaning there is a
possibility to use mmap on /dev/mem and cause system panic. It's probably
not that serious, because access to /dev/mem is limited and the system has
to have the panic_on_oops set, but still I think we should check this and
return error.

The path for this problem is:
mmap_mem() => remap_pfn_range() => page present => touch page => tlb miss =>
walk through paging structures => reserved bit set => #pf with rsvd flag

This patch adds check for x86. With this fix mmap returns -EINVAL if the
requested phys addr is larger then the supported phys addr width.

[1] Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 3A

x86_64 reproducer
---------------------------------8<--------------------------------------
 #include <stdio.h>
 #include <unistd.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <err.h>
 #include <stdlib.h>
 #include <sys/mman.h>

 #define die(fmt, ...) err(1, fmt, ##__VA_ARGS__)

 #define OFFSET 0x8000000000000LL

int main(int argc, char *argv[])
{
	int fd;
	long ps;
	long pgoff;
	char *map;
	char c;

	ps = sysconf(_SC_PAGE_SIZE);
	if (ps == -1)
		die("cannot get page size");

	fd = open("/dev/mem", O_RDONLY);
	if (fd == -1)
		die("cannot open /dev/mem");

	pgoff = (OFFSET + (ps - 1)) & ~(ps - 1);

	map = mmap(NULL, ps, PROT_READ, MAP_SHARED, fd, pgoff);
	if (map == MAP_FAILED)
		die("cannot mmap");

	c = map[0];

	if (munmap(map, ps) == -1)
		die("cannot munmap");

	if (close(fd) == -1)
		die("cannot close");

	return 0;
}
---------------------------------8<--------------------------------------

x86_32_PAE reproducer
---------------------------------8<--------------------------------------
 #define _GNU_SOURCE
 #define _LARGEFILE64_SOURCE
 #include <unistd.h>
 #include <sys/syscall.h>
 #include <stdio.h>
 #include <unistd.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <err.h>
 #include <stdlib.h>
 #include <sys/mman.h>

 #define die(fmt, ...) err(1, fmt, ##__VA_ARGS__)

 /* 37th bit in PTE */
 #define OFFSET 0x2000000

int main(int argc, char *argv[])
{
	int fd;
	long ps;
	char *map;
	char c;

	ps = sysconf(_SC_PAGE_SIZE);
	if (ps == -1)
		die("cannot get page size");

	fd = open("/dev/mem", O_RDONLY|O_LARGEFILE);
	if (fd == -1)
		die("cannot open /dev/mem");

	map = (char *)syscall(SYS_mmap2, NULL, ps, PROT_READ, MAP_SHARED, fd, OFFSET);
	if (map == MAP_FAILED)
		die("cannot mmap");

	c = map[0];

	if (munmap(map, ps) == -1)
		die("cannot munmap");

	if (close(fd) == -1)
		die("cannot close");

	return 0;
}
---------------------------------8<--------------------------------------

V2: fix pfn check in valid_mmap_phys_addr_range, thanks to Dave Hansen

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/include/asm/io.h |  4 ++++
 arch/x86/mm/mmap.c        | 12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index b8237d8..55c59d5 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -243,6 +243,10 @@ static inline void flush_write_buffers(void)
 #endif
 }
 
+#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
+extern int valid_phys_addr_range(phys_addr_t addr, size_t count);
+extern int valid_mmap_phys_addr_range(unsigned long pfn, size_t count);
+
 #endif /* __KERNEL__ */
 
 extern void native_io_delay(void);
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 919b912..c8acb10 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -31,6 +31,8 @@
 #include <linux/sched.h>
 #include <asm/elf.h>
 
+#include "physaddr.h"
+
 struct va_alignment __read_mostly va_align = {
 	.flags = -1,
 };
@@ -122,3 +124,13 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
 		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
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
+	return arch_pfn_possible(pfn + (count >> PAGE_SHIFT));
+}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
