Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21EA36B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:18:20 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id kc8so205201416pab.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:18:20 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g23si27858191pgn.73.2016.10.17.08.18.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 08:18:15 -0700 (PDT)
Subject: [PATCH] generic syscalls: kill cruft from removed pkey syscalls
From: Dave Hansen <dave@sr71.net>
Date: Mon, 17 Oct 2016 08:18:15 -0700
Message-Id: <20161017151814.1CE8B6C3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, tglx@linutronix.de, x86@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org, mgorman@techsingularity.net, linux-api@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org


From: Dave Hansen <dave.hansen@intel.com>

pkey_set() and pkey_get() were syscalls present in older versions
of the protection keys patches.  They were fully excised from the
x86 code, but some cruft was left in the generic syscall code.  The
C++ comments were intended to help to make it more glaring to me to
fix them before actually submitting them.  That technique worked,
but later than I would have liked.

I test-compiled this for arm64.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org
Cc: mgorman@techsingularity.net
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: luto@kernel.org
Cc: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org
Fixes: a60f7b69d92c0 ("generic syscalls: Wire up memory protection keys syscalls")
---

 b/include/linux/syscalls.h          |    3 ---
 b/include/uapi/asm-generic/unistd.h |    4 ----
 2 files changed, 7 deletions(-)

diff -puN include/uapi/asm-generic/unistd.h~kill-kpkey-syscall-nr-cruft include/uapi/asm-generic/unistd.h
--- a/include/uapi/asm-generic/unistd.h~kill-kpkey-syscall-nr-cruft	2016-10-17 08:05:47.587207124 -0700
+++ b/include/uapi/asm-generic/unistd.h	2016-10-17 08:06:01.759844119 -0700
@@ -730,10 +730,6 @@ __SYSCALL(__NR_pkey_mprotect, sys_pkey_m
 __SYSCALL(__NR_pkey_alloc,    sys_pkey_alloc)
 #define __NR_pkey_free 290
 __SYSCALL(__NR_pkey_free,     sys_pkey_free)
-#define __NR_pkey_get 291
-//__SYSCALL(__NR_pkey_get,      sys_pkey_get)
-#define __NR_pkey_set 292
-//__SYSCALL(__NR_pkey_set,      sys_pkey_set)
 
 #undef __NR_syscalls
 #define __NR_syscalls 291
diff -puN include/linux/syscalls.h~kill-kpkey-syscall-nr-cruft include/linux/syscalls.h
--- a/include/linux/syscalls.h~kill-kpkey-syscall-nr-cruft	2016-10-17 08:06:42.364669174 -0700
+++ b/include/linux/syscalls.h	2016-10-17 08:07:03.688627647 -0700
@@ -902,8 +902,5 @@ asmlinkage long sys_pkey_mprotect(unsign
 				  unsigned long prot, int pkey);
 asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
 asmlinkage long sys_pkey_free(int pkey);
-//asmlinkage long sys_pkey_get(int pkey, unsigned long flags);
-//asmlinkage long sys_pkey_set(int pkey, unsigned long access_rights,
-//			     unsigned long flags);
 
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
