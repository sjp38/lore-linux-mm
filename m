Subject: [PATCH] fix discontig with 0-sized nodes
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-eid7bhARILCPnhpLqL8t"
Message-Id: <1054948422.10502.632.camel@nighthawk>
Mime-Version: 1.0
Date: 06 Jun 2003 18:14:30 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Patricia Gaughen <gone@us.ibm.com>, Andrew Theurer <habanero@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-eid7bhARILCPnhpLqL8t
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

In order to turn an 8-way x440 into a 4-way for testing, we often use
mem=(1/2 of total) and maxcpus=4.  maxcpus has always worked, but mem=
hasn't.  The mem= parameter actually changes the kernel's e820
structure, which manifests itself as max_pfn.  node_end_pfn[] obeys this
because of find_max_pfn_node(), but node_start_pfn[] wasn't modified. 

If you have a mem= line that causes memory to stop before the beginning
of a node, you get a condition where start > end (because start was
never modified).  There is a bug check for this, but it was placed just
_before_ the error was made :)

Also, the bootmem alloc functions die if you request something of zero
size from them.  This patch avoids that too.  This shouldn't have much
of an effect on non-NUMA systems.  
-- 
Dave Hansen
haveblue@us.ibm.com




--=-eid7bhARILCPnhpLqL8t
Content-Disposition: attachment; filename="nice-x440-mem=-2.5.70-1.patch"
Content-Type: text/x-patch; name="nice-x440-mem=-2.5.70-1.patch"; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -ru linux-2.5.70-clean/arch/i386/mm/discontig.c linux-2.5.70-numa-mem=1/arch/i386/mm/discontig.c
--- linux-2.5.70-clean/arch/i386/mm/discontig.c	Mon May 26 18:00:40 2003
+++ linux-2.5.70-numa-mem=1/arch/i386/mm/discontig.c	Fri Jun  6 16:52:18 2003
@@ -114,10 +114,16 @@
  */
 static void __init find_max_pfn_node(int nid)
 {
-	if (node_start_pfn[nid] >= node_end_pfn[nid])
-		BUG();
 	if (node_end_pfn[nid] > max_pfn)
 		node_end_pfn[nid] = max_pfn;
+	/*
+	 * if a user has given mem=XXXX, then we need to make sure 
+	 * that the node _starts_ before that, too, not just ends
+	 */
+	if (node_start_pfn[nid] > max_pfn)
+		node_start_pfn[nid] = max_pfn;
+	if (node_start_pfn[nid] > node_end_pfn[nid])
+		BUG();
 }
 
 /* 
diff -ru linux-2.5.70-clean/mm/page_alloc.c linux-2.5.70-numa-mem=1/mm/page_alloc.c
--- linux-2.5.70-clean/mm/page_alloc.c	Mon May 26 18:00:22 2003
+++ linux-2.5.70-numa-mem=1/mm/page_alloc.c	Fri Jun  6 16:57:30 2003
@@ -1153,8 +1153,11 @@
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		size += zones_size[i];
 	size = LONG_ALIGN((size + 7) >> 3);
-	pgdat->valid_addr_bitmap = (unsigned long *)alloc_bootmem_node(pgdat, size);
-	memset(pgdat->valid_addr_bitmap, 0, size);
+	if (size) {
+		pgdat->valid_addr_bitmap = 
+			(unsigned long *)alloc_bootmem_node(pgdat, size);
+		memset(pgdat->valid_addr_bitmap, 0, size);
+	}
 }
 
 /*

--=-eid7bhARILCPnhpLqL8t--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
