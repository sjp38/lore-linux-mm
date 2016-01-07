Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CC181828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:08:22 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id do7so5961955pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:08:22 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id cj5si51368923pad.65.2016.01.06.16.01.32
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:32 -0800 (PST)
Subject: [PATCH 19/31] x86, pkeys: optimize fault handling in access_error()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:31 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000131.CA398B4E@viggo.jf.intel.com>
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
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/mm/fault.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-15-access_error arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-15-access_error	2016-01-06 15:50:11.270411174 -0800
+++ b/arch/x86/mm/fault.c	2016-01-06 15:50:11.274411354 -0800
@@ -900,10 +900,16 @@ bad_area(struct pt_regs *regs, unsigned
 static inline bool bad_area_access_from_pkeys(unsigned long error_code,
 		struct vm_area_struct *vma)
 {
+	/* This code is always called on the current mm */
+	bool foreign = false;
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
+	bool foreign = false;
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
