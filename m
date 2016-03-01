Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6738A6B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 14:42:04 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id l6so20986139pfl.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 11:42:04 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id rc17si29669pab.120.2016.03.01.11.42.03
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 11:42:03 -0800 (PST)
Subject: [PATCH] x86, pkeys: fix access_error() denial of writes to write-only VMA
From: Dave Hansen <dave@sr71.net>
Date: Tue, 01 Mar 2016 11:41:33 -0800
Message-Id: <20160301194133.65D0110C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, kirill@shutemov.name, avagin@gmail.com, linux-next@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Andrey Wagin reported that a simple test case was broken by:

	2b5f7d013fc ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")

This test case creates an unreadable VMA and my patch assumed
that all writes must be to readable VMAs.

The simplest fix for this is to remove the pkey-related bits
in access_error().  For execute-only support, I believe the
existing version is sufficient because the permissions we
are trying to enforce are entirely expressed in vma->vm_flags.
We just depend on pkeys to get *an* exception, it does not
matter that PF_PK was set, or even what state PKRU is in.

I will re-add the necessary bits with the full pkeys
implementation that includes the new syscalls.

The three cases that matter are:

1. If a write to an execute-only VMA occurs, we will see PF_WRITE
   set, but !VM_WRITE on the VMA, and return 1.  All execute-only
   VMAs have VM_WRITE clear by definition.
2. If a read occurs on a present PTE, we will fall in to the "read,
   present" case and return 1.
3. If a read occurs to a non-present PTE, we will miss the "read,
   not present" case, because the execute-only VMA will have
   VM_EXEC set, and we will properly return 0 allowing the PTE to
   be populated.

Test program:

#include <sys/mman.h>
#include <stdlib.h>

int main()
{
	int *p;
	p = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	p[0] = 1;

	return 0;
}

Fixes: 62b5f7d013fc ("mm/core, x86/mm/pkeys: Add execute-only protection keys support")
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrey Wagin <avagin@gmail.com>,
Cc: linux-next@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
---

 b/arch/x86/mm/fault.c |   18 ------------------
 1 file changed, 18 deletions(-)

diff -puN arch/x86/mm/fault.c~pkeys-102-fix-access_error arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-102-fix-access_error	2016-03-01 10:14:24.436678816 -0800
+++ b/arch/x86/mm/fault.c	2016-03-01 11:31:29.059059324 -0800
@@ -1122,24 +1122,6 @@ access_error(unsigned long error_code, s
 	/* This is only called for the current mm, so: */
 	bool foreign = false;
 	/*
-	 * Access or read was blocked by protection keys. We do
-	 * this check before any others because we do not want
-	 * to, for instance, confuse a protection-key-denied
-	 * write with one for which we should do a COW.
-	 */
-	if (error_code & PF_PK)
-		return 1;
-
-	if (!(error_code & PF_INSTR)) {
-		/*
-		 * Assume all accesses require either read or execute
-		 * permissions.  This is not an instruction access, so
-		 * it requires read permissions.
-		 */
-		if (!(vma->vm_flags & VM_READ))
-			return 1;
-	}
-	/*
 	 * Make sure to check the VMA so that we do not perform
 	 * faults just to hit a PF_PK as soon as we fill in a
 	 * page.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
