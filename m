Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7746B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:59:25 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so1825628iec.33
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:59:25 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id x10si27989635igg.53.2014.07.16.17.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 17:59:25 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so4837110igi.0
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 17:59:24 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:59:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3] mm, thp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
In-Reply-To: <alpine.DEB.2.02.1407161754000.23892@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1407161757500.23892@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C69C7B.1010709@suse.cz> <alpine.DEB.2.02.1407161754000.23892@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target 
node") improved the previous khugepaged logic which allocated a 
transparent hugepages from the node of the first page being collapsed.

However, it is still possible to collapse pages to remote memory which may 
suffer from additional access latency.  With the current policy, it is 
possible that 255 pages (with PAGE_SHIFT == 12) will be collapsed remotely 
if the majority are allocated from that node.

When zone_reclaim_mode is enabled, it means the VM should make every attempt
to allocate locally to prevent NUMA performance degradation.  In this case,
we do not want to collapse hugepages to remote nodes that would suffer from
increased access latency.  Thus, when zone_reclaim_mode is enabled, only
allow collapsing to nodes with RECLAIM_DISTANCE or less.

There is no functional change for systems that disable zone_reclaim_mode.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: only change behavior for zone_reclaim_mode per Dave Hansen
 v3: optimization based on previous node counts per Vlastimil Babka

 mm/huge_memory.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2234,6 +2234,30 @@ static void khugepaged_alloc_sleep(void)
 static int khugepaged_node_load[MAX_NUMNODES];
 
 #ifdef CONFIG_NUMA
+static bool khugepaged_scan_abort(int nid)
+{
+	int i;
+
+	/*
+	 * If zone_reclaim_mode is disabled, then no extra effort is made to
+	 * allocate memory locally.
+	 */
+	if (!zone_reclaim_mode)
+		return false;
+
+	/* If there is a count for this node already, it must be acceptable */
+	if (khugepaged_node_load[nid])
+		return false;
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		if (!khugepaged_node_load[i])
+			continue;
+		if (node_distance(nid, i) > RECLAIM_DISTANCE)
+			return true;
+	}
+	return false;
+}
+
 static int khugepaged_find_target_node(void)
 {
 	static int last_khugepaged_target_node = NUMA_NO_NODE;
@@ -2309,6 +2333,11 @@ static struct page
 	return *hpage;
 }
 #else
+static bool khugepaged_scan_abort(int nid)
+{
+	return false;
+}
+
 static int khugepaged_find_target_node(void)
 {
 	return 0;
@@ -2545,6 +2574,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		 * hit record.
 		 */
 		node = page_to_nid(page);
+		if (khugepaged_scan_abort(node))
+			goto out_unmap;
 		khugepaged_node_load[node]++;
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
