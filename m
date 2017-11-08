Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85C114403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 05:22:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l24so2063492pgu.17
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 02:22:59 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y4si3603396plb.122.2017.11.08.02.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 02:22:57 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/selftests: Add test for mapping placement for 5-level paging
Date: Wed,  8 Nov 2017 13:22:50 +0300
Message-Id: <20171108102250.38609-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With 5-level paging, we have 56-bit virtual address space available for
userspace. But we don't want to expose userspace to addresses above
47-bits, unless it asked specifically for it.

We use mmap(2) hint address as a way for kernel to know if it's okay to
allocate virtual memory above 47-bit.

Let's add a self-test that covers few corner cases of the interface.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 tools/testing/selftests/x86/5lvl.c   | 53 ++++++++++++++++++++++++++++++++++++
 tools/testing/selftests/x86/Makefile |  2 +-
 2 files changed, 54 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/x86/5lvl.c

diff --git a/tools/testing/selftests/x86/5lvl.c b/tools/testing/selftests/x86/5lvl.c
new file mode 100644
index 000000000000..94610fd13ba2
--- /dev/null
+++ b/tools/testing/selftests/x86/5lvl.c
@@ -0,0 +1,53 @@
+#include <stdio.h>
+#include <sys/mman.h>
+
+#define PAGE_SIZE	4096
+#define SIZE		(2 * PAGE_SIZE)
+#define LOW_ADDR	((void *) (1UL << 30))
+#define HIGH_ADDR	((void *) (1UL << 50))
+#define TASK_SIZE	((void *) (1UL << 47))
+
+int main(int argc, char **argv)
+{
+	void *p;
+
+	p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(NULL): %p %s\n", p, p > TASK_SIZE ? "FAILED!" : "");
+
+	p = mmap(LOW_ADDR, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(%p): %p %s\n", LOW_ADDR, p,
+			p > TASK_SIZE ? "FAILED!" : "");
+
+	p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(%p): %p\n", HIGH_ADDR, p);
+
+	p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(%p) again: %p\n", HIGH_ADDR, p);
+
+	p = mmap(HIGH_ADDR, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
+	printf("mmap(%p, MAP_FIXED): %p\n", HIGH_ADDR, p);
+
+	p = mmap((void *)-1, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(-1): %p\n", p);
+
+	p = mmap((void *)-1, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(-1) again: %p\n", p);
+
+	p = mmap(TASK_SIZE - PAGE_SIZE, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+	printf("mmap(%p, %d): %p %s\n", TASK_SIZE - PAGE_SIZE, SIZE, p,
+			p > TASK_SIZE ? "FAILED!" : "");
+
+	p = mmap(TASK_SIZE - PAGE_SIZE, SIZE, PROT_READ | PROT_WRITE,
+			MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
+	printf("mmap(TASK_SIZE - PAGE_SIZE, MAP_FIXED): %p\n", p);
+
+	return 0;
+}
diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
index 0a74a20ca32b..1f5d6565fbef 100644
--- a/tools/testing/selftests/x86/Makefile
+++ b/tools/testing/selftests/x86/Makefile
@@ -10,7 +10,7 @@ TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_sysc
 TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
 			test_FCMOV test_FCOMI test_FISTTP \
 			vdso_restorer
-TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip
+TARGETS_C_64BIT_ONLY := fsgsbase sysret_rip 5lvl
 
 TARGETS_C_32BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_32BIT_ONLY)
 TARGETS_C_64BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_64BIT_ONLY)
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
