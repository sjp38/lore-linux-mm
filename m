Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 310DE6B025E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:15:17 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id w8so17761858obg.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:15:17 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0117.outbound.protection.outlook.com. [104.47.0.117])
        by mx.google.com with ESMTPS id dh8si1130744oec.66.2016.05.17.05.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 May 2016 05:15:14 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv9 2/2] selftest/x86: add mremap vdso test
Date: Tue, 17 May 2016 15:13:52 +0300
Message-ID: <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
In-Reply-To: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

Should print on success:
[root@localhost ~]# ./test_mremap_vdso_32
	AT_SYSINFO_EHDR is 0xf773f000
[NOTE]	Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
[OK]
Or segfault if landing was bad (before patches):
[root@localhost ~]# ./test_mremap_vdso_32
	AT_SYSINFO_EHDR is 0xf774f000
[NOTE]	Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
Segmentation fault (core dumped)

Cc: Shuah Khan <shuahkh@osg.samsung.com>
Cc: linux-kselftest@vger.kernel.org
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
---
 tools/testing/selftests/x86/Makefile           |  2 +-
 tools/testing/selftests/x86/test_mremap_vdso.c | 99 ++++++++++++++++++++++++++
 2 files changed, 100 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/x86/test_mremap_vdso.c

diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
index c73425de3cfe..a691cdeb1fef 100644
--- a/tools/testing/selftests/x86/Makefile
+++ b/tools/testing/selftests/x86/Makefile
@@ -5,7 +5,7 @@ include ../lib.mk
 .PHONY: all all_32 all_64 warn_32bit_failure clean
 
 TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_syscall \
-			check_initial_reg_state sigreturn ldt_gdt iopl
+			check_initial_reg_state sigreturn ldt_gdt iopl test_mremap_vdso
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
diff --git a/tools/testing/selftests/x86/test_mremap_vdso.c b/tools/testing/selftests/x86/test_mremap_vdso.c
new file mode 100644
index 000000000000..831e2e0107d9
--- /dev/null
+++ b/tools/testing/selftests/x86/test_mremap_vdso.c
@@ -0,0 +1,99 @@
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
+
+#define PAGE_SIZE	4096
+
+static int try_to_remap(void *vdso_addr, unsigned long size)
+{
+	void *dest_addr, *new_addr;
+
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
+			return -1; /* retry with larger */
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
+	unsigned long auxval;
+	const char *ok_string = "[OK]\n";
+	int ret = -1;
+	unsigned long vdso_size = PAGE_SIZE;
+
+	auxval = getauxval(AT_SYSINFO_EHDR);
+	printf("\tAT_SYSINFO_EHDR is %#lx\n", auxval);
+	if (!auxval || auxval == -ENOENT) {
+		printf("[WARN]\tgetauxval failed\n");
+		return 0;
+	}
+
+	/* simpler than parsing ELF header */
+	while (ret < 0) {
+		ret = try_to_remap((void *)auxval, vdso_size);
+		vdso_size += PAGE_SIZE;
+	}
+
+	if (!ret)
+#if defined(__i386__)
+		asm volatile ("int $0x80" : :
+			"a" (__NR_write), "b" (STDOUT_FILENO),
+			"c" (ok_string), "d" (strlen(ok_string)));
+
+	asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (!!ret));
+#else
+		asm volatile ("syscall" : :
+			"a" (__NR_write), "D" (STDOUT_FILENO),
+			"S" (ok_string), "d" (strlen(ok_string)));
+
+	asm volatile ("syscall" : : "a" (__NR_exit), "D" (!!ret));
+#endif
+
+	return 0;
+}
-- 
2.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
