Message-Id: <20080525143453.486886000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:30 +1000
From: npiggin@suse.de
Subject: [patch 13/23] hugetlb: printk cleanup
Content-Disposition: inline; filename=hugetlb-printk-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
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
@@ -639,15 +639,28 @@ static void __init hugetlb_init_hstates(
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
