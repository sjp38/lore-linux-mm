Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1LNtVun015421
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 18:55:31 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1LNtVew029236
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 18:55:31 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1LNtUhd015167
	for <linux-mm@kvack.org>; Mon, 21 Feb 2005 18:55:30 -0500
Subject: Re: [RFC] [Patch] For booting a i386 numa system with no memory in
	a node
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1109029568.9817.1700.camel@knk>
References: <1106881119.2040.122.camel@cog.beaverton.ibm.com>
	 <1106882150.2040.126.camel@cog.beaverton.ibm.com>
	 <1106937253.27125.6.camel@knk>  <1106938993.14330.65.camel@localhost>
	 <1106941547.27125.25.camel@knk>  <1106942832.17936.3.camel@arrakis>
	 <1108611260.9817.1227.camel@knk>  <1108654782.19395.9.camel@localhost>
	 <1108664637.9817.1259.camel@knk>  <1108666091.19395.29.camel@localhost>
	 <1108671423.9817.1266.camel@knk>  <421510E9.3000901@us.ibm.com>
	 <1108677113.32193.8.camel@localhost> <42152690.4030508@us.ibm.com>
	 <9230000.1108666127@flay>  <1108686742.6482.51.camel@localhost>
	 <1109017040.9817.1638.camel@knk>  <1109018361.21720.3.camel@localhost>
	 <1109023409.9817.1667.camel@knk>  <1109024680.25666.4.camel@localhost>
	 <1109029568.9817.1700.camel@knk>
Content-Type: multipart/mixed; boundary="=-tK581pPp//0ZThizcSbM"
Date: Mon, 21 Feb 2005 15:55:26 -0800
Message-Id: <1109030126.25666.17.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>, matt dobson <colpatch@us.ibm.com>, John Stultz <johnstul@us.ibm.com>, Andy Whitcroft <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-tK581pPp//0ZThizcSbM
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I think you interpreted my suggestion about the if() backwards.  Is
there a reason the attached patch won't work?

-- Dave

--=-tK581pPp//0ZThizcSbM
Content-Disposition: attachment; filename=collapse-if.patch
Content-Type: text/x-patch; name=collapse-if.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit



---

 sparse-dave/arch/i386/mm/discontig.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff -puN arch/i386/mm/discontig.c~collapse-if arch/i386/mm/discontig.c
--- sparse/arch/i386/mm/discontig.c~collapse-if	2005-02-21 15:53:54.000000000 -0800
+++ sparse-dave/arch/i386/mm/discontig.c	2005-02-21 15:54:03.000000000 -0800
@@ -401,24 +401,22 @@ void __init zone_sizes_init(void)
 
 		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
-		if (node_has_online_mem(nid)){
-			if (start > low) {
+		if ((start > low) || !node_has_online_mem(nid)) {
 #ifdef CONFIG_HIGHMEM
 				BUG_ON(start > high);
 				zones_size[ZONE_HIGHMEM] = high - start;
 #endif
-			} else {
-				if (low < max_dma)
-					zones_size[ZONE_DMA] = low;
-				else {
-					BUG_ON(max_dma > low);
-					BUG_ON(low > high);
-					zones_size[ZONE_DMA] = max_dma;
-					zones_size[ZONE_NORMAL] = low - max_dma;
+		} else {
+			if (low < max_dma)
+				zones_size[ZONE_DMA] = low;
+			else {
+				BUG_ON(max_dma > low);
+				BUG_ON(low > high);
+				zones_size[ZONE_DMA] = max_dma;
+				zones_size[ZONE_NORMAL] = low - max_dma;
 #ifdef CONFIG_HIGHMEM
-					zones_size[ZONE_HIGHMEM] = high - low;
+				zones_size[ZONE_HIGHMEM] = high - low;
 #endif
-				}
 			}
 		}
 
_

--=-tK581pPp//0ZThizcSbM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
