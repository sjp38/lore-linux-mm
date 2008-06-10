Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM1eJj019277
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:40 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM1UIE235272
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:30 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM1UDX016026
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:30 -0400
Date: Tue, 10 Jun 2008 18:01:30 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220129.10257.69024.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 06/06] powerpc: Don't clear _PAGE_COHERENT when _PAGE_SAO is set
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a placeholder.  Benh tells me that he will come up with a better fix.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/platforms/pseries/lpar.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -Nurp linux005/arch/powerpc/platforms/pseries/lpar.c linux006/arch/powerpc/platforms/pseries/lpar.c
--- linux005/arch/powerpc/platforms/pseries/lpar.c	2008-06-05 10:07:34.000000000 -0500
+++ linux006/arch/powerpc/platforms/pseries/lpar.c	2008-06-10 16:48:59.000000000 -0500
@@ -305,7 +305,8 @@ static long pSeries_lpar_hpte_insert(uns
 	flags = 0;
 
 	/* Make pHyp happy */
-	if (rflags & (_PAGE_GUARDED|_PAGE_NO_CACHE))
+	if ((rflags & _PAGE_GUARDED) ||
+	    ((rflags & _PAGE_NO_CACHE) & !(rflags & _PAGE_WRITETHRU)))
 		hpte_r &= ~_PAGE_COHERENT;
 
 	lpar_rc = plpar_pte_enter(flags, hpte_group, hpte_v, hpte_r, &slot);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
