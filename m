Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37064828E1
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:30:24 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so110566312pab.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:30:24 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id c69si19071809pfj.224.2016.07.29.09.30.19
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 09:30:19 -0700 (PDT)
Subject: [PATCH 06/10] generic syscalls: wire up memory protection keys syscalls
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jul 2016 09:30:18 -0700
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
In-Reply-To: <20160729163009.5EC1D38C@viggo.jf.intel.com>
Message-Id: <20160729163018.505A6875@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de


From: Dave Hansen <dave.hansen@linux.intel.com>

These new syscalls are implemented as generic code, so enable
them for architectures like arm64 which use the generic syscall
table.

According to Arnd:

	Even if the support is x86 specific for the forseeable
	future, it may be good to reserve the number just in
	case.  The other architecture specific syscall lists are
	usually left to the individual arch maintainers, most a
	lot of the newer architectures share this table.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net
---

 b/include/linux/syscalls.h          |    8 ++++++++
 b/include/uapi/asm-generic/unistd.h |   12 +++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff -puN include/linux/syscalls.h~pkeys-119-syscalls-generic include/linux/syscalls.h
--- a/include/linux/syscalls.h~pkeys-119-syscalls-generic	2016-07-29 09:18:58.426562491 -0700
+++ b/include/linux/syscalls.h	2016-07-29 09:18:58.431562718 -0700
@@ -898,4 +898,12 @@ asmlinkage long sys_copy_file_range(int
 
 asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
 
+asmlinkage long sys_pkey_mprotect(unsigned long start, size_t len,
+				  unsigned long prot, int pkey);
+asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
+asmlinkage long sys_pkey_free(int pkey);
+//asmlinkage long sys_pkey_get(int pkey, unsigned long flags);
+//asmlinkage long sys_pkey_set(int pkey, unsigned long access_rights,
+//			     unsigned long flags);
+
 #endif
diff -puN include/uapi/asm-generic/unistd.h~pkeys-119-syscalls-generic include/uapi/asm-generic/unistd.h
--- a/include/uapi/asm-generic/unistd.h~pkeys-119-syscalls-generic	2016-07-29 09:18:58.428562582 -0700
+++ b/include/uapi/asm-generic/unistd.h	2016-07-29 09:18:58.432562763 -0700
@@ -724,9 +724,19 @@ __SYSCALL(__NR_copy_file_range, sys_copy
 __SC_COMP(__NR_preadv2, sys_preadv2, compat_sys_preadv2)
 #define __NR_pwritev2 287
 __SC_COMP(__NR_pwritev2, sys_pwritev2, compat_sys_pwritev2)
+#define __NR_pkey_mprotect 288
+__SYSCALL(__NR_pkey_mprotect, sys_pkey_mprotect)
+#define __NR_pkey_alloc 289
+__SYSCALL(__NR_pkey_alloc,    sys_pkey_alloc)
+#define __NR_pkey_free 290
+__SYSCALL(__NR_pkey_free,     sys_pkey_free)
+#define __NR_pkey_get 291
+//__SYSCALL(__NR_pkey_get,      sys_pkey_get)
+#define __NR_pkey_set 292
+//__SYSCALL(__NR_pkey_set,      sys_pkey_set)
 
 #undef __NR_syscalls
-#define __NR_syscalls 288
+#define __NR_syscalls 291
 
 /*
  * All syscalls below here should go away really,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
