Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 439B86B016C
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:48:58 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p7J7mtau025682
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:55 -0700
Received: from yxj19 (yxj19.prod.google.com [10.190.3.83])
	by hpaq14.eem.corp.google.com with ESMTP id p7J7mrdu002337
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:54 -0700
Received: by yxj19 with SMTP id 19so2375930yxj.5
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:48:53 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/9] mm: rcu read lock when getting from tail to head page
Date: Fri, 19 Aug 2011 00:48:25 -0700
Message-Id: <1313740111-27446-4-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

In the tail page case, put_compound_page() uses get_page_unless_zero()
to get a reference on the head page. There is a small possibility that
the compound page might get split, and the head page freed, before that
reference can be obtained.

Similarly, page_trans_compound_anon_split() needs to get a reference
on a a THP page's head before it can proceed with splitting it.

In order to guarantee page count stability one rcu grace period after
allocation, as described in page_cache_get_speculative() comment in
pagemap.h, we need to take the rcu read lock from the time we locate the
head page until we get a reference on it.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/ksm.c  |    4 ++++
 mm/swap.c |    8 +++++++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9a68b0c..0eec889 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -817,10 +817,12 @@ out:
 static int page_trans_compound_anon_split(struct page *page)
 {
 	int ret = 0;
+	rcu_read_lock();
 	struct page *transhuge_head = page_trans_compound_anon(page);
 	if (transhuge_head) {
 		/* Get the reference on the head to split it. */
 		if (get_page_unless_zero(transhuge_head)) {
+			rcu_read_unlock();
 			/*
 			 * Recheck we got the reference while the head
 			 * was still anonymous.
@@ -834,10 +836,12 @@ static int page_trans_compound_anon_split(struct page *page)
 				 */
 				ret = 1;
 			put_page(transhuge_head);
+			return ret;
 		} else
 			/* Retry later if split_huge_page run from under us. */
 			ret = 1;
 	}
+	rcu_read_unlock();
 	return ret;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..ac617dc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -78,7 +78,10 @@ static void put_compound_page(struct page *page)
 {
 	if (unlikely(PageTail(page))) {
 		/* __split_huge_page_refcount can run under us */
-		struct page *page_head = page->first_page;
+		struct page *page_head;
+
+		rcu_read_lock();
+		page_head = page->first_page;
 		smp_rmb();
 		/*
 		 * If PageTail is still set after smp_rmb() we can be sure
@@ -87,6 +90,8 @@ static void put_compound_page(struct page *page)
 		 */
 		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
 			unsigned long flags;
+
+			rcu_read_unlock();
 			/*
 			 * Verify that our page_head wasn't converted
 			 * to a a regular page before we got a
@@ -140,6 +145,7 @@ static void put_compound_page(struct page *page)
 			}
 		} else {
 			/* page_head is a dangling pointer */
+			rcu_read_unlock();
 			VM_BUG_ON(PageTail(page));
 			goto out_put_single;
 		}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
