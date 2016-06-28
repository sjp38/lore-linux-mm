Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82D32828E1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 07:37:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so29397408ith.1
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:37:03 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0110.outbound.protection.outlook.com. [157.55.234.110])
        by mx.google.com with ESMTPS id p189si15331091oig.146.2016.06.28.04.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 04:37:02 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv10 2/2] selftest/x86: add mremap vdso test
Date: Tue, 28 Jun 2016 14:35:39 +0300
Message-ID: <20160628113539.13606-3-dsafonov@virtuozzo.com>
In-Reply-To: <20160628113539.13606-1-dsafonov@virtuozzo.com>
References: <20160628113539.13606-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, mingo@redhat.com, luto@kernel.org, linux-mm@kvack.org, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Shuah Khan <shuahkh@osg.samsung.com>, x86@kernel.org, linux-kselftest@vger.kernel.org

Should print on success:
[root@localhost ~]# ./test_mremap_vdso_32
	AT_SYSINFO_EHDR is 0xf773f000
[NOTE]	Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
[OK]

Or print that mremap for vDSO is unsupported:
[root@localhost ~]# ./test_mremap_vdso_32
	AT_SYSINFO_EHDR is 0xf773c000
[NOTE]	Moving vDSO: [0xf773c000, 0xf773d000] -> [0xf7737000, 0xf7738000]
[FAIL]	mremap() of the vDSO does not work on this kernel!

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: x86@kernel.org
Cc: linux-kselftest@vger.kernel.org
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 tools/testing/selftests/x86/Makefile           |   3 +-
 tools/testing/selftests/x86/test_mremap_vdso.c | 111 +++++++++++++++++++++++++
 2 files changed, 113 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/x86/test_mremap_vdso.c

diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
index abe9c35c1cb6..c701349d4920 100644
--- a/tools/testing/selftests/x86/Makefile
+++ b/tools/testing/selftests/x86/Makefile
@@ -5,7 +5,8 @@ include ../lib.mk
 .PHONY: all all_32 all_64 warn_32bit_failure clean
 
 TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_syscall \
-			check_initial_reg_state sigreturn ldt_gdt iopl mpx-mini-test
+			check_initial_reg_state sigreturn ldt_gdt iopl mpx-mini-test \
+			test_mremap_vdso
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
diff --git a/tools/testing/selftests/x86/test_mremap_vdso.c b/tools/testing/selftests/x86/test_mremap_vdso.c
new file mode 100644
index 000000000000..a489a2410664
--- /dev/null
+++ b/tools/testing/selftests/x86/test_mremap_vdso.c
@@ -0,0 +1,111 @@
+/*
+ * 32-bit test to check vdso mremap.
+ *
+ * Copyright (c) 2016 Dmitry Safonov
+ * Suggested-by: Andrew Lutomirski
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Can be built statically:
+ * gcc -Os -Wall -static -m32 test_mremap_vdso.c
+ */
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+
+#include <sys/mman.h>
+#include <sys/auxv.h>
+#include <sys/syscall.h>
+#include <sys/wait.h>
+
+#define PAGE_SIZE	4096
+
+static int try_to_remap(void *vdso_addr, unsigned long size)
+{
+	void *dest_addr, *new_addr;
+
+	/* Searching for memory location where to remap */
+	dest_addr = mmap(0, size, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
+	if (dest_addr == MAP_FAILED) {
+		printf("[WARN]\tmmap failed (%d): %m\n", errno);
+		return 0;
+	}
+
+	printf("[NOTE]\tMoving vDSO: [%p, %#lx] -> [%p, %#lx]\n",
+		vdso_addr, (unsigned long)vdso_addr + size,
+		dest_addr, (unsigned long)dest_addr + size);
+	fflush(stdout);
+
+	new_addr = mremap(vdso_addr, size, size,
+			MREMAP_FIXED|MREMAP_MAYMOVE, dest_addr);
+	if ((unsigned long)new_addr == (unsigned long)-1) {
+		munmap(dest_addr, size);
+		if (errno == EINVAL) {
+			printf("[NOTE]\tvDSO partial move failed, will try with bigger size\n");
+			return -1; /* Retry with larger */
+		}
+		printf("[FAIL]\tmremap failed (%d): %m\n", errno);
+		return 1;
+	}
+
+	return 0;
+
+}
+
+int main(int argc, char **argv, char **envp)
+{
+	pid_t child;
+
+	child = fork();
+	if (child == -1) {
+		printf("[WARN]\tfailed to fork (%d): %m\n", errno);
+		return 1;
+	}
+
+	if (child == 0) {
+		unsigned long vdso_size = PAGE_SIZE;
+		unsigned long auxval;
+		int ret = -1;
+
+		auxval = getauxval(AT_SYSINFO_EHDR);
+		printf("\tAT_SYSINFO_EHDR is %#lx\n", auxval);
+		if (!auxval || auxval == -ENOENT) {
+			printf("[WARN]\tgetauxval failed\n");
+			return 0;
+		}
+
+		/* Simpler than parsing ELF header */
+		while (ret < 0) {
+			ret = try_to_remap((void *)auxval, vdso_size);
+			vdso_size += PAGE_SIZE;
+		}
+
+		/* Glibc is likely to explode now - exit with raw syscall */
+		asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (!!ret));
+	} else {
+		int status;
+
+		if (waitpid(child, &status, 0) != child ||
+			!WIFEXITED(status)) {
+			printf("[FAIL]\tmremap() of the vDSO does not work on this kernel!\n");
+			return 1;
+		} else if (WEXITSTATUS(status) != 0) {
+			printf("[FAIL]\tChild failed with %d\n",
+					WEXITSTATUS(status));
+			return 1;
+		}
+		printf("[OK]\n");
+	}
+
+	return 0;
+}
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
