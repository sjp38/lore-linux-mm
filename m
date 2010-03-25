Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 248A16B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 09:26:49 -0400 (EDT)
Date: Thu, 25 Mar 2010 08:26:44 -0500
From: Dean Roe <roe@cray.com>
Subject: MMU notifiers and hugepage copy-on-write
Message-ID: <20100325132644.GB20613@cray.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Are MMU notifiers not handling copy-on-write of hugetlb pages?
Looking at the source code, I don't see where this happens.
Non-hugetlb pages are handled via:
    do_wp_page() -> set_pte_at_notify() -> mmu_notifier_change_pte()


...but I don't see any MMU notifier callouts down the hugetlb_cow() path,
unless it fails to allocate a new_page():

        new_page = alloc_huge_page(vma, address, outside_reserve);

        if (IS_ERR(new_page)) {
                page_cache_release(old_page);

                /*
                 * If a process owning a MAP_PRIVATE mapping fails to COW,
                 * it is due to references held by a child and an insufficient
                 * huge page pool. To guarantee the original mappers
                 * reliability, unmap the page from child processes. The child
                 * may get SIGKILLed if it later faults.
                 */
                if (outside_reserve) {
                        BUG_ON(huge_pte_none(pte));
   >>>                  if (unmap_ref_private(mm, vma, old_page, address)) {


..where unmap_ref_private() calls __unmap_hugepage_range() which then
calls the MMU notifier invalidate_range functions.

Am I missing something?

Thanks,
Dean

-- 
Dean Roe
Cray Inc.
roe@cray.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
