Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3976B003C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 12:05:31 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so1072198pbb.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:05:30 -0700 (PDT)
Date: Wed, 2 Oct 2013 18:05:14 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: [RESEND PATCH] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <20131002160514.GA25471@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com

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

reproducer
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

/*
   1) Find some non system ram in case the CONFIG_STRICT_DEVMEM is defined
   $ cat /proc/iomem | grep -v "\(System RAM\|reserved\)"

   2) Find physical address width
   $ cat /proc/cpuinfo | grep "address sizes"

   PTE bits 51 - M are reserved, where M is physical address width found 2)
   Note: step 2) is actually not needed, we can always set just the 51th bit
   (0x8000000000000)

   Set OFFSET macro to

   (start of iomem range found in 1)) | (1 << 51)

   for example
   0x000a0000 | 0x8000000000000 = 0x80000000a0000

   where 0x000a0000 is start of PCI BUS on my laptop

 */

 #define OFFSET 0x80000000a0000LL

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
	printf("%Lx\n", pgoff);

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

oops info
---------------------------------8<--------------------------------------
Oct  2 11:24:02 amd-pence-01 kernel: rep: Corrupted page table at address 7f911ffc8000
Oct  2 11:24:02 amd-pence-01 kernel: PGD c18db067 PUD c270e067 PMD c3864067 PTE 80080000000a0225
Oct  2 11:24:02 amd-pence-01 kernel: Bad pagetable: 000d [#1] SMP
Oct  2 11:24:02 amd-pence-01 kernel: Modules linked in: cpufreq_ondemand(F) ipv6(F) microcode(F) pcspkr(F) serio_raw(F) acpi_cpufreq(F) freq_table(F) fam15h_power(F) k10temp(F) amd64_edac_mod(F) edac_core(F) edac_mce_amd(F) i2c_piix4(F) sg(F) bnx2(F) ext4(F) jbd2(F) mbcache(F) sd_mod(F) crc_t10dif(F) crct10dif_common(F) sr_mod(F) cdrom(F) ata_generic(F) pata_acpi(F) pata_atiixp(F) ahci(F) libahci(F) radeon(F) ttm(F) drm_kms_helper(F) drm(F) i2c_algo_bit(F) i2c_core(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F)
Oct  2 11:24:02 amd-pence-01 kernel: CPU: 11 PID: 2303 Comm: rep Tainted: GF            3.12.0-rc3+ #1
Oct  2 11:24:02 amd-pence-01 kernel: Hardware name: AMD Pence/Pence, BIOS WPN2905X_Weekly_12_09_05 09/03/2012
Oct  2 11:24:02 amd-pence-01 kernel: task: ffff8800c3912ae0 ti: ffff8800c3838000 task.ti: ffff8800c3838000
Oct  2 11:24:02 amd-pence-01 kernel: RIP: 0033:[<0000000000400776>]  [<0000000000400776>] 0x400775
Oct  2 11:24:02 amd-pence-01 kernel: RSP: 002b:00007fff2d34da10  EFLAGS: 00010213
Oct  2 11:24:02 amd-pence-01 kernel: RAX: 00007f911ffc8000 RBX: 0000000000000000 RCX: 00007f911fafd51a
Oct  2 11:24:02 amd-pence-01 kernel: RDX: 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
Oct  2 11:24:02 amd-pence-01 kernel: RBP: 00007fff2d34da50 R08: 0000000000000003 R09: 00080000000a0000
Oct  2 11:24:02 amd-pence-01 kernel: R10: 0000000000000001 R11: 0000000000000202 R12: 0000000000400590
Oct  2 11:24:02 amd-pence-01 kernel: R13: 00007fff2d34db30 R14: 0000000000000000 R15: 0000000000000000
Oct  2 11:24:02 amd-pence-01 kernel: FS:  00007f911ffce700(0000) GS:ffff880136cc0000(0000) knlGS:0000000000000000
Oct  2 11:24:02 amd-pence-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Oct  2 11:24:02 amd-pence-01 kernel: CR2: 00007f911ffc8000 CR3: 00000000c39ec000 CR4: 00000000000407e0
Oct  2 11:24:02 amd-pence-01 kernel:
Oct  2 11:24:02 amd-pence-01 kernel: RIP  [<0000000000400776>] 0x400775
Oct  2 11:24:02 amd-pence-01 kernel: RSP <00007fff2d34da10>
Oct  2 11:24:02 amd-pence-01 kernel: ---[ end trace 8a123cd70049eebc ]---
---------------------------------8<--------------------------------------

Please note the PTE value 80080000000a0225.

Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
---
 arch/x86/include/asm/io.h |  4 ++++
 arch/x86/mm/mmap.c        | 13 +++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 34f69cb..af9f363 100644
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
index 25e7e13..ef02a93 100644
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
+	resource_size_t addr = (pfn << PAGE_SHIFT) + count;
+	return phys_addr_valid(addr);
+}
-- 
1.8.3.1


-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
