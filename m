Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id AD4F76B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 14:48:08 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 18 May 2012 12:48:00 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 552C71FF0029
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:46:57 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4IIkgkn159786
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:46:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4IIkbfg004523
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:46:41 -0600
Subject: [RFC][PATCH] hugetlb: fix resv_map leak in error path
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 18 May 2012 11:46:30 -0700
Message-Id: <20120518184630.FF3307BD@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, kosaki.motohiro@jp.fujitsu.com, hughd@google.com, rientjes@google.com, adobriyan@gmail.com, akpm@linux-foundation.org, mel@csn.ul.ie, Dave Hansen <dave@linux.vnet.ibm.com>


When called for anonymous (non-shared) mappings,
hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
code in hugetlbfs's vm_ops->close() to release that allocation.

However, in the mmap() failure path, we do a plain unmap_region()
without the remove_vma() which actually calls vm_ops->close().

This is a decent fix.  This leak could get reintroduced if
new code (say, after hugetlb_reserve_pages() in
hugetlbfs_file_mmap()) decides to return an error.  But, I think
it would have to unroll the reservation anyway.

This hasn't been extensively tested.  Pretty much compile and
boot tested along with Christoph's test case.

Comments?


Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/mm/hugetlb.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff -puN mm/hugetlb.c~hugetlb-fix-leak mm/hugetlb.c
--- linux-2.6.git/mm/hugetlb.c~hugetlb-fix-leak	2012-05-18 11:45:50.355089708 -0700
+++ linux-2.6.git-dave/mm/hugetlb.c	2012-05-18 11:45:50.363089800 -0700
@@ -2157,6 +2157,15 @@ static void hugetlb_vm_op_open(struct vm
 		kref_get(&reservations->refs);
 }
 
+static void resv_map_put(struct vm_area_struct *vma)
+{
+	struct resv_map *reservations = vma_resv_map(vma);
+
+	if (!reservations)
+		return;
+	kref_put(&reservations->refs, resv_map_release);
+}
+
 static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 {
 	struct hstate *h = hstate_vma(vma);
@@ -2173,7 +2182,7 @@ static void hugetlb_vm_op_close(struct v
 		reserve = (end - start) -
 			region_count(&reservations->regions, start, end);
 
-		kref_put(&reservations->refs, resv_map_release);
+		resv_map_put(vma);
 
 		if (reserve) {
 			hugetlb_acct_memory(h, -reserve);
@@ -2990,12 +2999,16 @@ int hugetlb_reserve_pages(struct inode *
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
 	}
 
-	if (chg < 0)
-		return chg;
+	if (chg < 0) {
+		ret = chg;
+		goto out_err;
+	}
 
 	/* There must be enough pages in the subpool for the mapping */
-	if (hugepage_subpool_get_pages(spool, chg))
-		return -ENOSPC;
+	if (hugepage_subpool_get_pages(spool, chg)) {
+		ret = -ENOSPC;
+		goto out_err;
+	}
 
 	/*
 	 * Check enough hugepages are available for the reservation.
@@ -3004,7 +3017,7 @@ int hugetlb_reserve_pages(struct inode *
 	ret = hugetlb_acct_memory(h, chg);
 	if (ret < 0) {
 		hugepage_subpool_put_pages(spool, chg);
-		return ret;
+		goto out_err;
 	}
 
 	/*
@@ -3021,6 +3034,9 @@ int hugetlb_reserve_pages(struct inode *
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
 		region_add(&inode->i_mapping->private_list, from, to);
 	return 0;
+out_err:
+	resv_map_put(vma);
+	return ret;
 }
 
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
