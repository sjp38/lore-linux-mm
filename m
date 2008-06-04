Message-Id: <20080604113112.400602118@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
Date: Wed, 04 Jun 2008 21:29:50 +1000
From: npiggin@suse.de
Subject: [patch 11/21] hugetlb: printk cleanup
Content-Disposition: inline; filename=hugetlb-printk-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- Reword sentence to clarify meaning with multiple options
- Add support for using GB prefixes for the page size
- Add extra printk to delayed > MAX_ORDER allocation code

Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-04 20:51:22.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-04 20:51:23.000000000 +1000
@@ -931,15 +931,27 @@ static void __init hugetlb_init_hstates(
 	}
 }
 
+static char * __init memfmt(char *buf, unsigned long n)
+{
+	if (n >= (1UL << 30))
+		sprintf(buf, "%lu GB", n >> 30);
+	else if (n >= (1UL << 20))
+		sprintf(buf, "%lu MB", n >> 20);
+	else
+		sprintf(buf, "%lu KB", n >> 10);
+	return buf;
+}
+
 static void __init report_hugepages(void)
 {
 	struct hstate *h;
 
 	for_each_hstate(h) {
-		printk(KERN_INFO "Total HugeTLB memory allocated, "
-				"%ld %dMB pages\n",
-				h->free_huge_pages,
-				1 << (h->order + PAGE_SHIFT - 20));
+		char buf[32];
+		printk(KERN_INFO "HugeTLB registered %s page size, "
+				 "pre-allocated %ld pages\n",
+			memfmt(buf, huge_page_size(h)),
+			h->free_huge_pages);
 	}
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
