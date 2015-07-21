Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 55ED29003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:59:45 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so140384671qkd.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 12:59:45 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id 123si29576350qha.40.2015.07.21.12.59.42
        for <linux-mm@kvack.org>;
        Tue, 21 Jul 2015 12:59:43 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall system calls
Date: Tue, 21 Jul 2015 15:59:37 -0400
Message-Id: <1437508781-28655-3-git-send-email-emunson@akamai.com>
In-Reply-To: <1437508781-28655-1-git-send-email-emunson@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

With the refactored mlock code, introduce new system calls for mlock,
munlock, and munlockall.  The new calls will allow the user to specify
what lock states are being added or cleared.  mlock2 and munlock2 are
trivial at the moment, but a follow on patch will add a new mlock state
making them useful.

munlock2 addresses a limitation of the current implementation.  If a
user calls mlockall(MCL_CURRENT | MCL_FUTURE) and then later decides
that MCL_FUTURE should be removed, they would have to call munlockall()
followed by mlockall(MCL_CURRENT) which could potentially be very
expensive.  The new munlockall2 system call allows a user to simply
clear the MCL_FUTURE flag.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: adi-buildroot-devel@lists.sourceforge.net
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-mips@linux-mips.org
Cc: linux-am33-list@redhat.com
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
---
Changes from V3:
* Do a (hopefully) complete job of adding the new system calls

 arch/alpha/include/asm/unistd.h           |  2 +-
 arch/alpha/include/uapi/asm/mman.h        |  2 ++
 arch/alpha/include/uapi/asm/unistd.h      |  3 +++
 arch/alpha/kernel/systbls.S               |  3 +++
 arch/arm/include/asm/unistd.h             |  2 +-
 arch/arm/include/uapi/asm/unistd.h        |  3 +++
 arch/arm/kernel/calls.S                   |  3 +++
 arch/arm64/include/asm/unistd32.h         |  6 ++++++
 arch/avr32/include/uapi/asm/unistd.h      |  3 +++
 arch/avr32/kernel/syscall_table.S         |  3 +++
 arch/blackfin/include/uapi/asm/unistd.h   |  3 +++
 arch/blackfin/mach-common/entry.S         |  3 +++
 arch/cris/arch-v10/kernel/entry.S         |  3 +++
 arch/cris/arch-v32/kernel/entry.S         |  3 +++
 arch/frv/kernel/entry.S                   |  3 +++
 arch/ia64/include/asm/unistd.h            |  2 +-
 arch/ia64/include/uapi/asm/unistd.h       |  3 +++
 arch/ia64/kernel/entry.S                  |  3 +++
 arch/m32r/kernel/entry.S                  |  3 +++
 arch/m32r/kernel/syscall_table.S          |  3 +++
 arch/m68k/include/asm/unistd.h            |  2 +-
 arch/m68k/include/uapi/asm/unistd.h       |  3 +++
 arch/m68k/kernel/syscalltable.S           |  3 +++
 arch/microblaze/include/uapi/asm/unistd.h |  3 +++
 arch/microblaze/kernel/syscall_table.S    |  3 +++
 arch/mips/include/uapi/asm/mman.h         |  5 +++++
 arch/mips/include/uapi/asm/unistd.h       | 21 +++++++++++++++------
 arch/mips/kernel/scall32-o32.S            |  3 +++
 arch/mips/kernel/scall64-64.S             |  3 +++
 arch/mips/kernel/scall64-n32.S            |  3 +++
 arch/mips/kernel/scall64-o32.S            |  3 +++
 arch/mn10300/kernel/entry.S               |  3 +++
 arch/parisc/include/uapi/asm/mman.h       |  2 ++
 arch/parisc/include/uapi/asm/unistd.h     |  5 ++++-
 arch/powerpc/include/uapi/asm/mman.h      |  2 ++
 arch/powerpc/include/uapi/asm/unistd.h    |  3 +++
 arch/s390/include/uapi/asm/unistd.h       |  5 ++++-
 arch/s390/kernel/compat_wrapper.c         |  3 +++
 arch/s390/kernel/syscalls.S               |  3 +++
 arch/sh/kernel/syscalls_32.S              |  3 +++
 arch/sparc/include/uapi/asm/mman.h        |  2 ++
 arch/sparc/include/uapi/asm/unistd.h      |  5 ++++-
 arch/sparc/kernel/systbls_32.S            |  2 +-
 arch/sparc/kernel/systbls_64.S            |  4 ++--
 arch/tile/include/uapi/asm/mman.h         |  5 +++++
 arch/x86/entry/syscalls/syscall_32.tbl    |  3 +++
 arch/x86/entry/syscalls/syscall_64.tbl    |  3 +++
 arch/xtensa/include/uapi/asm/mman.h       |  5 +++++
 arch/xtensa/include/uapi/asm/unistd.h     | 10 ++++++++--
 include/linux/syscalls.h                  |  4 ++++
 include/uapi/asm-generic/mman.h           |  2 ++
 include/uapi/asm-generic/unistd.h         |  8 +++++++-
 kernel/sys_ni.c                           |  3 +++
 mm/mlock.c                                | 28 ++++++++++++++++++++++++++++
 54 files changed, 205 insertions(+), 19 deletions(-)

