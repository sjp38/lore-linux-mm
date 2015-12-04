Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 097FC82F6D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:08 -0500 (EST)
Received: by pfbg73 with SMTP id g73so17642678pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:07 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fi15si15423247pac.191.2015.12.03.17.14.51
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:51 -0800 (PST)
Subject: [PATCH 19/34] x86, pkeys: optimize fault handling in access_error()
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:50 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011450.A07593D5@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

We might not strictly have to make modifictions to
access_error() to check the VMA here.

If we do not, we will do this:
1. app sets VMA pkey to K
2. app touches a !present page
3. do_page_fault(), allocates and maps page, sets pte.pkey=K
4. return to userspace
5. touch instruction reexecutes, but triggers PF_PK
6. do PKEY signal

What happens with this patch applied:
1. app sets VMA pkey to K
2. app touches a !present page
3. do_page_fault() notices that K is inaccessible
4. do PKEY signal

We basically skip the fault that does an allocation.

So what this lets us do is protect areas from even being
*populated* unless it is accessible according to protection
keys.  That seems handy to me and makes protection keys work
more like an mprotect()'d mapping.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/mm/fault.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-15-access_error arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-15-access_error	2015-12-03 16:21:26.872727820 -0800
+++ b/arch/x86/mm/fault.c	2015-12-03 16:21:26.876728002 -0800
@@ -900,10 +900,16 @@ bad_area(struct pt_regs *regs, unsigned
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 		struct vm_area_struct *vma)
 {
+	/* This code is always called on the current mm */
+	int foreign = 0;
+
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
 		return false;
 	if (error_code & PF_PK)
 		return true;
+	/* this checks permission keys on the VMA: */
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE), foreign))
+		return true;
 	return false;
 }
 
@@ -1091,6 +1097,8 @@ int show_unhandled_signals = 1;
 static inline int
 access_error(unsigned long error_code, struct vm_area_struct *vma)
 {
+	/* This is only called for the current mm, so: */
+	int foreign = 0;
 	/*
 	 * Access or read was blocked by protection keys. We do
 	 * this check before any others because we do not want
@@ -1099,6 +1107,13 @@ access_error(unsigned long error_code, s
 	 */
 	if (error_code & PF_PK)
 		return 1;
+	/*
+	 * Make sure to check the VMA so that we do not perform
+	 * faults just to hit a PF_PK as soon as we fill in a
+	 * page.
+	 */
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE), foreign))
+		return 1;
 
 	if (error_code & PF_WRITE) {
 		/* write, present and write, not present: */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
