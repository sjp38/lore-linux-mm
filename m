Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 69BDC6B007D
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:26 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a hugepage with use_reserve
Date: Mon, 29 Jul 2013 14:32:08 +0900
Message-Id: <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If parallel fault occur, we can fail to allocate a hugepage,
because many threads dequeue a hugepage to handle a fault of same address.
This makes reserved pool shortage just for a little while and this cause
faulting thread who is ensured to have enough reserved hugepages
to get a SIGBUS signal.

To solve this problem, we already have a nice solution, that is,
a hugetlb_instantiation_mutex. This blocks other threads to dive into
a fault handler. This solve the problem clearly, but it introduce
performance degradation, because it serialize all fault handling.

Now, I try to remove a hugetlb_instantiation_mutex to get rid of
performance degradation. A prerequisite is that other thread should
not get a SIGBUS if they are ensured to have enough reserved pages.

For this purpose, if we fail to allocate a new hugepage with use_reserve,
we return just 0, instead of VM_FAULT_SIGBUS. use_reserve
represent that this user is legimate one who are ensured to have enough
reserved pages. This prevent these thread not to get a SIGBUS signal and
make these thread retrying fault handling.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6a9ec69..909075b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2623,7 +2623,10 @@ retry_avoidcopy:
 			WARN_ON_ONCE(1);
 		}
 
-		ret = VM_FAULT_SIGBUS;
+		if (use_reserve)
+			ret = 0;
+		else
+			ret = VM_FAULT_SIGBUS;
 		goto out_lock;
 	}
 
@@ -2741,7 +2744,10 @@ retry:
 
 		page = alloc_huge_page(vma, address, use_reserve);
 		if (IS_ERR(page)) {
-			ret = VM_FAULT_SIGBUS;
+			if (use_reserve)
+				ret = 0;
+			else
+				ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