diff --git a/arch/alpha/include/asm/unistd.h b/arch/alpha/include/asm/unistd.h
index a56e608..1d09392 100644
--- a/arch/alpha/include/asm/unistd.h
+++ b/arch/alpha/include/asm/unistd.h
@@ -3,7 +3,7 @@
 
 #include <uapi/asm/unistd.h>
 
-#define NR_SYSCALLS			514
+#define NR_SYSCALLS			517
 
 #define __ARCH_WANT_OLD_READDIR
 #define __ARCH_WANT_STAT64
diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index 0086b47..ec72436 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -38,6 +38,8 @@
 #define MCL_CURRENT	 8192		/* lock all currently mapped pages */
 #define MCL_FUTURE	16384		/* lock all additions to address space */
 
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
diff --git a/arch/alpha/include/uapi/asm/unistd.h b/arch/alpha/include/uapi/asm/unistd.h
index aa33bf5..29141d6 100644
--- a/arch/alpha/include/uapi/asm/unistd.h
+++ b/arch/alpha/include/uapi/asm/unistd.h
@@ -475,5 +475,8 @@
 #define __NR_getrandom			511
 #define __NR_memfd_create		512
 #define __NR_execveat			513
+#define __NR_mlock2			514
+#define __NR_munlock2			515
+#define __NR_munlockall2		516
 
 #endif /* _UAPI_ALPHA_UNISTD_H */
diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.S
index 9b62e3f..04d1cce 100644
--- a/arch/alpha/kernel/systbls.S
+++ b/arch/alpha/kernel/systbls.S
@@ -532,6 +532,9 @@ sys_call_table:
 	.quad sys_getrandom
 	.quad sys_memfd_create
 	.quad sys_execveat
+	.quad sys_mlock2
+	.quad sys_munlock2			/* 515 */
+	.quad sys_munlockall2
 
 	.size sys_call_table, . - sys_call_table
 	.type sys_call_table, @object
diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index 32640c4..7cba573 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -19,7 +19,7 @@
  * This may need to be greater than __NR_last_syscall+1 in order to
  * account for the padding in the syscall table
  */
-#define __NR_syscalls  (388)
+#define __NR_syscalls  (392)
 
 /*
  * *NOTE*: This is a ghost syscall private to the kernel.  Only the
diff --git a/arch/arm/include/uapi/asm/unistd.h b/arch/arm/include/uapi/asm/unistd.h
index 0c3f5a0..46eaf405 100644
--- a/arch/arm/include/uapi/asm/unistd.h
+++ b/arch/arm/include/uapi/asm/unistd.h
@@ -414,6 +414,9 @@
 #define __NR_memfd_create		(__NR_SYSCALL_BASE+385)
 #define __NR_bpf			(__NR_SYSCALL_BASE+386)
 #define __NR_execveat			(__NR_SYSCALL_BASE+387)
+#define __NR_mlock2			(__NR_SYSCALL_BASE+388)
+#define __NR_munlock2			(__NR_SYSCALL_BASE+389)
+#define __NR_munlockall2		(__NR_SYSCALL_BASE+390)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 05745eb..8880822 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -397,6 +397,9 @@
 /* 385 */	CALL(sys_memfd_create)
 		CALL(sys_bpf)
 		CALL(sys_execveat)
+		CALL(sys_mlock2)
+		CALL(sys_munlock2)
+/* 390 */	CALL(sys_munlockall2)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/arm64/include/asm/unistd32.h b/arch/arm64/include/asm/unistd32.h
index cef934a..318072aa 100644
--- a/arch/arm64/include/asm/unistd32.h
+++ b/arch/arm64/include/asm/unistd32.h
@@ -797,3 +797,9 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
 __SYSCALL(__NR_bpf, sys_bpf)
 #define __NR_execveat 387
 __SYSCALL(__NR_execveat, compat_sys_execveat)
