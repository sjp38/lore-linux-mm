Message-Id: <20080423015430.311388000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:08 +1000
From: npiggin@suse.de
Subject: [patch 06/18] hugetlb: multi hstate proc files
Content-Disposition: inline; filename=hugetlb-proc-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Convert /proc output code over to report multiple hstates

I chose to just report the numbers in a row, in the hope 
to minimze breakage of existing software. The "compat" page size
is always the first number.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   64 ++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 42 insertions(+), 22 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -739,39 +739,59 @@ int hugetlb_overcommit_handler(struct ct
 
 #endif /* CONFIG_SYSCTL */
 
+static int dump_field(char *buf, unsigned field)
+{
+	int n = 0;
+	struct hstate *h;
+	for_each_hstate (h)
+		n += sprintf(buf + n, " %5lu", *(unsigned long *)((char *)h + field));
+	buf[n++] = '\n';
+	return n;
+}
+
 int hugetlb_report_meminfo(char *buf)
 {
-	struct hstate *h = &global_hstate;
-	return sprintf(buf,
-			"HugePages_Total: %5lu\n"
-			"HugePages_Free:  %5lu\n"
-			"HugePages_Rsvd:  %5lu\n"
-			"HugePages_Surp:  %5lu\n"
-			"Hugepagesize:    %5lu kB\n",
-			h->nr_huge_pages,
-			h->free_huge_pages,
-			h->resv_huge_pages,
-			h->surplus_huge_pages,
-			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
+	struct hstate *h;
+	int n = 0;
+	n += sprintf(buf + 0, "HugePages_Total:");
+	n += dump_field(buf + n, offsetof(struct hstate, nr_huge_pages));
+	n += sprintf(buf + n, "HugePages_Free: ");
+	n += dump_field(buf + n, offsetof(struct hstate, free_huge_pages));
+	n += sprintf(buf + n, "HugePages_Rsvd: ");
+	n += dump_field(buf + n, offsetof(struct hstate, resv_huge_pages));
+	n += sprintf(buf + n, "HugePages_Surp: ");
+	n += dump_field(buf + n, offsetof(struct hstate, surplus_huge_pages));
+	n += sprintf(buf + n, "Hugepagesize:   ");
+	for_each_hstate (h)
+		n += sprintf(buf + n, " %5lu", huge_page_size(h) / 1024);
+	n += sprintf(buf + n, " kB\n");
+	return n;
 }
 
 int hugetlb_report_node_meminfo(int nid, char *buf)
 {
-	struct hstate *h = &global_hstate;
-	return sprintf(buf,
-		"Node %d HugePages_Total: %5u\n"
-		"Node %d HugePages_Free:  %5u\n"
-		"Node %d HugePages_Surp:  %5u\n",
-		nid, h->nr_huge_pages_node[nid],
-		nid, h->free_huge_pages_node[nid],
-		nid, h->surplus_huge_pages_node[nid]);
+	int n = 0;
+	n += sprintf(buf, "Node %d HugePages_Total: ", nid);
+	n += dump_field(buf + n, offsetof(struct hstate,
+						nr_huge_pages_node[nid]));
+	n += sprintf(buf + n, "Node %d HugePages_Free: ", nid);
+	n += dump_field(buf + n, offsetof(struct hstate,
+						free_huge_pages_node[nid]));
+	n += sprintf(buf + n, "Node %d HugePages_Surp: ", nid);
+	n += dump_field(buf + n, offsetof(struct hstate,
+						surplus_huge_pages_node[nid]));
+	return n;
 }
 
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {
-	struct hstate *h = &global_hstate;
-	return h->nr_huge_pages * (1 << huge_page_order(h));
+	long x = 0;
+	struct hstate *h;
+	for_each_hstate (h) {
+		x += h->nr_huge_pages * (1 << huge_page_order(h));
+	}
+	return x;
 }
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
