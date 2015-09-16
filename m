Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 85DA86B0274
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:56:19 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so219678305pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:56:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tc9si42275497pbc.232.2015.09.16.10.49.09
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:09 -0700 (PDT)
Subject: [PATCH 15/26] x86, pkeys: optimize fault handling in access_error()
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:08 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174908.01625DF4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


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

---

 b/arch/x86/mm/fault.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-15-access_error arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-15-access_error	2015-09-16 10:48:18.012271934 -0700
+++ b/arch/x86/mm/fault.c	2015-09-16 10:48:18.016272115 -0700
@@ -889,6 +889,9 @@ static inline bool bad_area_access_from_
 		return false;
 	if (error_code & PF_PK)
 		return true;
+	/* this checks permission keys on the VMA: */
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE)))
+		return true;
 	return false;
 }
 
@@ -1075,6 +1078,13 @@ access_error(unsigned long error_code, s
 	 */
 	if (error_code & PF_PK)
 		return 1;
+	/*
+	 * Make sure to check the VMA so that we do not perform
+	 * faults just to hit a PF_PK as soon as we fill in a
+	 * page.
+	 */
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE)))
+		return 1;
 
 	if (error_code & PF_WRITE) {
 		/* write, present and write, not present: */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