+#define __NR_mlock2 388
+__SYSCALL(__NR_mlock2, sys_mlock2)
+#define __NR_munlock2 389
+__SYSCALL(__NR_munlock2, sys_munlock2)
+#define __NR_munlockall2 390
+__SYSCALL(__NR_munlockall2, sys_munlockall2)
diff --git a/arch/avr32/include/uapi/asm/unistd.h b/arch/avr32/include/uapi/asm/unistd.h
index bbe2fba..e6a1681 100644
--- a/arch/avr32/include/uapi/asm/unistd.h
+++ b/arch/avr32/include/uapi/asm/unistd.h
@@ -333,5 +333,8 @@
 #define __NR_memfd_create	318
 #define __NR_bpf		319
 #define __NR_execveat		320
+#define __NR_mlock2		321
+#define __NR_munlock2		322
+#define __NR_munlockall2	323
 
 #endif /* _UAPI__ASM_AVR32_UNISTD_H */
diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/syscall_table.S
index c3b593b..83928ab 100644
--- a/arch/avr32/kernel/syscall_table.S
+++ b/arch/avr32/kernel/syscall_table.S
@@ -334,4 +334,7 @@ sys_call_table:
 	.long	sys_memfd_create
 	.long	sys_bpf
 	.long	sys_execveat		/* 320 */
+	.long   sys_mlock2
+	.long   sys_munlock2
+	.long   sys_munlockall2
 	.long	sys_ni_syscall		/* r8 is saturated at nr_syscalls */
diff --git a/arch/blackfin/include/uapi/asm/unistd.h b/arch/blackfin/include/uapi/asm/unistd.h
index 0cb9078..37c0362 100644
--- a/arch/blackfin/include/uapi/asm/unistd.h
+++ b/arch/blackfin/include/uapi/asm/unistd.h
@@ -433,6 +433,9 @@
 #define __IGNORE_munlock
 #define __IGNORE_mlockall
 #define __IGNORE_munlockall
+#define __IGNORE_mlock2
+#define __IGNORE_munlock2
+#define __IGNORE_munlockall2
 #define __IGNORE_mincore
 #define __IGNORE_madvise
 #define __IGNORE_remap_file_pages
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index 8d9431e..5d83587 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1704,6 +1704,9 @@ ENTRY(_sys_call_table)
 	.long _sys_memfd_create		/* 390 */
 	.long _sys_bpf
 	.long _sys_execveat
+	.long _sys_mlock2
+	.long _sys_munlock2
+	.long _sys_munlockall2		/* 395 */
 
 	.rept NR_syscalls-(.-_sys_call_table)/4
 	.long _sys_ni_syscall
diff --git a/arch/cris/arch-v10/kernel/entry.S b/arch/cris/arch-v10/kernel/entry.S
index 81570fc..d0ce531 100644
--- a/arch/cris/arch-v10/kernel/entry.S
+++ b/arch/cris/arch-v10/kernel/entry.S
@@ -955,6 +955,9 @@ sys_call_table:
 	.long sys_process_vm_writev
 	.long sys_kcmp			/* 350 */
 	.long sys_finit_module
+	.long sys_mlock2
+	.long sys_munlock2
+	.long sys_munlockall2
 
         /*
          * NOTE!! This doesn't have to be exact - we just have
diff --git a/arch/cris/arch-v32/kernel/entry.S b/arch/cris/arch-v32/kernel/entry.S
index 026a0b2..7f50a0b 100644
--- a/arch/cris/arch-v32/kernel/entry.S
+++ b/arch/cris/arch-v32/kernel/entry.S
@@ -875,6 +875,9 @@ sys_call_table:
 	.long sys_process_vm_writev
 	.long sys_kcmp			/* 350 */
 	.long sys_finit_module
+	.long sys_mlock2
+	.long sys_munlock2
+	.long sys_munlockall2
 
 	/*
 	 * NOTE!! This doesn't have to be exact - we just have
diff --git a/arch/frv/kernel/entry.S b/arch/frv/kernel/entry.S
index dfcd263..ee605a0 100644
--- a/arch/frv/kernel/entry.S
+++ b/arch/frv/kernel/entry.S
@@ -1515,5 +1515,8 @@ sys_call_table:
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
 	.long sys_setns
+	.long sys_mlock2
+	.long sys_munlock2
+	.long sys_munlockall2		/* 340 */
 
 syscall_table_size = (. - sys_call_table)
diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 95c39b9..db73390 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -11,7 +11,7 @@
 
 
 
-#define NR_syscalls			319 /* length of syscall table */
+#define NR_syscalls			322 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index 4610795..5f485cc 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -332,5 +332,8 @@
 #define __NR_memfd_create		1340
 #define __NR_bpf			1341
 #define __NR_execveat			1342
+#define __NR_mlock2			1343
+#define __NR_munlock2			1344
+#define __NR_munlockall2		1345
 
 #endif /* _UAPI_ASM_IA64_UNISTD_H */
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index ae0de7b..3ef4457 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1768,5 +1768,8 @@ sys_call_table:
 	data8 sys_memfd_create			// 1340
 	data8 sys_bpf
 	data8 sys_execveat
+	data8 sys_mlock2
+	data8 sys_munlock2
+	data8 sys_munlockall2			// 1345
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/arch/m32r/kernel/entry.S b/arch/m32r/kernel/entry.S
index c639bfa..4f7f2e2 100644
--- a/arch/m32r/kernel/entry.S
+++ b/arch/m32r/kernel/entry.S
@@ -76,6 +76,9 @@
 #define sys_munlock		sys_ni_syscall
 #define sys_mlockall		sys_ni_syscall
 #define sys_munlockall		sys_ni_syscall
+#define sys_mlock2		sys_ni_syscall
+#define sys_munlock2		sys_ni_syscall
+#define sys_munlockall2		sys_ni_syscall
 #define sys_mremap		sys_ni_syscall
 #define sys_mincore		sys_ni_syscall
 #define sys_remap_file_pages	sys_ni_syscall
diff --git a/arch/m32r/kernel/syscall_table.S b/arch/m32r/kernel/syscall_table.S
index f365c19..9918c3e 100644
--- a/arch/m32r/kernel/syscall_table.S
+++ b/arch/m32r/kernel/syscall_table.S
@@ -325,3 +325,6 @@ ENTRY(sys_call_table)
 	.long sys_eventfd
 	.long sys_fallocate
 	.long sys_setns			/* 325 */
+	.long sys_mlock2
+	.long sys_munlock2
+	.long sys_munlockall2
diff --git a/arch/m68k/include/asm/unistd.h b/arch/m68k/include/asm/unistd.h
index 244e0db..b18f3da 100644
--- a/arch/m68k/include/asm/unistd.h
+++ b/arch/m68k/include/asm/unistd.h
@@ -4,7 +4,7 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		356
+#define NR_syscalls		359
 
 #define __ARCH_WANT_OLD_READDIR
 #define __ARCH_WANT_OLD_STAT
diff --git a/arch/m68k/include/uapi/asm/unistd.h b/arch/m68k/include/uapi/asm/unistd.h
index 61fb6cb..1405c3f 100644
--- a/arch/m68k/include/uapi/asm/unistd.h
+++ b/arch/m68k/include/uapi/asm/unistd.h
@@ -361,5 +361,8 @@
 #define __NR_memfd_create	353
 #define __NR_bpf		354
 #define __NR_execveat		355
+#define __NR_mlock2		356
+#define __NR_munlock2		357
+#define __NR_munlockall2	358
 
 #endif /* _UAPI_ASM_M68K_UNISTD_H_ */
diff --git a/arch/m68k/kernel/syscalltable.S b/arch/m68k/kernel/syscalltable.S
index a0ec430..7963c03 100644
--- a/arch/m68k/kernel/syscalltable.S
+++ b/arch/m68k/kernel/syscalltable.S
@@ -376,4 +376,7 @@ ENTRY(sys_call_table)
 	.long sys_memfd_create
 	.long sys_bpf
 	.long sys_execveat		/* 355 */
+	.long sys_mlock2
+	.long sys_munlock2
+	.long sys_munlockall2
 
diff --git a/arch/microblaze/include/uapi/asm/unistd.h b/arch/microblaze/include/uapi/asm/unistd.h
index 32850c7..59b06b0 100644
--- a/arch/microblaze/include/uapi/asm/unistd.h
+++ b/arch/microblaze/include/uapi/asm/unistd.h
@@ -404,5 +404,8 @@
 #define __NR_memfd_create	386
 #define __NR_bpf		387
 #define __NR_execveat		388
+#define __NR_mlock2		389 /* ok - nommu or mmu */
+#define __NR_munlock2		390 /* ok - nommu or mmu */
+#define __NR_munlockall2	391 /* ok - nommu or mmu */
 
 #endif /* _UAPI_ASM_MICROBLAZE_UNISTD_H */
diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze/kernel/syscall_table.S
index 29c8568..6e4b0fe 100644
--- a/arch/microblaze/kernel/syscall_table.S
+++ b/arch/microblaze/kernel/syscall_table.S
@@ -389,3 +389,6 @@ ENTRY(sys_call_table)
 	.long sys_memfd_create
 	.long sys_bpf
 	.long sys_execveat
+	.long sys_mlock2
+	.long sys_munlock2		/* 390 */
+	.long sys_munlockall2
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index cfcb876..67c1cdf 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -62,6 +62,11 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+/*
+ * Flags for mlock
+ */
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
 #define MADV_SEQUENTIAL 2		/* expect sequential page references */
diff --git a/arch/mips/include/uapi/asm/unistd.h b/arch/mips/include/uapi/asm/unistd.h
index c03088f..101b884 100644
--- a/arch/mips/include/uapi/asm/unistd.h
+++ b/arch/mips/include/uapi/asm/unistd.h
@@ -377,16 +377,19 @@
 #define __NR_memfd_create		(__NR_Linux + 354)
 #define __NR_bpf			(__NR_Linux + 355)
 #define __NR_execveat			(__NR_Linux + 356)
+#define __NR_mlock2			(__NR_Linux + 357)
+#define __NR_munlock2			(__NR_Linux + 358)
+#define __NR_munlockall2		(__NR_Linux + 359)
 
 /*
  * Offset of the last Linux o32 flavoured syscall
  */
-#define __NR_Linux_syscalls		356
+#define __NR_Linux_syscalls		359
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI32 */
 
 #define __NR_O32_Linux			4000
-#define __NR_O32_Linux_syscalls		356
+#define __NR_O32_Linux_syscalls		359
 
 #if _MIPS_SIM == _MIPS_SIM_ABI64
 
@@ -711,16 +714,19 @@
 #define __NR_memfd_create		(__NR_Linux + 314)
 #define __NR_bpf			(__NR_Linux + 315)
 #define __NR_execveat			(__NR_Linux + 316)
+#define __NR_mlock2			(__NR_Linux + 317)
+#define __NR_munlock2			(__NR_Linux + 318)
+#define __NR_munlockall2		(__NR_Linux + 319)
 
 /*
  * Offset of the last Linux 64-bit flavoured syscall
  */
-#define __NR_Linux_syscalls		316
+#define __NR_Linux_syscalls		319
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI64 */
 
 #define __NR_64_Linux			5000
-#define __NR_64_Linux_syscalls		316
+#define __NR_64_Linux_syscalls		319
 
 #if _MIPS_SIM == _MIPS_SIM_NABI32
 
@@ -1049,15 +1055,18 @@
 #define __NR_memfd_create		(__NR_Linux + 318)
 #define __NR_bpf			(__NR_Linux + 319)
 #define __NR_execveat			(__NR_Linux + 320)
+#define __NR_mlock2			(__NR_Linux + 321)
+#define __NR_munlock2			(__NR_Linux + 322)
+#define __NR_munlockall2		(__NR_Linux + 323)
 
 /*
  * Offset of the last N32 flavoured syscall
  */
-#define __NR_Linux_syscalls		320
+#define __NR_Linux_syscalls		323
 
 #endif /* _MIPS_SIM == _MIPS_SIM_NABI32 */
 
 #define __NR_N32_Linux			6000
