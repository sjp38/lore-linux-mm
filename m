Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id F27088E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 09:31:30 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id u63so6293463oie.17
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 06:31:30 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k3si4742532otn.156.2018.12.10.06.31.29
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 06:31:29 -0800 (PST)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Subject: [RFC][PATCH 2/3] arm64: Define Documentation/arm64/elf_at_flags.txt
Date: Mon, 10 Dec 2018 14:30:43 +0000
Message-Id: <20181210143044.12714-3-vincenzo.frascino@arm.com>
In-Reply-To: <20181210143044.12714-1-vincenzo.frascino@arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
the userspace (EL0) is allowed to set a non-zero value in the
top byte but the resulting pointers are not allowed at the
user-kernel syscall ABI boundary.

With the relaxed ABI proposed through this document, it is now possible
to pass tagged pointers to the syscalls, when these pointers are in
memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap() or brk().

This change in the ABI requires a mechanism to inform the userspace
that such an option is available.

This patch specifies and documents the way on which AT_FLAGS can be
used to advertise this feature to the userspace.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
---
 Documentation/arm64/elf_at_flags.txt | 111 +++++++++++++++++++++++++++
 1 file changed, 111 insertions(+)
 create mode 100644 Documentation/arm64/elf_at_flags.txt

diff --git a/Documentation/arm64/elf_at_flags.txt b/Documentation/arm64/elf_at_flags.txt
new file mode 100644
index 000000000000..153e657c058a
--- /dev/null
+++ b/Documentation/arm64/elf_at_flags.txt
@@ -0,0 +1,111 @@
+ARM64 ELF AT_FLAGS
+==================
+
+This document describes the usage and semantics of AT_FLAGS on arm64.
+
+1. Introduction
+---------------
+
+AT_FLAGS is part of the Auxiliary Vector, contains the flags and it
+is currently set to zero by the kernel on arm64.
+
+The auxiliary vector can be accessed by the userspace using the
+getauxval() API provided by the C library.
+getauxval() returns an unsigned long and when a flag is present in
+the AT_FLAGS, the corresponding bit in the returned value is set to 1.
+
+The AT_FLAGS with a "defined semantic" on arm64 are exposed to the
+userspace via user API (uapi/asm/atflags.h).
+The AT_FLAGS bits with "undefined semantics" are set to zero by default.
+This means that the AT_FLAGS bits to which this document does not assign
+an explicit meaning are to be intended reserved for future use.
+The kernel will populate all such bits with zero until meanings are
+assigned to them. If and when meanings are assigned, it is guaranteed
+that they will not impact the functional operation of existing userspace
+software. Userspace software should ignore any AT_FLAGS bit whose meaning
+is not defined when the software is written.
+
+The userspace software can test for features by acquiring the AT_FLAGS
+entry of the auxiliary vector, and testing whether a relevant flag
+is set.
+
+Example of a userspace test function:
+
+bool feature_x_is_present(void)
+{
+	unsigned long at_flags = getauxval(AT_FLAGS);
+	if (at_flags & FEATURE_X)
+		return true;
+
+	return false;
+}
+
+Where the software relies on a feature advertised by AT_FLAGS, it
+should check that the feature is present before attempting to
+use it.
+
+2. Features exposed via AT_FLAGS
+--------------------------------
+
+bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
+
+    On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
+    the userspace (EL0) is allowed to set a non-zero value in the top
+    byte but the resulting pointers are not allowed at the user-kernel
+    syscall ABI boundary.
+    When bit[0] is set to 1 the kernel is advertising to the userspace
+    that a relaxed ABI is supported hence this type of pointers are now
+    allowed to be passed to the syscalls, when these pointers are in
+    memory ranges obtained by anonymous (MAP_ANONYMOUS) mmap() or brk().
+    In these cases the tag is preserved as the pointer goes through the
+    kernel. Only when the kernel needs to check if a pointer is coming
+    from userspace (i.e. access_ok()) an untag operation is required.
+
+3. ARM64_AT_FLAGS_SYSCALL_TBI
+-----------------------------
+
+When ARM64_AT_FLAGS_SYSCALL_TBI is enabled every syscalls can accept tagged
+pointers, when these pointers are in memory ranges obtained by an anonymous
+(MAP_ANONYMOUS) mmap() or brk().
+
+A definition of the meaning of tagged pointers on arm64 can be found in:
+Documentation/arm64/tagged-pointers.txt.
+
+When a pointer does not are in a memory range obtained by an anonymous mmap()
+or brk(), this can not be passed to a syscall if it is tagged.
+
+To be more explicit: a syscall can accept pointers whose memory range is
+obtained by a non-anonymous mmap() or brk() if and only if the tag encoded in
+the top-byte is 0x00.
+
+When a new syscall is added, this can accept tagged pointers if and only if
+these pointers are in memory ranges obtained by an anonymous (MAP_ANONYMOUS)
+mmap() or brk(). In all the other cases, the tag encoded in the top-byte is
+expected to be 0x00.
+
+Example of correct usage (pseudo-code) for a userspace application:
+
+bool arm64_syscall_tbi_is_present(void)
+{
+	unsigned long at_flags = getauxval(AT_FLAGS);
+	if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
+			return true;
+
+	return false;
+}
+
+void main(void)
+{
+	char *addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE,
+			  MAP_ANONYMOUS, -1, 0);
+
+	/* Check if the relaxed ABI is supported */
+	if (arm64_syscall_tbi_is_present()) {
+		/* Add a tag to the pointer and to the memory */
+		addr = tag_pointer_and_memory(addr);
+	}
+
+	/* Write to memory */
+	strcpy("Hello World\n", addr);
+}
+
-- 
2.19.2
