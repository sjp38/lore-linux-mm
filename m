Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51C046B0276
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:56:34 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215794651pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:56:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xc2si42280861pbc.187.2015.09.16.10.49.13
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:13 -0700 (PDT)
Subject: [PATCH 26/26] x86, pkeys: Documentation
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:13 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174913.AF5FEA6D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



---

 b/Documentation/x86/protection-keys.txt |   65 ++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff -puN /dev/null Documentation/x86/protection-keys.txt
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/Documentation/x86/protection-keys.txt	2015-09-16 09:45:55.874491904 -0700
@@ -0,0 +1,65 @@
+Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
+which will be found on future Intel CPUs.
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
+The kernel attempts to make protection keys consistent with the
+behavior of a plain mprotect().  For instance if you do this:
+
+        mprotect(ptr, size, PROT_NONE);
+	something(ptr);
+
+you can expect the same effects with protection keys when doing this:
+
+	mprotect(ptr, size, PROT_READ|PROT_WRITE);
+        set_pkey(ptr, size, 4);
+        wrpkru(0xffffff3f); // access disable pkey 4
+	something(ptr);
+
+That should be true whether something() is a direct access to 'ptr'
+like:
+
+        *ptr = foo;
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
+=========
+
+Changes in v005:
+ * completed "software enforcement of PKEYs"
+ * fixed a ton of bugs
+
+Changes in v004:
+ * bunch of code updates including working signal handling
+
+Changes in v003:
+ * update to new FPU code, and add a bunch of XSAVE patches
+   to the beginning
+
+Changes in v002:
+
+ * make mprotect() actually work
+
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
