Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB3E6B025A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:24 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215644716pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tc9si42275497pbc.232.2015.09.16.10.49.09
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:09 -0700 (PDT)
Subject: [PATCH 07/26] x86, pkeys: new page fault error code bit: PF_PK
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:05 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174905.E22CA62B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Note: "PK" is how the Intel SDM refers to this bit, so we also
use that nomenclature.

This only defines the bit, it does not plumb it anywhere to be
handled.

---

 b/arch/x86/mm/fault.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff -puN arch/x86/mm/fault.c~pkeys-05-pfec arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-05-pfec	2015-09-16 10:48:14.219099976 -0700
+++ b/arch/x86/mm/fault.c	2015-09-16 10:48:14.222100112 -0700
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
@@ -916,7 +918,10 @@ static int spurious_fault_check(unsigned
 
 	if ((error_code & PF_INSTR) && !pte_exec(*pte))
 		return 0;
-
+	/*
+	 * Note: We do not do lazy flushing on protection key
+	 * changes, so no spurious fault will ever set PF_PK.
+	 */
 	return 1;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
