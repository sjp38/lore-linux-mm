Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 812EA6B0262
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:28:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so377543854pfb.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:28:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xt10si1960707pab.1.2016.05.31.08.28.25
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 08:28:25 -0700 (PDT)
Subject: [PATCH 7/8] pkeys: add details of system call use to Documentation/
From: Dave Hansen <dave@sr71.net>
Date: Tue, 31 May 2016 08:28:24 -0700
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
In-Reply-To: <20160531152814.36E0B9EE@viggo.jf.intel.com>
Message-Id: <20160531152824.2B18E890@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This spells out all of the pkey-related system calls that we have
and provides some example code fragments to demonstrate how we
expect them to be used.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/Documentation/x86/protection-keys.txt |   63 ++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff -puN Documentation/x86/protection-keys.txt~pkeys-120-syscall-docs Documentation/x86/protection-keys.txt
--- a/Documentation/x86/protection-keys.txt~pkeys-120-syscall-docs	2016-05-31 08:27:50.554178908 -0700
+++ b/Documentation/x86/protection-keys.txt	2016-05-31 08:27:50.558179089 -0700
@@ -18,6 +18,69 @@ even though there is theoretically space
 permissions are enforced on data access only and have no effect on
 instruction fetches.
 
+=========================== Syscalls ===========================
+
+There are 5 system calls which directly interact with pkeys:
+
+	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
+	int pkey_free(int pkey);
+	int sys_pkey_mprotect(unsigned long start, size_t len,
+			      unsigned long prot, int pkey);
+	unsigned long pkey_get(int pkey);
+	int pkey_set(int pkey, unsigned long access_rights);
+
+Before a pkey can be used, it must first be allocated with
+pkey_alloc().  An application may either call pkey_set() or the
+WRPKRU instruction directly in order to change access permissions
+to memory covered with a key.
+
+	int real_prot = PROT_READ|PROT_WRITE;
+	pkey = pkey_alloc(0, PKEY_DENY_WRITE);
+	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);
+	... application runs here
+
+Now, if the application needs to update the data at 'ptr', it can
+gain access, do the update, then remove its write access:
+
+	pkey_set(pkey, 0); // clear PKEY_DENY_WRITE
+	*ptr = foo; // assign something
+	pkey_set(pkey, PKEY_DENY_WRITE); // set PKEY_DENY_WRITE again
+
+Now when it frees the memory, it will also free the pkey since it
+is no longer in use:
+
+	munmap(ptr, PAGE_SIZE);
+	pkey_free(pkey);
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
+	sys_pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
+	sys_pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE);
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
+
 =========================== Config Option ===========================
 
 This config option adds approximately 1.5kb of text. and 50 bytes of
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
