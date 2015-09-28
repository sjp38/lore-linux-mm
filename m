Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 092BC82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:46 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so182143045pad.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:45 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.24
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:24 -0700 (PDT)
Subject: [PATCH 16/25] x86, pkeys: optimize fault handling in access_error()
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:23 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191823.2563873B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


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

 b/arch/x86/mm/fault.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-15-access_error arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-15-access_error	2015-09-28 11:39:48.287289263 -0700
+++ b/arch/x86/mm/fault.c	2015-09-28 11:39:48.290289400 -0700
@@ -904,6 +904,9 @@ static inline bool bad_area_access_from_
 		return false;
 	if (error_code & PF_PK)
 		return true;
+	/* this checks permission keys on the VMA: */
+	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE)))
+		return true;
 	return false;
 }
 
@@ -1091,6 +1094,13 @@ access_error(unsigned long error_code, s
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
