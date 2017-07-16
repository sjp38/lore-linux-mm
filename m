Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 470CC6B069E
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:00:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so35171489qkb.3
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:37 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id m21si12505585qkm.345.2017.07.15.21.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 21:00:36 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id a66so16024466qkb.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:36 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 62/62] Documentation/vm: PowerPC specific updates to memory protection keys
Date: Sat, 15 Jul 2017 20:57:04 -0700
Message-Id: <1500177424-13695-63-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Add documentation updates that capture PowerPC specific changes.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 Documentation/vm/protection-keys.txt |   90 ++++++++++++++++++++++++---------
 1 files changed, 65 insertions(+), 25 deletions(-)

diff --git a/Documentation/vm/protection-keys.txt b/Documentation/vm/protection-keys.txt
index b643045..9330105 100644
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
+future Intel CPUs and on PowerPC 7 and higher CPUs.
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
 
@@ -83,3 +106,20 @@ with a read():
 The kernel will send a SIGSEGV in both cases, but si_code will be set
 to SEGV_PKERR when violating protection keys versus SEGV_ACCERR when
 the plain mprotect() permissions are violated.
+
+
+====================================================================
+		Semantic differences
+
+The following semantic differences exist between x86 and power.
+
+a) powerpc *also* allows creation of a key with execute-disabled.
+	The following is allowed on powerpc.
+	pkey = pkey_alloc(0, PKEY_DISABLE_EXECUTE);
+
+b) changing the permission bits of a key from a signal handler does not
+   persist on x86. The PKRU specific fpregs entry needs to be modified
+   for it to persist.  On powerpc the permission bits of the key can be
+   modified by programming the AMR register from the signal handler.
+   The changes persist across signal boundaries.
+=====================================================================
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
