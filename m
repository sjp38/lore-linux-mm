Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1PIOOH0001239
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:24:24 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1PIOO8w060958
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:24:24 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1PIONkP022866
	for <linux-mm@kvack.org>; Fri, 25 Feb 2005 13:24:23 -0500
Subject: Re: [PATCH 5/5] SRAT cleanup: make calculations and indenting
	level more sane
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200502241456.14048.jamesclv@us.ibm.com>
References: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com>
	 <200502241249.54796.jamesclv@us.ibm.com> <1109282578.9817.1993.camel@knk>
	 <200502241456.14048.jamesclv@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-thokUb1jR6019WNgFnZn"
Date: Fri, 25 Feb 2005 10:24:11 -0800
Message-Id: <1109355851.6921.1.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jamesclv@us.ibm.com
Cc: keith <kmannth@us.ibm.com>, linux-mm <linux-mm@kvack.org>, matt dobson <colpatch@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

--=-thokUb1jR6019WNgFnZn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Keith, James,

How about this one?  I think it handles non-sequential entries, and it
uses node_has_online_mem() instead of open-coding it.  

-- Dave

--=-thokUb1jR6019WNgFnZn
Content-Disposition: attachment; filename=A3.3-srat-cleanup.patch
Content-Type: text/x-patch; name=A3.3-srat-cleanup.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit


Using the assumption that all addresses in the SRAT are ascending,
the calculations can get a bit simpler, and remove the 
"been_here_before" variable.

This also breaks that calculation out into its own function, which
further simplifies the look of the code.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 sparse-dave/arch/i386/kernel/srat.c |   67 ++++++++++++++++++------------------
 1 files changed, 35 insertions(+), 32 deletions(-)

diff -puN arch/i386/kernel/srat.c~A3.3-srat-cleanup arch/i386/kernel/srat.c
--- sparse/arch/i386/kernel/srat.c~A3.3-srat-cleanup	2005-02-25 10:18:19.000000000 -0800
+++ sparse-dave/arch/i386/kernel/srat.c	2005-02-25 10:18:26.000000000 -0800
@@ -181,6 +181,38 @@ static __init void chunk_to_zones(unsign
 	}
 }
 
+/*
+ * The SRAT table always lists ascending addresses, so can always
+ * assume that the first "start" address that you see is the real
+ * start of the node, and that the current "end" address is after
+ * the previous one.
+ */
+static __init void node_read_chunk(int nid, struct node_memory_chunk_s *memory_chunk)
+{
+	/*
+	 * Only add present memory as told by the e820.
+	 * There is no guarantee from the SRAT that the memory it
+	 * enumerates is present at boot time because it represents
+	 * *possible* memory hotplug areas the same as normal RAM.
+	 */
+	if (memory_chunk->start_pfn >= max_pfn) {
+		printk (KERN_INFO "Ignoring SRAT pfns: 0x%08lx -> %08lx\n",
+			memory_chunk->start_pfn, memory_chunk->end_pfn);
+		return;
+	}
+	if (memory_chunk->nid != nid)
+		return;
+
+	if (!node_has_online_mem(nid))
+		node_start_pfn[nid] = memory_chunk->start_pfn;
+
+	if (node_start_pfn[nid] > memory_chunk->start_pfn)
+		node_start_pfn[nid] = memory_chunk->start_pfn;
+
+	if (node_end_pfn[nid] < memory_chunk->end_pfn)
+		node_end_pfn[nid] = memory_chunk->end_pfn;
+}
+
 /* Parse the ACPI Static Resource Affinity Table */
 static int __init acpi20_parse_srat(struct acpi_table_srat *sratp)
 {
@@ -261,41 +293,12 @@ static int __init acpi20_parse_srat(stru
 	printk("Number of memory chunks in system = %d\n", num_memory_chunks);
 
 	for (j = 0; j < num_memory_chunks; j++){
+		struct node_memory_chunk_s * chunk = &node_memory_chunk[j];
 		printk("chunk %d nid %d start_pfn %08lx end_pfn %08lx\n",
-		       j, node_memory_chunk[j].nid,
-		       node_memory_chunk[j].start_pfn,
-		       node_memory_chunk[j].end_pfn);
+		       j, chunk->nid, chunk->start_pfn, chunk->end_pfn);
+		node_read_chunk(chunk->nid, chunk);
 	}
  
-	/*calculate node_start_pfn/node_end_pfn arrays*/
-	for_each_online_node(nid) {
-		int been_here_before = 0;
-
-		for (j = 0; j < num_memory_chunks; j++){
-			/*
-			 * Only add present memroy to node_end/start_pfn
-			 * There is no guarantee from the srat that the memory
-			 * is present at boot time.
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
-		}
-	}
 	for_each_online_node(nid) {
 		unsigned long start = node_start_pfn[nid];
 		unsigned long end = node_end_pfn[nid];
_

--=-thokUb1jR6019WNgFnZn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
