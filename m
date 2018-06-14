Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 711256B000D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:46:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o10-v6so3287633qtm.7
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:46:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10-v6sor2043697qvm.7.2018.06.13.17.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:46:53 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 04/24] selftests/vm: move arch-specific definitions to arch-specific header
Date: Wed, 13 Jun 2018 17:44:55 -0700
Message-Id: <1528937115-10132-5-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

From: Thiago Jung Bauermann <bauerman@linux.ibm.com>

In preparation for multi-arch support, move definitions which have
arch-specific values to x86-specific header.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |  111 +-----------------
 tools/testing/selftests/vm/pkey-x86.h        |  156 ++++++++++++++++++++++++++
 tools/testing/selftests/vm/protection_keys.c |   47 --------
 3 files changed, 162 insertions(+), 152 deletions(-)
 create mode 100644 tools/testing/selftests/vm/pkey-x86.h

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index 6ad1bd5..3ed2f02 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -21,9 +21,6 @@
 
 #define PTR_ERR_ENOTSUP ((void *)-ENOTSUP)
 
-#define NR_PKEYS 16
-#define PKEY_BITS_PER_PKEY 2
-
 #ifndef DEBUG_LEVEL
 #define DEBUG_LEVEL 0
 #endif
@@ -73,19 +70,13 @@ static inline void sigsafe_printf(const char *format, ...)
 	}					\
 } while (0)
 
+#if defined(__i386__) || defined(__x86_64__) /* arch */
+#include "pkey-x86.h"
+#else /* arch */
+#error Architecture not supported
+#endif /* arch */
+
 extern unsigned int shadow_pkey_reg;
