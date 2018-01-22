Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70DB1800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:29:04 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id o22so15724409qtb.17
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:29:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g188sor10539754qkf.12.2018.01.22.10.29.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 10:29:03 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 1/2] Documentation/x86: Move protecton key documentation to arch neutral directory
Date: Mon, 22 Jan 2018 10:28:35 -0800
Message-Id: <1516645716-10174-2-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516645716-10174-1-git-send-email-linuxram@us.ibm.com>
References: <1516645716-10174-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, linux-doc@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, arnd@arndb.de

Since PowerPC and Intel both support memory protection keys, moving
the documenation to arch-neutral directory.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 Documentation/vm/protection-keys.txt  |   90 +++++++++++++++++++++++++++++++++
 Documentation/x86/protection-keys.txt |   90 ---------------------------------
 2 files changed, 90 insertions(+), 90 deletions(-)
 create mode 100644 Documentation/vm/protection-keys.txt
 delete mode 100644 Documentation/x86/protection-keys.txt

diff --git a/Documentation/vm/protection-keys.txt b/Documentation/vm/protection-keys.txt
new file mode 100644
index 0000000..ecb0d2d
--- /dev/null
+++ b/Documentation/vm/protection-keys.txt
@@ -0,0 +1,90 @@
+Memory Protection Keys for Userspace (PKU aka PKEYs) is a feature
+which is found on Intel's Skylake "Scalable Processor" Server CPUs.
+It will be avalable in future non-server parts.
+
+For anyone wishing to test or use this feature, it is available in
+Amazon's EC2 C5 instances and is known to work there using an Ubuntu
+17.04 image.
+
+Memory Protection Keys provides a mechanism for enforcing page-based
+protections, but without requiring modification of the page tables
+when an application changes protection domains.  It works by
+dedicating 4 previously ignored bits in each page table entry to a
+"protection key", giving 16 possible keys.
+
+There is also a new user-accessible register (PKRU) with two separate
+bits (Access Disable and Write Disable) for each key.  Being a CPU
+register, PKRU is inherently thread-local, potentially giving each
+thread a different set of protections from every other thread.
+
+There are two new instructions (RDPKRU/WRPKRU) for reading and writing
+to the new register.  The feature is only available in 64-bit mode,
+even though there is theoretically space in the PAE PTEs.  These
+permissions are enforced on data access only and have no effect on
+instruction fetches.
+
+=========================== Syscalls ===========================
+
+There are 3 system calls which directly interact with pkeys:
+
+	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
+	int pkey_free(int pkey);
+	int pkey_mprotect(unsigned long start, size_t len,
+			  unsigned long prot, int pkey);
+
+Before a pkey can be used, it must first be allocated with
+pkey_alloc().  An application calls the WRPKRU instruction
+directly in order to change access permissions to memory covered
+with a key.  In this example WRPKRU is wrapped by a C function
+called pkey_set().
+
+	int real_prot = PROT_READ|PROT_WRITE;
+	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE);
+	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);
+	... application runs here
+
+Now, if the application needs to update the data at 'ptr', it can
+gain access, do the update, then remove its write access:
+
+	pkey_set(pkey, 0); // clear PKEY_DISABLE_WRITE
+	*ptr = foo; // assign something
+	pkey_set(pkey, PKEY_DISABLE_WRITE); // set PKEY_DISABLE_WRITE again
+
+Now when it frees the memory, it will also free the pkey since it
+is no longer in use:
+
+	munmap(ptr, PAGE_SIZE);
+	pkey_free(pkey);
+
+(Note: pkey_set() is a wrapper for the RDPKRU and WRPKRU instructions.
+ An example implementation can be found in
+ tools/testing/selftests/x86/protection_keys.c)
+
+=========================== Behavior ===========================
+
+The kernel attempts to make protection keys consistent with the
+behavior of a plain mprotect().  For instance if you do this:
+
+	mprotect(ptr, size, PROT_NONE);
+	something(ptr);
+
+you can expect the same effects with protection keys when doing this:
+
+	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
+	pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE, pkey);
+	something(ptr);
+
+That should be true whether something() is a direct access to 'ptr'
+like:
+
+	*ptr = foo;
+
+or when the kernel does the access on the application's behalf like
+with a read():
+
+	read(fd, ptr, 1);
+
+The kernel will send a SIGSEGV in both cases, but si_code will be set
+to SEGV_PKERR when violating protection keys versus SEGV_ACCERR when
+the plain mprotect() permissions are violated.
diff --git a/Documentation/x86/protection-keys.txt b/Documentation/x86/protection-keys.txt
deleted file mode 100644
index ecb0d2d..0000000
--- a/Documentation/x86/protection-keys.txt
+++ /dev/null
@@ -1,90 +0,0 @@
-Memory Protection Keys for Userspace (PKU aka PKEYs) is a feature
-which is found on Intel's Skylake "Scalable Processor" Server CPUs.
-It will be avalable in future non-server parts.
-
-For anyone wishing to test or use this feature, it is available in
-Amazon's EC2 C5 instances and is known to work there using an Ubuntu
-17.04 image.
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
-
-=========================== Syscalls ===========================
-
-There are 3 system calls which directly interact with pkeys:
-
-	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
-	int pkey_free(int pkey);
-	int pkey_mprotect(unsigned long start, size_t len,
-			  unsigned long prot, int pkey);
-
-Before a pkey can be used, it must first be allocated with
-pkey_alloc().  An application calls the WRPKRU instruction
-directly in order to change access permissions to memory covered
-with a key.  In this example WRPKRU is wrapped by a C function
-called pkey_set().
-
-	int real_prot = PROT_READ|PROT_WRITE;
-	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE);
-	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
-	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);
-	... application runs here
-
-Now, if the application needs to update the data at 'ptr', it can
-gain access, do the update, then remove its write access:
-
-	pkey_set(pkey, 0); // clear PKEY_DISABLE_WRITE
-	*ptr = foo; // assign something
-	pkey_set(pkey, PKEY_DISABLE_WRITE); // set PKEY_DISABLE_WRITE again
-
-Now when it frees the memory, it will also free the pkey since it
-is no longer in use:
-
-	munmap(ptr, PAGE_SIZE);
-	pkey_free(pkey);
-
-(Note: pkey_set() is a wrapper for the RDPKRU and WRPKRU instructions.
- An example implementation can be found in
- tools/testing/selftests/x86/protection_keys.c)
-
-=========================== Behavior ===========================
-
-The kernel attempts to make protection keys consistent with the
-behavior of a plain mprotect().  For instance if you do this:
-
-	mprotect(ptr, size, PROT_NONE);
-	something(ptr);
-
-you can expect the same effects with protection keys when doing this:
-
-	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
-	pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE, pkey);
-	something(ptr);
-
-That should be true whether something() is a direct access to 'ptr'
-like:
-
-	*ptr = foo;
-
-or when the kernel does the access on the application's behalf like
-with a read():
-
-	read(fd, ptr, 1);
-
-The kernel will send a SIGSEGV in both cases, but si_code will be set
-to SEGV_PKERR when violating protection keys versus SEGV_ACCERR when
-the plain mprotect() permissions are violated.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
