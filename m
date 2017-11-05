Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B59276B0253
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 05:35:27 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id n82so7346703oig.22
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 02:35:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t70si5189240oit.40.2017.11.05.02.35.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Nov 2017 02:35:26 -0800 (PST)
From: Florian Weimer <fweimer@redhat.com>
Subject: MPK: pkey_free and key reuse
Message-ID: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
Date: Sun, 5 Nov 2017 11:35:21 +0100
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------FD90FF5814645BD95351E841"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

This is a multi-part message in MIME format.
--------------FD90FF5814645BD95351E841
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

I'm working on adding memory protection key support to glibc.

I don't think pkey_free, as it is implemented today, is very safe due to 
key reuse by a subsequent pkey_alloc.  I see two problems:

(A) pkey_free allows reuse for they key while there are still mappings 
that use it.

(B) If a key is reused, existing threads retain their access rights, 
while there is an expectation that pkey_alloc denies access for the 
threads except the current one.

Issue (A) could be fixed by having pkey_free to mark the key for reuse, 
and only actually reuse it if all those mappings are gone.  This could 
have a significant performance cost, but pkey_free is supposed to be rare.

Issue (B) is much harder to fix.  There is no atomic way to change 
access for a single key, so there is always a race condition due to the 
read-modify-write cycle for the PKRU update in user space.  This means 
that even if the kernel iterated over all threads to revoke access on 
pkey_free, there is a chance that the race reinstantiates the old access 
rights.

