Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMXV2K007657
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:31 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXU6Z178212
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXUnZ024235
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Message-Id: <20080618223329.644300254@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:33:00 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 6/6] powerpc: Dont clear _PAGE_COHERENT when _PAGE_SAO is set
Content-Disposition: inline; filename=dont_clobber_M.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

---

 arch/powerpc/platforms/pseries/lpar.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.26-rc5/arch/powerpc/platforms/pseries/lpar.c
===================================================================
--- linux-2.6.26-rc5.orig/arch/powerpc/platforms/pseries/lpar.c
+++ linux-2.6.26-rc5/arch/powerpc/platforms/pseries/lpar.c
@@ -305,7 +305,8 @@ static long pSeries_lpar_hpte_insert(uns
 	flags = 0;
 
 	/* Make pHyp happy */
-	if (rflags & (_PAGE_GUARDED|_PAGE_NO_CACHE))
+	if ((rflags & _PAGE_GUARDED) ||
+	    ((rflags & _PAGE_NO_CACHE) & !(rflags & _PAGE_WRITETHRU)))
 		hpte_r &= ~_PAGE_COHERENT;
 
 	lpar_rc = plpar_pte_enter(flags, hpte_group, hpte_v, hpte_r, &slot);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
