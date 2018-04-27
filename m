Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C52E6B0009
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:49:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x205-v6so2120250pgx.19
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 10:49:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h64-v6si1618827pge.206.2018.04.27.10.49.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 10:49:52 -0700 (PDT)
Subject: [PATCH 4/9] x86, pkeys: override pkey when moving away from PROT_EXEC
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 27 Apr 2018 10:45:32 -0700
References: <20180427174527.0031016C@viggo.jf.intel.com>
In-Reply-To: <20180427174527.0031016C@viggo.jf.intel.com>
Message-Id: <20180427174532.B20FFEA3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, shakeelb@google.com, stable@vger.kernel.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

I got a bug report that the following code (roughly) was
causing a SIGSEGV:

	mprotect(ptr, size, PROT_EXEC);
	mprotect(ptr, size, PROT_NONE);
	mprotect(ptr, size, PROT_READ);
	*ptr = 100;

The problem is hit when the mprotect(PROT_EXEC)
is implicitly assigned a protection key to the VMA, and made
that key ACCESS_DENY|WRITE_DENY.  The PROT_NONE mprotect()
failed to remove the protection key, and the PROT_NONE->
PROT_READ left the PTE usable, but the pkey still in place
and left the memory inaccessible.

To fix this, we ensure that we always "override" the pkee
at mprotect() if the VMA does not have execute-only
permissions, but the VMA has the execute-only pkey.

We had a check for PROT_READ/WRITE, but it did not work
for PROT_NONE.  This entirely removes the PROT_* checks,
which ensures that PROT_NONE now works.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 62b5f7d013f ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
Reported-by: Shakeel Butt <shakeelb@google.com>
Cc: stable@vger.kernel.org
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuah@kernel.org>
---

 b/arch/x86/include/asm/pkeys.h |   12 +++++++++++-
 b/arch/x86/mm/pkeys.c          |   21 +++++++++++----------
 2 files changed, 22 insertions(+), 11 deletions(-)

diff -puN arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively	2018-04-26 10:42:18.971487371 -0700
+++ b/arch/x86/include/asm/pkeys.h	2018-04-26 10:42:18.977487371 -0700
@@ -2,6 +2,8 @@
 #ifndef _ASM_X86_PKEYS_H
 #define _ASM_X86_PKEYS_H
 
+#define ARCH_DEFAULT_PKEY	0
+
 #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
 
 extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
@@ -15,7 +17,7 @@ extern int __execute_only_pkey(struct mm
 static inline int execute_only_pkey(struct mm_struct *mm)
 {
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
-		return 0;
+		return ARCH_DEFAULT_PKEY;
 
 	return __execute_only_pkey(mm);
 }
@@ -56,6 +58,14 @@ bool mm_pkey_is_allocated(struct mm_stru
 		return false;
 	if (pkey >= arch_max_pkey())
 		return false;
+	/*
+	 * The exec-only pkey is set in the allocation map, but
+	 * is not available to any of the user interfaces like
+	 * mprotect_pkey().
+	 */
+	if (pkey == mm->context.execute_only_pkey)
+		return false;
+
 	return mm_pkey_allocation_map(mm) & (1U << pkey);
 }
 
diff -puN arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/mm/pkeys.c
--- a/arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively	2018-04-26 10:42:18.973487371 -0700
+++ b/arch/x86/mm/pkeys.c	2018-04-26 10:47:34.806486584 -0700
@@ -94,26 +94,27 @@ int __arch_override_mprotect_pkey(struct
 	 */
 	if (pkey != -1)
 		return pkey;
-	/*
-	 * Look for a protection-key-drive execute-only mapping
-	 * which is now being given permissions that are not
-	 * execute-only.  Move it back to the default pkey.
-	 */
-	if (vma_is_pkey_exec_only(vma) &&
-	    (prot & (PROT_READ|PROT_WRITE))) {
-		return 0;
-	}
+
 	/*
 	 * The mapping is execute-only.  Go try to get the
 	 * execute-only protection key.  If we fail to do that,
 	 * fall through as if we do not have execute-only
-	 * support.
+	 * support in this mm.
 	 */
 	if (prot == PROT_EXEC) {
 		pkey = execute_only_pkey(vma->vm_mm);
 		if (pkey > 0)
 			return pkey;
+	} else if (vma_is_pkey_exec_only(vma)) {
+		/*
+		 * Protections are *not* PROT_EXEC, but the mapping
+		 * is using the exec-only pkey.  This mapping was
+		 * PROT_EXEC and will no longer be.  Move back to
+		 * the default pkey.
+		 */
+		return ARCH_DEFAULT_PKEY;
 	}
+
 	/*
 	 * This is a vanilla, non-pkey mprotect (or we failed to
 	 * setup execute-only), inherit the pkey from the VMA we
_