One way to deal with this is to give up and just remove pkey_free from 
the API (i.e., we wouldn't provide it in glibc).  A slightly less 
drastic way could add two pkey_alloc flags, a flag to disable pkey_free 
for the new key (which would mainly serve as a documentation of intent), 
and another flag which requests a pristine key which has never been used 
before.  With the second flag, and assuming correct key management, 
libraries would have some confidence that other threads in the process 
would not implicitly gain access to the new key (although there is the 
init_pkru= boot flag, which overrides the thread default, so it doesn't 
look like the assumption is actually valid).

All this is of course a bit on thin ice anyway because code could just 
clear the PKRU register at any time.

I'm attaching my glibc patch for reference.  The interesting bits is 
probably the test case (and how it creates and joins threads) and the 
pkey_set/pkey_get functions.  The support/ subdirectory is just our 
testing framework which is still very younga??I needed a few more 
functions for debugging, which is why they are in this patch.

Key reuse is not the only problem, we also have an issue with siglongjmp:

   https://sourceware.org/bugzilla/show_bug.cgi?id=22396

I've started wondering whether it even makes sense to expose this 
interface for general use.  I don't think any other architecture will 
implement something like this in the same way (with a PKRU register 
which can simply be cleared, and keys which are easily guessed and 
reused).  I suspect the only use for this functionality is in-memory 
databases which use DAX mappings for persistence, and want to reduce 
risk of persistent data corruption due to random pointer writes.  (And 
maybe execute-only memory, but that's not really benefiting anyone anyway.)

Thanks,
Florian

PS: The manpages need fixing.  Right now, they are misleading.

--------------FD90FF5814645BD95351E841
Content-Type: text/x-patch;
 name="glibc-pkey.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="glibc-pkey.patch"


This adds system call wrappers for pkey_alloc, pkey_free, pkey_mprotect,
and x86-64 implementations of pkey_get and pkey_set, which abstract over
the PKRU CPU register and hide the actual number of memory protection
keys supported by the CPU.

The system call wrapers use unsigned int instead of unsigned long for
parameters, so that no special treatment for x32 is needed.  The flags
argument is currently unused, and the access rights bit mask is limited
to two bits by the current PKRU register layout anyway.

2017-11-04  Florian Weimer  <fweimer@redhat.com>

	Linux: Implement interfaces for memory protection keys
	* support/Makefile (libsupport-routines): Add
	support_test_compare_failure, xraise, xsigaction, xsignal,
	xsysconf.
	* support/check.h (TEST_COMPARE): New macro.
	(support_test_compare_failure): Declare.
	* support/xsignal.h (xraise, xsignal, xsigaction): Declare.
	* support/xunistd.h (xsysconf): Declare.
	* support/support_test_compare_failure.c: New file.
	* support/xraise.c: Likewise.
	* support/xsigaction.c: Likewise.
	* support/xsignal.c: Likewise.
	* support/xsysconf.c: Likewise.
	* sysdeps/unix/sysv/linux/Makefile [misc] (routines): Add
	pkey_set, pkey_get.
	[misc] (tests): Add tst-pkey.
	(tst-pkey): Link with -lpthread.
	* sysdeps/unix/sysv/linux/Versions (GLIBC_2.27): Add pkey_alloc,
	pkey_free, pkey_set, pkey_get, pkey_mprotect.
	* sysdeps/unix/sysv/linux/bits/mman-linux.h (PKEY_DISABLE_ACCESS)
	(PKEY_DISABLE_WRITE): Define.
	(pkey_alloc, pkey_free, pkey_set, pkey_get, pkey_mprotect):
	Declare.
	* sysdeps/unix/sysv/linux/bits/siginfo-consts.h (SEGV_BNDERR)
	(SEGV_PKUERR): Add.
	* sysdeps/unix/sysv/linux/pkey_get.c: New file.
	* sysdeps/unix/sysv/linux/pkey_set.c: Likewise.
	* sysdeps/unix/sysv/linux/syscalls.list (pkey_alloc, pkey_free)
	(pkey_mprotect): Add.
	* sysdeps/unix/sysv/linux/tst-pkey.c: New file.
	* sysdeps/unix/sysv/linux/x86_64/arch-pkey.h: Likewise.
	* sysdeps/unix/sysv/linux/x86_64/pkey_get.c: Likewise.
	* sysdeps/unix/sysv/linux/x86_64/pkey_set.c: Likewise.
	* sysdeps/unix/sysv/linux/**.abilist: Update.

diff --git a/NEWS b/NEWS
index 933085417c..0652012a09 100644
--- a/NEWS
+++ b/NEWS
@@ -38,6 +38,10 @@ Major new features:
 * glibc now provides the <sys/memfd.h> header file and the memfd_create
   system call.
 
+* Support for memory protection keys was added.  The <sys/mman.h> header now
+  declares the functions pkey_alloc, pkey_free, pkey_memprotect, pkey_set,
+  pkey_get.
+
 Deprecated and removed features, and other changes affecting compatibility:
 
 * On GNU/Linux, the obsolete Linux constant PTRACE_SEIZE_DEVEL is no longer
diff --git a/support/Makefile b/support/Makefile
index dafb1737a4..50d4269e24 100644
--- a/support/Makefile
+++ b/support/Makefile
@@ -52,9 +52,10 @@ libsupport-routines = \
   support_record_failure \
   support_run_diff \
   support_shared_allocate \
-  support_write_file_string \
+  support_test_compare_failure \
   support_test_main \
   support_test_verify_impl \
+  support_write_file_string \
   temp_file \
   write_message \
   xaccept \
@@ -84,8 +85,8 @@ libsupport-routines = \
   xpthread_attr_destroy \
   xpthread_attr_init \
   xpthread_attr_setdetachstate \
-  xpthread_attr_setstacksize \
   xpthread_attr_setguardsize \
+  xpthread_attr_setstacksize \
   xpthread_barrier_destroy \
   xpthread_barrier_init \
   xpthread_barrier_wait \
@@ -116,14 +117,18 @@ libsupport-routines = \
   xpthread_sigmask \
   xpthread_spin_lock \
   xpthread_spin_unlock \
+  xraise \
   xreadlink \
   xrealloc \
   xrecvfrom \
   xsendto \
   xsetsockopt \
+  xsigaction \
+  xsignal \
   xsocket \
   xstrdup \
   xstrndup \
+  xsysconf \
   xunlink \
   xwaitpid \
   xwrite \
diff --git a/support/check.h b/support/check.h
index bdcd12952a..29b709c2b0 100644
--- a/support/check.h
+++ b/support/check.h
@@ -86,6 +86,35 @@ void support_test_verify_exit_impl (int status, const char *file, int line,
    does not support reporting failures from a DSO.  */
 void support_record_failure (void);
 
+/* Compare the two numbers LEFT and RIGHT and report failure if they
+   are different.  */
+#define TEST_COMPARE(left, right)                                       \
+  ({                                                                    \
+    __typeof__ (left) __left_value = (left);                            \
+    __typeof__ (right) __right_value = (right);                         \
+    _Static_assert (sizeof (__left_value) <= sizeof (long long),        \
+                    "left value fits into long long");                  \
+    _Static_assert (sizeof (__right_value) <= sizeof (long long),       \
+                    "right value fits into long long");                 \
+    if (__left_value != __right_value                                   \
+        || ((__left_value > 0) != (__right_value > 0)))                 \
+      support_test_compare_failure                                      \
+        (__FILE__, __LINE__,                                            \
+         #left, __left_value, __left_value > 0,                         \
+         #right, __right_value, __right_value > 0);                     \
+  })
+
+/* Internal implementation of TEST_COMPARE.  LEFT_POSITIVE and
+   RIGHT_POSITIVE are used to fit both unsigned long long and long
+   long arguments into LEFT_VALUE and RIGHT_VALUE.  */
+void support_test_compare_failure (const char *file, int line,
+                                   const char *left_expr,
+                                   long long left_value,
+                                   int left_positive,
+                                   const char *right_expr,
+                                   long long right_value,
+                                   int right_positive);
+
 /* Internal function called by the test driver.  */
 int support_report_failure (int status)
   __attribute__ ((weak, warn_unused_result));
diff --git a/support/support_test_compare_failure.c b/support/support_test_compare_failure.c
new file mode 100644
index 0000000000..38fec1ca89
--- /dev/null
+++ b/support/support_test_compare_failure.c
@@ -0,0 +1,46 @@
+/* Reporting mumeric comparison failure.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <stdio.h>
+#include <support/check.h>
+
+static void
+report (const char *which, const char *expr, long long value, int positive)
+{
+  printf ("  %s: ", which);
+  if (positive)
+    printf ("%llu", (unsigned long long) value);
+  else
+    printf ("%lld", value);
+  printf (" (0x%llx); from: %s\n", (unsigned long long) value, expr);
+}
+
+void
+support_test_compare_failure (const char *file, int line,
+                              const char *left_expr,
+                              long long left_value,
+                              int left_positive,
+                              const char *right_expr,
+                              long long right_value,
+                              int right_positive)
+{
+  support_record_failure ();
+  printf ("%s:%d: numeric comparison failure\n", file, line);
+  report (" left", left_expr, left_value, left_positive);
+  report ("right", right_expr, right_value, right_positive);
+}
diff --git a/support/xraise.c b/support/xraise.c
new file mode 100644
index 0000000000..9126c6c3ea
--- /dev/null
+++ b/support/xraise.c
@@ -0,0 +1,27 @@
+/* Error-checking wrapper for raise.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <support/check.h>
+#include <support/xsignal.h>
+
+void
+xraise (int sig)
+{
+  if (raise (sig) != 0)
+    FAIL_EXIT1 ("raise (%d): %m" , sig);
+}
diff --git a/support/xsigaction.c b/support/xsigaction.c
new file mode 100644
index 0000000000..b74c69afae
--- /dev/null
+++ b/support/xsigaction.c
@@ -0,0 +1,27 @@
+/* Error-checking wrapper for sigaction.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <support/check.h>
+#include <support/xsignal.h>
+
+void
+xsigaction (int sig, const struct sigaction *newact, struct sigaction *oldact)
+{
+  if (sigaction (sig, newact, oldact))
+    FAIL_EXIT1 ("sigaction (%d): %m" , sig);
+}
diff --git a/support/xsignal.c b/support/xsignal.c
new file mode 100644
index 0000000000..22a1dd74a7
--- /dev/null
+++ b/support/xsignal.c
@@ -0,0 +1,29 @@
+/* Error-checking wrapper for signal.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <support/check.h>
+#include <support/xsignal.h>
+
+sighandler_t
+xsignal (int sig, sighandler_t handler)
+{
+  sighandler_t result = signal (sig, handler);
+  if (result == SIG_ERR)
+    FAIL_EXIT1 ("signal (%d, %p): %m", sig, handler);
+  return result;
+}
diff --git a/support/xsignal.h b/support/xsignal.h
index 3dc0d9d5ce..3087ed0082 100644
--- a/support/xsignal.h
+++ b/support/xsignal.h
@@ -24,6 +24,14 @@
 
 __BEGIN_DECLS
 
+/* The following functions call the corresponding libc functions and
+   terminate the process on error.  */
+
+void xraise (int sig);
+sighandler_t xsignal (int sig, sighandler_t handler);
+void xsigaction (int sig, const struct sigaction *newact,
+                 struct sigaction *oldact);
+
 /* The following functions call the corresponding libpthread functions
    and terminate the process on error.  */
 
diff --git a/support/xsysconf.c b/support/xsysconf.c
new file mode 100644
index 0000000000..15ab1e26c4
--- /dev/null
+++ b/support/xsysconf.c
@@ -0,0 +1,36 @@
+/* Error-checking wrapper for sysconf.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <errno.h>
+#include <support/check.h>
+#include <support/xunistd.h>
+
+long
+xsysconf (int name)
+{
+  /* Detect errors by a changed errno value, in case -1 is a valid
+     value.  Make sure that the caller does not see the zero value for
+     errno.  */
+  int old_errno = errno;
+  errno = 0;
+  long result = sysconf (name);
+  if (errno != 0)
+    FAIL_EXIT1 ("sysconf (%d): %m", name);
+  errno = old_errno;
+  return result;
+}
diff --git a/support/xunistd.h b/support/xunistd.h
index 05c2626a7b..00376f7aae 100644
--- a/support/xunistd.h
+++ b/support/xunistd.h
@@ -39,6 +39,7 @@ void xstat (const char *path, struct stat64 *);
 void xmkdir (const char *path, mode_t);
 void xchroot (const char *path);
 void xunlink (const char *path);
+long xsysconf (int name);
 
 /* Read the link at PATH.  The caller should free the returned string
    with free.  */
diff --git a/sysdeps/unix/sysv/linux/Makefile b/sysdeps/unix/sysv/linux/Makefile
index 53e41510e3..095cf93892 100644
--- a/sysdeps/unix/sysv/linux/Makefile
+++ b/sysdeps/unix/sysv/linux/Makefile
@@ -18,7 +18,7 @@ sysdep_routines += clone umount umount2 readahead \
 		   setfsuid setfsgid epoll_pwait signalfd \
 		   eventfd eventfd_read eventfd_write prlimit \
 		   personality epoll_wait tee vmsplice splice \
-		   open_by_handle_at
+		   open_by_handle_at pkey_set pkey_get
 
 CFLAGS-gethostid.c = -fexceptions
 CFLAGS-tee.c = -fexceptions -fasynchronous-unwind-tables
@@ -44,7 +44,7 @@ sysdep_headers += sys/mount.h sys/acct.h sys/sysctl.h \
 
 tests += tst-clone tst-clone2 tst-clone3 tst-fanotify tst-personality \
 	 tst-quota tst-sync_file_range test-errno-linux tst-sysconf-iov_max \
-	 tst-memfd_create
+	 tst-memfd_create tst-pkey
 
 # Generate the list of SYS_* macros for the system calls (__NR_*
 # macros).  The file syscall-names.list contains all possible system
@@ -92,6 +92,8 @@ $(objpfx)tst-syscall-list.out: \
 # Separate object file for access to the constant from the UAPI header.
 $(objpfx)tst-sysconf-iov_max: $(objpfx)tst-sysconf-iov_max-uapi.o
 
+$(objpfx)tst-pkey: $(shared-thread-library)
+
 endif # $(subdir) == misc
 
 ifeq ($(subdir),time)
diff --git a/sysdeps/unix/sysv/linux/Versions b/sysdeps/unix/sysv/linux/Versions
index 992c19729f..798ffc7660 100644
--- a/sysdeps/unix/sysv/linux/Versions
+++ b/sysdeps/unix/sysv/linux/Versions
@@ -168,6 +168,7 @@ libc {
   }
   GLIBC_2.27 {
     memfd_create;
+    pkey_alloc; pkey_free; pkey_set; pkey_get; pkey_mprotect;
   }
   GLIBC_PRIVATE {
     # functions used in other libraries
diff --git a/sysdeps/unix/sysv/linux/aarch64/libc.abilist b/sysdeps/unix/sysv/linux/aarch64/libc.abilist
index 140ca28abc..85788be12b 100644
--- a/sysdeps/unix/sysv/linux/aarch64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/aarch64/libc.abilist
@@ -2107,6 +2107,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/alpha/libc.abilist b/sysdeps/unix/sysv/linux/alpha/libc.abilist
index f698e1b2f4..3b463dacbe 100644
--- a/sysdeps/unix/sysv/linux/alpha/libc.abilist
+++ b/sysdeps/unix/sysv/linux/alpha/libc.abilist
@@ -2018,6 +2018,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/arm/libc.abilist b/sysdeps/unix/sysv/linux/arm/libc.abilist
index 8a8af3e3e4..a1315aef35 100644
--- a/sysdeps/unix/sysv/linux/arm/libc.abilist
+++ b/sysdeps/unix/sysv/linux/arm/libc.abilist
@@ -108,6 +108,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.4 GLIBC_2.4 A
 GLIBC_2.4 _Exit F
 GLIBC_2.4 _IO_2_1_stderr_ D 0xa0
diff --git a/sysdeps/unix/sysv/linux/bits/mman-linux.h b/sysdeps/unix/sysv/linux/bits/mman-linux.h
index b091181960..da5ec79334 100644
--- a/sysdeps/unix/sysv/linux/bits/mman-linux.h
+++ b/sysdeps/unix/sysv/linux/bits/mman-linux.h
@@ -109,3 +109,38 @@
 # define MCL_ONFAULT	4		/* Lock all pages that are
 					   faulted in.  */
 #endif
+
+/* Memory protection key support.  */
+#ifdef __USE_GNU
+
+/* FLags for pkey_alloc.  */
+# define PKEY_DISABLE_ACCESS 0x1
+# define PKEY_DISABLE_WRITE 0x2
+
+__BEGIN_DECLS
+
+/* Allocate a new protection key, with the PKEY_DISABLE_* bits
+   specified in ACCESS_RIGHTS.  The protection key mask for the
+   current thread is updated to match the access privilege for the new
+   key.  */
+int pkey_alloc (unsigned int __flags, unsigned int __access_rights) __THROW;
+
+/* Update the access rights for the current thread for KEY, which must
+   have been allocated using pkey_alloc.  */
+int pkey_set (int __key, unsigned int __access_rights) __THROW;
+
+/* Return the access rights for the current thread for KEY, which must
+   have been allocated using pkey_alloc.  */
+int pkey_get (int _key) __THROW;
+
+/* Free an allocated protection key, which must have been allocated
+   using pkey_alloc.  */
+int pkey_free (int __key) __THROW;
+
+/* Apply memory protection flags for KEY to the specified address
+   range.  */
+int pkey_mprotect (void *__addr, size_t __len, int __prot, int __pkey) __THROW;
+
+__END_DECLS
+
+#endif /* __USE_GNU */
diff --git a/sysdeps/unix/sysv/linux/bits/siginfo-consts.h b/sysdeps/unix/sysv/linux/bits/siginfo-consts.h
index 525840cea1..e86b933040 100644
--- a/sysdeps/unix/sysv/linux/bits/siginfo-consts.h
+++ b/sysdeps/unix/sysv/linux/bits/siginfo-consts.h
@@ -111,8 +111,12 @@ enum
 {
   SEGV_MAPERR = 1,		/* Address not mapped to object.  */
 #  define SEGV_MAPERR	SEGV_MAPERR
-  SEGV_ACCERR			/* Invalid permissions for mapped object.  */
+  SEGV_ACCERR,			/* Invalid permissions for mapped object.  */
 #  define SEGV_ACCERR	SEGV_ACCERR
+  SEGV_BNDERR,			/* Bounds checking failure.  */
+#  define SEGV_BNDERR	SEGV_BNDERR
+  SEGV_PKUERR			/* Protection key checking failure.  */
+#  define SEGV_PKUERR	SEGV_PKUERR
 };
 
 /* `si_code' values for SIGBUS signal.  */
diff --git a/sysdeps/unix/sysv/linux/hppa/libc.abilist b/sysdeps/unix/sysv/linux/hppa/libc.abilist
index 5b81a6cd7d..7397d728f2 100644
--- a/sysdeps/unix/sysv/linux/hppa/libc.abilist
+++ b/sysdeps/unix/sysv/linux/hppa/libc.abilist
@@ -1872,6 +1872,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/i386/libc.abilist b/sysdeps/unix/sysv/linux/i386/libc.abilist
index 51ead9e867..cffdf251d6 100644
--- a/sysdeps/unix/sysv/linux/i386/libc.abilist
+++ b/sysdeps/unix/sysv/linux/i386/libc.abilist
@@ -2037,6 +2037,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/ia64/libc.abilist b/sysdeps/unix/sysv/linux/ia64/libc.abilist
index 78b4ee8d40..3292510a55 100644
--- a/sysdeps/unix/sysv/linux/ia64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/ia64/libc.abilist
@@ -1901,6 +1901,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/m68k/coldfire/libc.abilist b/sysdeps/unix/sysv/linux/m68k/coldfire/libc.abilist
index d9c97779e4..636bbdd1a7 100644
--- a/sysdeps/unix/sysv/linux/m68k/coldfire/libc.abilist
+++ b/sysdeps/unix/sysv/linux/m68k/coldfire/libc.abilist
@@ -109,6 +109,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.4 GLIBC_2.4 A
 GLIBC_2.4 _Exit F
 GLIBC_2.4 _IO_2_1_stderr_ D 0x98
diff --git a/sysdeps/unix/sysv/linux/m68k/m680x0/libc.abilist b/sysdeps/unix/sysv/linux/m68k/m680x0/libc.abilist
index 4acbf7eeed..6952863f86 100644
--- a/sysdeps/unix/sysv/linux/m68k/m680x0/libc.abilist
+++ b/sysdeps/unix/sysv/linux/m68k/m680x0/libc.abilist
@@ -1986,6 +1986,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/microblaze/libc.abilist b/sysdeps/unix/sysv/linux/microblaze/libc.abilist
index 93f02f08ce..ac5b56abab 100644
--- a/sysdeps/unix/sysv/linux/microblaze/libc.abilist
+++ b/sysdeps/unix/sysv/linux/microblaze/libc.abilist
@@ -2107,3 +2107,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/mips/mips32/fpu/libc.abilist b/sysdeps/unix/sysv/linux/mips/mips32/fpu/libc.abilist
index 795e85de70..bb0958e842 100644
--- a/sysdeps/unix/sysv/linux/mips/mips32/fpu/libc.abilist
+++ b/sysdeps/unix/sysv/linux/mips/mips32/fpu/libc.abilist
@@ -1961,6 +1961,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/mips/mips32/nofpu/libc.abilist b/sysdeps/unix/sysv/linux/mips/mips32/nofpu/libc.abilist
index dc714057b7..9104eb4d6d 100644
--- a/sysdeps/unix/sysv/linux/mips/mips32/nofpu/libc.abilist
+++ b/sysdeps/unix/sysv/linux/mips/mips32/nofpu/libc.abilist
@@ -1959,6 +1959,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/mips/mips64/n32/libc.abilist b/sysdeps/unix/sysv/linux/mips/mips64/n32/libc.abilist
index ce7bc9b175..58a5d5e141 100644
--- a/sysdeps/unix/sysv/linux/mips/mips64/n32/libc.abilist
+++ b/sysdeps/unix/sysv/linux/mips/mips64/n32/libc.abilist
@@ -1957,6 +1957,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/mips/mips64/n64/libc.abilist b/sysdeps/unix/sysv/linux/mips/mips64/n64/libc.abilist
index 3fdd85eace..2efac14a7d 100644
--- a/sysdeps/unix/sysv/linux/mips/mips64/n64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/mips/mips64/n64/libc.abilist
@@ -1952,6 +1952,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/nios2/libc.abilist b/sysdeps/unix/sysv/linux/nios2/libc.abilist
index 3e0bcb2a5c..9ef29e4e98 100644
--- a/sysdeps/unix/sysv/linux/nios2/libc.abilist
+++ b/sysdeps/unix/sysv/linux/nios2/libc.abilist
@@ -2148,3 +2148,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/pkey_get.c b/sysdeps/unix/sysv/linux/pkey_get.c
new file mode 100644
index 0000000000..fc3204c82f
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/pkey_get.c
@@ -0,0 +1,26 @@
+/* Obtaining the thread memory protection key, generic stub.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <errno.h>
+
+int
+pkey_get (int key)
+{
+  __set_errno (ENOSYS);
+  return -1;
+}
diff --git a/sysdeps/unix/sysv/linux/pkey_set.c b/sysdeps/unix/sysv/linux/pkey_set.c
new file mode 100644
index 0000000000..f686c4373c
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/pkey_set.c
@@ -0,0 +1,26 @@
+/* Changing the thread memory protection key, generic stub.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <errno.h>
+
+int
+pkey_set (int key, unsigned int access_rights)
+{
+  __set_errno (ENOSYS);
+  return -1;
+}
diff --git a/sysdeps/unix/sysv/linux/powerpc/powerpc32/fpu/libc.abilist b/sysdeps/unix/sysv/linux/powerpc/powerpc32/fpu/libc.abilist
index 375c69d9d1..60c024096f 100644
--- a/sysdeps/unix/sysv/linux/powerpc/powerpc32/fpu/libc.abilist
+++ b/sysdeps/unix/sysv/linux/powerpc/powerpc32/fpu/libc.abilist
@@ -1990,6 +1990,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/powerpc/powerpc32/nofpu/libc.abilist b/sysdeps/unix/sysv/linux/powerpc/powerpc32/nofpu/libc.abilist
index a88172a906..327933c973 100644
--- a/sysdeps/unix/sysv/linux/powerpc/powerpc32/nofpu/libc.abilist
+++ b/sysdeps/unix/sysv/linux/powerpc/powerpc32/nofpu/libc.abilist
@@ -1995,6 +1995,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc-le.abilist b/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc-le.abilist
index fa026a332c..b04c31bc10 100644
--- a/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc-le.abilist
+++ b/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc-le.abilist
@@ -2202,3 +2202,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc.abilist b/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc.abilist
index 838f395d78..e0645e9e25 100644
--- a/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/powerpc/powerpc64/libc.abilist
@@ -109,6 +109,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 _Exit F
 GLIBC_2.3 _IO_2_1_stderr_ D 0xe0
diff --git a/sysdeps/unix/sysv/linux/s390/s390-32/libc.abilist b/sysdeps/unix/sysv/linux/s390/s390-32/libc.abilist
index 41b79c496a..ef434c61a7 100644
--- a/sysdeps/unix/sysv/linux/s390/s390-32/libc.abilist
+++ b/sysdeps/unix/sysv/linux/s390/s390-32/libc.abilist
@@ -1990,6 +1990,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/s390/s390-64/libc.abilist b/sysdeps/unix/sysv/linux/s390/s390-64/libc.abilist
index 68251a0e69..4114a4ce57 100644
--- a/sysdeps/unix/sysv/linux/s390/s390-64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/s390/s390-64/libc.abilist
@@ -1891,6 +1891,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/sh/libc.abilist b/sysdeps/unix/sysv/linux/sh/libc.abilist
index bc1aae275e..f4478b0cc5 100644
--- a/sysdeps/unix/sysv/linux/sh/libc.abilist
+++ b/sysdeps/unix/sysv/linux/sh/libc.abilist
@@ -1876,6 +1876,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/sparc/sparc32/libc.abilist b/sysdeps/unix/sysv/linux/sparc/sparc32/libc.abilist
index 93e6d092ac..136a57fc0e 100644
--- a/sysdeps/unix/sysv/linux/sparc/sparc32/libc.abilist
+++ b/sysdeps/unix/sysv/linux/sparc/sparc32/libc.abilist
@@ -1983,6 +1983,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/sparc/sparc64/libc.abilist b/sysdeps/unix/sysv/linux/sparc/sparc64/libc.abilist
index b11d6764d4..9ad0790829 100644
--- a/sysdeps/unix/sysv/linux/sparc/sparc64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/sparc/sparc64/libc.abilist
@@ -1920,6 +1920,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.27 strfromf128 F
 GLIBC_2.27 strtof128 F
 GLIBC_2.27 strtof128_l F
diff --git a/sysdeps/unix/sysv/linux/syscalls.list b/sysdeps/unix/sysv/linux/syscalls.list
index 40c4fbb9ea..6f657eea2e 100644
--- a/sysdeps/unix/sysv/linux/syscalls.list
+++ b/sysdeps/unix/sysv/linux/syscalls.list
@@ -110,3 +110,6 @@ setns		EXTRA	setns		i:ii	setns
 process_vm_readv EXTRA	process_vm_readv i:ipipii process_vm_readv
 process_vm_writev EXTRA	process_vm_writev i:ipipii process_vm_writev
 memfd_create    EXTRA	memfd_create	i:si    memfd_create
+pkey_alloc	EXTRA	pkey_alloc	i:ii	pkey_alloc
+pkey_free	EXTRA	pkey_free	i:i	pkey_free
+pkey_mprotect	EXTRA	pkey_mprotect	i:aiii  pkey_mprotect
diff --git a/sysdeps/unix/sysv/linux/tile/tilegx/tilegx32/libc.abilist b/sysdeps/unix/sysv/linux/tile/tilegx/tilegx32/libc.abilist
index e9eb4ff7bd..d4f2094027 100644
--- a/sysdeps/unix/sysv/linux/tile/tilegx/tilegx32/libc.abilist
+++ b/sysdeps/unix/sysv/linux/tile/tilegx/tilegx32/libc.abilist
@@ -2114,3 +2114,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/tile/tilegx/tilegx64/libc.abilist b/sysdeps/unix/sysv/linux/tile/tilegx/tilegx64/libc.abilist
index 8f08e909cd..4916dbabb5 100644
--- a/sysdeps/unix/sysv/linux/tile/tilegx/tilegx64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/tile/tilegx/tilegx64/libc.abilist
@@ -2114,3 +2114,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/tile/tilepro/libc.abilist b/sysdeps/unix/sysv/linux/tile/tilepro/libc.abilist
index e9eb4ff7bd..d4f2094027 100644
--- a/sysdeps/unix/sysv/linux/tile/tilepro/libc.abilist
+++ b/sysdeps/unix/sysv/linux/tile/tilepro/libc.abilist
@@ -2114,3 +2114,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
diff --git a/sysdeps/unix/sysv/linux/tst-pkey.c b/sysdeps/unix/sysv/linux/tst-pkey.c
new file mode 100644
index 0000000000..42d50e37c2
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/tst-pkey.c
@@ -0,0 +1,390 @@
+/* Tests for memory protection keys.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <errno.h>
+#include <inttypes.h>
+#include <setjmp.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <support/check.h>
+#include <support/support.h>
+#include <support/test-driver.h>
+#include <support/xsignal.h>
+#include <support/xthread.h>
+#include <support/xunistd.h>
+#include <sys/mman.h>
+
+/* Used to force threads to wait until the main thread has set up the
+   keys as intended.  */
+static pthread_barrier_t barrier;
+
+/* The keys used for testing.  These have been allocated with access
+   rights set based on their array index.  */
+enum { key_count = 4 };
+static int keys[key_count];
+static volatile int *pages[key_count];
+
+/* Used to report results from the signal handler.  */
+static volatile void *sigsegv_addr;
+static volatile int sigsegv_code;
+static volatile int sigsegv_pkey;
+static sigjmp_buf sigsegv_jmp;
+
+/* Used to handle expected read or write faults.  */
+static void
+sigsegv_handler (int signum, siginfo_t *info, void *context)
+{
+  sigsegv_addr = info->si_addr;
+  sigsegv_code = info->si_code;
+  sigsegv_pkey = info->si_pkey;
+  siglongjmp (sigsegv_jmp, 2);
+}
+
+static const struct sigaction sigsegv_sigaction =
+  {
+    .sa_flags = SA_RESETHAND | SA_SIGINFO,
+    .sa_sigaction = &sigsegv_handler,
+  };
+
+/* Check if PAGE is readable (if !WRITE) or writable (if WRITE).  */
+static bool
+check_page_access (int page, bool write)
+{
+  /* This is needed to work around bug 22396: On x86-64, siglongjmp
+     does not restore the protection key access rights for the current
+     thread.  We restore only the access rights for the keys under
+     test.  (This is not a general solution to this problem, but it
+     allows testing to proceed after a fault.)  */
+  unsigned saved_rights[key_count];
+  for (int i = 0; i < key_count; ++i)
+    saved_rights[i] = pkey_get (keys[i]);
+
+  volatile int *addr = pages[page];
+  if (test_verbose > 0)
+    {
+      printf ("info: checking access at %p (page %d) for %s\n",
+              addr, page, write ? "writing" : "reading");
+    }
+  int result = sigsetjmp (sigsegv_jmp, 1);
+  if (result == 0)
+    {
+      xsigaction (SIGSEGV, &sigsegv_sigaction, NULL);
+      if (write)
+        *addr = 3;
+      else
+        (void) *addr;
+      xsignal (SIGSEGV, SIG_DFL);
+      if (test_verbose > 0)
+        puts ("  --> access allowed");
+      return true;
+    }
+  else
+    {
+      xsignal (SIGSEGV, SIG_DFL);
+      if (test_verbose > 0)
+        puts ("  --> access denied");
+      TEST_COMPARE (result, 2);
+      TEST_COMPARE ((uintptr_t) sigsegv_addr, (uintptr_t) addr);
+      TEST_COMPARE (sigsegv_code, SEGV_PKUERR);
+      TEST_COMPARE (sigsegv_pkey, keys[page]);
+      for (int i = 0; i < key_count; ++i)
+        TEST_COMPARE (pkey_set (keys[i], saved_rights[i]), 0);
+      return false;
+    }
+}
+
+static volatile sig_atomic_t sigusr1_handler_ran;
+
+/* Used to check that access is revoked in signal handlers.  */
+static void
+sigusr1_handler (int signum)
+{
+  TEST_COMPARE (signum, SIGUSR1);
+  for (int i = 0; i < key_count; ++i)
+    TEST_COMPARE (pkey_get (keys[i]), PKEY_DISABLE_ACCESS);
+  sigusr1_handler_ran = 1;
+}
+
+/* Used to report results from other threads.  */
+struct thread_result
+{
+  int access_rights[key_count];
+  pthread_t next_thread;
+};
+
+/* Return the thread's access rights for the keys under test.  */
+static void *
+get_thread_func (void *closure)
+{
+  struct thread_result *result = xmalloc (sizeof (*result));
+  for (int i = 0; i < key_count; ++i)
+    result->access_rights[i] = pkey_get (keys[i]);
+  memset (&result->next_thread, 0, sizeof (result->next_thread));
+  return result;
+}
+
+/* Wait for initialization and then check that the current thread does
+   not have access through the keys under test.  */
+static void *
+delayed_thread_func (void *closure)
+{
+  bool check_access = *(bool *) closure;
+  pthread_barrier_wait (&barrier);
+  struct thread_result *result = get_thread_func (NULL);
+
+  if (check_access)
+    {
+      /* Also check directly.  This code should not run with other
+         threads in parallel because of the SIGSEGV handler which is
+         installed by check_page_access.  */
+      for (int i = 0; i < key_count; ++i)
+        {
+          TEST_VERIFY (!check_page_access (i, false));
+          TEST_VERIFY (!check_page_access (i, true));
+        }
+    }
+
+  result->next_thread = xpthread_create (NULL, get_thread_func, NULL);
+  return result;
+}
+
+static int
+do_test (void)
+{
+  long pagesize = xsysconf (_SC_PAGESIZE);
+
+  xpthread_barrier_init (&barrier, NULL, 2);
+  bool delayed_thread_check_access = true;
+  pthread_t delayed_thread = xpthread_create
+    (NULL, &delayed_thread_func, &delayed_thread_check_access);
+
+  keys[0] = pkey_alloc (0, 0);
+  if (keys[0] < 0)
+    {
+      if (errno == ENOSYS)
+        {
+          puts ("warning: kernel does not support memory protection keys");
+          return EXIT_UNSUPPORTED;
+        }
+      if (errno == ENOSPC)
+        {
+          puts ("warning: CPU does not support memory protection keys");
+          return EXIT_UNSUPPORTED;
+        }
+      FAIL_EXIT1 ("pkey_alloc: %m");
+    }
+  TEST_COMPARE (pkey_get (keys[0]), 0);
+  for (int i = 1; i < key_count; ++i)
+    {
+      keys[i] = pkey_alloc (0, i);
+      if (keys[i] < 0)
+        FAIL_EXIT1 ("pkey_alloc (0, %d): %m", i);
+      /* pkey_alloc is supposed to change the current thread's access
+         rights for the new key.  */
+      TEST_COMPARE (pkey_get (keys[i]), i);
+    }
+  /* Check that all the keys have the expected access rights for the
+     current thread.  */
+  for (int i = 0; i < key_count; ++i)
+    TEST_COMPARE (pkey_get (keys[i]), i);
+
+  /* Allocate a test page for each key.  */
+  for (int i = 0; i < key_count; ++i)
+    {
+      pages[i] = xmmap (NULL, pagesize, PROT_READ | PROT_WRITE,
+                        MAP_ANONYMOUS | MAP_PRIVATE, -1);
+      TEST_COMPARE (pkey_mprotect ((void *) pages[i], pagesize,
+                                   PROT_READ | PROT_WRITE, keys[i]), 0);
+    }
+
+  /* Check that the initial thread does not have access to the new
+     keys.  */
+  {
+    pthread_barrier_wait (&barrier);
+    struct thread_result *result = xpthread_join (delayed_thread);
+    for (int i = 0; i < key_count; ++i)
+      TEST_COMPARE (result->access_rights[i],
+                    PKEY_DISABLE_ACCESS);
+    struct thread_result *result2 = xpthread_join (result->next_thread);
+    for (int i = 0; i < key_count; ++i)
+      TEST_COMPARE (result->access_rights[i],
+                    PKEY_DISABLE_ACCESS);
+    free (result);
+    free (result2);
+  }
+
+  /* Check that the current thread access rights are inherited by new
+     threads.  */
+  {
+    pthread_t get_thread = xpthread_create (NULL, get_thread_func, NULL);
+    struct thread_result *result = xpthread_join (get_thread);
+    for (int i = 0; i < key_count; ++i)
+      TEST_COMPARE (result->access_rights[i], i);
+    free (result);
+  }
+
+  for (int i = 0; i < key_count; ++i)
+    TEST_COMPARE (pkey_get (keys[i]), i);
+
+  /* Check that in a signal handler, there is no access.  */
+  xsignal (SIGUSR1, &sigusr1_handler);
+  xraise (SIGUSR1);
+  xsignal (SIGUSR1, SIG_DFL);
+  TEST_COMPARE (sigusr1_handler_ran, 1);
+
+  /* The first key results in a writable page.  */
+  TEST_VERIFY (check_page_access (0, false));
+  TEST_VERIFY (check_page_access (0, true));
+
+  /* The other keys do not.   */
+  for (int i = 1; i < key_count; ++i)
+    {
+      if (test_verbose)
+        printf ("info: checking access for key %d, bits 0x%x\n",
+                i, pkey_get (keys[i]));
+      for (int j = 0; j < key_count; ++j)
+        TEST_COMPARE (pkey_get (keys[j]), j);
+      if (i & PKEY_DISABLE_ACCESS)
+        {
+          TEST_VERIFY (!check_page_access (i, false));
+          TEST_VERIFY (!check_page_access (i, true));
+        }
+      else
+        {
+          TEST_VERIFY (i & PKEY_DISABLE_WRITE);
+          TEST_VERIFY (check_page_access (i, false));
+          TEST_VERIFY (!check_page_access (i, true));
+        }
+    }
+
+  /* But if we set the current thread's access rights, we gain
+     access.  */
+  for (int do_write = 0; do_write < 2; ++do_write)
+    for (int allowed_key = 0; allowed_key < key_count; ++allowed_key)
+      {
+        for (int i = 0; i < key_count; ++i)
+          if (i == allowed_key)
+            {
+              if (do_write)
+                TEST_COMPARE (pkey_set (keys[i], 0), 0);
+              else
+                TEST_COMPARE (pkey_set (keys[i], PKEY_DISABLE_WRITE), 0);
+            }
+          else
+            TEST_COMPARE (pkey_set (keys[i], PKEY_DISABLE_ACCESS), 0);
+
+        if (test_verbose)
+          printf ("info: key %d is allowed access for %s\n",
+                  allowed_key, do_write ? "writing" : "reading");
+        for (int i = 0; i < key_count; ++i)
+          if (i == allowed_key)
+            {
+              TEST_VERIFY (check_page_access (i, false));
+              TEST_VERIFY (check_page_access (i, true) == do_write);
+            }
+          else
+            {
+              TEST_VERIFY (!check_page_access (i, false));
+              TEST_VERIFY (!check_page_access (i, true));
+            }
+      }
+
+  /* Restore access to all keys, and launch a thread which should
+     inherit that access.  */
+  for (int i = 0; i < key_count; ++i)
+    {
+      TEST_COMPARE (pkey_set (keys[i], 0), 0);
+      TEST_VERIFY (check_page_access (i, false));
+      TEST_VERIFY (check_page_access (i, true));
+    }
+  delayed_thread_check_access = false;
+  delayed_thread = xpthread_create
+    (NULL, delayed_thread_func, &delayed_thread_check_access);
+
+  TEST_COMPARE (pkey_free (keys[0]), 0);
+  /* Second pkey_free will fail because the key has already been
+     freed.  */
+  TEST_COMPARE (pkey_free (keys[0]),-1);
+  TEST_COMPARE (errno, EINVAL);
+  for (int i = 1; i < key_count; ++i)
+    TEST_COMPARE (pkey_free (keys[i]), 0);
+
+  /* Check what happens to running threads which have access to
+     previously allocated protection keys.  The implemented behavior
+     is somewhat dubious: Ideally, pkey_free should revoke access to
+     that key and pkey_alloc of the same (numeric) key should not
+     implicitly confer access to already-running threads, but this is
+     not what happens in practice.  */
+  {
+    /* The limit is in place to avoid running indefinitely in case
+       there many keys available.  */
+    int *keys_array = xcalloc (100000, sizeof (*keys_array));
+    int keys_allocated = 0;
+    while (keys_allocated < 100000)
+      {
+        int new_key = pkey_alloc (0, PKEY_DISABLE_WRITE);
+        if (new_key < 0)
+          {
+            /* No key reuse observed before running out of keys.  */
+            TEST_COMPARE (errno, ENOSPC);
+            break;
+          }
+        for (int i = 0; i < key_count; ++i)
+          if (new_key == keys[i])
+            {
+              /* We allocated the key with disabled write access.
+                 This should affect the protection state of the
+                 existing page.  */
+              TEST_VERIFY (check_page_access (i, false));
+              TEST_VERIFY (!check_page_access (i, true));
+
+              xpthread_barrier_wait (&barrier);
+              struct thread_result *result = xpthread_join (delayed_thread);
+              /* The thread which was launched before should still have
+                 access to the key.  */
+              TEST_COMPARE (result->access_rights[i], 0);
+              struct thread_result *result2
+                = xpthread_join (result->next_thread);
+              /* Same for a thread which is launched afterwards from
+                 the old thread.  */
+              TEST_COMPARE (result2->access_rights[i], 0);
+              free (result);
+              free (result2);
+              keys_array[keys_allocated++] = new_key;
+              goto after_key_search;
+            }
+        /* Save key for later deallocation.  */
+        keys_array[keys_allocated++] = new_key;
+      }
+  after_key_search:
+    /* Deallocate the keys allocated for testing purposes.  */
+    for (int j = 0; j < keys_allocated; ++j)
+      TEST_COMPARE (pkey_free (keys_array[j]), 0);
+    free (keys_array);
+  }
+
+  for (int i = 0; i < key_count; ++i)
+    xmunmap ((void *) pages[i], pagesize);
+
+  xpthread_barrier_destroy (&barrier);
+  return 0;
+}
+
+#include <support/test-driver.c>
diff --git a/sysdeps/unix/sysv/linux/x86_64/64/libc.abilist b/sysdeps/unix/sysv/linux/x86_64/64/libc.abilist
index 0a4f7797ac..1ea74f9e8c 100644
--- a/sysdeps/unix/sysv/linux/x86_64/64/libc.abilist
+++ b/sysdeps/unix/sysv/linux/x86_64/64/libc.abilist
@@ -1878,6 +1878,11 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F
 GLIBC_2.3 GLIBC_2.3 A
 GLIBC_2.3 __ctype_b_loc F
 GLIBC_2.3 __ctype_tolower_loc F
diff --git a/sysdeps/unix/sysv/linux/x86_64/arch-pkey.h b/sysdeps/unix/sysv/linux/x86_64/arch-pkey.h
new file mode 100644
index 0000000000..8e9bfdae96
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/x86_64/arch-pkey.h
@@ -0,0 +1,40 @@
+/* Helper functions for manipulating memory protection keys.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#ifndef _ARCH_PKEY_H
+#define _ARCH_PKEY_H
+
+/* Return the value of the PKRU register.  */
+static inline unsigned int
+pkey_read (void)
+{
+  unsigned int result;
+  __asm__ volatile (".byte 0x0f, 0x01, 0xee"
+                    : "=a" (result) : "c" (0) : "rdx");
+  return result;
+}
+
+/* Overwrite the PKRU register with VALUE.  */
+static inline void
+pkey_write (unsigned int value)
+{
+  __asm__ volatile (".byte 0x0f, 0x01, 0xef"
+                    : : "a" (value), "c" (0), "d" (0));
+}
+
+#endif /* _ARCH_PKEY_H */
diff --git a/sysdeps/unix/sysv/linux/x86_64/pkey_get.c b/sysdeps/unix/sysv/linux/x86_64/pkey_get.c
new file mode 100644
index 0000000000..3a9bfbe676
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/x86_64/pkey_get.c
@@ -0,0 +1,33 @@
+/* Reading the per-thread memory protection key, x86_64 version.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <arch-pkey.h>
+#include <errno.h>
+
+int
+pkey_get (int key)
+{
+  if (key < 0 || key > 15)
+    {
+      __set_errno (EINVAL);
+      return -1;
+    }
+  unsigned int pkru = pkey_read ();
+  return (pkru >> (2 * key)) & 3;
+  return 0;
+}
diff --git a/sysdeps/unix/sysv/linux/x86_64/pkey_set.c b/sysdeps/unix/sysv/linux/x86_64/pkey_set.c
new file mode 100644
index 0000000000..91dffd22c3
--- /dev/null
+++ b/sysdeps/unix/sysv/linux/x86_64/pkey_set.c
@@ -0,0 +1,35 @@
+/* Changing the per-thread memory protection key, x86_64 version.
+   Copyright (C) 2017 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Lesser General Public
+   License as published by the Free Software Foundation; either
+   version 2.1 of the License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Lesser General Public License for more details.
+
+   You should have received a copy of the GNU Lesser General Public
+   License along with the GNU C Library; if not, see
+   <http://www.gnu.org/licenses/>.  */
+
+#include <arch-pkey.h>
+#include <errno.h>
+
+int
+pkey_set (int key, unsigned int rights)
+{
+  if (key < 0 || key > 15 || rights > 3)
+    {
+      __set_errno (EINVAL);
+      return -1;
+    }
+  unsigned int mask = 3 << (2 * key);
+  unsigned int pkru = pkey_read ();
+  pkru = (pkru & ~mask) | (rights << (2 * key));
+  pkey_write (pkru);
+  return 0;
+}
diff --git a/sysdeps/unix/sysv/linux/x86_64/x32/libc.abilist b/sysdeps/unix/sysv/linux/x86_64/x32/libc.abilist
index 23f6a91429..1d3d598618 100644
--- a/sysdeps/unix/sysv/linux/x86_64/x32/libc.abilist
+++ b/sysdeps/unix/sysv/linux/x86_64/x32/libc.abilist
@@ -2121,3 +2121,8 @@ GLIBC_2.27 GLIBC_2.27 A
 GLIBC_2.27 glob F
 GLIBC_2.27 glob64 F
 GLIBC_2.27 memfd_create F
+GLIBC_2.27 pkey_alloc F
+GLIBC_2.27 pkey_free F
+GLIBC_2.27 pkey_get F
+GLIBC_2.27 pkey_mprotect F
+GLIBC_2.27 pkey_set F

--------------FD90FF5814645BD95351E841--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
