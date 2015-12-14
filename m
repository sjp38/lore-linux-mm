Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9508A6B0260
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:05 -0500 (EST)
Received: by padhk6 with SMTP id hk6so68112042pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:05 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id cj5si10520285pad.65.2015.12.14.11.06.04
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:04 -0800 (PST)
Subject: [PATCH 08/32] x86, pkeys: new page fault error code bit: PF_PK
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:56 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190556.92FC3386@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/arch/x86/mm/fault.c~pkeys-05-pfec	2015-12-14 10:42:42.240777820 -0800
+++ b/arch/x86/mm/fault.c	2015-12-14 10:42:42.244778000 -0800
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
