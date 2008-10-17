Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9H4xjEp018302
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 00:59:45 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9H4xjno103144
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 22:59:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9H4xGLU003769
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 22:59:16 -0600
Message-ID: <48F81BBF.7050801@us.ibm.com>
Date: Thu, 16 Oct 2008 23:59:43 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] powerpc: properly reserve in bootmem the lmb reserved
 regions that cross NUMA nodes
References: <48EE6720.6010601@linux.vnet.ibm.com> <1223614516.8157.154.camel@pasglop>
In-Reply-To: <1223614516.8157.154.camel@pasglop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Adam Litke <agl@us.ibm.com>, Kumar Gala <galak@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Thu, 2008-10-09 at 15:18 -0500, Jon Tollefson wrote:
>   
>> If there are multiple reserved memory blocks via lmb_reserve() that are
>> contiguous addresses and on different NUMA nodes we are losing track of which 
>> address ranges to reserve in bootmem on which node.  I discovered this 
>> when I recently got to try 16GB huge pages on a system with more then 2 nodes.
>>     
>
> I'm going to apply it, however, could you double check something for
> me ? A cursory glance of the new version makes me wonder, what if the
> first call to get_node_active_region() ends up with the work_fn never
> hitting the if () case ? I think in that case, node_ar->end_pfn never
> gets initialized right ? Can that happen in practice ? I suspect that
> isn't the case but better safe than sorry...
>   
I have tested this on a few machines and it hasn't been a problem.  But 
I don't see anything in lmb_reserve() that would prevent reserving a 
block that was outside of valid memory.  So to be safe I have attached a 
patch that checks for an empty active range.

I also noticed that the size to reserve for subsequent nodes for a 
reserve that spans nodes wasn't taking into account the amount reserved 
on previous nodes so the patch addresses that too.  If you would prefer 
this be a separate patch let me know.

> If there's indeed a potential problem, please send a fixup patch.
>
> Cheers,
> Ben.
>   
Adjust amount to reserve based on previous nodes for reserves spanning
multiple nodes. Check if the node active range is empty before attempting
to pass the reserve to bootmem.  In practice the range shouldn't be empty,
but to be sure we check.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 
 arch/powerpc/mm/numa.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)


diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 6cf5c71..195bfcd 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -116,6 +116,7 @@ static int __init get_active_region_work_fn(unsigned long start_pfn,
 
 /*
  * get_node_active_region - Return active region containing start_pfn
+ * Active range returned is empty if none found.
  * @start_pfn: The page to return the region for.
  * @node_ar: Returned set to the active region containing start_pfn
  */
@@ -126,6 +127,7 @@ static void __init get_node_active_region(unsigned long start_pfn,
 
 	node_ar->nid = nid;
 	node_ar->start_pfn = start_pfn;
+	node_ar->end_pfn = start_pfn;
 	work_with_active_regions(nid, get_active_region_work_fn, node_ar);
 }
 
@@ -933,18 +935,20 @@ void __init do_init_bootmem(void)
 		struct node_active_region node_ar;
 
 		get_node_active_region(start_pfn, &node_ar);
-		while (start_pfn < end_pfn) {
+		while (start_pfn < end_pfn &&
+			node_ar.start_pfn < node_ar.end_pfn) {
+			unsigned long reserve_size = size;
 			/*
 			 * if reserved region extends past active region
 			 * then trim size to active region
 			 */
 			if (end_pfn > node_ar.end_pfn)
-				size = (node_ar.end_pfn << PAGE_SHIFT)
+				reserve_size = (node_ar.end_pfn << PAGE_SHIFT)
 					- (start_pfn << PAGE_SHIFT);
-			dbg("reserve_bootmem %lx %lx nid=%d\n", physbase, size,
-				node_ar.nid);
+			dbg("reserve_bootmem %lx %lx nid=%d\n", physbase,
+				reserve_size, node_ar.nid);
 			reserve_bootmem_node(NODE_DATA(node_ar.nid), physbase,
-						size, BOOTMEM_DEFAULT);
+						reserve_size, BOOTMEM_DEFAULT);
 			/*
 			 * if reserved region is contained in the active region
 			 * then done.
@@ -959,6 +963,7 @@ void __init do_init_bootmem(void)
 			 */
 			start_pfn = node_ar.end_pfn;
 			physbase = start_pfn << PAGE_SHIFT;
+			size = size - reserve_size;
 			get_node_active_region(start_pfn, &node_ar);
 		}
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
