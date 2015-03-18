Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 161426B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:43:59 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so54385547pac.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 14:43:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mj1si38513102pdb.40.2015.03.18.14.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 14:43:58 -0700 (PDT)
Date: Wed, 18 Mar 2015 14:43:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 2/4] hugetlbfs: add minimum size accounting to
 subpools
Message-Id: <20150318144357.0e7e25cdca5066c39032bae6@linux-foundation.org>
In-Reply-To: <464e43df640c54408ed78d1397ad8148784e4ecc.1426549011.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
	<464e43df640c54408ed78d1397ad8148784e4ecc.1426549011.git.mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 16 Mar 2015 16:53:27 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> The same routines that perform subpool maximum size accounting
> hugepage_subpool_get/put_pages() are modified to also perform
> minimum size accounting.  When a delta value is passed to these
> routines, calculate how global reservations must be adjusted
> to maintain the subpool minimum size.  The routines now return
> this global reserve count adjustment.  This global adjusted
> reserve count is then passed to the global accounting routine
> hugetlb_acct_memory().
> 

The comment layout is a bit chaotic.  Also, sentences start with
capital letters and end with little round things!  It's a bit
anal but heck, the kernel isn't written in linglish.


--- a/mm/hugetlb.c~hugetlbfs-add-minimum-size-accounting-to-subpools-fix
+++ a/mm/hugetlb.c
@@ -125,8 +125,10 @@ static long hugepage_subpool_get_pages(s
 
 	if (spool->min_hpages) {		/* minimum size accounting */
 		if (delta > spool->rsv_hpages) {
-			/* asking for more reserves than those already taken
-			 * on behalf of subpool. return difference */
+			/*
+			 * Asking for more reserves than those already taken on
+			 * behalf of subpool.  Return difference.
+			 */
 			ret = delta - spool->rsv_hpages;
 			spool->rsv_hpages = 0;
 		} else {
@@ -141,7 +143,7 @@ unlock_ret:
 }
 
 /*
- * subpool accounting for freeing and unreserving pages
+ * Subpool accounting for freeing and unreserving pages.
  * Return the number of global page reservations that must be dropped.
  * The return value may only be different than the passed value (delta)
  * in the case where a subpool minimum size must be maintained.
@@ -170,8 +172,10 @@ static long hugepage_subpool_put_pages(s
 			spool->rsv_hpages = spool->min_hpages;
 	}
 
-	/* If hugetlbfs_put_super couldn't free spool due to
-	* an outstanding quota reference, free it now. */
+	/*
+	 * If hugetlbfs_put_super couldn't free spool due to an outstanding
+	 * quota reference, free it now.
+	 */
 	unlock_or_release_subpool(spool);
 
 	return ret;
@@ -923,9 +927,9 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under
-	 * it's minimum size if the reservation is not restored after
-	 * page is free.  Therefore, force restore_reserve operation.
+	 * A return code of zero implies that the subpool will be under its
+	 * minimum size if the reservation is not restored after page is free.
+	 * Therefore, force restore_reserve operation.
 	 */
 	if (hugepage_subpool_put_pages(spool, 1) == 0)
 		restore_reserve = true;
@@ -2523,8 +2527,8 @@ static void hugetlb_vm_op_close(struct v
 
 	if (reserve) {
 		/*
-		 * decrement reserve counts.  The global reserve count
-		 * may be adjusted if the subpool has a minimum size.
+		 * Decrement reserve counts.  The global reserve count may be
+		 * adjusted if the subpool has a minimum size.
 		 */
 		gbl_reserve = hugepage_subpool_put_pages(spool, reserve);
 		hugetlb_acct_memory(h, -gbl_reserve);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
