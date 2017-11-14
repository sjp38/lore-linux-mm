Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 978806B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 08:44:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o7so20244834pgc.23
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 05:44:03 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m3si15464432pgs.471.2017.11.14.05.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 05:44:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 2/2] x86/selftests: Add test for mapping placement for 5-level paging
Date: Tue, 14 Nov 2017 16:43:22 +0300
Message-Id: <20171114134322.40321-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
References: <20171114134322.40321-1-kirill.shutemov@linux.intel.com>
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