-static inline unsigned int __read_pkey_reg(void)
-{
-	unsigned int eax, edx;
-	unsigned int ecx = 0;
-	unsigned int pkey_reg;
-
-	asm volatile(".byte 0x0f,0x01,0xee\n\t"
-		     : "=a" (eax), "=d" (edx)
-		     : "c" (ecx));
-	pkey_reg = eax;
-	return pkey_reg;
-}
 
 static inline unsigned int _read_pkey_reg(int line)
 {
@@ -100,19 +91,6 @@ static inline unsigned int _read_pkey_reg(int line)
 
 #define read_pkey_reg() _read_pkey_reg(__LINE__)
 
-static inline void __write_pkey_reg(unsigned int pkey_reg)
-{
-	unsigned int eax = pkey_reg;
-	unsigned int ecx = 0;
-	unsigned int edx = 0;
-
-	dprintf4("%s() changing %08x to %08x\n", __func__,
-			__read_pkey_reg(), pkey_reg);
-	asm volatile(".byte 0x0f,0x01,0xef\n\t"
-		     : : "a" (eax), "c" (ecx), "d" (edx));
-	assert(pkey_reg == __read_pkey_reg());
-}
-
 static inline void write_pkey_reg(unsigned int pkey_reg)
 {
 	dprintf4("%s() changing %08x to %08x\n", __func__,
@@ -157,83 +135,6 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
 	dprintf4("pkey_reg now: %08x\n", read_pkey_reg());
 }
 
-#define PAGE_SIZE 4096
-#define MB	(1<<20)
-
-static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
-		unsigned int *ecx, unsigned int *edx)
-{
-	/* ecx is often an input as well as an output. */
-	asm volatile(
-		"cpuid;"
-		: "=a" (*eax),
-		  "=b" (*ebx),
-		  "=c" (*ecx),
-		  "=d" (*edx)
-		: "0" (*eax), "2" (*ecx));
-}
-
-/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx) */
-#define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
-#define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
-
-static inline int cpu_has_pku(void)
-{
-	unsigned int eax;
-	unsigned int ebx;
-	unsigned int ecx;
-	unsigned int edx;
-
-	eax = 0x7;
-	ecx = 0x0;
-	__cpuid(&eax, &ebx, &ecx, &edx);
-
-	if (!(ecx & X86_FEATURE_PKU)) {
-		dprintf2("cpu does not have PKU\n");
-		return 0;
-	}
-	if (!(ecx & X86_FEATURE_OSPKE)) {
-		dprintf2("cpu does not have OSPKE\n");
-		return 0;
-	}
-	return 1;
-}
-
-#define XSTATE_PKEY_BIT	(9)
-#define XSTATE_PKEY	0x200
-
-int pkey_reg_xstate_offset(void)
-{
-	unsigned int eax;
-	unsigned int ebx;
-	unsigned int ecx;
-	unsigned int edx;
-	int xstate_offset;
-	int xstate_size;
-	unsigned long XSTATE_CPUID = 0xd;
-	int leaf;
-
-	/* assume that XSTATE_PKEY is set in XCR0 */
-	leaf = XSTATE_PKEY_BIT;
-	{
-		eax = XSTATE_CPUID;
-		ecx = leaf;
-		__cpuid(&eax, &ebx, &ecx, &edx);
-
-		if (leaf == XSTATE_PKEY_BIT) {
-			xstate_offset = ebx;
-			xstate_size = eax;
-		}
-	}
-
-	if (xstate_size == 0) {
-		printf("could not find size/offset of PKEY in xsave state\n");
-		return 0;
-	}
-
-	return xstate_offset;
-}
-
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
 #define ALIGN_UP(x, align_to)	(((x) + ((align_to)-1)) & ~((align_to)-1))
 #define ALIGN_DOWN(x, align_to) ((x) & ~((align_to)-1))
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
new file mode 100644
index 0000000..2f04ade
--- /dev/null
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -0,0 +1,156 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+
+#ifndef _PKEYS_X86_H
+#define _PKEYS_X86_H
+
+#ifdef __i386__
+
+#ifndef SYS_mprotect_key
+# define SYS_mprotect_key	380
+#endif
+
+#ifndef SYS_pkey_alloc
+# define SYS_pkey_alloc		381
+# define SYS_pkey_free		382
+#endif
+
+#define REG_IP_IDX		REG_EIP
+#define si_pkey_offset		0x14
+
+#else
+
+#ifndef SYS_mprotect_key
+# define SYS_mprotect_key	329
+#endif
+
+#ifndef SYS_pkey_alloc
+# define SYS_pkey_alloc		330
+# define SYS_pkey_free		331
+#endif
+
+#define REG_IP_IDX		REG_RIP
+#define si_pkey_offset		0x20
+
+#endif
+
+#ifndef PKEY_DISABLE_ACCESS
+# define PKEY_DISABLE_ACCESS	0x1
+#endif
+
+#ifndef PKEY_DISABLE_WRITE
+# define PKEY_DISABLE_WRITE	0x2
+#endif
+
+#define NR_PKEYS		16
+#define PKEY_BITS_PER_PKEY	2
+#define HPAGE_SIZE		(1UL<<21)
+#define PAGE_SIZE		4096
+#define MB			(1<<20)
+
+static inline void __page_o_noops(void)
+{
+	/* 8-bytes of instruction * 512 bytes = 1 page */
+	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
+}
+
+static inline unsigned int __read_pkey_reg(void)
+{
+	unsigned int eax, edx;
+	unsigned int ecx = 0;
+	unsigned int pkey_reg;
+
+	asm volatile(".byte 0x0f,0x01,0xee\n\t"
+		     : "=a" (eax), "=d" (edx)
+		     : "c" (ecx));
+	pkey_reg = eax;
+	return pkey_reg;
+}
+
+static inline void __write_pkey_reg(unsigned int pkey_reg)
+{
+	unsigned int eax = pkey_reg;
+	unsigned int ecx = 0;
+	unsigned int edx = 0;
+
+	dprintf4("%s() changing %08x to %08x\n", __func__,
+			__read_pkey_reg(), pkey_reg);
+	asm volatile(".byte 0x0f,0x01,0xef\n\t"
+		     : : "a" (eax), "c" (ecx), "d" (edx));
+	assert(pkey_reg == __read_pkey_reg());
+}
+
+static inline void __cpuid(unsigned int *eax, unsigned int *ebx,
+		unsigned int *ecx, unsigned int *edx)
+{
+	/* ecx is often an input as well as an output. */
+	asm volatile(
+		"cpuid;"
+		: "=a" (*eax),
+		  "=b" (*ebx),
+		  "=c" (*ecx),
+		  "=d" (*edx)
+		: "0" (*eax), "2" (*ecx));
+}
+
+/* Intel-defined CPU features, CPUID level 0x00000007:0 (ecx) */
+#define X86_FEATURE_PKU        (1<<3) /* Protection Keys for Userspace */
+#define X86_FEATURE_OSPKE      (1<<4) /* OS Protection Keys Enable */
+
+static inline int cpu_has_pku(void)
+{
+	unsigned int eax;
+	unsigned int ebx;
+	unsigned int ecx;
+	unsigned int edx;
+
+	eax = 0x7;
+	ecx = 0x0;
+	__cpuid(&eax, &ebx, &ecx, &edx);
+
+	if (!(ecx & X86_FEATURE_PKU)) {
+		dprintf2("cpu does not have PKU\n");
+		return 0;
+	}
+	if (!(ecx & X86_FEATURE_OSPKE)) {
+		dprintf2("cpu does not have OSPKE\n");
+		return 0;
+	}
+	return 1;
+}
+
+#define XSTATE_PKEY_BIT	(9)
+#define XSTATE_PKEY	0x200
+
+int pkey_reg_xstate_offset(void)
+{
+	unsigned int eax;
+	unsigned int ebx;
+	unsigned int ecx;
+	unsigned int edx;
+	int xstate_offset;
+	int xstate_size;
+	unsigned long XSTATE_CPUID = 0xd;
+	int leaf;
+
+	/* assume that XSTATE_PKEY is set in XCR0 */
+	leaf = XSTATE_PKEY_BIT;
+	{
+		eax = XSTATE_CPUID;
+		ecx = leaf;
+		__cpuid(&eax, &ebx, &ecx, &edx);
+
+		if (leaf == XSTATE_PKEY_BIT) {
+			xstate_offset = ebx;
+			xstate_size = eax;
+		}
+	}
+
+	if (xstate_size == 0) {
+		printf("could not find size/offset of PKEY in xsave state\n");
+		return 0;
+	}
+
+	return xstate_offset;
+}
+
+#endif /* _PKEYS_X86_H */
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index cad52dc..99e4e1e 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -49,9 +49,6 @@
 int test_nr;
 
 unsigned int shadow_pkey_reg;
