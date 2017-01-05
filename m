Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 285326B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:15:44 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id sr6so692267wjb.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:15:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r20si190265wrc.122.2017.01.05.07.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 07:15:42 -0800 (PST)
Date: Thu, 5 Jan 2017 16:15:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: hugetlb: reservation race leading to under provisioning
Message-ID: <20170105151540.GT21618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org

Hi,
we have a customer report on an older kernel (3.12) but I believe the
same issue is present in the current vanilla kernel. There is a race
between mmap trying to do a reservation which fails when racing with
truncate_hugepages. See the reproduced attached.

It should go like this (analysis come from the customer and I hope I
haven't screwed their write up).

: Task (T1) does mmap and calls into gather_surplus_pages(), looking for N
: pages.  It determines it needs to allocate N pages, drops the lock, and
: does so.
: 
: We will have:
: hstate->resv_huge_pages == N
: hstate->free_huge_pages == N
: 
: That mapping is then munmap()ed by task T2, which truncates the file:
: 
: truncate_hugepages() {
: 	for each page of the inode after lstart {
: 		truncate_huge_page(page) {
: 			hugetlb_unreserve_pages() {
: 				hugetlb_acct_memory() {
: 					return_unused_surplus_pages() {
: 
: return_unused_surplus_pages() drops h->resv_huge_pages to 0, then
: begins calling free_pool_huge_page() N times:
: 
: 	h->resv_huge_pages -= unused_resv_pages
: 	while (nr_pages--) {
: 		free_pool_huge_page(h, &node_states[N_MEMORY], 1) {
: 			h->free_huge_pages--;
: 		}
: 		cond_resched_lock(&hugetlb_lock);
: 	}
: 
: But the cond_resched_lock() triggers, and it releases the lock with
: 
: h->resv_huge_pages == 0
: h->free_huge_pages == M << N
: 
: T1 having completed its allocations with allocated == N now
: acquires the lock, and recomputes
: 
: needed = (h->resv_huge_pages + delta) - (h->free_huge_pages + allocated);
: 
: needed = N - (M + N) = -M
: 
: Then
: 
: needed += N                  = -M+N
: h->resv_huge_pages += N       = N
: 
: It frees N-M pages to the hugetlb pool via enqueue_huge_page(),
: 
: list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
: 	if ((--needed) < 0)
: 		break;
: 		/*
: 		* This page is now managed by the hugetlb allocator and has
: 		* no users -- drop the buddy allocator's reference.
: 		*/
: 		put_page_testzero(page);
: 		VM_BUG_ON(page_count(page));
: 		enqueue_huge_page(h, page) {
: 			h->free_huge_pages++;
: 		}
: 	}
: 
: h->resv_huge_pages == N
: h->free_huge_pages == N-M
: 
: It releases the lock in order to free the remainder of surplus_list
: via put_page().
: 
: When it releases the lock, T1 reclaims it and returns from
: gather_surplus_pages().
: 
: But then hugetlb_acct_memory() checks
: 
: 	if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
: 		return_unused_surplus_pages(h, delta);
: 		goto out;
: 	}
: 
: and returns -ENOMEM.

The cond_resched has been added by 7848a4bf51b3 ("mm/hugetlb.c: add
cond_resched_lock() in return_unused_surplus_pages()") and it smells
fishy AFAICT. It leaves the inconsistent state of the hstate behind.
I guess we want to uncommit the reservation one page at the time, something like:

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3edb759c5c7d..e3a599146d7c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1783,12 +1783,13 @@ static void return_unused_surplus_pages(struct hstate *h,
 {
 	unsigned long nr_pages;
 
-	/* Uncommit the reservation */
-	h->resv_huge_pages -= unused_resv_pages;
 
 	/* Cannot return gigantic pages currently */
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h)) {
+		/* Uncommit the reservation */
+		h->resv_huge_pages -= unused_resv_pages;
 		return;
+	}
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
 
@@ -1803,6 +1804,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	while (nr_pages--) {
 		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
 			break;
+		h->resv_huge_pages--;
 		cond_resched_lock(&hugetlb_lock);
 	}
 }

but I am just not getting the nr_pages = min... part and the way thing
how we can have less surplus_huge_pages than unused_resv_pages....  This
whole code is so confusing that I would even rather go with a simple
revert of 7848a4bf51b3 which would be much easier for the stable backport.

What do you guys think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
