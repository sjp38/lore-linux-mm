Message-Id: <20080423015431.134811000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:16 +1000
From: npiggin@suse.de
Subject: [patch 14/18] hugetlb: printk cleanup
Content-Disposition: inline; filename=hugetlb-printk-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

- Reword sentence to clarify meaning with multiple options
- Add support for using GB prefixes for the page size
- Add extra printk to delayed > MAX_ORDER allocation code

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -612,15 +612,28 @@ static void __init hugetlb_init_hstates(
 	}
 }
 
+static __init char *memfmt(char *buf, unsigned long n)
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
-		printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
-				h->free_huge_pages,
-				1 << (h->order + PAGE_SHIFT - 20));
-	}
+		char buf[32];
+		printk(KERN_INFO "HugeTLB registered %s page size, "
+				 "pre-allocated %ld pages\n",
+			memfmt(buf, huge_page_size(h)),
+			h->free_huge_pages);
+        }
 }
 
 static int __init hugetlb_init(void)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