-
-#define HPAGE_SIZE	(1UL<<21)
-
 int dprint_in_signal;
 char dprint_in_signal_buffer[DPRINT_IN_SIGNAL_BUF_SIZE];
 
@@ -137,12 +134,6 @@ void abort_hooks(void)
 #endif
 }
 
-static inline void __page_o_noops(void)
-{
-	/* 8-bytes of instruction * 512 bytes = 1 page */
-	asm(".rept 512 ; nopl 0x7eeeeeee(%eax) ; .endr");
-}
-
 /*
  * This attempts to have roughly a page of instructions followed by a few
  * instructions that do a write, and another page of instructions.  That
@@ -165,36 +156,6 @@ void lots_o_noops_around_write(int *write_to_me)
 	dprintf3("%s() done\n", __func__);
 }
 
-#ifdef __i386__
-
-#ifndef SYS_mprotect_key
-# define SYS_mprotect_key	380
-#endif
-
-#ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc		381
-# define SYS_pkey_free		382
-#endif
-
-#define REG_IP_IDX		REG_EIP
-#define si_pkey_offset		0x14
-
-#else
-
-#ifndef SYS_mprotect_key
-# define SYS_mprotect_key	329
-#endif
-
-#ifndef SYS_pkey_alloc
-# define SYS_pkey_alloc		330
-# define SYS_pkey_free		331
-#endif
-
-#define REG_IP_IDX		REG_RIP
-#define si_pkey_offset		0x20
-
-#endif
-
 void dump_mem(void *dumpme, int len_bytes)
 {
 	char *c = (void *)dumpme;
@@ -367,14 +328,6 @@ pid_t fork_lazy_child(void)
 	return forkret;
 }
 
-#ifndef PKEY_DISABLE_ACCESS
-# define PKEY_DISABLE_ACCESS	0x1
-#endif
-
-#ifndef PKEY_DISABLE_WRITE
-# define PKEY_DISABLE_WRITE	0x2
-#endif
-
 static u32 hw_pkey_get(int pkey, unsigned long flags)
 {
 	u32 mask = (PKEY_DISABLE_ACCESS|PKEY_DISABLE_WRITE);
-- 
1.7.1
