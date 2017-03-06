Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBC46B03CD
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:21:29 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 2so140453929oif.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:21:29 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0137.outbound.protection.outlook.com. [104.47.0.137])
        by mx.google.com with ESMTPS id o25si8051709otd.246.2017.03.06.06.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 06:21:28 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv6 5/5] selftests/x86: add test for 32-bit mmap() return addr
Date: Mon, 6 Mar 2017 17:17:21 +0300
Message-ID: <20170306141721.9188-6-dsafonov@virtuozzo.com>
In-Reply-To: <20170306141721.9188-1-dsafonov@virtuozzo.com>
References: <20170306141721.9188-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-kselftest@vger.kernel.org

This test calls 32-bit mmap() through int 0x80 and checks /proc/self/maps
for allocated VMA's address - it should be downer than 4 Gb. Just
accessing allocated with mmap pointer will not work, as we could have
some VMA placed on the same address as lower 4 bytes of the new mapping.
As allocation is top-down by default (unless legacy personality was set),
we can expect that mmap() will allocate memory over 4Gb if mmap_base
has been computed not correctly.

On failure it prints:
[NOTE]	Allocated mmap 0x6f36a000, sized 0x400000
[NOTE]	New mapping appeared: 0x7f936f36a000
[FAIL]	Found VMA [0x7f936f36a000, 0x7f936f76a000] in maps file, that was allocated with compat syscall

Cc: Shuah Khan <shuah@kernel.org>
Cc: linux-kselftest@vger.kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 tools/testing/selftests/x86/Makefile           |   2 +-
 tools/testing/selftests/x86/test_compat_mmap.c | 208 +++++++++++++++++++++++++
 2 files changed, 209 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/x86/test_compat_mmap.c

diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
index 38e0a9ca5d71..959224d6750d 100644
--- a/tools/testing/selftests/x86/Makefile
+++ b/tools/testing/selftests/x86/Makefile
@@ -10,7 +10,7 @@ TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_sysc
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
-TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip
+TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip test_compat_mmap
 
 TARGETS_C_32BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_32BIT_ONLY)
 TARGETS_C_64BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_64BIT_ONLY)
