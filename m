Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE0866B0270
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 21:21:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b82so5394431qkc.2
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 18:21:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i184sor101270qkd.110.2017.09.15.18.21.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 18:21:46 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH 6/6] Documentation/vm: PowerPC specific updates to memory protection keys
Date: Fri, 15 Sep 2017 18:21:10 -0700
Message-Id: <1505524870-4783-7-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org
Cc: arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Add documentation updates that capture PowerPC specific changes.

Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 Documentation/vm/protection-keys.txt |  125 +++++++++++++++++++++++++++-------
 1 files changed, 100 insertions(+), 25 deletions(-)

diff --git a/Documentation/vm/protection-keys.txt b/Documentation/vm/protection-keys.txt
index b643045..ef5f73b 100644
--- a/Documentation/vm/protection-keys.txt
+++ b/Documentation/vm/protection-keys.txt
@@ -1,22 +1,45 @@
-Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
-which will be found on future Intel CPUs.
-
-Memory Protection Keys provides a mechanism for enforcing page-based
-protections, but without requiring modification of the page tables
-when an application changes protection domains.  It works by
-dedicating 4 previously ignored bits in each page table entry to a
-"protection key", giving 16 possible keys.
-
-There is also a new user-accessible register (PKRU) with two separate
-bits (Access Disable and Write Disable) for each key.  Being a CPU
-register, PKRU is inherently thread-local, potentially giving each
-thread a different set of protections from every other thread.
-
-There are two new instructions (RDPKRU/WRPKRU) for reading and writing
-to the new register.  The feature is only available in 64-bit mode,
-even though there is theoretically space in the PAE PTEs.  These
-permissions are enforced on data access only and have no effect on
-instruction fetches.
+Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature found on
+future Intel CPUs and on PowerPC 5 and higher CPUs.
+
+Memory Protection Keys provide a mechanism for enforcing page-based
+protections, but without requiring modification of the page tables when an
+application changes protection domains.
+
+It works by dedicating bits in each page table entry to a "protection key".
+There is also a user-accessible register with two separate bits for each
+key.  Being a CPU register, the user-accessible register is inherently
+thread-local, potentially giving each thread a different set of protections
+from every other thread.
+
+On Intel:
+
+	Four previously bits are used the page table entry giving 16 possible keys.
+
+	The user accessible register(PKRU) has a bit each per key to disable
+	access and to disable write.
+
+	The feature is only available in 64-bit mode, even though there is
+	theoretically space in the PAE PTEs.  These permissions are enforced on
+	data access only and have no effect on instruction fetches.
+
+On PowerPC:
+
+	Five bits in the page table entry are used giving 32 possible keys.
+	This support is currently for Hash Page Table mode only.
+
+	The user accessible register(AMR) has a bit each per key to disable
+	read and write. Access disable can be achieved by disabling
+	read and write.
+
+	'mtspr 0xd, mem' reads the AMR register
+	'mfspr mem, 0xd' writes into the AMR register.
+
+	Execution can  be  disabled by allocating a key with execute-disabled
+	permission. The execute-permissions on the key; however, cannot be
+	changed through a user accessible register. The CPU will not allow
+	execution of instruction in pages that are associated with
+	execute-disabled key.
+
 
 =========================== Syscalls ===========================
 
@@ -28,9 +51,9 @@ There are 3 system calls which directly interact with pkeys:
 			  unsigned long prot, int pkey);
 
 Before a pkey can be used, it must first be allocated with
-pkey_alloc().  An application calls the WRPKRU instruction
+pkey_alloc().  An application calls the WRPKRU/AMR instruction
 directly in order to change access permissions to memory covered
-with a key.  In this example WRPKRU is wrapped by a C function
+with a key.  In this example WRPKRU/AMR is wrapped by a C function
 called pkey_set().
 
 	int real_prot = PROT_READ|PROT_WRITE;
@@ -52,11 +75,11 @@ is no longer in use:
 	munmap(ptr, PAGE_SIZE);
 	pkey_free(pkey);
 
-(Note: pkey_set() is a wrapper for the RDPKRU and WRPKRU instructions.
+(Note: pkey_set() is a wrapper for the RDPKRU,WRPKRU or AMR instructions.
  An example implementation can be found in
- tools/testing/selftests/x86/protection_keys.c)
+ tools/testing/selftests/vm/protection_keys.c)
 
-=========================== Behavior ===========================
+=========================== Behavior =================================
 
 The kernel attempts to make protection keys consistent with the
 behavior of a plain mprotect().  For instance if you do this:
@@ -66,7 +89,7 @@ behavior of a plain mprotect().  For instance if you do this:
 
 you can expect the same effects with protection keys when doing this:
 
-	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
+	pkey = pkey_alloc(0, PKEY_DISABLE_ACCESS);
 	pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE, pkey);
 	something(ptr);
 
@@ -83,3 +106,55 @@ with a read():
 The kernel will send a SIGSEGV in both cases, but si_code will be set
 to SEGV_PKERR when violating protection keys versus SEGV_ACCERR when
 the plain mprotect() permissions are violated.
+
+========================== sysfs Interface ==========================
+
+Information about support of protection keys on the system can be
+found in the /sys/kernel/mm/protection_keys directory, which
+contains the following files:
+
+- total_keys: Shows the number of keys supported by the hardware.
+    Not all of those keys may be available for use by a process
+    because the platform or operating system may reserve some keys
+    for their own use.
+
+- usable_keys: Shows the minimum number of keys guaranteed to be
+    available for use by a process. In other words: total_keys minus
+    the keys reserved by the platform or operating system. This
+    number doesn't change to reflect keys that are already being
+    used by the process reading the file.
+
+    There may be one more key available than what is advertised in
+    this file because the kernel may use one key for mprotect()
+    calls setting up memory with execute-only permissions. This file
+    assumes that this key is being used, but if it is not the
+    process will have one more key it can use for other purposes.
+
+- disable_access_supported: Tells whether the system supports keys
+    which disallow reading from a given page (i.e., the
+    PKEY_DISABLE_ACCESS flag is supported).
+
+- disable_write_supported: Tells whether the system supports keys
+    which disallow writing to a given page (i.e., the
+    PKEY_DISABLE_WRITE flag is supported).
+
+- disable_execute_supported: Tells whether the system supports keys
+    which disallow code execution from a given page (i.e., the
+    PKEY_DISABLE_EXECUTE flag is supported).
+
+====================================================================
+		Semantic differences
+
+The following semantic differences exist between x86 and power.
+
+a) powerpc (PowerPC8 onwards) *also* allows creation of a key with
+   execute-disabled.
+	The following is allowed
+	pkey = pkey_alloc(0, PKEY_DISABLE_EXECUTE);
+
+b) changes to the key permission bits from a signal handler do not
+   persist on x86. The PKRU specific  fpregs  entry  need   to  be
+   modified for it to persist.  On powerpc the key  permission can
+   be  modified  by  programming  the AMR register from the signal
+   handler. The changes persist across signal boundaries.
+=====================================================================
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
