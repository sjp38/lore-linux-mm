Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD116B0027
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:48:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r1so5263529pgq.7
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:48:32 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d126si5599940pgc.385.2018.03.16.14.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:48:31 -0700 (PDT)
Subject: [PATCH 1/3] x86, pkeys: do not special case protection key 0
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 16 Mar 2018 14:46:56 -0700
References: <20180316214654.895E24EC@viggo.jf.intel.com>
In-Reply-To: <20180316214654.895E24EC@viggo.jf.intel.com>
Message-Id: <20180316214656.0E059008@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

mm_pkey_is_allocated() treats pkey 0 as unallocated.  That is
inconsistent with the manpages, and also inconsistent with
mm->context.pkey_allocation_map.  Stop special casing it and only
disallow values that are actually bad (< 0).

The end-user visible effect of this is that you can now use
mprotect_pkey() to set pkey=0.

This is a bit nicer than what Ram proposed because it is simpler
and removes special-casing for pkey 0.  On the other hand, it does
allow applciations to pkey_free() pkey-0, but that's just a silly
thing to do, so we are not going to protect against it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
--- a/arch/x86/include/asm/mmu_context.h~x86-pkey-0-default-allocated	2018-03-16 14:46:39.023285476 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2018-03-16 14:46:39.028285476 -0700
@@ -191,7 +191,7 @@ static inline int init_new_context(struc
 
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
-		/* pkey 0 is the default and always allocated */
+		/* pkey 0 is the default and allocated implicitly */
 		mm->context.pkey_allocation_map = 0x1;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
diff -puN arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated arch/x86/include/asm/pkeys.h
--- a/arch/x86/include/asm/pkeys.h~x86-pkey-0-default-allocated	2018-03-16 14:46:39.025285476 -0700
+++ b/arch/x86/include/asm/pkeys.h	2018-03-16 14:46:39.028285476 -0700
@@ -49,10 +49,10 @@ bool mm_pkey_is_allocated(struct mm_stru
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
