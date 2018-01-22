Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1708800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:29:06 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n28so15771529qtk.7
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:29:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93sor11303461qkt.114.2018.01.22.10.29.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:29:05 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 2/2] Documentation/vm: PowerPC specific updates to memory protection keys
Date: Mon, 22 Jan 2018 10:28:36 -0800
Message-Id: <1516645716-10174-3-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516645716-10174-1-git-send-email-linuxram@us.ibm.com>
References: <1516645716-10174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, linux-doc@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Add documentation updates that capture PowerPC specific changes.

Signed-off-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 Documentation/vm/protection-keys.txt |   84 +++++++++++++++++++++++++--------
 1 files changed, 63 insertions(+), 21 deletions(-)

diff --git a/Documentation/vm/protection-keys.txt b/Documentation/vm/protection-keys.txt
index ecb0d2d..7a4cbce 100644
--- a/Documentation/vm/protection-keys.txt
+++ b/Documentation/vm/protection-keys.txt
@@ -1,27 +1,52 @@
 Memory Protection Keys for Userspace (PKU aka PKEYs) is a feature
 which is found on Intel's Skylake "Scalable Processor" Server CPUs.
-It will be avalable in future non-server parts.
+It will be available in future non-server parts.
 
 For anyone wishing to test or use this feature, it is available in
 Amazon's EC2 C5 instances and is known to work there using an Ubuntu
 17.04 image.
 
-Memory Protection Keys provides a mechanism for enforcing page-based
-protections, but without requiring modification of the page tables
-when an application changes protection domains.  It works by
-dedicating 4 previously ignored bits in each page table entry to a
-"protection key", giving 16 possible keys.
+This feature is available on PowerPC 5 and higher CPUs.
 
-There is also a new user-accessible register (PKRU) with two separate
-bits (Access Disable and Write Disable) for each key.  Being a CPU
-register, PKRU is inherently thread-local, potentially giving each
-thread a different set of protections from every other thread.
+Memory Protection Keys provide a mechanism for enforcing page-based
+protections, but without requiring modification of the page tables when an
+application changes protection domains.
 
-There are two new instructions (RDPKRU/WRPKRU) for reading and writing
-to the new register.  The feature is only available in 64-bit mode,
-even though there is theoretically space in the PAE PTEs.  These
-permissions are enforced on data access only and have no effect on
-instruction fetches.
+It works by dedicating bits in each page table entry to a "protection key".
+There is also a user-accessible register with two separate bits for each
+key.  Being a CPU register, the user-accessible register is inherently
+thread-local, potentially giving each thread a different set of protections
+from every other thread.
+
+On Intel:
+
+	Four previously ignored bits in the page table entry are used giving
+       	16 possible keys.
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
+	read and write. Access-disable can be achieved by disabling
+	read and write.
+
+	'mtspr 0xd, mem' reads the AMR register
+	'mfspr mem, 0xd' writes into the AMR register.
+
+	Execution can be disabled by allocating a key with execute-disabled
+	permission. The execute-permissions on the key; however, cannot be
+	changed through a user accessible register.  The CPU will not allow
+	execution of instruction in pages that are associated with
+	execute-disabled key.
 
 =========================== Syscalls ===========================
 
@@ -33,9 +58,9 @@ There are 3 system calls which directly interact with pkeys:
 			  unsigned long prot, int pkey);
 
 Before a pkey can be used, it must first be allocated with
-pkey_alloc().  An application calls the WRPKRU instruction
+pkey_alloc().  An application calls the WRPKRU/AMR instruction
 directly in order to change access permissions to memory covered
-with a key.  In this example WRPKRU is wrapped by a C function
+with a key.  In this example WRPKRU/AMR is wrapped by a C function
 called pkey_set().
 
 	int real_prot = PROT_READ|PROT_WRITE;
@@ -57,11 +82,11 @@ is no longer in use:
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
@@ -71,7 +96,7 @@ behavior of a plain mprotect().  For instance if you do this:
 
 you can expect the same effects with protection keys when doing this:
 
-	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
+	pkey = pkey_alloc(0, PKEY_DISABLE_ACCESS);
 	pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE, pkey);
 	something(ptr);
 
@@ -88,3 +113,20 @@ with a read():
 The kernel will send a SIGSEGV in both cases, but si_code will be set
 to SEGV_PKERR when violating protection keys versus SEGV_ACCERR when
 the plain mprotect() permissions are violated.
+
+====================================================================
+		Differences
+
+The following differences exist between x86 and power.
+
+a) powerpc (PowerPC8 onwards) *also* allows creation of a key with
+   execute-disabled.
+	The following is allowed
+	pkey = pkey_alloc(0, PKEY_DISABLE_EXECUTE);
+
+b) On powerpc the access/write permission on a key can be modified by
+   programming the AMR register from the signal handler. The changes
+   persist across signal boundaries. On x86, the PKRU specific fpregs
+   entry must be modified to change the access/write permission on
+   a key.
+=====================================================================
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
