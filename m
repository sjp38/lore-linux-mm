Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 27F43900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:17:27 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FIr3xl006504
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:53:03 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FJGWjE033296
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:16:40 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FJGWSV013251
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:16:32 -0600
Subject: [PATCH] make new gfp.h BUG_ON() in to VM_BUG_ON()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104150945230.5863@router.home>
References: <1302795695.14658.6801.camel@nimitz>
	 <20110414132220.970cfb2a.akpm@linux-foundation.org>
	 <1302817191.16562.1036.camel@nimitz>
	 <alpine.DEB.2.00.1104150945230.5863@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 15 Apr 2011 12:16:29 -0700
Message-ID: <1302894989.16562.3884.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jan Beulich <JBeulich@novell.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, 2011-04-15 at 09:45 -0500, Christoph Lameter wrote:
> You can also remove the #ifdef. Use VM_BUG_ON.

Gotcha.

--

This goes on top of

	include-linux-gfph-work-around-apparent-sparse-confusion.patch

already in the -mm tree.

VM_BUG_ON() if effectively a BUG_ON() undef #ifdef CONFIG_DEBUG_VM.
That is exactly what we have here now, and two different folks have
suggested doing it this way.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/gfp.h |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -puN include/linux/gfp.h~make-gfp_h-BUG_ON-in-too-VM_BUG_ON include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~make-gfp_h-BUG_ON-in-too-VM_BUG_ON	2011-04-15 10:59:24.192432223 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-15 10:59:39.384429223 -0700
@@ -249,9 +249,7 @@ static inline enum zone_type gfp_zone(gf
 
 	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
 					 ((1 << ZONES_SHIFT) - 1);
-#ifdef CONFIG_DEBUG_VM
-	BUG_ON((GFP_ZONE_BAD >> bit) & 1);
-#endif
+	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
 	return z;
 }
 
_


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