diff --git a/tools/testing/selftests/x86/test_compat_mmap.c b/tools/testing/selftests/x86/test_compat_mmap.c
new file mode 100644
index 000000000000..245d9407653e
--- /dev/null
+++ b/tools/testing/selftests/x86/test_compat_mmap.c
@@ -0,0 +1,208 @@
+/*
+ * Check that compat 32-bit mmap() returns address < 4Gb on 64-bit.
+ *
+ * Copyright (c) 2017 Dmitry Safonov (Virtuozzo)
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
+#include <sys/mman.h>
+#include <sys/types.h>
+
+#include <stdio.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <signal.h>
+#include <stdlib.h>
+
+#define PAGE_SIZE 4096
+#define MMAP_SIZE (PAGE_SIZE*1024)
+#define MAX_VMAS 50
+#define BUF_SIZE 1024
+
+#ifndef __NR32_mmap2
+#define __NR32_mmap2 192
+#endif
+
+struct syscall_args32 {
+	uint32_t nr, arg0, arg1, arg2, arg3, arg4, arg5;
+};
+
+static void do_full_int80(struct syscall_args32 *args)
+{
+	asm volatile ("int $0x80"
+		      : "+a" (args->nr),
+			"+b" (args->arg0), "+c" (args->arg1), "+d" (args->arg2),
+			"+S" (args->arg3), "+D" (args->arg4),
+			"+rbp" (args->arg5)
+			: : "r8", "r9", "r10", "r11");
+}
+
+void *mmap2(void *addr, size_t len, int prot, int flags,
+	int fildes, off_t off)
+{
+	struct syscall_args32 s;
+
+	s.nr	= __NR32_mmap2;
+	s.arg0	= (uint32_t)(uintptr_t)addr;
+	s.arg1	= (uint32_t)len;
+	s.arg2	= prot;
+	s.arg3	= flags;
+	s.arg4	= fildes;
+	s.arg5	= (uint32_t)off;
+
+	do_full_int80(&s);
+
+	return (void *)(uintptr_t)s.nr;
+}
+
+struct vm_area {
+	unsigned long start;
+	unsigned long end;
+};
+
+static struct vm_area vmas_before_mmap[MAX_VMAS];
+static struct vm_area vmas_after_mmap[MAX_VMAS];
+
+static char buf[BUF_SIZE];
+
+int parse_maps(struct vm_area *vmas)
+{
+	FILE *maps;
+	int i;
+
+	maps = fopen("/proc/self/maps", "r");
+	if (maps == NULL) {
+		printf("[ERROR]\tFailed to open maps file: %m\n");
+		return -1;
+	}
+
+	for (i = 0; i < MAX_VMAS; i++) {
+		struct vm_area *v = &vmas[i];
+		char *end;
+
+		if (fgets(buf, BUF_SIZE, maps) == NULL)
+			break;
+
+		v->start = strtoul(buf, &end, 16);
+		v->end = strtoul(end + 1, NULL, 16);
+		//printf("[NOTE]\tVMA: [%#lx, %#lx]\n", v->start, v->end);
+	}
+
+	if (i == MAX_VMAS) {
+		printf("[ERROR]\tNumber of VMAs is bigger than reserved array's size\n");
+		return -1;
+	}
+
+	if (fclose(maps)) {
+		printf("[ERROR]\tFailed to close maps file: %m\n");
+		return -1;
+	}
+	return 0;
+}
+
+int compare_vmas(struct vm_area *vmax, struct vm_area *vmay)
+{
+	if (vmax->start > vmay->start)
+		return 1;
+	if (vmax->start < vmay->start)
+		return -1;
+	if (vmax->end > vmay->end)
+		return 1;
+	if (vmax->end < vmay->end)
+		return -1;
+	return 0;
+}
+
+unsigned long vma_size(struct vm_area *v)
+{
+	return v->end - v->start;
+}
+
+int find_new_vma_like(struct vm_area *vma)
+{
+	int i, j = 0, found_alike = -1;
+
+	for (i = 0; i < MAX_VMAS && j < MAX_VMAS; i++, j++) {
+		int cmp = compare_vmas(&vmas_before_mmap[i],
+				&vmas_after_mmap[j]);
+
+		if (cmp == 0)
+			continue;
+		if (cmp < 0) {/* Lost mapping */
+			printf("[NOTE]\tLost mapping: %#lx\n",
+				vmas_before_mmap[i].start);
+			j--;
+			continue;
+		}
+
+		printf("[NOTE]\tNew mapping appeared: %#lx\n",
+				vmas_after_mmap[j].start);
+		i--;
+		if (!compare_vmas(&vmas_after_mmap[j], vma))
+			return 0;
+
+		if (((vmas_after_mmap[j].start & 0xffffffff) == vma->start) &&
+				(vma_size(&vmas_after_mmap[j]) == vma_size(vma)))
+			found_alike = j;
+	}
+
+	/* Left new vmas in tail */
+	for (; i < MAX_VMAS; i++)
+		if (!compare_vmas(&vmas_after_mmap[j], vma))
+			return 0;
+
+	if (found_alike != -1) {
+		printf("[FAIL]\tFound VMA [%#lx, %#lx] in maps file, that was allocated with compat syscall\n",
+			vmas_after_mmap[found_alike].start,
+			vmas_after_mmap[found_alike].end);
+		return -1;
+	}
+
+	printf("[ERROR]\tCan't find [%#lx, %#lx] in maps file\n",
+		vma->start, vma->end);
+	return -1;
+}
+
+int main(int argc, char **argv)
+{
+	void *map;
+	struct vm_area vma;
+
+	if (parse_maps(vmas_before_mmap)) {
+		printf("[ERROR]\tFailed to parse maps file\n");
+		return 1;
+	}
+
+	map = mmap2(0, MMAP_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC,
+			MAP_PRIVATE | MAP_ANON, -1, 0);
+	if (((uintptr_t)map) % PAGE_SIZE) {
+		printf("[ERROR]\tmmap2 failed: %d\n",
+				(~(uint32_t)(uintptr_t)map) + 1);
+		return 1;
+	} else {
+		printf("[NOTE]\tAllocated mmap %p, sized %#x\n", map, MMAP_SIZE);
+	}
+
+	if (parse_maps(vmas_after_mmap)) {
+		printf("[ERROR]\tFailed to parse maps file\n");
+		return 1;
+	}
+
+	munmap(map, MMAP_SIZE);
+
+	vma.start = (unsigned long)(uintptr_t)map;
+	vma.end = vma.start + MMAP_SIZE;
+	if (find_new_vma_like(&vma))
+		return 1;
+
+	printf("[OK]\n");
+
+	return 0;
+}
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
