Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1OJTmR6012651
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:29:48 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1OJTmSt250448
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:29:48 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1OJTma5008583
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 14:29:48 -0500
Subject: Re: [PATCH 5/5] SRAT cleanup: make calculations and indenting
	level more sane
From: keith <kmannth@us.ibm.com>
In-Reply-To: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com>
References: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com>
Content-Type: multipart/mixed; boundary="=-XpSSJiKRiPAiXkoT8h1i"
Message-Id: <1109273434.9817.1950.camel@knk>
Mime-Version: 1.0
Date: Thu, 24 Feb 2005 11:30:34 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, matt dobson <colpatch@us.ibm.com>, Mike Kravetz <kravetz@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, anton@samba.org, ygoto@us.fujitsu.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

--=-XpSSJiKRiPAiXkoT8h1i
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-02-24 at 09:29, Dave Hansen wrote:
> Using the assumption that all addresses in the SRAT are ascending,
> the calculations can get a bit simpler, and remove the 
> "been_here_before" variable.
> 
> This also breaks that calculation out into its own function, which
> further simplifies the look of the code.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> ---
> 
>  sparse-dave/arch/i386/kernel/srat.c |   61 ++++++++++++++++++------------------
>  1 files changed, 32 insertions(+), 29 deletions(-)

(snip)

This looks a lot better then the existing code.  Thanks. 
 
Why not take it one step further??  Something like the attached patch.
There is no reason to loop over the nodes as the srat entries contain
node info and we can use the the new node_has_online_mem. 

This booted ok on my hot-add enabled 8-way. 
 I am not %100 sure it is ok to make the assumption that the memory is
always reported linearly but that is the assumption of the previous code
so it must be for all know examples. 

Keith 


--=-XpSSJiKRiPAiXkoT8h1i
Content-Disposition: attachment; filename=patch-srat-cleanup-v2
Content-Type: text/x-patch; name=patch-srat-cleanup-v2; charset=
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c linux-2.6.11-rc4-fix7-srat/arch/i386/kernel/srat.c
--- linux-2.6.11-rc4-fix7/arch/i386/kernel/srat.c	2005-02-21 13:56:28.000000000 -0800
+++ linux-2.6.11-rc4-fix7-srat/arch/i386/kernel/srat.c	2005-02-24 11:10:09.000000000 -0800
@@ -269,34 +269,24 @@
 	}
  
 	/*calculate node_start_pfn/node_end_pfn arrays*/
-	for_each_online_node(nid) {
-		int been_here_before = 0;
-
-		for (j = 0; j < num_memory_chunks; j++){
-			/*
-			 *Only add present memroy to node_end/start_pfn 
-			 *There is no guarantee from the srat that the memory 
-			 *is present at boot time. 
-			 */
-			if (node_memory_chunk[j].start_pfn >= max_pfn) {
-				printk (KERN_INFO "Ignoring chunk of memory reported in the SRAT (could be hot-add zone?)\n");
-				printk (KERN_INFO "chunk is reported from pfn %04x to %04x\n",
-					node_memory_chunk[j].start_pfn, node_memory_chunk[j].end_pfn);
-				continue;
-			}
-			if (node_memory_chunk[j].nid == nid) {
-				if (been_here_before == 0) {
-					node_start_pfn[nid] = node_memory_chunk[j].start_pfn;
-					node_end_pfn[nid] = node_memory_chunk[j].end_pfn;
-					been_here_before = 1;
-				} else { /* We've found another chunk of memory for the node */
-					if (node_start_pfn[nid] < node_memory_chunk[j].start_pfn) {
-						node_end_pfn[nid] = node_memory_chunk[j].end_pfn;
-					}
-				}
-			}
+	for (j = 0; j < num_memory_chunks; j++){
+		int nid = node_memory_chunk[j].nid;
+		/*
+		 *Only add present memroy to node_end/start_pfn
+		 *There is no guarantee from the srat that the memory
+		 *is present at boot time.
+		 */
+		if (node_memory_chunk[j].start_pfn >= max_pfn) {
+			printk (KERN_INFO "Ignoring SRAT pfns: 0x%08lx -> %08lx\n",
+				node_memory_chunk[j].start_pfn, node_memory_chunk[j].end_pfn);
+			continue;
 		}
+		if (!node_has_online_mem(nid))
+			node_start_pfn[nid] = node_memory_chunk[j].start_pfn;
+			
+		node_end_pfn[nid] = node_memory_chunk[j].end_pfn;
 	}
+
 	return 1;
 out_fail:
 	return 0;

--=-XpSSJiKRiPAiXkoT8h1i--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
