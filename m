Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id C8AB36B0255
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 13:03:57 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so87286562qge.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 10:03:57 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id m76si25625732qkh.92.2015.07.07.10.03.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 10:03:52 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3 2/5] mm: mlock: Add new mlock, munlock, and munlockall system calls
Date: Tue,  7 Jul 2015 13:03:40 -0400
Message-Id: <1436288623-13007-3-git-send-email-emunson@akamai.com>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

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
 arch/alpha/include/asm/unistd.h        |  2 +-
 arch/alpha/include/uapi/asm/mman.h     |  2 ++
 arch/alpha/kernel/systbls.S            |  3 +++
 arch/arm/kernel/calls.S                |  3 +++
 arch/arm64/include/asm/unistd32.h      |  6 ++++++
 arch/avr32/kernel/syscall_table.S      |  3 +++
 arch/blackfin/mach-common/entry.S      |  3 +++
 arch/cris/arch-v10/kernel/entry.S      |  3 +++
 arch/cris/arch-v32/kernel/entry.S      |  3 +++
 arch/frv/kernel/entry.S                |  3 +++
 arch/ia64/kernel/entry.S               |  3 +++
 arch/m32r/kernel/entry.S               |  3 +++
 arch/m32r/kernel/syscall_table.S       |  3 +++
 arch/m68k/kernel/syscalltable.S        |  3 +++
 arch/microblaze/kernel/syscall_table.S |  3 +++
 arch/mips/include/uapi/asm/mman.h      |  5 +++++
 arch/mips/kernel/scall32-o32.S         |  3 +++
 arch/mips/kernel/scall64-64.S          |  3 +++
 arch/mips/kernel/scall64-n32.S         |  3 +++
 arch/mips/kernel/scall64-o32.S         |  3 +++
 arch/mn10300/kernel/entry.S            |  3 +++
 arch/parisc/include/uapi/asm/mman.h    |  2 ++
 arch/powerpc/include/uapi/asm/mman.h   |  2 ++
 arch/s390/kernel/syscalls.S            |  3 +++
 arch/sh/kernel/syscalls_32.S           |  3 +++
 arch/sparc/include/uapi/asm/mman.h     |  2 ++
 arch/sparc/kernel/systbls_32.S         |  2 +-
 arch/sparc/kernel/systbls_64.S         |  4 ++--
 arch/tile/include/uapi/asm/mman.h      |  5 +++++
 arch/x86/entry/syscalls/syscall_32.tbl |  3 +++
 arch/x86/entry/syscalls/syscall_64.tbl |  3 +++
 arch/xtensa/include/uapi/asm/mman.h    |  5 +++++
 arch/xtensa/include/uapi/asm/unistd.h  | 10 ++++++++--
 include/linux/syscalls.h               |  4 ++++
 include/uapi/asm-generic/mman.h        |  2 ++
 include/uapi/asm-generic/unistd.h      |  8 +++++++-
 kernel/sys_ni.c                        |  3 +++
 mm/mlock.c                             | 28 ++++++++++++++++++++++++++++
 38 files changed, 148 insertions(+), 7 deletions(-)

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
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 05745eb..514e77b 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -397,6 +397,9 @@
 /* 385 */	CALL(sys_memfd_create)
 		CALL(sys_bpf)
 		CALL(sys_execveat)
+		CALL(sys_mlock2)
+		CALL(sys_munlock2)
+/* 400 */	CALL(sys_munlockall2)
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
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index 6e8de80..7af6066 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -582,3 +582,6 @@ EXPORT(sys_call_table)
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
index d07b210..ee59c82 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -567,4 +567,7 @@ EXPORT(sys32_call_table)
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
index b95c305..961913c 100644
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
+__SYSCALL(342, sys_munlock2, 3)
+#define __NR_munlockall2			344
+__SYSCALL(342, sys_munlock2, 1)
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
