Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDD96B026A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:19:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d20so6134325pfn.16
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:19:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t19-v6si24162258plo.287.2018.05.09.10.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 10:19:05 -0700 (PDT)
Subject: [PATCH 13/13] x86/pkeys: Do not special case protection key 0
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 09 May 2018 10:13:58 -0700
References: <20180509171336.76636D88@viggo.jf.intel.com>
In-Reply-To: <20180509171336.76636D88@viggo.jf.intel.com>
Message-Id: <20180509171358.47FD785E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, stable@vger.kernel.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

mm_pkey_is_allocated() treats pkey 0 as unallocated.  That is
inconsistent with the manpages, and also inconsistent with
mm->context.pkey_allocation_map.  Stop special casing it and only
disallow values that are actually bad (< 0).

The end-user visible effect of this is that you can now use
mprotect_pkey() to set pkey=0.

This is a bit nicer than what Ram proposed[1] because it is simpler
and removes special-casing for pkey 0.  On the other hand, it does
allow applications to pkey_free() pkey-0, but that's just a silly
thing to do, so we are not going to protect against it.

The scenario that could happen is similar to what happens if you free
any other pkey that is in use: it might get reallocated later and used
to protect some other data.  The most likely scenario is that pkey-0
comes back from pkey_alloc(), an access-disable or write-disable bit
is set in PKRU for it, and the next stack access will SIGSEGV.  It's
not horribly different from if you mprotect()'d your stack or heap to
be unreadable or unwritable, which is generally very foolish, but also
not explicitly prevented by the kernel.

1. http://lkml.kernel.org/r/1522112702-27853-1-git-send-email-linuxram@us.ibm.com

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: 58ab9a088dda ("x86/pkeys: Check against max pkey to avoid overflows")
Cc: stable@vger.kernel.org
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>p
Cc: Shuah Khan <shuah@kernel.org>
---

 b/arch/x86/include/asm/mmu_context.h |    2 +-
 b/arch/x86/include/asm/pkeys.h       |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated	2018-05-09 09:20:24.362698393 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2018-05-09 09:20:24.367698393 -0700
@@ -193,7 +193,7 @@ static inline int init_new_context(struc
 
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
-		/* pkey 0 is the default and always allocated */
+		/* pkey 0 is the default and allocated implicitly */
 		mm->context.pkey_allocation_map = 0x1;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
diff -puN arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated	2018-05-09 09:20:24.364698393 -0700
+++ b/arch/x86/include/asm/pkeys.h	2018-05-09 09:20:24.367698393 -0700
@@ -51,10 +51,10 @@ bool mm_pkey_is_allocated(struct mm_stru
 {
 	/*
 	 * "Allocated" pkeys are those that have been returned
-	 * from pkey_alloc().  pkey 0 is special, and never
-	 * returned from pkey_alloc().
+	 * from pkey_alloc() or pkey 0 which is allocated
+	 * implicitly when the mm is created.
 	 */
-	if (pkey <= 0)
+	if (pkey < 0)
 		return false;
 	if (pkey >= arch_max_pkey())
 		return false;
_