-#define __NR_N32_Linux_syscalls		320
+#define __NR_N32_Linux_syscalls		323
 
 #endif /* _UAPI_ASM_UNISTD_H */
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index 4cc1350..c409d53 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -599,3 +599,6 @@ EXPORT(sys_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 4355 */
 	PTR	sys_execveat
+	PTR	sys_mlock2
+	PTR	sys_munlock2
+	PTR	sys_munlockall2
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index ad4d4463..0aa2742 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -436,4 +436,7 @@ EXPORT(sys_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 5315 */
 	PTR	sys_execveat
+	PTR	sys_mlock2
+	PTR	sys_munlock2
+	PTR	sys_munlockall2
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index 446cc65..eb21955 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -429,4 +429,7 @@ EXPORT(sysn32_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf
 	PTR	compat_sys_execveat		/* 6320 */
+	PTR	sys_mlock2
+	PTR	sys_munlock2
+	PTR	sys_munlockall2
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index f543ff4..f45049c 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -584,4 +584,7 @@ EXPORT(sys32_call_table)
 	PTR	sys_memfd_create
 	PTR	sys_bpf				/* 4355 */
 	PTR	compat_sys_execveat
+	PTR	sys_mlock2
+	PTR	sys_munlock2
+	PTR	sys_munlockall2
 	.size	sys32_call_table,.-sys32_call_table
diff --git a/arch/mn10300/kernel/entry.S b/arch/mn10300/kernel/entry.S
index 177d61d..d34adf5 100644
--- a/arch/mn10300/kernel/entry.S
+++ b/arch/mn10300/kernel/entry.S
@@ -767,6 +767,9 @@ ENTRY(sys_call_table)
 	.long sys_perf_event_open
 	.long sys_recvmmsg
 	.long sys_setns
+	.long sys_mlock2		/* 340 */
+	.long sys_munlock2
+	.long sys_munlockall2
 
 
 nr_syscalls=(.-sys_call_table)/4
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index 294d251..daab994 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -32,6 +32,8 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MADV_NORMAL     0               /* no further special treatment */
 #define MADV_RANDOM     1               /* expect random page references */
 #define MADV_SEQUENTIAL 2               /* expect sequential page references */
diff --git a/arch/parisc/include/uapi/asm/unistd.h b/arch/parisc/include/uapi/asm/unistd.h
index 2e639d7..455c8a3 100644
--- a/arch/parisc/include/uapi/asm/unistd.h
+++ b/arch/parisc/include/uapi/asm/unistd.h
@@ -358,8 +358,11 @@
 #define __NR_memfd_create	(__NR_Linux + 340)
 #define __NR_bpf		(__NR_Linux + 341)
 #define __NR_execveat		(__NR_Linux + 342)
+#define __NR_mlock2		(__NR_Linux + 343)
+#define __NR_munlock2		(__NR_Linux + 344)
+#define __NR_munlockall2	(__NR_Linux + 345)
 
-#define __NR_Linux_syscalls	(__NR_execveat + 1)
+#define __NR_Linux_syscalls	(__NR_munlockall2 + 1)
 
 
 #define __IGNORE_select		/* newselect */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 6ea26df..189e85f 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -23,6 +23,8 @@
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
 
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index e4aa173..c9901e7 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -386,5 +386,8 @@
 #define __NR_bpf		361
 #define __NR_execveat		362
 #define __NR_switch_endian	363
+#define __NR_mlock2		364
+#define __NR_munlock2		365
+#define __NR_munlockall2	366
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
diff --git a/arch/s390/include/uapi/asm/unistd.h b/arch/s390/include/uapi/asm/unistd.h
index 67878af..d1c5b1f 100644
--- a/arch/s390/include/uapi/asm/unistd.h
+++ b/arch/s390/include/uapi/asm/unistd.h
@@ -290,7 +290,10 @@
 #define __NR_s390_pci_mmio_write	352
 #define __NR_s390_pci_mmio_read		353
 #define __NR_execveat		354
-#define NR_syscalls 355
+#define __NR_mlock2		355
+#define __NR_munlock2		356
+#define __NR_munlockall2	357
+#define NR_syscalls 358
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/compat_wrapper.c b/arch/s390/kernel/compat_wrapper.c
index f8498dd..58339e2 100644
--- a/arch/s390/kernel/compat_wrapper.c
+++ b/arch/s390/kernel/compat_wrapper.c
@@ -220,3 +220,6 @@ COMPAT_SYSCALL_WRAP2(memfd_create, const char __user *, uname, unsigned int, fla
 COMPAT_SYSCALL_WRAP3(bpf, int, cmd, union bpf_attr *, attr, unsigned int, size);
 COMPAT_SYSCALL_WRAP3(s390_pci_mmio_write, const unsigned long, mmio_addr, const void __user *, user_buffer, const size_t, length);
 COMPAT_SYSCALL_WRAP3(s390_pci_mmio_read, const unsigned long, mmio_addr, void __user *, user_buffer, const size_t, length);
+COMPAT_SYSCALL_WRAP3(mlock2, unsigned long, start, size_t, len, int, flags);
+COMPAT_SYSCALL_WRAP3(munlock2, unsigned long, start, size_t, len, int, flags);
+COMPAT_SYSCALL_WRAP1(munlockall2, int, flags);
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 1acad02..f6d81d6 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -363,3 +363,6 @@ SYSCALL(sys_bpf,compat_sys_bpf)
 SYSCALL(sys_s390_pci_mmio_write,compat_sys_s390_pci_mmio_write)
 SYSCALL(sys_s390_pci_mmio_read,compat_sys_s390_pci_mmio_read)
 SYSCALL(sys_execveat,compat_sys_execveat)
+SYSCALL(sys_mlock2,compat_sys_mlock2)			/* 355 */
+SYSCALL(sys_munlock2,compat_sys_munlock2)
+SYSCALL(sys_munlockall2,compat_sys_munlockall2)
diff --git a/arch/sh/kernel/syscalls_32.S b/arch/sh/kernel/syscalls_32.S
index 734234b..6d07867 100644
--- a/arch/sh/kernel/syscalls_32.S
+++ b/arch/sh/kernel/syscalls_32.S
@@ -386,3 +386,6 @@ ENTRY(sys_call_table)
 	.long sys_process_vm_writev
 	.long sys_kcmp
 	.long sys_finit_module
+	.long sys_mlock2
+	.long sys_munlock2		/* 370 */
+	.long sys_munlockall2
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 0b14df3..13d51be 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -18,6 +18,8 @@
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
 
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
diff --git a/arch/sparc/include/uapi/asm/unistd.h b/arch/sparc/include/uapi/asm/unistd.h
index 6f35f4d..c25bbb1 100644
--- a/arch/sparc/include/uapi/asm/unistd.h
+++ b/arch/sparc/include/uapi/asm/unistd.h
@@ -416,8 +416,11 @@
 #define __NR_memfd_create	348
 #define __NR_bpf		349
 #define __NR_execveat		350
+#define __NR_mlock2		351
+#define __NR_munlock2		352
+#define __NR_munlockall2	353
 
-#define NR_syscalls		351
+#define NR_syscalls		354
 
 /* Bitmask values returned from kern_features system call.  */
 #define KERN_FEATURE_MIXED_MODE_STACK	0x00000001
diff --git a/arch/sparc/kernel/systbls_32.S b/arch/sparc/kernel/systbls_32.S
index e31a905..72b68d4 100644
--- a/arch/sparc/kernel/systbls_32.S
+++ b/arch/sparc/kernel/systbls_32.S
@@ -87,4 +87,4 @@ sys_call_table:
 /*335*/	.long sys_syncfs, sys_sendmmsg, sys_setns, sys_process_vm_readv, sys_process_vm_writev
 /*340*/	.long sys_ni_syscall, sys_kcmp, sys_finit_module, sys_sched_setattr, sys_sched_getattr
 /*345*/	.long sys_renameat2, sys_seccomp, sys_getrandom, sys_memfd_create, sys_bpf
-/*350*/	.long sys_execveat
+/*350*/	.long sys_execveat, sys_mlock2, sys_munlock2, sys_munlockall2
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
index d72f76a..a96bfea 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -88,7 +88,7 @@ sys_call_table32:
 	.word sys_syncfs, compat_sys_sendmmsg, sys_setns, compat_sys_process_vm_readv, compat_sys_process_vm_writev
 /*340*/	.word sys_kern_features, sys_kcmp, sys_finit_module, sys_sched_setattr, sys_sched_getattr
 	.word sys32_renameat2, sys_seccomp, sys_getrandom, sys_memfd_create, sys_bpf
-/*350*/	.word sys32_execveat
+/*350*/	.word sys32_execveat, sys_mlock2, sys_munlock2, sys_munlockall2
 
 #endif /* CONFIG_COMPAT */
 
@@ -168,4 +168,4 @@ sys_call_table:
 	.word sys_syncfs, sys_sendmmsg, sys_setns, sys_process_vm_readv, sys_process_vm_writev
 /*340*/	.word sys_kern_features, sys_kcmp, sys_finit_module, sys_sched_setattr, sys_sched_getattr
 	.word sys_renameat2, sys_seccomp, sys_getrandom, sys_memfd_create, sys_bpf
-/*350*/	.word sys64_execveat
+/*350*/	.word sys64_execveat, sys_mlock2, sys_munlock2, sys_munlockall2
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index 81b8fc3..f69ce48 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -37,5 +37,10 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+/*
+ * Flags for mlock
+ */
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 
 #endif /* _ASM_TILE_MMAN_H */
diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index ef8187f..13ce950 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -365,3 +365,6 @@
 356	i386	memfd_create		sys_memfd_create
 357	i386	bpf			sys_bpf
 358	i386	execveat		sys_execveat			stub32_execveat
+359	i386	mlock2			sys_mlock2
+360	i386	munlock2		sys_munlock2
+361	i386	munlockall2		sys_munlockall2
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 9ef32d5..13b3cb1 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -329,6 +329,9 @@
 320	common	kexec_file_load		sys_kexec_file_load
 321	common	bpf			sys_bpf
 322	64	execveat		stub_execveat
+323	common	mlock2			sys_mlock2
+324	common	munlock2		sys_munlock2
+325	common	munlockall2		sys_munlockall2
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 201aec0..11f354f 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -75,6 +75,11 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+/*
+ * Flags for mlock
+ */
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
diff --git a/arch/xtensa/include/uapi/asm/unistd.h b/arch/xtensa/include/uapi/asm/unistd.h
index b95c305..fbd0876 100644
--- a/arch/xtensa/include/uapi/asm/unistd.h
+++ b/arch/xtensa/include/uapi/asm/unistd.h
@@ -753,8 +753,14 @@ __SYSCALL(339, sys_memfd_create, 2)
 __SYSCALL(340, sys_bpf, 3)
 #define __NR_execveat				341
 __SYSCALL(341, sys_execveat, 5)
-
-#define __NR_syscall_count			342
+#define __NR_mlock2				342
+__SYSCALL(342, sys_mlock2, 3)
+#define __NR_munlock2				343
+__SYSCALL(343, sys_munlock2, 3)
+#define __NR_munlockall2			344
+__SYSCALL(344, sys_munlock2, 1)
+
+#define __NR_syscall_count			345
 
 /*
  * sysxtensa syscall handler
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index b45c45b..aecab5d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -884,4 +884,8 @@ asmlinkage long sys_execveat(int dfd, const char __user *filename,
 			const char __user *const __user *argv,
 			const char __user *const __user *envp, int flags);
 
+asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
+asmlinkage long sys_munlock2(unsigned long start, size_t len, int flags);
+asmlinkage long sys_munlockall2(int flags);
+
 #endif
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index e9fe6fd..242436b 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -18,4 +18,6 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+#define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+
 #endif /* __ASM_GENERIC_MMAN_H */
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index e016bd9..e759fa2 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -709,9 +709,15 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
 __SYSCALL(__NR_bpf, sys_bpf)
 #define __NR_execveat 281
 __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
+#define __NR_mlock2 282
+__SYSCALL(__NR_mlock2, sys_mlock2)
+#define __NR_munlock2 283
+__SYSCALL(__NR_munlock2, sys_munlock2)
+#define __NR_munlockall2 284
+__SYSCALL(__NR_munlockall2, sys_munlockall2)
 
 #undef __NR_syscalls
-#define __NR_syscalls 282
+#define __NR_syscalls 285
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7995ef5..63529b7 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -193,6 +193,9 @@ cond_syscall(sys_mlock);
 cond_syscall(sys_munlock);
 cond_syscall(sys_mlockall);
 cond_syscall(sys_munlockall);
+cond_syscall(sys_mlock2);
+cond_syscall(sys_munlock2);
+cond_syscall(sys_munlockall2);
 cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
diff --git a/mm/mlock.c b/mm/mlock.c
index 8e52c23..d6e61d6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -648,6 +648,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	return do_mlock(start, len, VM_LOCKED);
 }
 
+SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
+{
+	if (!flags || flags & ~MLOCK_LOCKED)
+		return -EINVAL;
+
+	return do_mlock(start, len, VM_LOCKED);
+}
+
 static int do_munlock(unsigned long start, size_t len, vm_flags_t flags)
 {
 	int ret;
@@ -667,6 +675,13 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 	return do_munlock(start, len, VM_LOCKED);
 }
 
+SYSCALL_DEFINE3(munlock2, unsigned long, start, size_t, len, int, flags)
+{
+	if (!flags || flags & ~MLOCK_LOCKED)
+		return -EINVAL;
+	return do_munlock(start, len, VM_LOCKED);
+}
+
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
@@ -756,6 +771,19 @@ SYSCALL_DEFINE0(munlockall)
 	return ret;
 }
 
+SYSCALL_DEFINE1(munlockall2, int, flags)
+{
+	int ret = -EINVAL;
+
+	if (!flags || flags & ~(MCL_CURRENT | MCL_FUTURE))
+		return ret;
+
+	down_write(&current->mm->mmap_sem);
+	ret = do_munlockall(flags);
+	up_write(&current->mm->mmap_sem);
+	return ret;
+}
+
 /*
  * Objects with different lifetime than processes (SHM_LOCK and SHM_HUGETLB
  * shm segments) get accounted against the user_struct instead.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
