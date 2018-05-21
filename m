Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C80E86B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 17:19:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q15-v6so9830839pff.17
        for <linux-mm@kvack.org>; Mon, 21 May 2018 14:19:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c9-v6si14860333plz.501.2018.05.21.14.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 14:19:52 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 33/95] x86/pkeys: Do not special case protection key 0
Date: Mon, 21 May 2018 23:11:23 +0200
Message-Id: <20180521210454.799243479@linuxfoundation.org>
In-Reply-To: <20180521210447.219380974@linuxfoundation.org>
References: <20180521210447.219380974@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellermen <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ram Pai <linuxram@us.ibm.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 2fa9d1cfaf0e02f8abef0757002bff12dfcfa4e6 upstream.

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
Cc: Andrew Morton <akpm@linux-foundation.org>p
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Fixes: 58ab9a088dda ("x86/pkeys: Check against max pkey to avoid overflows")
Link: http://lkml.kernel.org/r/20180509171358.47FD785E@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/mmu_context.h |    2 +-
 arch/x86/include/asm/pkeys.h       |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -192,7 +192,7 @@ static inline int init_new_context(struc
 
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
-		/* pkey 0 is the default and always allocated */
+		/* pkey 0 is the default and allocated implicitly */
 		mm->context.pkey_allocation_map = 0x1;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
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
