Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4456D82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:24:59 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so182339359pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:24:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.27
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:27 -0700 (PDT)
Subject: [PATCH 25/25] x86, pkeys: Documentation
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:27 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191827.0BDF3C64@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/Documentation/x86/protection-keys.txt |   54 ++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff -puN /dev/null Documentation/x86/protection-keys.txt
--- /dev/null	2015-07-13 14:24:11.435656502 -0700
+++ b/Documentation/x86/protection-keys.txt	2015-09-28 11:40:16.120555350 -0700
@@ -0,0 +1,54 @@
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
+	mprotect(ptr, size, PROT_READ|PROT_WRITE);
+	set_pkey(ptr, size, 4);
+	wrpkru(0xffffff3f); // access disable pkey 4
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
