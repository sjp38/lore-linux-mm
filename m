Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 65720828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:06 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o185so41173917pfb.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:06 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m2si25608901pfj.159.2016.01.29.10.16.54
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:54 -0800 (PST)
Subject: [PATCH 08/31] x86, pkeys: new page fault error code bit: PF_PK
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:54 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181654.CD3A8A3A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Note: "PK" is how the Intel SDM refers to this bit, so we also
use that nomenclature.

This only defines the bit, it does not plumb it anywhere to be
handled.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/mm/fault.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-05-pfec arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-05-pfec	2016-01-28 15:52:19.775377103 -0800
+++ b/arch/x86/mm/fault.c	2016-01-28 15:52:19.778377241 -0800
@@ -33,6 +33,7 @@
  *   bit 2 ==	 0: kernel-mode access	1: user-mode access
  *   bit 3 ==				1: use of reserved bit detected
  *   bit 4 ==				1: fault was an instruction fetch
+ *   bit 5 ==				1: protection keys block access
  */
 enum x86_pf_error_code {
 
@@ -41,6 +42,7 @@ enum x86_pf_error_code {
 	PF_USER		=		1 << 2,
 	PF_RSVD		=		1 << 3,
 	PF_INSTR	=		1 << 4,
+	PF_PK		=		1 << 5,
 };
 
 /*
@@ -916,6 +918,12 @@ static int spurious_fault_check(unsigned
 
 	if ((error_code & PF_INSTR) && !pte_exec(*pte))
 		return 0;
+	/*
+	 * Note: We do not do lazy flushing on protection key
+	 * changes, so no spurious fault will ever set PF_PK.
+	 */
+	if ((error_code & PF_PK))
+		return 1;
 
 	return 1;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
