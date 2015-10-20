Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0F38C82F66
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 19:56:28 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so35384153pab.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:56:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id zd10si8780670pac.43.2015.10.20.16.56.27
        for <linux-mm@kvack.org>;
        Tue, 20 Oct 2015 16:56:27 -0700 (PDT)
Subject: [PATCH] mm, hugetlbfs: optimize when NUMA=n
From: Dave Hansen <dave@sr71.net>
Date: Tue, 20 Oct 2015 16:56:12 -0700
Message-Id: <20151020235611.A30DC32F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

My recent patch "mm, hugetlb: use memory policy when available" added some
bloat to hugetlb.o.  This patch aims to get some of the bloat back,
especially when NUMA is not in play.

It does this with an implicit #ifdef and marking some things static that
should have been static in my first patch.  It also makes the warnings
only VM_WARN_ON()s.  They were responsible for a pretty big chunk of the
bloat.

Doing this gets our NUMA=n text size back to a wee bit _below_ where we
started before the original patch.

It also shaves a bit of space off the NUMA=y case, but not much.  Enforcing
the mempolicy definitely takes some text and it's hard to avoid.

size(1) output:

   text	   data	    bss	    dec	    hex	filename
  30745	   3433	   2492	  36670	   8f3e	hugetlb.o.nonuma.baseline
  31305	   3755	   2492	  37552	   92b0	hugetlb.o.nonuma.patch1
  30713	   3433	   2492	  36638	   8f1e	hugetlb.o.nonuma.patch2 (this patch)
  25235	    473	  41276	  66984	  105a8	hugetlb.o.numa.baseline
  25715	    475	  41276	  67466	  1078a	hugetlb.o.numa.patch1
  25491	    473	  41276	  67240	  106a8	hugetlb.o.numa.patch2 (this patch)

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/mm/hugetlb.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff -puN mm/hugetlb.c~hugetlbfs-decrapify-with-no-numa mm/hugetlb.c
--- a/mm/hugetlb.c~hugetlbfs-decrapify-with-no-numa	2015-10-20 16:47:24.501877643 -0700
+++ b/mm/hugetlb.c	2015-10-20 16:52:33.060946354 -0700
@@ -1455,9 +1455,14 @@ static struct page *__hugetlb_alloc_budd
 
 	/*
 	 * We need a VMA to get a memory policy.  If we do not
-	 * have one, we use the 'nid' argument
+	 * have one, we use the 'nid' argument.
+	 *
+	 * The mempolicy stuff below has some non-inlined bits
+	 * and calls ->vm_ops.  That makes it hard to optimize at
+	 * compile-time, even when NUMA is off and it does
+	 * nothing.  This helps the compiler optimize it out.
 	 */
-	if (!vma) {
+	if (!IS_ENABLED(CONFIG_NUMA) || !vma) {
 		/*
 		 * If a specific node is requested, make sure to
 		 * get memory from there, but only when a node
@@ -1474,7 +1479,8 @@ static struct page *__hugetlb_alloc_budd
 
 	/*
 	 * OK, so we have a VMA.  Fetch the mempolicy and try to
-	 * allocate a huge page with it.
+	 * allocate a huge page with it.  We will only reach this
+	 * when CONFIG_NUMA=y.
 	 */
 	do {
 		struct page *page;
@@ -1515,8 +1521,8 @@ static struct page *__alloc_buddy_huge_p
 		return NULL;
 
 	if (vma || addr) {
-		WARN_ON_ONCE(!addr || addr == -1);
-		WARN_ON_ONCE(nid != NUMA_NO_NODE);
+		VM_WARN_ON_ONCE(!addr || addr == -1);
+		VM_WARN_ON_ONCE(nid != NUMA_NO_NODE);
 	}
 	/*
 	 * Assume we will successfully allocate the surplus page to
@@ -1580,6 +1586,7 @@ static struct page *__alloc_buddy_huge_p
  * NUMA_NO_NODE, which means that it may be allocated
  * anywhere.
  */
+static
 struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
 {
 	unsigned long addr = -1;
@@ -1590,6 +1597,7 @@ struct page *__alloc_buddy_huge_page_no_
 /*
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
+static
 struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
