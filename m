Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 26CB26B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:42 -0500 (EST)
Received: by pfbg73 with SMTP id g73so17650137pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:41 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id we6si15424118pab.216.2015.12.03.17.15.39
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:40 -0800 (PST)
Subject: [PATCH 34/34] x86, pkeys: Documentation
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:11 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011511.5D72478D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/Documentation/x86/protection-keys.txt |   53 ++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff -puN /dev/null Documentation/x86/protection-keys.txt
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/Documentation/x86/protection-keys.txt	2015-12-03 16:22:15.486932540 -0800
@@ -0,0 +1,53 @@
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
+	mprotect(ptr, size, PROT_NONE);
+	something(ptr);
+
+you can expect the same effects with protection keys when doing this:
+
+	sys_pkey_alloc(no_flag, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
+	sys_mprotect_pkey(ptr, size, PROT_READ|PROT_WRITE);
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
+=========================== Config Option ===========================
+
+This config option adds approximately 1.5kb of text. and 50 bytes of
+data to the executable.  A workload which does large O_DIRECT reads
+of holes in XFS files was run to exercise get_user_pages_fast().  No
+performance delta was observed with the config option
+enabled or disabled.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
