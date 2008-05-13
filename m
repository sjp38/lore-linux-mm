Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4DHJYD9017082
	for <linux-mm@kvack.org>; Tue, 13 May 2008 13:19:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DHJYSf147184
	for <linux-mm@kvack.org>; Tue, 13 May 2008 13:19:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DHJX7m020040
	for <linux-mm@kvack.org>; Tue, 13 May 2008 13:19:34 -0400
Message-ID: <4829CDA8.9070106@us.ibm.com>
Date: Tue, 13 May 2008 12:19:36 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 1/6 v2] allow arch specific function for allocating gigantic
 pages
References: <4829CAC3.30900@us.ibm.com>
In-Reply-To: <4829CAC3.30900@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Paul Mackerras <paulus@samba.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Allow alloc_bm_huge_page() to be overridden by architectures that can't
always use bootmem. This requires huge_boot_pages to be available for
use by this function. The 16G pages on ppc64 have to be reserved prior
to boot-time. The location of these pages are indicated in the device
tree.


A BUG_ON in huge_add_hstate is commented out in order to allow 64K huge
pages to continue to work on power.



Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 include/linux/hugetlb.h |   10 ++++++++++
 mm/hugetlb.c            |   15 ++++++---------
 2 files changed, 16 insertions(+), 9 deletions(-)


diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8c47ca7..b550ec7 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -35,6 +35,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
+extern struct list_head huge_boot_pages;
 
 /* arch callbacks */
 
@@ -205,6 +206,14 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 };
 
+struct huge_bm_page {
+	struct list_head list;
+	struct hstate *hstate;
+};
+
+/* arch callback */
+int alloc_bm_huge_page(struct hstate *h);
+
 void __init huge_add_hstate(unsigned order);
 struct hstate *size_to_hstate(unsigned long size);
 
@@ -256,6 +265,7 @@ extern unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
 
 #else
 struct hstate {};
+#define alloc_bm_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_vma(v) NULL
 #define hstate_inode(i) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5273f6c..efb5805 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -27,6 +27,7 @@ unsigned long max_huge_pages[HUGE_MAX_HSTATE];
 unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
+struct list_head huge_boot_pages;
 
 static int max_hstate = 0;
 
@@ -533,14 +534,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	return page;
 }
 
-static __initdata LIST_HEAD(huge_boot_pages);
-
-struct huge_bm_page {
-	struct list_head list;
-	struct hstate *hstate;
-};
-
-static int __init alloc_bm_huge_page(struct hstate *h)
+/* Can be overriden by architectures */
+__attribute__((weak)) int alloc_bm_huge_page(struct hstate *h)
 {
 	struct huge_bm_page *m;
 	int nr_nodes = nodes_weight(node_online_map);
@@ -583,6 +578,8 @@ static void __init hugetlb_init_hstate(struct hstate *h)
 	unsigned long i;
 
 	/* Don't reinitialize lists if they have been already init'ed */
+	if (!huge_boot_pages.next)
+		INIT_LIST_HEAD(&huge_boot_pages);
 	if (!h->hugepage_freelists[0].next) {
 		for (i = 0; i < MAX_NUMNODES; ++i)
 			INIT_LIST_HEAD(&h->hugepage_freelists[i]);
@@ -664,7 +661,7 @@ void __init huge_add_hstate(unsigned order)
 		return;
 	}
 	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
-	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
+/*	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);*/
 	h = &hstates[max_hstate++];
 	h->order = order;
 	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
