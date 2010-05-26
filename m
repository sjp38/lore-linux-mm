Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4F66B01B6
	for <linux-mm@kvack.org>; Wed, 26 May 2010 17:57:43 -0400 (EDT)
Received: from cflmr01.us.cray.com (cflmr01.us.cray.com [172.30.74.53])
	by mail1.cray.com (8.13.6/8.13.3/gw-5323) with ESMTP id o4QLvfiO001776
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 26 May 2010 16:57:41 -0500 (CDT)
Received: from cfexcas01.americas.cray.com (cfexcas01-2.us.cray.com [172.30.74.227])
	by cflmr01.us.cray.com (8.14.3/8.13.8/hubv2-LastChangedRevision: 12029) with ESMTP id o4QLveK4004405
	for <linux-mm@kvack.org>; Wed, 26 May 2010 16:57:40 -0500
Message-ID: <4BFD9953.8080408@cray.com>
Date: Wed, 26 May 2010 14:57:39 -0700
From: Doug Doan <dougd@cray.com>
MIME-Version: 1.0
Subject: Bug in hugetlb_cow()?
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm working on a driver that relies on mmu notifications, and found that it is 
lacking for huge pages.

 From handle_mm_fault(),

If we take the normal page path, this is what happens:

handle_pte_fault -> do_wp_page -> ptep_clear_flush_notify -> 
mmu_notifier_invalidate_page

If we're dealing with huge pages, this is what happens:

hugetlb_fault -> hugetlb_cow -> (no mmu notifiers)

Below is my patch, can anyone comment?

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4c9e6bb..96d9937 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2345,11 +2345,17 @@ retry_avoidcopy:
         ptep = huge_pte_offset(mm, address & huge_page_mask(h));
         if (likely(pte_same(huge_ptep_get(ptep), pte))) {
                 /* Break COW */
+               mmu_notifier_invalidate_range_start(mm,
+                       address & huge_page_mask(h),
+                       (address & huge_page_mask(h)) + huge_page_size(h));
                 huge_ptep_clear_flush(vma, address, ptep);
                 set_huge_pte_at(mm, address, ptep,
                                 make_huge_pte(vma, new_page, 1));
                 /* Make the old page be freed below */
                 new_page = old_page;
+               mmu_notifier_invalidate_range_end(mm,
+                       address & huge_page_mask(h),
+                       (address & huge_page_mask(h)) + huge_page_size(h));
         }
         page_cache_release(new_page);
         page_cache_release(old_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
