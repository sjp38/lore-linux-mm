Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAE0C6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:36:46 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 192so17563188pgd.18
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:36:46 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 3si18071854pli.734.2017.11.15.06.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:36:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 2/2] x86/selftests: Add test for mapping placement for 5-level paging
Date: Wed, 15 Nov 2017 17:36:07 +0300
Message-Id: <20171115143607.81541-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171115143607.81541-1-kirill.shutemov@linux.intel.com>
References: <20171115143607.81541-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With 5-level paging, we have 56-bit virtual address space available for
userspace. But we don't want to expose userspace to addresses above
47-bits, unless it asked specifically for it.

We use mmap(2) hint address as a way for kernel to know if it's okay to
allocate virtual memory above 47-bit.

Let's add a self-test that covers few corner cases of the interface.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 tools/testing/selftests/x86/5lvl.c   | 177 +++++++++++++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile |   2 +-
 2 files changed, 178 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/x86/5lvl.c

diff --git a/tools/testing/selftests/x86/5lvl.c b/tools/testing/selftests/x86/5lvl.c
new file mode 100644
index 000000000000..2eafdcd4c2b3
--- /dev/null
+++ b/tools/testing/selftests/x86/5lvl.c
@@ -0,0 +1,177 @@
+#include <stdio.h>
+#include <sys/mman.h>
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+
+#define PAGE_SIZE	4096
+#define LOW_ADDR	((void *) (1UL << 30))
+#define HIGH_ADDR	((void *) (1UL << 50))
+
+struct testcase {
+	void *addr;
+	unsigned long size;
+	unsigned long flags;
+	const char *msg;
+	unsigned int low_addr_required:1;
+	unsigned int keep_mapped:1;
+};
+
+static struct testcase testcases[] = {
+	{
+		.addr = NULL,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(NULL)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = LOW_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(LOW_ADDR)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR) again",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(HIGH_ADDR, MAP_FIXED)",
+	},
+	{
+		.addr = (void*) -1,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void*) -1,
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1) again",
+	},
+	{
+		.addr = (void *)((1UL << 47) - PAGE_SIZE),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap((1UL << 47), 2 * PAGE_SIZE)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)((1UL << 47) - PAGE_SIZE / 2),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap((1UL << 47), 2 * PAGE_SIZE / 2)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)((1UL << 47) - PAGE_SIZE),
+		.size = 2 * PAGE_SIZE,
+		.flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap((1UL << 47) - PAGE_SIZE, 2 * PAGE_SIZE, MAP_FIXED)",
+	},
+	{
+		.addr = NULL,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(NULL, MAP_HUGETLB)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = LOW_ADDR,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(LOW_ADDR, MAP_HUGETLB)",
+		.low_addr_required = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(HIGH_ADDR, MAP_HUGETLB) again",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = HIGH_ADDR,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap(HIGH_ADDR, MAP_FIXED | MAP_HUGETLB)",
+	},
+	{
+		.addr = (void*) -1,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1, MAP_HUGETLB)",
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void*) -1,
+		.size = 2UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap(-1, MAP_HUGETLB) again",
+	},
+	{
+		.addr = (void *)((1UL << 47) - PAGE_SIZE),
+		.size = 4UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS,
+		.msg = "mmap((1UL << 47), 4UL << 20, MAP_HUGETLB)",
+		.low_addr_required = 1,
+		.keep_mapped = 1,
+	},
+	{
+		.addr = (void *)((1UL << 47) - (2UL << 20)),
+		.size = 4UL << 20,
+		.flags = MAP_HUGETLB | MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
+		.msg = "mmap((1UL << 47) - (2UL << 20), 4UL << 20, MAP_FIXED | MAP_HUGETLB)",
+	},
+};
+
+int main(int argc, char **argv)
+{
+	int i;
+	void *p;
+
+	for (i = 0; i < ARRAY_SIZE(testcases); i++) {
+		struct testcase *t = testcases + i;
+
+		p = mmap(t->addr, t->size, PROT_NONE, t->flags, -1, 0);
+
+		printf("%s: %p - ", t->msg, p);
+
+		if (p == MAP_FAILED) {
+			printf("FAILED\n");
+			continue;
+		}
+
+		if (t->low_addr_required && p >= (void *)(1UL << 47))
+			printf("FAILED\n");
+		else
+			printf("OK\n");
+		if (!t->keep_mapped)
+			munmap(p, t->size);
+	}
+	return 0;
+}
diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
index 7b1adeee4b0f..939a337128db 100644
--- a/tools/testing/selftests/x86/Makefile
+++ b/tools/testing/selftests/x86/Makefile
@@ -11,7 +11,7 @@ TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_sysc
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
-TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip
+TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip 5lvl
 
 TARGETS_C_32BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_32BIT_ONLY)
 TARGETS_C_64BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_64BIT_ONLY)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
